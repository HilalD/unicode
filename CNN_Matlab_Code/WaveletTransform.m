function [ output_args ] = WaveletTransform( transformPath, samplePath, wl, sc)
%WAVELETTRANSFORM Summary of this function goes here
%   Detailed explanation goes here
datetime
%% do lotsa wavelet transforms
transformPath = 'C:\Users\user\Documents\MATLAB\PDM-master';
cont_or_disc = 'continuous'; %choose type of transform
samplePath = 'C:\Users\user\Documents\MATLAB\PDM-master\windowed150ms';
sampDS = fileDatastore(samplePath, 'ReadFcn', @load, 'IncludeSubfolders', true, 'FileExtensions', '.mat');

% get max number of windows per file for per-file image database (so we can
% normalize the images in each file)
maxWindowNum = 0;
[sizex, ~] = size(sampDS.Files);
for i=1:sizex
    currFile = read(sampDS);
    currFile = currFile.tempmat;
    [lenx, ~] = size(currFile{1});
    %[lenx ~] = size(sampDS.Files{i});
    if lenx > maxWindowNum
        maxWindowNum = lenx;
    end
end

%reset datastore index
reset(sampDS);

%imDB = cell(total_size, 2); %spot for transform and label
%dbIndex = 1; %current index

ims_per_file_db = cell(maxWindowNum,1);


transformPath = fullfile(transformPath,'transformed150ms');
if ~exist(transformPath,'file')
    mkdir(transformPath);
end

wl = 'db40'; %wavelet type
sc = 5; %resolution (2^sc)

if  strcmp( cont_or_disc , 'continuous' )
    for i=1:length(sampDS.Files)
        currFile = read(sampDS);
        currFile = struct2cell(currFile);
        currFile = currFile{1,1};
        currFile = cell2mat(currFile(1));
        
        % get name
        [~, name, ~] = fileparts(sampDS.Files{i});
        % get label
        parts = strsplit(sampDS.Files{i},filesep);
        label = parts{end-1};
        
        [lenx, ~]=size(currFile);
        
        if ~exist(fullfile(transformPath,label),'file')
            mkdir(fullfile(transformPath,label));
        end
        
%         maxval = -100;
%         minval = 100;
        
        for j=1:lenx
            ccfs = cwt(currFile(j,:),1:2^sc,wl);
            %ccfs = cwtft(currFile(j,:),'scales',1:2^sc,'wavelet',{'dog' 40});
            ims_per_file_db{j} = ccfs;
            
%             gArr = gpuArray(ccfs);
%             curMax = max(gArr(:));
%             curMin = min(gArr(:));
            % save max and min values for file-wise normalization
%             curMax = max(ims_per_file_db{j}(:));
%             curMin = min(ims_per_file_db{j}(:));
%             if curMax > maxval
%                 maxval = curMax;
%             end
%             if curMin < minval
%                 minval = curMin;
%             end
        end
        minval = -1.717183;
        maxval = 1.615170;
        %fprintf('label: %s, minval: %f, maxval: %d\n',label, minval, maxval);
        for j=1:lenx
            tranPathC = fullfile(transformPath,label,strcat(name,'_', int2str(j),'.tiff'));
            imwrite(im2uint16(mat2gray(ims_per_file_db{j},[minval, maxval])), tranPathC, 'tiff');
%             imwrite(im2uint16(1-mat2gray(abs(ims_per_file_db{j}))), tranPathC, 'tiff');
            %imwrite(mat2gray(ims_per_file_db{j}), tranPathC, 'tiff');
%             varj = ims_per_file_db{j};
%             tranPathC = fullfile(transformPath,label,strcat(name,'_', int2str(j),'.mat'));
%             %str = strcat('ims_per_file_db{',num2str(j),'}');
%             save(tranPathC, 'varj');
            % -0.1, 0.1 are arbitrary 'black' & 'white' so that all
            % transforms have the same grayscale values for the same scale
            % info
            % not sure which is the better way to do it... don't delete the
            % comments before we ask Alex
            %dbIndex = dbIndex + 1;
        end
    end
    % else %discrete
    %     for i=1:length(sampDS.Files)
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
    %             tranPathD = fullfile(transformPath,int2str(winDB{i,2}),strcat(int2str(dbIndex),'.tiff'));
    %             %imwrite(im2uint16(mat2gray(cfd,[-0.1, 0.1])), tranPathD, 'tiff');
    %             imwrite(im2uint16(mat2gray(cfd)), tranPathD, 'tiff');
    %             dbIndex = dbIndex + 1;
    %         end
    %     end
end
datetime
end
%% save labels database into file - uneeded
%tranPath = strcat(path,'transformed\labels');
% mkdir(path,'transformed');
%save(tranPath, 'labels');

%% create imageDataStore for CNN
% do this in a separate file, as it's not specifically relevant to..
% the transformation
% the following is how to create the input data of the CNN (for
% training), including labels
% imds = ImageDatastore('c:\\temp\transformed\samples',...
%   'IncludeSubfolders', true, 'FileExtentions', '.tiff',...
%   'LabelSource','foldernames');


