if(~exist('loadedData', 'var'))
    dataLoadScript
    loadedData.fnames = fnames;
    loadedData.allLabels = allLabels;
    loadedData.st = st;
    loadedData.sl = sl;
    loadedData.dataAll = dataAll;
    loadedData.labelsAll = labelsAll;
    loadedData.labelsParticipant = labelsParticipant;
    loadedData.uniqueParticipantLabels = uniqueParticipantLabels;
    loadedData.participantsNum = participantsNum;
    loadedData.rootFolder = rootFolder;
end
path = '/home/hdiab/Dropbox/checkpoint/resultsForReport';


epochsNum           = 30; %15
initialLearnRate    = 0.1;  % 0.1 0.01 for timit
learnRateDropFactor = 0.4;  % 0.4
miniBatchSize       = 256;   % 128
learnRateDropPeriod = 4;    %4
SR = [];
totalsRuns =0;
lrdp=1;
newPath = strcat(path, '/multiclassNoTimitNoSilence/classes/0-2-3')
classNums = [1,4,6];
repeatTimes = 10;
useTIMIT = false;
for times=1:repeatTimes
   mkdir(newPath);
   [sr] = runSomePermutationsFromRAM(epochsNum,initialLearnRate,learnRateDropFactor,miniBatchSize,learnRateDropPeriod,newPath,loadedData,classNums,useTIMIT);
   SR = [SR,sr];
   totalsRuns = totalsRuns+1;
   save(strcat(newPath,'/',num2str(times),'-t-',num2str(floor(sr*100)),'sr.mat'),'SR');
  if (times == repeatTimes)
      save(strcat(newPath,'/',num2str(floor(mean(SR)*1000)),'AVGSuccess.mat'),'SR');
  end
end
mean(SR)
std(SR)
SR = [];
