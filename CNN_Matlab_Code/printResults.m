function SR = printResults(votes, labels)
% compute average success rate 
s           = sum(votes, 3); 
t           = repmat(sum(s, 2), 1, 3); 
avg_p_res   = s./t; 
disp('Final average results: '); print_table(avg_p_res, {'%.3g'}, labels, [' ', labels]);
disp(['Mean success rate: ' num2str(trace(avg_p_res)/size(avg_p_res, 1))]);
SR = trace(avg_p_res)/size(avg_p_res, 1);

end