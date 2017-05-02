function [res_windows_count_all, res_windows_percents, res_majority_vote_all, info] = plotsAndSuccessRate(testData, testDegreeLabels, testParticipantLabels, currentLabels, trainedNet)
res_windows_count_all = []; res_windows_percents = []; res_majority_vote_all = [];

% diary logResults.txt

%% Build the Convolutinal Neural Network Structure
convnet = CreateCNN();
class(convnet); 

%% Train CNN
% [trainedNet, info]              = trainNetwork(trainData, trainDegreeLabels, convnet, opts);

res_majority_vote_all           = zeros(2,2);
res_windows_count_all           = zeros(2,2);
%% Classifiy using the trained CNN
YTest                           = classify(trainedNet,testData);
%% Compute overall classification results
[res_windows_count_all, order]  = confusionmat(testDegreeLabels, YTest, 'order', currentLabels);

participantCodes = unique(testParticipantLabels); 

if participantCodes == 1 % in case only one participant data contained in the testing set
    % perform majority voting on the participant (this line works only on leave one out)
    res_majority_vote_all           = round(res_windows_count_all./repmat(sum(res_windows_count_all, 2), 1, size(res_windows_count_all,2)));
else
    res_majority_vote_all = zeros(2,2); 
    % vote per participant
    for i=1:length(participantCodes)
       % take all the decisisons belongs to the corrent participant and do majority voting
       p_inds       = find(testParticipantLabels == participantCodes(i)); 
       p_expected   = testDegreeLabels(p_inds); 
       p_actual     = YTest(p_inds); 
       [p_c_mat]    = confusionmat(p_expected, p_actual, 'order', currentLabels);
       % perform majority voting
       p_vote_tmp   = round(p_c_mat./repmat(sum(p_c_mat, 2), 1, size(p_c_mat,2)));
       res_majority_vote_all = res_majority_vote_all + p_vote_tmp; 
    end
end
% in case of leave one participant out, this one doesnt matter (same as res_majority_vote)
res_majority_vote_all(isnan(res_majority_vote_all)) = 0;

% results in percents
res_windows_percents            = res_windows_count_all./repmat(sum(res_windows_count_all, 2), 1, size(res_windows_count_all,2));
res_windows_percents(isnan(res_windows_percents)) = 0;
% print results
% print_table(res_windows_count_all);
% diary off