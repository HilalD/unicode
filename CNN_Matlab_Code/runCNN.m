function [res_windows_count_all, res_windows_percents, res_majority_vote_all, info] = runCNN(trainData, trainDegreeLabels, trainParticipantLabels, testData, testDegreeLabels, testParticipantLabels, opts, currentLabels, numOfClasses,useTIMIT)
    %%%
    % numOfClasses: the number of possible classes to classify to
    % useTIMIT: boolean, true if we want to use the weights/features that
    % we learned from training the network on the TIMIT dataset (transfer learning)
    %%%
    res_windows_count_all = []; res_windows_percents = []; res_majority_vote_all = [];

    if ~exist('numOfClasses', 'var')
        numOfClasses = 2;
    end

    assert (numOfClasses>1);
    load('timitTrainedNet.mat')
    
    %% Build the Convolutinal Neural Network Structure
    if(useTIMIT)
        convnet = CreateCNN(numOfClasses,trainedNet);
    else
        convnet = CreateCNN(numOfClasses);
    end
    convnet = CreateCNN(numOfClasses,trainedNet);
    class(convnet); 

    %% Train CNN
    [trainedNet, info]              = trainNetwork(trainData, trainDegreeLabels, convnet, opts);

    res_majority_vote_all           = zeros(numOfClasses,numOfClasses);
    res_windows_count_all           = zeros(numOfClasses,numOfClasses);
    %% Classifiy using the trained CNN
    [YTest,YScores]                           = classify(trainedNet,testData);
    %% Compute overall classification results
    [res_windows_count_all, order]  = confusionmat(testDegreeLabels, YTest, 'order', currentLabels);

    participantCodes = unique(testParticipantLabels); 

    res_majority_vote_all = zeros(numOfClasses,numOfClasses); 
    % vote per participant
    for i=1:length(participantCodes)
       p_inds       = find(testParticipantLabels == participantCodes(i)); 
       p_expected   = testDegreeLabels(p_inds); 
       p_actual     = YTest(p_inds); 
       [p_c_mat]    = confusionmat(p_expected, p_actual, 'order', currentLabels);


       p_c_mat2 = p_c_mat;
       p_c_mat2(p_c_mat2~=max(max(p_c_mat)))=0;
       p_c_mat2(p_c_mat2~=0) =1;
       res_majority_vote_all = res_majority_vote_all + p_c_mat2; 
       p_c_mat
    end

    % in case of leave one participant out, this one doesnt matter (same as res_majority_vote)
    res_majority_vote_all(isnan(res_majority_vote_all)) = 0;
    if(isempty(find(res_majority_vote_all,1)))
        disp('no prediction at all')
    end
    if ~isempty(find(res_majority_vote_all(linspace(1,numel(res_majority_vote_all),length(res_majority_vote_all))), 1))
        disp('pridection was successful')
    else
        disp('pridection ERROR')
    end
    % results in percents
    res_windows_percents            = res_windows_count_all./repmat(sum(res_windows_count_all, 2), 1, size(res_windows_count_all,2));
    res_windows_percents(isnan(res_windows_percents)) = 0; 