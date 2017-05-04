% function [] = runSomePermutationsFromRAM(epochsNum,initialLearnRate,learnRateDropFactor,miniBatchSize,learnRateDropPeriod,checkpointPath)

epochsNum           = 15;
printLog2CMD        = false; 
initialLearnRate    = 0.1; 
learnRateDropFactor = 0.4; 
miniBatchSize       = 128; 
learnRateDropPeriod = 4; 
opts        = trainingOptions('sgdm', 'InitialLearnRate', initialLearnRate, 'MiniBatchSize', miniBatchSize, 'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', learnRateDropFactor, 'LearnRateDropPeriod', learnRateDropPeriod, 'MaxEpochs', epochsNum, 'Shuffle', 'once', 'Verbose', printLog2CMD);%,'CheckpointPath','C:\Users\user\Documents\MATLAB\PDM-master\checkpoint');

% percentage of training set out of the whole datset. the rest go to the test set
% only relevant if NOT using leave-one-out
trainingSetPercentage = 0.85;

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

if ~exist('x', 'var')
    x = 6;
end

% print the permutations for debugging
disp([fnames{i} '<-->' fnames{j} '<-->' fnames{x}]);
% select the approporiate groups
currentLabels           = [allLabels(i), allLabels(j), allLabels(x)];
% indexes of the windows that are needed for the classification
tempInds                = ((labelsAll == allLabels(i)) | (labelsAll == allLabels(j)) | (labelsAll == allLabels(x)));
% create the sub dataset
tempDataAll             = dataAll(:, :, :, tempInds);
tempLabelsAll           = labelsAll(tempInds);
tempLabelsParticipant   = labelsParticipant(tempInds);
% compute the number of participants to check now
participantUniqueID     = unique(tempLabelsParticipant);
participantsNum         = length(participantUniqueID);

% run the permutations divide into train and test sets)
res                     = zeros(3,3,participantsNum);
res_p                   = zeros(3,3,participantsNum);
res_mvote               = zeros(3,3,participantsNum);
res_soft_vote           = zeros(3,3,participantsNum); % added by hilal
info                    = cell(1, participantsNum); 
notTested               = [];
plotsNum                = ceil(participantsNum/3);
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
    [trainData, trainDegreeLabels, trainParticipantLabels] = balanceData(trainData, trainDegreeLabels, trainParticipantLabels, allLabels, [i, j, x]);
    
    % Shuffle the train data
    shuffledInds = randperm(length(trainParticipantLabels));
    
    % Train and test CNN
    try
        [res(:,:,k), res_p(:,:,k), res_mvote(:,:,k),res_soft_vote(:,:,k), info{k}] = runCNN(trainData(:,:,:,shuffledInds), trainDegreeLabels(shuffledInds), trainParticipantLabels(shuffledInds), testData, testDegreeLabels, testParticipantLabels, opts, trainingSetPercentage, currentLabels);
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
SR =printResluts(res_mvote,{fnames{i},fnames{j},fnames{x}});

fprintf('\n \nResults using soft vote \n')
printResluts(res_soft_vote,{fnames{i},fnames{j},fnames{x}})

if ~isempty(notTested)
    fprintf('Following participants not tested due to array problem...\n'); 
    disp(notTested); 
end
% fprintf('\n');
stopHere  = 1;
%    end
%end
