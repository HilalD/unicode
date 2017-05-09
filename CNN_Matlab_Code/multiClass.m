function [SR, softSR] = runSomePermutationsFromRAM(epochsNum,initialLearnRate,learnRateDropFactor,miniBatchSize,learnRateDropPeriod,checkpointPath,loadedData)


printLog2CMD        = true;
if ~exist('epochsNum', 'var')
    epochsNum           = 15; %15
    initialLearnRate    = 0.1;  % 0.1
    learnRateDropFactor = 0.4;  % 0.4
    miniBatchSize       = 128;   % 128
    learnRateDropPeriod = 4;    %4
    checkpointPath = '/home/hdiab/checkpoint';
end
diary(strcat(checkpointPath,'/myTextLog.txt'));

opts        = trainingOptions('sgdm', 'InitialLearnRate', initialLearnRate, 'MiniBatchSize', miniBatchSize, 'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', learnRateDropFactor, 'LearnRateDropPeriod', learnRateDropPeriod, 'MaxEpochs', epochsNum, 'Shuffle', 'once', 'Verbose', printLog2CMD,'CheckpointPath',checkpointPath);

% percentage of training set out of the whole datset. the rest go to the test set
% only relevant if NOT using leave-one-out
trainingSetPercentage = 0.85;
if(exist('loadedData', 'var'))
        fnames = loadedData.fnames;
        allLabels = loadedData.allLabels;
        st = loadedData.st;
        sl = loadedData.sl;
        dataAll = loadedData.dataAll;
        labelsAll = loadedData.labelsAll;
        labelsParticipant = loadedData.labelsParticipant;
        uniqueParticipantLabels = loadedData.uniqueParticipantLabels;
        participantsNum = loadedData.participantsNum;
        rootFolder = loadedData.rootFolder;
end
if ~exist('rootFolder', 'var')
    dataLoadScript
end
% clear the gpu memory and run training and testing
g = gpuDevice(1);reset(g);

%% run on all possible binary classification permutations
%for i=1:length(fnames)-1
%    for j=i+1:length(fnames)

if ~exist('i', 'var')
    i = 2; 
end
if ~exist('j', 'var')
    j = 3;
end

% if ~exist('x', 'var')
%     x = 6;
% end

class_nums = [2,3];
numOfClassifications = size(class_nums,2);
assert (numOfClassifications>1);

% print the permutations for debugging
dispStr ='';
currentLabels = [];
tempInds =zeros(size(labelsAll));
names_for_disp = {};
for classInd=1:numOfClassifications
    
    classNum = class_nums(classInd);
    dispStr = strcat(dispStr, fnames{classNum},'<-->');
    % select the approporiate groups
    currentLabels = [currentLabels, allLabels(classNum)];
    
    % indexes of the windows that are needed for the classification
    tempInds = tempInds | (labelsAll == allLabels(classNum));
    
    names_for_disp(classInd) = {fnames{classNum}};
end

disp(dispStr);

% create the sub dataset
tempDataAll             = dataAll(:, :, :, tempInds);
tempLabelsAll           = labelsAll(tempInds);
tempLabelsParticipant   = labelsParticipant(tempInds);
% compute the number of participants to check now
participantUniqueID     = unique(tempLabelsParticipant);
participantsNum         = length(participantUniqueID);

% run the permutations divide into train and test sets)
res                     = zeros(numOfClassifications,numOfClassifications,participantsNum);
res_p                   = zeros(numOfClassifications,numOfClassifications,participantsNum);
res_mvote               = zeros(numOfClassifications,numOfClassifications,participantsNum);
res_soft_vote           = zeros(numOfClassifications,numOfClassifications,participantsNum); % added by hilal
info                    = cell(1, participantsNum); 
notTested               = [];
plotsNum                = ceil(participantsNum/numOfClassifications);
tic
close all; figure(1);  
% run leave one out
for k = 1:participantsNum
    fprintf('(%d/%d);', k, participantsNum); % write to cmd how many left
    % clear the gpu memory and run training and testing
    % g = gpuDevice(1);reset(g);
    
    % divide into train and test
    ind                     = (tempLabelsParticipant == participantUniqueID(k));
    trainData               = tempDataAll(:, :, :, ~ind);
    trainDegreeLabels       = tempLabelsAll(~ind);
    trainDegreeLabels       = categorical(trainDegreeLabels, unique(trainDegreeLabels));
    trainParticipantLabels  = tempLabelsParticipant(~ind);
    trainDataSz             = length(trainParticipantLabels);
    
    testData                = tempDataAll(:, :, :, ind);
    testDegreeLabels        = tempLabelsAll(ind);
    testDegreeLabels        = categorical(testDegreeLabels, unique(testDegreeLabels));
    testParticipantLabels   = tempLabelsParticipant(ind);
    
    % perform data balancing
    [trainData, trainDegreeLabels, trainParticipantLabels] = balanceData(trainData, trainDegreeLabels, trainParticipantLabels, allLabels, class_nums);
    
    % Shuffle the train data
    shuffledInds = randperm(length(trainParticipantLabels));
    
    % Train and test CNN
    try
        [res(:,:,k), res_p(:,:,k), res_mvote(:,:,k),res_soft_vote(:,:,k), info{k}] = runCNN(trainData(:,:,:,shuffledInds), trainDegreeLabels(shuffledInds), trainParticipantLabels(shuffledInds), testData, testDegreeLabels, testParticipantLabels, opts, trainingSetPercentage, currentLabels, numOfClassifications);
        % figure(1); plot(info{k}.TrainingAccuracy); title([fnames{i} '<-->' fnames{j} ';(' num2str(k) ')']);
        % scrollsubplot(plotsNum,2); title([fnames{i} '<-->' fnames{j} ';(' num2str(k) ')']);
    catch
        notTested = [notTested, k];
    end
    % disp('intermediate results sum: '); print_table(sum(res_mvote, 3), {'%.3g'}, {fnames{i}, fnames{j}}, {' ', fnames{i}, fnames{j}});
    stopHere = 1;
end
toc 
fprintf('Results using majority vote \n')
SR =printResults(res_mvote,names_for_disp);

for k = 1:participantsNum
    p_c_mat = res_soft_vote(:,:,k);
    p_vote_tmp   = round(p_c_mat./repmat(sum(p_c_mat, 2), 1, size(p_c_mat,2)));
    res_soft_vote(:,:,k) = p_vote_tmp;
end 
fprintf('\n \nResults using soft vote \n')
softSR = printResults(res_soft_vote,names_for_disp);

if ~isempty(notTested)
    fprintf('Following participants not tested due to array problem...\n'); 
    disp(notTested); 
end
% fprintf('\n');
stopHere  = 1;
%    end
diary('off');
end
