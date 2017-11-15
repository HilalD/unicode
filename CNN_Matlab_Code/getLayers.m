%cd 15epochs2-3/checkpoint1
paths = dir;
S = [paths(:).datenum].'; % you may want to eliminate . and .. first.
[S,S] = sort(S);
S = {paths(S).name} ;
paths = S';
%layers = ones(size(paths,1),1);
convLayers = ones(size(paths,1));
fullLayers = ones(size(paths,1));
for i=2:size(paths,1)-2
    load(paths{i})
    paths(i)
    %layers(i) = struct('conv',gather(net.Layers(2,1).Weights),'full',gather(net.Layers(5,1).Weights));
    layers(i).conv = gather(net.Layers(2,1).Weights);
    layers(i).full = gather(net.Layers(5,1).Weights);
    layers(i).name = paths(i);
    %convLayers(i) = gather(net.Layers(2,1).Weights);
    %fullLayers(i) = gather(net.Layers(5,1).Weights);
end