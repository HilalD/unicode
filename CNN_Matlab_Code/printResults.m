function SR = printResults(votes, labels)
% compute average success rate 
s           = sum(votes, 3); 
t           = repmat(sum(s, 2), 1, size(labels,2)); 
avg_p_res   = s./t; 
avg_p_res(isnan(avg_p_res)) = 0;
disp('Final average results: '); print_table(avg_p_res, {'%.3g'}, labels, [' ', labels]);
%disp(['Mean success rate: ' num2str(trace(avg_p_res)/size(avg_p_res, 1))]);
disp(['Mean success rate: ' num2str(trace(s)/trace(t))]);
%SR = trace(avg_p_res)/size(avg_p_res, 1);
SR = trace(s)/trace(t);
end