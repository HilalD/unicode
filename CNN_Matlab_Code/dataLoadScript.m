% this script is meant to load the data, in order to have these variables
% allways in matlab memory. For efficiency purposes. 
rootFolder = fullfile('/Users/hilldi/Documents/MATLAB/parkinsons project','hilalWindowing'); % set sample folder


%% Load Categories
[dataAll, labelsAll, labelsParticipant, uniqueParticipantLabels] = loadAllData(rootFolder);
%% Create Categories
allLabels = categorical(unique(labelsAll));
participantsNum = length(uniqueParticipantLabels);
