function [convnet] = CreateCNN()

convnet = [ ...
    imageInputLayer([1 882*1], 'Normalization', 'none'); % set input size to size of window in samples 882 is for 20ms
    
    convolution2dLayer([1 256], 15, 'Stride', 4);
    reluLayer();
    maxPooling2dLayer([1 4], 'Stride', 2);
    % averagePooling2dLayer([1 3],'Stride',2);
%     convolution2dLayer([1 2], 10, 'Stride', 2);
%     reluLayer();
%     maxPooling2dLayer([1 2], 'Stride', 2);
%     
    %convolution2dLayer([1 2], 8, 'Stride', 2);
    %reluLayer();
    %maxPooling2dLayer([1 2],'Stride',2);
    
    
%             convolution2dLayer([1 10],60,'Stride',2);
%             reluLayer();
%             maxPooling2dLayer([1 2],'Stride',2);
%             
%             convolution2dLayer([1 10],60,'Stride',2);
%             reluLayer();
%             maxPooling2dLayer([1 2],'Stride',2);
            
    % fullyConnectedLayer(5); % ALEX changed (was 500)
    % reluLayer();
    fullyConnectedLayer(5); % ALEX changed (was 500)
    reluLayer();
    fullyConnectedLayer(2); % Change this to set number of output neurons
    softmaxLayer();
    classificationLayer();...
    ];
        
%             imageInputLayer([32 45], 'Normalization', 'none');
%             convolution2dLayer(10,20,'Stride',2);
%             reluLayer();
%             maxPooling2dLayer(2,'Stride',2);
%             fullyConnectedLayer(120);
%             reluLayer();
%             fullyConnectedLayer(2);
%             softmaxLayer();
%             classificationLayer()];
% convnet = [
%     %imageInputLayer([227 227 3])
%     imageInputLayer([32 882])
%     convolution2dLayer([11 1], 8)
%     reluLayer('Name', 'relu1')
%     %crossChannelNormalizationLayer(5,'K',1)
%     maxPooling2dLayer([2,2],'Stride',[2 2])
%     convolution2dLayer([1 11], 8)
%     reluLayer('Name', 'relu2')
%     %crossChannelNormalizationLayer(5,'K',1)
%     maxPooling2dLayer([2,2],'Stride',[2 2])
%     %convolution2dLayer([4 4], 13)
%     %reluLayer('Name', 'relu3')
%     %crossChannelNormalizationLayer(5,'K',1)
%     %maxPooling2dLayer([2,4],'Stride',1)
%     fullyConnectedLayer(64)
%     reluLayer('Name', 'relu4')
%     fullyConnectedLayer(2);
%     %reluLayer('Name', 'relu5')
%     softmaxLayer('Name','sml1')
%     classificationLayer('Name','coutput')
%     ];
%end
%