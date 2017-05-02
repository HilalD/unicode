%  function showWeights(net)
% convlayer = net.Layers(2,1).Weights;
%  convlayer_new = reshape(convlayer,256,15);
%  plotWeights(convlayer_new')
%  
%  
%   easy = net.Layers(5,1).Weights;
%   plotWeights(easy)
% end
 function showWeights()
 hilal = 0;
    load('/Users/hilldi/Documents/MATLAB/parkinsons project/Hilal''s Folder/layers.mat')
    load('/Users/hilldi/Documents/MATLAB/parkinsons project/Hilal''s Folder/infos.mat')
    figure;
    
      for j=1:size(layers(),2)
          layers(j).name
        convlayer = layers(j).conv;
         convlayer_new = reshape(convlayer,256,15);
         %plotWeights(convlayer_new')
         weights = convlayer_new';
         %%
         numVars = size(weights,1);
        weightsPerVar = size(weights,2);
        
        participantNum = floor(j/16)+1;
        trainingAccuracy = info{participantNum}.TrainingAccuracy;
        epochNum = mod(j-1,15)+1;
        epochSize = size(trainingAccuracy,2)/15;
        epochAccuracy = mean(trainingAccuracy((epochSize)*(epochNum-1)+1:(epochSize)*(epochNum)));
        % - Build title axes and title.
        axes( 'Position', [0, 0.95, 1, 0.05] ) ;
        set( gca, 'Color', 'None', 'XColor', 'None', 'YColor', 'None' ) ;
        ccc =text( 0.5, 0, ['Participant ' num2str(participantNum) ' Training Accuracy ' num2str(epochAccuracy) '%'], 'FontSize', 13', 'FontWeight', 'Bold','HorizontalAlignment', 'Center', 'VerticalAlignment', 'Bottom' ) ;
        
        for i=1:numVars
            a = subplot(5,3,i);
            
            if hilal ==0
                
                h(i) =plot(1:weightsPerVar,weights(i,:),'color','r');
            else
                h(i).XData = 1:weightsPerVar;
                y = weights(i,:); 
                h(i).YData = y;
                drawnow expose
            end
            pause(0.060)
            
        end
        hilal =1
        if(mod(j,15)==0)
            figure;
            hilal = 0
        end
        

        %%

%           full = layers(j).full;
%           weights2 = full;
%          %%
%          numVars = size(weights2,1);
%         weightsPerVar = size(weights2,2);
%         for i=1:numVars
%             subplot(5,3,i);
%             if hilal ==0
%                 
%                 h(i) =plot(1:weightsPerVar,weights2(i,:),'color','r');
%             else
%                 h(i).XData = 1:weightsPerVar;
%                 y = weights2(i,:); 
%                 h(i).YData = y;
%                 drawnow expose
%             end
%             pause(0.10)
%             
%             
%         end
        %%
           pause(0.70)
           ccc.delete()
          
     end
     close all
end