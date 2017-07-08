function [] = windowing2p0timit(db,dialectName)
%% window and transform all wav files in directory
% Parameters
    millisecs = 30; %size of window in millisecs
    overlapPercentage = 0.3; % an overlap of .9 would have 90% overlap between windows, for example
    winPath = '/Users/hilldi/Documents/MATLAB/parkinsons project/hilalWindowing'; % folder for windows
    
%% load directory and files with .wav extension
% filepath = '/home/alex/PDM-Master/cut';
% files = dir(fullfile(filepath,'*.wav'));
% labelpath = '/home/alex/PDM-Master/R01 Subject characteristics.xls';
%% load xls file which contains label information
% filename = labelpath;
% xlRange = 'A6:L57';
% R01Table = xlsread(filename, 1, xlRange);
% R01Table_C = ([R01Table(:,1) R01Table(:,7) R01Table(:,11) R01Table(:,12)]);
%% audioread all files into 'database'
%wavDB = cell(length(files),3);
% wavDS = fileDatastore(filepath,'ReadFcn',@audioread);
%data1 = read(wavDS);
%data1 = sum(data1,2) ./ 2;
[wavs,freqSamples,metas] = query(db,'dialect', dialectName);
for i=1:length(wavs)
    y = wavs{i};
    Fs = freqSamples;
    % average out channels if not mono
    [~, n] = size(y);
    if n > 1
        y = sum(y,2) ./ n;
    end
    %wavDB{i,1} = y;
    %wavDB{i,2} = Fs;
    patient_serial = metas{i,1}.speaker;    
    % if unlabeled
    if ~isempty(patient_serial)
        severity_label = metas{i,1}.dialect;
        if isempty(severity_label)
            continue;
        end
    else
        continue;
    end
    
    %% cut the file into windows
%     millisecs = 20; %size of window in millisecs
    winSize = 1323;%round((Fs/1000)*millisecs); %size of window in samples
%     overlapPercentage = 0.90;
    
    loc = 1;
    ind = 1;
    
%     winPath = '/home/alex/PDM-Master/windowed20ms';
    if ~exist(fullfile(winPath,num2str(patient_serial)),'file')
        mkdir(winPath,num2str(patient_serial));
    end
    if ~exist(fullfile(winPath,num2str(patient_serial),num2str(severity_label)),'file')
        mkdir(fullfile(winPath,num2str(patient_serial),num2str(severity_label)));
    end
    
    samVec = zeros(2*round(length(y)/winSize), winSize);
    while loc+winSize <= (length(y)-winSize)
        str = sprintf('%05d',ind);
        temppath = fullfile(winPath,num2str(patient_serial),...
            num2str(severity_label),...
            strcat(num2str(severity_label),'_',str,'.mat'));
        samVec(ind , 1:winSize) = y(loc:(loc+winSize-1));
        if any(samVec(ind , 1:winSize),2) ~= 0
            tempmat = samVec(ind , 1:winSize);
            save(temppath, 'tempmat','patient_serial', 'severity_label');
        end       
        loc = loc + round(winSize * overlapPercentage); %have 50% overlap
        ind = ind + 1;
    end
end
end
