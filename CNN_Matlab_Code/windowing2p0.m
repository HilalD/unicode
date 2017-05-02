function [] = windowing2p0(filepath, windowpath, labelpath, millisecs, overlapPercentage)
%% window and transform all wav files in directory
% Parameters
    millisecs = 20; %size of window in millisecs
    overlapPercentage = 0.5; % an overlap of .9 would have 90% overlap between windows, for example
    winPath = '/home/alex/PDM-Master/windowed20ms'; % folder for windows
    
%% load directory and files with .wav extension
filepath = '/home/alex/PDM-Master/cut';
files = dir(fullfile(filepath,'*.wav'));
labelpath = '/home/alex/PDM-Master/R01 Subject characteristics.xls';
%% load xls file which contains label information
filename = labelpath;
xlRange = 'A6:L57';
R01Table = xlsread(filename, 1, xlRange);
R01Table_C = ([R01Table(:,1) R01Table(:,7) R01Table(:,11) R01Table(:,12)]);
%% audioread all files into 'database'
%wavDB = cell(length(files),3);
wavDS = fileDatastore(filepath,'ReadFcn',@audioread);
%data1 = read(wavDS);
%data1 = sum(data1,2) ./ 2;
for i=1:length(wavDS.Files)
    %[y,Fs] = audioread(fullfile(filepath,files(i).name));
    [y, Fs] = audioread(wavDS.Files{i});
    % average out channels if not mono
    [~, n] = size(y);
    if n > 1
        y = sum(y,2) ./ n;
    end
    %wavDB{i,1} = y;
    %wavDB{i,2} = Fs;
    
    %get severity of disease from xls table
    [~, name, ~] = fileparts(wavDS.Files{i});
    splitName = strsplit(name);
    patient_serial = (sscanf(splitName{2}, '%*c%d', [1 inf]));
    [row,~] = find(R01Table_C(:,1) == patient_serial);
    
    % if unlabeled
    if ~isempty(patient_serial)
        severity_label = R01Table(row,7);
%         if patient_serial == 43
%             patient_serial
%         end
        if isempty(severity_label)
            continue;
        end
    else
        continue;
    end
    %wavDB{i,3} = severity_label;
    
    if severity_label ~= round(severity_label)
        severity_label = num2str(severity_label);
        severity_label = strrep(severity_label, '.', '_');
    else
        severity_label = num2str(severity_label);
    end
    %% cut the file into windows
%     millisecs = 20; %size of window in millisecs
    winSize = round((Fs/1000)*millisecs); %size of window in samples
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
            strcat(name,'_',num2str(severity_label),'_',str,'.mat'));
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
