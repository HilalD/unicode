function [trainData, trainDegreeLabels, trainParticipantLabels] = balanceData(trainData, trainDegreeLabels, trainParticipantLabels, allLabels, labelIndices)
% Function:
% oversamples data as needed
% Input:
%   original data
%   method

assert(size(labelIndices,2)>1)
indexWithMaxData =1; % the index of the label that has the most data with that label.
x_count = 0; % the number of training labels with label at index indexWithMaxData
for ind=1:size(labelIndices,2) % get the index with the max data
    x = labelIndices(ind);
    x_count_new = sum(trainDegreeLabels==allLabels(x));
    if (x_count_new>x_count)
        x_count = x_count_new;
        indexWithMaxData =x;
    end
end

for ind=1:size(labelIndices,2)
    i = labelIndices(ind);
    if (i~=indexWithMaxData)
        i_count     = sum(trainDegreeLabels==allLabels(i));
        trainDataSz = size(trainData, 4);

        if x_count > i_count % not equal (since x_count is the max)
            dataWindowsRatio = i_count/x_count;
            dataInds = find(trainDegreeLabels==allLabels(i));
            % oversample group i by the dataWindowsRatio
            interpRatio = round(x_count*(1-dataWindowsRatio));
            [~, sampInds]           = datasample(dataInds, interpRatio); 
            trainData(:,:,:, trainDataSz+1:trainDataSz+interpRatio) = trainData(:, :, :, dataInds(sampInds));
            trainDegreeLabels       = [trainDegreeLabels; trainDegreeLabels(dataInds(sampInds))];
            trainParticipantLabels  = [trainParticipantLabels; trainParticipantLabels(dataInds(sampInds))];
        end
        
    end
end
end