close all; % pause(1);
res_res     = zeros(2,2);
max_iter    = 3;
info_stack  = {};
for iter=1:max_iter
    i = 1; j = 3;
    runSomePermutationsFromRAM;
    res_res = res_res + avg_p_res;
    info_stack{iter} = info;
end
res_res = res_res/max_iter;
disp('Average across tryouts: '); print_table(res_res, {'%.3g'}, {fnames{i}, fnames{j}}, {' ', fnames{i}, fnames{j}});
disp(['Average diag: ' num2str(mean(diag(res_res)))]);

for plotIter = 1:length(info_stack)
    figure(plotIter);
    ln          = length(info_stack{plotIter});
    subPlotNum  = ceil(ln/2);
    for plots=1:ln
        scrollsubplot(subPlotNum, 2, plots);
        plot(info_stack{plotIter}{plots}.TrainingAccuracy);
    end
end