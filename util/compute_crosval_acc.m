function [idx_val_tp, idx_tps] = compute_crosval_acc(sub_decod_vals)

n_sub = size(sub_decod_vals, 2);
  
idx_val_tp = [];
idx_tps = [];
% keyboard
for sb = 1:n_sub
    train = sub_decod_vals(:, setdiff(1:n_sub, sb));
    [a,b,c,d]=ttest(train');
    [~, idx] = max(d.tstat);
    idx_val_tp(sb) = sub_decod_vals(idx, sb);
    idx_tps(sb) = idx;
end

end