%function [ output_args ] = PDDiagConvNetOneFile( imdb_location, convnet )
%PDDIAGCONVNET : input labeled image databbase location and convnet, run
%convnet on image database
%   The function processes all images in the database through a given 
%   convolutional neural network to categorize them. Specifically
%   each image is the wavelet transform of a PD patient's voice taken at
%   short intervals (about tens of milliseconds). The convnet is trained
%   and tested using existing functions, then a Confusion matrix and other
%   statistics are shown
%% create imageDataStore for CNN
% the following is how to create the input data of the CNN (for
% training), including labels

% rootFolder = fullfile('C:\Users\user\Documents\MATLAB\PDM-master\caltech101', '101_ObjectCategories');
rootFolder = fullfile('C:\Users\user\Documents\MATLAB\PDM-master\','dataOhad.mat');
categories = {'0','1','1.5','2','2.5','3','4'}; % Set the categories: '0','1','1_5','2','2_5','3','4'
    
display 'Loading dataset...';
% imds = imageDatastore(fullfile(rootFolder, categories),...
%     'IncludeSubfolders', true,...
%   'LabelSource','foldernames');
load(rootFolder);

% Filter category indices
flags = zeros(size(data,1),1);
for i=1:length(categories)
    flags(labels == str2double(categories{i})) = 1;
end
data(flags == 0,:) = []; %remove zero rows
labels(flags == 0,:) = []; %remove zero rows

% Count each label
[labelCounts,labelCategories] = histc(labels,unique(str2double(categories)));
table(str2double(categories'),labelCounts,'VariableNames',{'Labels','LabelCounts'})

% Equalize labels & split to training and test groups
minSetCount = min(labelCounts);
splitDataTraining = cell(size(categories));
splitDataTesting = cell(size(categories));
for i=1:length(categories)
    if i == 1
        splitDataTraining{i} = data(1:sum(labelCounts(1:i)),:);
        splitDataTraining{i} = splitDataTraining{i}(randperm(size(splitDataTraining{i},1),minSetCount),:);
    else
        splitDataTraining{i} = data(sum(labelCounts(1:i-1)):sum(labelCounts(1:i)),:);
        splitDataTraining{i} = splitDataTraining{i}(randperm(size(splitDataTraining{i},1),minSetCount),:);
    end

end 
trainingLabels = [];
testLabels = [];
for i=1:length(categories)
%     perm =  randperm(minSetCount, round(minSetCount * 0.8));
%     compPerm = setxor(minSetCount,perm);
    trainingIdxs = randperm(minSetCount, round(minSetCount * 0.8));
    testIdxs = setxor(1:minSetCount,trainingIdxs); % get complementary permutation
    splitDataTesting{i} =  splitDataTraining{i}(testIdxs,:);
    splitDataTraining{i} =  splitDataTraining{i}(trainingIdxs,:);
    
    trainingLabels = [trainingLabels; ones(length(trainingIdxs),1) * str2double(categories{i})];
    testLabels = [testLabels; ones(length(testIdxs),1) * str2double(categories{i})];
end

trainingSet = cell2mat(splitDataTraining');
testSet = cell2mat(splitDataTesting');

clear splitDataTraining;
clear splitDataTesting;
clear data;

% Fit data to convnet format
trainingSet = trainingSet';
trainingSet = reshape(trainingSet, [1 size(trainingSet,1) 1 size(trainingSet,2)]);
testSet = testSet';
testSet = reshape(testSet, [1 size(testSet,1) 1 size(testSet,2)]);

trainingLabels = categorical(trainingLabels);
testLabels = categorical(testLabels);

CreateCNN;
% cnnMatFile = fullfile(tempdir, 'imagenet-caffe-alex.mat');
% convnet = helperImportMatConvNet(cnnMatFile);
% convnet.Layers(1).InputSize = [32, 882, 1]
class(convnet)


%% start CNN
 if ~exist('C:\Users\user\Documents\MATLAB\PDM-master\checkpoint','file')
            mkdir('C:\Users\user\Documents\MATLAB\PDM-master\checkpoint');
        end
opts = trainingOptions('sgdm','InitialLearnRate',0.1,'MiniBatchSize',32,'LearnRateSchedule','piecewise','LearnRateDropFactor',0.5,...
    'MaxEpochs',100)%,'CheckpointPath','C:\Users\user\Documents\MATLAB\PDM-master\checkpoint');

[trainedNet, trainInfo] = trainNetwork(trainingSet,trainingLabels, convnet, opts);
% save trainingOf340.mat trainedNet trainInfo
%end

