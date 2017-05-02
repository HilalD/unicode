function [arr, labels] = dataStore2SimpleAray(dObject)
arr         = [];
temp        = readall(dObject);
temp        = cell2mat(temp);
temp        = temp';
arr(1, :, 1, :) = temp;
labels      = dObject.Labels;