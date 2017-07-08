function [ arr, labelsAll, labelsParticipant, uniqueParticipantLabels] = loadAllData(rootFolder)
fnames = dir(rootFolder);
fnames = fnames(4:end);

dataAll = []; labelsAll = []; labelsParticipant = [];
fprintf('\n'); arr = [];
for i=1:length(fnames)
    fprintf('%d.\n',i); 
    % load participant
    imds         = imageDatastore(fullfile(rootFolder,fnames(i).name), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
    imds.ReadFcn = @(filename)readAndPreprocessImage(filename);
    % read one participant
    dataAll     = [dataAll; cell2mat(readall(imds))]; 
    labelsAll   = [labelsAll; imds.Labels]; 
    % create labels for one participant
    labelsParticipant = [labelsParticipant; repmat({fnames(i).name},[length(imds.Labels) 1])];
    stopHere    = 1; 
end
fprintf('\n');
dataAll             = dataAll';
arr(1, :, 1, :)     = dataAll;
uniqueParticipantLabels = {fnames.name}; 
stopHere = 1; 