% 
% path = '';
% 
% 
% epochsNum           = 10;
% initialLearnRate    = 1; 
% miniBatchSize       = 32; 
% learnRateDropFactor = 1; 
% learnRateDropPeriod = 4;
% SR = zeros(4,8,3,6,6);
% 
% for j=1:4
%     epochsNum = epochsNum +5;
%   for x= 1:8
%       initialLearnRate = initialLearnRate -0.1;
%       for mSize=1:3
%           miniBatchSize = miniBatchSize *2;
%           
%           for lrdf=1:6
%               learnRateDropFactor = learnRateDropFactor- 0.1;
%               for lrdp=2:6
%                   learnRateDropPeriod = lrdp;
%                   
%                    newPath = strcat(path ,'test-',num2str(j),'-',num2str(x),'-',num2str(mSize),'-',num2str(lrdf),'-',num2str(lrdp),'-')
%                    mkdir(newPath);
%     
%                    SR(j,x,mSize,lrdf,lrdp) = runSomePermutationsFromRAM(epochsNum,initialLearnRate,learnRateDropFactor,miniBatchSize,learnRateDropPeriod,newPath);
%     
%                   save('sr.mat','SR');
%               end
%           end
%       end
%   end
% end
function testingParams(x)
    if(exist('loadedData', 'var'))
        fnames = loadedData.fnames;
        allLabels = loadedData.allLabels;
        st = loadedData.st;
        sl = loadedData.sl;
        dataAll = loadedData.dataAll;
        labelsAll = loadedData.labelsAll;
        labelsParticipant = loadedData.labelsParticipant;
        uniqueParticipantLabels = loadedData.uniqueParticipantLabels;
        participantsNum = loadedData.participantsNum;
        rootFolder = loadedData.rootFolder;
    end
    
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


