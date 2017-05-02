function [res_windows_count_all, res_windows_percents, res_majority_vote_all,res_soft_voting, info] = runCNN(trainData, trainDegreeLabels, trainParticipantLabels, testData, testDegreeLabels, testParticipantLabels, opts, trainingSetPercentage, currentLabels)
res_windows_count_all = []; res_windows_percents = []; res_majority_vote_all = []; res_soft_voting =[];

% diary logResults.txt

%% Build the Convolutinal Neural Network Structure
convnet = CreateCNN();
class(convnet); 

%% Train CNN
[trainedNet, info]              = trainNetwork(trainData, trainDegreeLabels, convnet, opts);

res_majority_vote_all           = zeros(2,2);
res_windows_count_all           = zeros(2,2);
%% Classifiy using the trained CNN
[YTest,YScores]                           = classify(trainedNet,testData);
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

%%%%%% HILAL's CODE
% we sum the scores of the windows instead of taking the max vote
res_soft_voting = zeros(2,2);
window_scores = sum(YScores)./size(YScores,1);
winning_label_ind = window_scores==max(window_scores);
losing_label_ind = window_scores==min(window_scores);
winning_label = currentLabels(winning_label_ind);
if winning_label == p_expected(1) % all the windows have the same label
    res_soft_voting(winning_label_ind,winning_label_ind)=1;
else
    res_soft_voting(losing_label_ind,winning_label_ind)=1;
end
%%%%%%
% print results
% print_table(res_windows_count_all);
% diary off