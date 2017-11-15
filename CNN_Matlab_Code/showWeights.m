 function showWeights(net)
convlayer = net.Layers(2,1).Weights;
 convlayer_new = reshape(convlayer,256,15);
 plotWeights(convlayer_new')
 
 
  easy = net.Layers(5,1).Weights;
  plotWeights(easy)
 end