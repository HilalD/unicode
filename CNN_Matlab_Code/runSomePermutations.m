function [] = runSomePermutations()

epochsNum   = 15; % originally 100
opts        = trainingOptions('sgdm', 'InitialLearnRate', 0.1, 'MiniBatchSize', 128, 'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', 0.5, 'MaxEpochs', epochsNum);%,'CheckpointPath','C:\Users\user\Documents\MATLAB\PDM-master\checkpoint');

% percentage of training set out of the whole datset. the rest go to the test set
% only relevant if NOT using leave-one-out
trainingSetPercentage = 0.85; 

rootFolder = fullfile('/home/hdiab/PDM-Master','windowed20ms'); % set sample folder

%% Categories
st.S0   = [7 10 13 14 17 42 50 56 59];
st.S1   = [19 32 37 66];
st.S1_5 = [21 22 44 71];
st.S2   = [2 8 26 29 31 33 39 45 46 47 48 58 60 63 69 70 74];
st.S2_5 = [4 6 16 18 24 27 34 51 62];
st.S3   = [1 5 20 25 38 54 73];
st.S4   = [35];
% labels
sl.S0   = ones(1, length(st.S0))*0;
sl.S1   = ones(1, length(st.S1))*10;
sl.S1_5 = ones(1, length(st.S1_5))*15;
sl.S2   = ones(1, length(st.S2))*20;
sl.S2_5 = ones(1, length(st.S2_5))*25;
sl.S3   = ones(1, length(st.S3))*30;
sl.S4   = ones(1, length(st.S4))*40;

[dataAll, labelsAll, labelsParticipant, uniqueParticipantLabels] = loadAllData(st, sl, rootFolder);
participantsNum = length(uniqueParticipantLabels); 

allLabels = categorical({'0', '1', '1_5', '2', '2_5', '3', '4'});

% S = [st.S0 st.S1]; % change this to set categories: S0 S1 S1_5 S2 S2_5 S3 S4
fnames = fieldnames(st);

%% run on all possible binary classification permutations
useInArrayStructure = 1; 
for i=1:length(fnames)-1
    for j=i+1:length(fnames)
        i = 4; j = 5; 
        
        % print the permutations for debugging
        disp([fnames{i} '<-->' fnames{j}]);
        % select the approporiate groups
                
        % run the permutations divide into train and test sets)
        res             = zeros(2,2,participantsNum);
        res_p           = zeros(2,2,participantsNum);
        res_mvote       = zeros(2,2,participantsNum);
        
        % perform leave one participant out
        for k = 1:participantsNum
            fprintf('(%d/%d)\n', k, participantsNum); % write to cmd how many left
            
            % clear the gpu memory and run training and testing
            g = gpuDevice(1);reset(g);
            
            % tic; 
            
            ind                     = (labelsParticipant == uniqueParticipantLabels(k)); 
            trainData               = dataAll(:, :, :, ~ind); 
            trainDegreeLabels       = labelsAll(~ind); 
            trainParticipantLabels  = labelsParticipant(~ind); 
            
            testData                = dataAll(:, :, :, ind);  
            testDegreeLabels        = labelsAll(ind); 
            testParticipantLabels   = labelsParticipant(ind); 
            
            [res(:,:,k), res_p(:,:,k), res_mvote(:,:,k)] = runCNN(trainData, trainDegreeLabels, trainParticipantLabels, testData, testDegreeLabels, testParticipantLabels, opts, trainingSetPercentage, rootFolder);
            % [res(:,:,k), res_p(:,:,k), res_mvote(:,:,k)]     = PDDiagConvNet(S_lv1O, Sc, opts, trainingSetPercentage, rootFolder, currentLabels, useInArrayStructure); 
            % toc;
            disp('intermediate results sum: ');
            print_table(sum(res_mvote, 3)); 
            stopHere = 1;
        end
        % fprintf('\n');
        stopHere  = 1;
    end
end
% TODO: run the classification on the permutaitons

% MAKE SURE TO CHANGE THE OUTPUT SIZE FOR THE CNN

% end - Parameters

