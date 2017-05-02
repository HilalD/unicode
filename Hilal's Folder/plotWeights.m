function plotWeights(weights)
    
    numVars = size(weights,1);
    weightsPerVar = size(weights,2);
    
    figure;
    for i=1:numVars
        subplot(5,3,i);
        plot(1:weightsPerVar,weights(i,:),'color','r');
    end
end