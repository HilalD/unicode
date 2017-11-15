% this script is meant to load the data, in order to have these variables
% allways in matlab memory. For efficiency purposes. 
rootFolder = fullfile('/home/hdiab/PDM-Master','windowed30ms-03-complexsilencefiltered'); % set sample folder

%% Create Categories
[st, sl]    = createDataAndLabelsStructure();
allLabels   = categorical({'0', '1', '1_5', '2', '2_5', '3', '4'});
fnames      = fieldnames(st);

%% Load Categories
[dataAll, labelsAll, labelsParticipant, uniqueParticipantLabels] = loadAllData(st, sl, rootFolder);
participantsNum = length(uniqueParticipantLabels);
