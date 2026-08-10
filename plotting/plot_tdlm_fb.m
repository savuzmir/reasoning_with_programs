function [out, npThreshAll_lb, npThreshAll_ub, comp_seq] = plot_tdlm_fb(comp, curr, lab, perm_thresh, thresh_col, colo)

comp_seq = squeeze(comp(:, :, 1));
[~, ~, npThreshAll_lb, npThreshAll_ub] = compute_tdlm_null_bounds_fb(squeeze(comp(:, :, 2:end)), perm_thresh);


if isempty(thresh_col)
    thresh_col = 'k';
end
plot([1, size(comp, 2)], npThreshAll_lb*[1, 1], '--', 'color', thresh_col, 'linewidth', 1); hold on
plot([1, size(comp, 2)], npThreshAll_ub*[1, 1], '--', 'color', thresh_col, 'linewidth', 1)

out=plotmse(comp_seq, colo, [0, 1]); box off

end