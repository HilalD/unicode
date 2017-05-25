function [convnet] = CreateCNN(numOfClasses, transferLearningNet)
%%CREATECNN creates a convoloutional network that we want to train
%numOfClasses: the number of possible classes
%transferLearningNet(optional): if this is passed then we want to use given
%network and change the last layers so that we do transfer learning.
%%
if ~exist('numOfClasses', 'var')
    numOfClasses = 2;
end
assert (numOfClasses>1);

convnet = [ ...
    imageInputLayer([1 882*1], 'Normalization', 'none'); % set input size to size of window in samples 882 is for 20ms
    
    convolution2dLayer([1 256], 15, 'Stride', 4);
    reluLayer();
    maxPooling2dLayer([1 4], 'Stride', 2);
    % averagePooling2dLayer([1 3],'Stride',2);
    fullyConnectedLayer(5); % ALEX changed (was 500)
    reluLayer();
    fullyConnectedLayer(numOfClasses); % Change this to set number of output neurons
    softmaxLayer();
    classificationLayer();...
    ];
%%
if exist('transferLearningNet', 'var')
    convnet = transferLearningNet.Layers(1:end-3);
    convnet(end+1) = fullyConnectedLayer(numOfClasses,...
        'WeightLearnRateFactor',10,'BiasLearnRateFactor',20);
    convnet(end+1) = softmaxLayer();
    convnet(end+1) = classificationLayer();
end
