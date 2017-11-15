function [SR] = runSomePermutationsFromRAM(epochsNum,initialLearnRate,learnRateDropFactor,miniBatchSize,learnRateDropPeriod,checkpointPath,loadedData,classNums,useTIMIT)
%%%
% loadedData: used so we dont load the data more than once (takes a few
% mins)
% checkpointPath: str path to save logs or checkpoints to
% classNums: array with the numbers of the classes that we are using to
% train/classify
% useTIMIT: boolean, true if we want to use the weights/features that
% we learned from training the network on the TIMIT dataset (transfer learning)
%%%

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

opts        = trainingOptions('sgdm', 'InitialLearnRate', initialLearnRate, 'MiniBatchSize', miniBatchSize, 'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', learnRateDropFactor, 'LearnRateDropPeriod', learnRateDropPeriod, 'MaxEpochs', epochsNum, 'Shuffle', 'once', 'Verbose', printLog2CMD);%,'CheckpointPath',checkpointPath);

% percentage of training set out of the whole datset. the rest go to the test set
% only relevant if NOT using leave-one-out
if(exist('loadedData', 'var'))  % instead of reloading data everytime
        fnames = loadedData.fnames;
        allLabels = loadedData.allLabels;
        %st = loadedData.st;
        %sl = loadedData.sl;
        dataAll = loadedData.dataAll;
        labelsAll = loadedData.labelsAll;
        labelsParticipant = loadedData.labelsParticipant;
        %uniqueParticipantLabels = loadedData.uniqueParticipantLabels;
        %participantsNum = loadedData.participantsNum;
        rootFolder = loadedData.rootFolder;
end
if ~exist('rootFolder', 'var')
    dataLoadScript
end
% clear the gpu memory and run training and testing
g = gpuDevice(1);reset(g);

%class_nums = [1,2,3,4,5,6];
class_nums = classNums;
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
info                    = cell(1, participantsNum); 
notTested               = [];
tic
% run leave one out
wrongPredictionsNum = 0;
for k = 1:participantsNum
    fprintf('(%d/%d);', k, participantsNum); % write to cmd how many left

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
        [res(:,:,k), res_p(:,:,k), res_mvote(:,:,k), info{k}] = runCNN(trainData(:,:,:,shuffledInds), trainDegreeLabels(shuffledInds), trainParticipantLabels(shuffledInds), testData, testDegreeLabels, testParticipantLabels, opts, currentLabels, numOfClassifications,useTIMIT);
        res_majority_vote_all = res_mvote(:,:,k);
        if isempty(find(res_majority_vote_all(linspace(1,numel(res_majority_vote_all),length(res_majority_vote_all))), 1))
            wrongPredictionsNum = wrongPredictionsNum+1;
        end
        fprintf('\n(%d%% wrong thus far);', floor(100*wrongPredictionsNum/participantsNum));
    end
toc 
fprintf('Results using majority vote \n')
SR =printResults(res_mvote,names_for_disp);

diary('off');
end
