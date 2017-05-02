function [trainData, trainDegreeLabels, trainParticipantLabels] = balanceData(trainData, trainDegreeLabels, trainParticipantLabels, allLabels, i, j, method, dropFactor)
% Function:
%
% Input:
%   original data
%   method

if method == 0
    % do nothing
    return; 
end
if ~exist('dropFactor', 'var')
    dropFactor = 0; 
end

if dropFactor > 0
   % drop X% of the data from training 
   ln               = length(trainDegreeLabels); 
   dropSamplesNum   = round(dropFactor*ln);
   indPerm          = randperm(ln); 
   ind2drop         = indPerm(1:dropSamplesNum);
   
   trainData(:,:,:,ind2drop)        = [];
   trainDegreeLabels(ind2drop)      = [];
   trainParticipantLabels(ind2drop) = [];
end
% TODO: consider to oversample the smaller dataset
i_count     = sum(trainDegreeLabels==allLabels(i));
j_count     = sum(trainDegreeLabels==allLabels(j));
trainDataSz = size(trainData, 4);

if i_count > j_count
    i_bigger_than_j = 1; 
    % means i_count is bigger that j
    dataWindowsRatio = j_count/i_count;
else
    i_bigger_than_j = 0; 
    % means i_count is smaller than j
    dataWindowsRatio = i_count/j_count;
end

if method == 1
    % oversample the training dataset incase of strong bias
    if i_bigger_than_j
        % oversample group j by the dataWindowsRatio
        dataInds = find(trainDegreeLabels==allLabels(j));
        interpRatio = round(i_count*(1-dataWindowsRatio));
    else
        % oversample group i by the dataWindowsRatio
        dataInds = find(trainDegreeLabels==allLabels(i));
        interpRatio = round(j_count*(1-dataWindowsRatio));
    end
    [~, sampInds]           = datasample(dataInds, interpRatio); 
    trainData(:,:,:, trainDataSz+1:trainDataSz+interpRatio) = trainData(:, :, :, dataInds(sampInds));
    trainDegreeLabels       = [trainDegreeLabels; trainDegreeLabels(dataInds(sampInds))];
    trainParticipantLabels  = [trainParticipantLabels; trainParticipantLabels(dataInds(sampInds))];
elseif method == 2
    if i_count > j_count
        % downsample i
        dataInds = find(trainDegreeLabels==allLabels(i));
        downRatio = round(i*dataWindowsRatio);
    else
        % downsample j
        dataInds = find(trainDegreeLabels==allLabels(j));
        downRatio = round(j_count*dataWindowsRatio);
    end
    % choose the indeces to downsample
    indsPerm    = randperm(length(dataInds));
    % newDataInds = dataInds(indsPerm);
    % indBorder   = round(length(indsPerm)*downRatio);
    data2rem    = dataInds(indsPerm(1:downRatio)); % data indexes that need to be downsampled
    % remove the selected indexes
    trainData(:,:,:, data2rem)          = [];
    trainDegreeLabels(data2rem)         = [];
    trainParticipantLabels(data2rem)    = [];
else
    return; 
end