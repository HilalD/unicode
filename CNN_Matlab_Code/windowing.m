function [] = windowing(filepath, windowpath, labelpath, millisecs, overlapPercentage)
%% window and transform all wav files in directory
%clear all
%% load directory and files with .wav extension
filepath = 'C:\Users\user\Documents\MATLAB\PDM-master\cut';
files = dir(fullfile(filepath,'*.wav'));
labelpath = 'C:\Users\user\Documents\MATLAB\PDM-master\R01 Subject characteristics.xls';
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
    millisecs = 150; %size of window in millisecs
    winSize = round((Fs/1000)*millisecs); %size of window in samples
    overlapPercentage = 0.5;
    
    loc = 1;
    ind = 1;
    
    samVec = zeros(2*round(length(y)/winSize), winSize); %1 for label, not needed at this point
    while loc+winSize <= (length(y)-winSize)
        samVec(ind , 1:winSize) = y(loc:(loc+winSize-1));
        loc = loc + round(winSize * overlapPercentage); %have 50% overlap
        ind = ind + 1;
    end
    samVec( ~any(samVec,2), : ) = []; %remove zero rows
    %winDB{i,1} = samvec(:,1:winSize);
    %winDB{i,2} = severity_label; %insert severity label, per-file...
    %... rather than per-window
    
    %% save windowed files to labeled folder
    winPath = 'C:\Users\user\Documents\MATLAB\PDM-master\windowed150ms';
    if ~exist(fullfile(winPath,num2str(severity_label)),'file')
        mkdir(winPath,num2str(severity_label));
    end
    %for j=1:size(samVec,1)
    %temppath = fullfile(winPath,num2str(severity_label),strcat(name,'_',num2str(severity_label),'_',num2str(j),'.wav'));
    temppath = fullfile(winPath,num2str(severity_label),strcat(name,'_',num2str(severity_label),'.mat'));
    %        audiowrite(temppath,y,Fs);
    currWinFile = cell(1,2);
    currWinFile{1,1} = samVec;
    currWinFile{1,2} = severity_label;
    tempmat = currWinFile;
    save(temppath, 'tempmat');
    %end
end
end
% clear pathstr name ext;
%
% %% window all files in database - create windowed database
% [lx, ly] = size(wavDB);
% winDB = cell(lx,2);
% for i=1:lx %for every file in wavDB...
%     millisecs = 20; %size of window in millisecs
%     winSize = round((wavDB{i,2}/1000)*millisecs); %size of window in samples
%
%     loc = 1;
%     ind = 1;
%
%     samVec = zeros(2*round(length(wavDB{i,1})/winSize), winSize + 1); %1 for label, not needed at this point
%
%     % cut the file INTO PIECES this is OUR LAST RESORT
%     while loc+winSize <= (length(wavDB{i,1})-winSize)
%         samVec(ind , 1:winSize) = wavDB{i,1}(loc:(loc+winSize-1));
%         loc = loc + winSize/2; %have 50% overlap
%         ind = ind + 1;
%     end
%     samVec( ~any(samVec,2), : ) = []; %remove zero rows
%     winDB{i,1} = samVec(:,1:winSize);
%     winDB{i,2} = wavDB{i,3}; %insert severity label, per-file...
%     %... rather than per-window
%
% end
% clear samvec;
%
% %% write window database into files - 1 per audiofile
% winPath = fullfile(filepath,'windowed');
% mkdir(filepath,'windowed');
%
% for i=1:length(winDB)
%     %temppath = strcat(tranPath,'\',files(i).name,'.mat');
%     temppath = fullfile(winPath,strcat(files(i).name,'.mat'));
%     tempmat = winDB{i};
%     save(temppath, 'tempmat');
% end
% %save(strcat(windowPath,'\','something.mat'), 'winDB');
% clear tempmat;
%
% %% save windowed database into labeled folders as .wav files i guess...
% for i=1:length(winDB)
%     %temppath = strcat(tranPath,'\',files(i).name,'.mat');
%     temppath = fullfile(winPath,winDB{i,2},strcat(files(i).name,'.mat'));
%     tempmat = winDB{i};
%     save(temppath, 'tempmat');
% end
% %% do lotsa wavelet transforms
% cont_or_disc = 'continuous'; %choose type of transform
%
% % get total number of windows, for creating database
% total_size = 0;
% [sizex, sizey] = size(winDB);
% for i=1:sizex
%     [lenx leny] = size(winDB{i});
%     total_size = total_size + lenx;
% end
%
% tranDB = cell(total_size, 2); %spot for transform and label
% dbIndex = 1; %current index
% tranPath = fullfile(filepath,'transformed\samples\');
% mkdir(filepath,'transformed\samples');
%
% wl = 'db4'; %wavelet type
% sc = 5; %resolution (2^sc)
%
% if  strcmp( cont_or_disc , 'continuous' )
%     for i=1:length(winDB)
%         [lenx, leny]=size(winDB{i,1});
%         mkdir(filepath,fullfile('transformed\samples\',int2str(winDB{i,2})));
%         for j=1:lenx
%             ccfs = cwt(winDB{i,1}(j,:),1:2^sc,wl);
%             tranPathC = fullfile(tranPath,int2str(winDB{i,2}),'\',strcat(int2str(dbIndex),'.tiff'));
%             %imwrite(im2uint16(mat2gray(ccfs,[-0.1, 0.1])), tranPathC, 'tiff');
%             imwrite(im2uint16(mat2gray(ccfs)), tranPathC, 'tiff');
%             % -0.1, 0.1 are arbitrary 'black' & 'white' so that all transforms
%             % not sure which is the better way to do it... don't delete the
%             % comments before we ask Alex
%             dbIndex = dbIndex + 1;
%         end
%     end
% else %discrete
%     for i=1:length(winDB)
%         [lenx, leny]=size(winDB{i,1});
%         mkdir(filepath,fullfile('transformed\samples\',int2str(winDB{i,2})));
%         for j=1:lenx
%             [c,l]=wavedec(winDB{i,1}(j,:),sc,wl);
%             % Compute and reshape DWT to compare with CWT.
%             cfd=zeros(sc,leny);
%             for k=1:sc
%                 d=detcoef(c,l,k);
%                 d=d(ones(1,2^k),:);
%                 cfd(k,:)=wkeep(d(:)',leny);
%             end
%             cfd=cfd(:);
%             I=find(abs(cfd) <sqrt(eps));
%             cfd(I)=zeros(size(I));
%             cfd=reshape(cfd,sc,leny);
%
%             %tranPathD = strcat(tranPath,int2str(winDB{i,2}),'\',int2str(dbIndex),'.tiff');
%             tranPathD = fullfile(tranPath,int2str(winDB{i,2}),strcat(int2str(dbIndex),'.tiff'));
%             %imwrite(im2uint16(mat2gray(cfd,[-0.1, 0.1])), tranPathD, 'tiff');
%             imwrite(im2uint16(mat2gray(cfd)), tranPathD, 'tiff');
%             dbIndex = dbIndex + 1;
%         end
%     end
% end
% %end
% %% save labels database into file - uneeded
% %tranPath = strcat(path,'transformed\labels');
% % mkdir(path,'transformed');
% %save(tranPath, 'labels');
%
% %% create imageDataStore for CNN
% % do this in a separate file, as it's not specifically relevant to..
% % the transformation
% % the following is how to create the input data of the CNN (for
% % training), including labels
% % imds = ImageDatastore('c:\temp\transformed\samples',...
% %   'IncludeSubfolders', true, 'FileExtentions', '.tiff',...
% %   'LabelSource','foldernames');