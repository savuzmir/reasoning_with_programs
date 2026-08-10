function out_stats = plot_rsa_message_passing_results(rel_container, rel_len_a, null_type, out_cfg, rsa_tp, curr)

null_bound = 97.5;
perm_type = 1;

if null_type == 0

    foo = [];
    for i = 1:out_cfg.n_perm
        [a,b,c,d]=ttest(rel_container(:, :, i, rsa_tp));
        foo(:, :, 1, i) = squeeze(d.tstat);
    end

    real_dat = squeeze(foo(:, rel_len_a, :, out_cfg.empir_idx));
    perm_dat = squeeze(foo(:, rel_len_a, :, out_cfg.null_idx));
    ub_val = compute_cluster_stats(real_dat', perm_dat, null_bound, 2);

else

    real_dat = squeeze(nanmean(rel_container(:, rel_len_a, :, rsa_tp), 1));
    perm_dat = squeeze(real_dat(:, out_cfg.null_idx));
    ub_val = compute_cluster_stats(real_dat(:, 1), perm_dat, null_bound, 2);

end

plot([0, length(rel_len_a)], [0, 0], ':k'); hold on; box off
plot(ub_val.threshUB, 'color', out_cfg.col_val, 'linestyle', '--');
plot(ub_val.threshLB * -1, 'color', out_cfg.col_val, 'linestyle', '--');
plot_sigline_perm(rel_container(:, rel_len_a, out_cfg.empir_idx, rsa_tp), ub_val, max(nanmean(rel_container(:, rel_len_a, 1, rsa_tp), 1)) + 0.005, perm_type, [0, 1], out_cfg.col_val)

if rsa_tp == 1
    tp_vals = [find(rel_len_a == 50), find(rel_len_a == 100), find(rel_len_a == 150), find(rel_len_a == 200)];
    figElements(curr, ' Start', 'Time [ms]', 'RSA Betas [a.u.]', [1 length(rel_len_a)], [-0.02, 0.04], tp_vals, {'Stim ON', '500', '1000', '1500'}, [], {}, 18, [], []);

else
    tp_vals = [find(rel_len_a == 150), find(rel_len_a == 200), find(rel_len_a == 250), find(rel_len_a == 300), find(rel_len_a == 350)];
    figElements(curr, ' End', 'Time [ms]', 'RSA Betas [a.u.]', [1 length(rel_len_a)], [-0.02, 0.04], tp_vals, {'-1500', '-1000', '-500', 'Stim OFF'}, [], {}, 18, [], []);

end

out_stats = ub_val;

end
