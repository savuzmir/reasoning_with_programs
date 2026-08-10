function out = compute_three_step_null(out_three_values, sub_idx, trs, rel_l)

null_vals = [];
for i = 1:1000

   sw_rev_perm = out_three_values.three_step_seq_swap(trs, 6, :, rel_l, 2, sub_idx);
   sw_perm     = out_three_values.three_step_seq_swap(trs, 6, :, rel_l, 1, sub_idx);

    tmp = [];
    for sb = 1:29
        rel_rw_a = squeeze(nanmean(sw_rev_perm(:, :, 6, :, :, sb), 4));
        rel_rw_a = find(~isnan(rel_rw_a(:, 1)));
    
        rel_rw_b = squeeze(nanmean(sw_perm(:, :, 6, :, :, sb), 4));
        rel_rw_b = find(~isnan(rel_rw_b(:, 1)));
    
        joint = [sw_rev_perm(rel_rw_a, :, :, :, :, sb); sw_perm(rel_rw_b, :, :, :, :, sb)];
    
        full_rows = shuffle([1:(length(rel_rw_a) + length(rel_rw_b))]);

        sw_rev_in_perm = squeeze(nanmean(nanmean(nanmean(joint(full_rows(1:end/2), :, :, :, :), 4), 5), 1));
        sw_in_perm     = squeeze(nanmean(nanmean(nanmean(joint(full_rows((end/2 + 1):end), :, :, :, :), 4), 5), 1));
        tmp(:, sb) = sw_rev_in_perm - sw_in_perm; 
    end
    
    null_vals(:, :, i) = squeeze(tmp)'; 
end

out = struct;
out.null_vals = null_vals;