filename = '/Users/hilldi/Documents/MATLAB/parkinsons project/Hilals Folder/windowing5vlass1vs2vs3vs4vs6/windowResultswithSilence.csv';
numOfclasses = 5;
numOfPatients = 15; % default
windows = zeros(numOfclasses*numOfPatients,10*numOfclasses);
for i=1:10
    load(strcat('/Users/hilldi/Documents/MATLAB/parkinsons project/Hilals Folder/windowing5vlass1vs2vs3vs4vs6/',num2str(i),'windowDistributions.mat'))
    if size(windowDistributions,3) ~=numOfPatients
        numOfPatients= size(windowDistributions,3);
        windows = zeros(numOfclasses*numOfPatients,10*numOfclasses);
    end
    for j=1:size(windowDistributions,3)
        windows(numOfclasses*(j-1)+1:numOfclasses*j,[numOfclasses*(i-1)+1:numOfclasses*i]) = reshape(windowDistributions(:,:,j),numOfclasses,numOfclasses);
    end
    
end
csvwrite(filename,windows)