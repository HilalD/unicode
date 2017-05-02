%function [ output_args ] = PDDiagConvNet( imdb_location, convnet, opts, trainingPctg )
%PDDIAGCONVNET : input labeled image databbase location and convnet, run
%convnet on image database
%   The function processes all images in the database through a given
%   convolutional neural network to categorize them. Specifically
%   each image is the wavelet transform of a PD patient's voice taken at
%   short intervals (about tens of milliseconds). The convnet is trained
%   and tested using existing functions, then a Confusion matrix and other
%   statistics are shown

function [res_windows_count_all, res_windows_percents, res_majority_vote_all] = PDDiagConvNet(S, Sc, opts, trainingSetPercentage, rootFolder, currentLabels, useArray)
res_windows_count_all = []; res_windows_percents = []; res_majority_vote_all = [];
%% create imageDataStore for CNN
%% Parameters

%  if ~exist('C:\Users\user\Documents\MATLAB\PDM-master\checkpoint','file')
%             mkdir('C:\Users\user\Documents\MATLAB\PDM-master\checkpoint');
%         end

% St = repmat(S,1,length(categories));
% categories = repmat(categories,length(S),1);
% S = St;
% categories = {categories{:}};
diary logResults.txt
tic
display 'Loading dataset...';
% imds = imageDatastore(fullfile(rootFolder, categories),...
%     'IncludeSubfolders', true,...
%   'LabelSource','foldernames');
% imds = imageDatastore(fullfile(rootFolder,S, categories),...
%   'FileExtensions','.mat','IncludeSubfolders', true,...
%   'LabelSource','foldernames');
if isempty(Sc)
    % load the data
    imds = imageDatastore(fullfile(rootFolder,S), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
    imds.ReadFcn = @(filename)readAndPreprocessImage(filename);
    
    display 'Counting labels...';
    tbl = countEachLabel(imds)
    
    display 'Equalizing labels...';
    minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
    
    % Use splitEachLabel method to trim the set.
    imds = splitEachLabel(imds, int32(minSetCount * 1), 'randomized');
    
    % Notice that each set now has exactly the same number of images.
    f = countEachLabel(imds)
    
    % Create test and training sets
    [trainingSet, testSet] = splitEachLabel(imds, trainingSetPercentage, 'randomize');
    
else % if using Leave-One (participant)-Out
    % read the training set data
    trainingSet = imageDatastore(fullfile(rootFolder,S), 'FileExtensions', '.mat', 'IncludeSubfolders', true, 'LabelSource','foldernames');
    trainingSet.ReadFcn = @(filename)readAndPreprocessImage(filename);
    
    if useArray
        tic
        [trainingSetArray, trainingSetArrayLabels] = dataStore2SimpleAray(trainingSet);
        
        temp    = imageDatastore(fullfile(rootFolder,Sc), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
        % setup the reading function
        temp.ReadFcn = @(filename)readAndPreprocessImage(filename);    
        [testSetArray, testSetArrayLabels] = dataStore2SimpleAray(temp);
        toc
    else
        % read the testing set data
        for i=1:length(Sc)
            % load the file locations
            temp    = imageDatastore(fullfile(rootFolder,Sc(i)), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
            lenIm   = length(temp.Labels);
            cnt     = 1;
            jump    = 500;
            
            % tic
            for j=1:jump:lenIm % read the data in portions
                testSet{i,cnt}  = imageDatastore(fullfile(rootFolder,Sc(i)), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
                sel             = ones(1,lenIm);
                sel(j:j+jump-1) = 0;
                testSet{i,cnt}.Files(sel==1) = [];
                % setup the reading function
                testSet{i,cnt}.ReadFcn = @(filename)readAndPreprocessImage(filename);
                cnt = cnt + 1;
            end
            % pick the last samples
            if j<lenIm
                testSet{i,cnt}  = imageDatastore(fullfile(rootFolder,Sc(i)), 'FileExtensions','.mat','IncludeSubfolders', true, 'LabelSource','foldernames');
                sel             = ones(1,lenIm);
                sel(j:end)      = 0;
                testSet{i,cnt}.Files(sel==1) = [];
                % setup the reading function
                testSet{i,cnt}.ReadFcn = @(filename)readAndPreprocessImage(filename);
            end
            % toc
            % stopHere = 1;
        end
    end
    
    display 'Counting labels...';
    tbl = countEachLabel(trainingSet)
    
    display 'Equalizing labels...';
    minSetCount = min(tbl{:,2}); % determine the smallest amount of images in a category
    
    % Use splitEachLabel method to trim the set.
    trainingSet = splitEachLabel(trainingSet, int32(minSetCount * 1), 'randomized');
    
end

convnet = CreateCNN();
class(convnet)

% tnSet = countEachLabel(trainingSet)
% tsSet = countEachLabel(testSet)

%% Train CNN
if useArray
    [trainedNet] = trainNetwork(trainingSetArray, trainingSetArrayLabels, convnet, opts);
else
    % [trainedNet, trainInfo] = trainNetwork(trainingSet, convnet, opts);
    [trainedNet] = trainNetwork(trainingSet, convnet, opts);
    % plot(trainInfo.TrainingAccuracy);
end
%% Classifiy using the trained CNN
res_majority_vote_all = zeros(2,2);
res_windows_count_all = zeros(2,2);
if useArray
    YTest                           = classify(trainedNet,testSetArray);
    
    [res_windows_count_all, order]  = confusionmat(testSetArrayLabels, YTest, 'order', currentLabels);
    res_majority_vote_all           = round(res_windows_count_all./repmat(sum(res_windows_count_all, 2), 1, size(res_windows_count_all,2)));
    
    % in case of leave one participant out, this one doesnt matter (same as res_majority_vote)
    res_majority_vote_all(isnan(res_majority_vote_all)) = 0;
    
    StopHere = 1;
else
    for i = 1:size(testSet, 1)
        YTest = []; labels = [];
        % classfiy each test set group
        for j = 1:size(testSet, 2)
            tempRes = classify(trainedNet,testSet{i,j});
            YTest   = [YTest; tempRes];
            labels  = [labels; testSet{i,j}.Labels];
            StopHere = 1;
        end
        % accuracy                    = sum(YTest == labels) / numel(labels);
        [res_windows_count, order]  = confusionmat(labels,YTest, 'order', currentLabels);
        res_windows_count_all       = res_windows_count_all + res_windows_count;
        res_majority_vote           = round(res_windows_count./repmat(sum(res_windows_count, 2), 1, size(res_windows_count,2)));
        
        % in case of leave one participant out, this one doesnt matter (same as res_majority_vote)
        res_majority_vote(isnan(res_majority_vote)) = 0;
        res_majority_vote_all       = res_majority_vote_all + res_majority_vote;
        StopHere = 1;
    end
end
% results in percents
res_windows_percents        = res_windows_count_all./repmat(sum(res_windows_count_all, 2), 1, size(res_windows_count_all,2));
res_windows_percents(isnan(res_windows_percents)) = 0;
toc
print_table(res_windows_count_all);
diary off

% save trainingOf340.mat trainedNet trainInfo
%end
