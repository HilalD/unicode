function [Sc, S] = collectData(lv1O, S)
% turns the data into cell array that can be read by imageDataStore
%%
Sc  = S(ismember(S,lv1O)); % S-Complementary, for the test set in case of leave-one-out
S   = S(~ismember(S,lv1O));
if iscell(S)
    return; 
end
S = num2cell(S);
for i=1:length(S)
    S{i} = num2str(S{i});
end
Sc = num2cell(Sc);
for i=1:length(Sc)
    Sc{i} = num2str(Sc{i});
end