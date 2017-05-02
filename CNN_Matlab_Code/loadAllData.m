function [ arr, labelsAll, labelsParticipant, uniqueParticipantLabels] = loadAllData(St, Sl, rootFolder)

fnames = fieldnames(St);
S = []; L = []; 
for i=1:length(fnames)
    S = [S St.(fnames{i})];
    L = [L Sl.(fnames{i})];
end
[~, Sc]   = collectData(NaN, S);
dataAll = []; labelsAll = []; labelsParticipant = [];
fprintf('\n'); arr = [];
for i=1:length(S)
    fprintf('.'); 
    % load participant
    imds         = imageDatastore(fullfile(rootFolder,Sc{i}), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
    imds.ReadFcn = @(filename)readAndPreprocessImage(filename);
    % read one participant
    dataAll     = [dataAll; cell2mat(readall(imds))]; 
    labelsAll   = [labelsAll; imds.Labels]; 
    % create labels for one participant
    labelsParticipant = [labelsParticipant; ones(length(imds.Labels), 1)*S(i)];
    stopHere    = 1; 
end
fprintf('\n');
dataAll             = dataAll';
arr(1, :, 1, :)     = dataAll;
uniqueParticipantLabels = unique(labelsParticipant); 
stopHere = 1; 