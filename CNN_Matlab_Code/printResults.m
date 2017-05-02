function SR = printResults(votes, label1, label2)
% compute average success rate 
s           = sum(votes, 3); 
t           = repmat(sum(s, 2), 1, 2); 
avg_p_res   = s./t; 
disp('Final average results: '); print_table(avg_p_res, {'%.3g'}, {label1, label2}, {' ', label1, label2});
disp(['Mean success rate: ' num2str(trace(avg_p_res)/size(avg_p_res, 1))]);
SR = trace(avg_p_res)/size(avg_p_res, 1);

end