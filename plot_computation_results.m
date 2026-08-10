function out = plot_computation_results()

out = struct;


out_computation_results = load('out_computation_results');

% =================================
% attr decoding

attribute_figure = figure(710);

clf(attribute_figure);
tiledlayout(attribute_figure, 1, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
attribute_axes = gobjects(1, 4);

for attr = 1:3
    attribute_axes(attribute) = nexttile;
    if attr == 1
        plotmse(out_computation_results.att_decod_a_fn, out_cfg.default_vec, [0, 1])
    elseif attr == 2
        plotmse(out_computation_results.att_decod_b_fn, out_cfg.default_vec, [0, 1])
    elseif attr == 3
        plotmse(out_computation_results.att_decod_c_fn, out_cfg.default_vec, [0, 1])
    end

    yline(50, ':k');
    figElements(attribute_figure, '', 'Time [ms]', 'Attr. Decod. Acc. [%]', [1, 50], [47, 70], [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);
  
    axis square
    box off
end

nexttile;
attribute_bar_info = {'Reasoning task', 'Attribute', 'Decoding accuracy_{\Delta} [pp]', [0.5, 3.5], [], 1:3, {'Limb', 'Hat', 'Shape'}, [], {}, 16, [], []};
plotBar(out_computation_results.att_peaks, attribute_bar_info, out_cfg.default_vec, out_cfg.default_vec, attribute_figure, 0, 0, 1, 1);
yline(0, ':k');
axis square
box off

print_ttest(out_computation_results.att_peaks(:, 1))
% 2.3225    0.9802         0       NaN    0.0249    2.3694   28.0000    0.4400
print_ttest(out_computation_results.att_peaks(:, 2))
% 2.8985    0.8101         0       NaN    0.0013    3.5780   28.0000    0.6644
print_ttest(out_computation_results.att_peaks(:, 3))
% 1.9615    0.5866         0       NaN    0.0024    3.3437   28.0000    0.6209

% ===========
% seq vals

main_figure = figure(711);
clf(main_figure);
set(main_figure, 'Name', 'Object-Operation-Output computation', 'Color', 'w');
tiledlayout(main_figure, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
hold on
swap_handle = plotmse(q_smooth(out_computation_results.seq_val.swap, 2, 1), out_cfg.swap_color, [0, 1]);
branch_handle = plotmse(q_smooth(out_computation_results.seq_val.branch, 2, 1), out_cfg.branch_color, [0, 1]);
yline(0, ':k');
yline(out_computation_results.seq_val.max_threshold, '--k');
yline(-out_computation_results.seq_val.max_threshold, '--k');
figElements(main_figure, 'Output Alignment', 'Lag [ms]', 'Output Alignment [a.u.]', [1, 19], [-0.02, 0.04], [1, 10, 19], {'Rep. ON', '100', '200'}, [], {}, 16, [], []);
legend([branch_handle, swap_handle], {'Branch', 'Swap'}, 'Location', 'best', 'Box', 'off');
axis square
box off

nexttile;
accuracy_values = fliplr(out_computation_results.seq_val.corr_incorr);
accuracy_figure_info = {'Output window: 110-120 ms', 'Trial accuracy', 'Output Alignment [z-scored]', [0.5, 2.5], [], 1:2, {'Correct', 'Incorrect'}, [], {}, 16, [], []};
plotBar(accuracy_values, accuracy_figure_info, out_cfg.swap_color, out_cfg.swap_color, main_figure, 0, 0, 1);
yline(0, ':k');
axis square
box off

print_ttest(accuracy_values(:, 1), 1, accuracy_values(:, 2))



% ==================
% input output signal
reactivation_figure = figure(712);

output_trace = out_computation_results.output .* 100;
input_trace  = out_computation_results.input .* 100;

output_handle = plotmse(output_trace, output_color, [0, 1]);
input_handle  = plotmse(input_trace, input_color, [0, 1]);

yline(0, ':k');

cluster = compute_cluster_stats(out_computation_results.out_in_stats(:, 1), out_computation_results.out_in_stats(:, 2:end), 95, 2);

significant_samples = isfinite(cluster.survived_mass_UB);
significance_line = nan(1, numel(out_computation_results.out_in_stats(:, 1), 1));
significance_line(significant_samples) = 1.75;
plot(significance_line, 'k', 'LineWidth', 2);

figElements(reactivation_figure, '', 'Time from replay onset [ms]', 'Reactivation_{\Delta} [%]', [1, numel(out_computation_results.out_in_stats(:, 1))], [-1, 2], [1, 51, 101], {'Onset', '100', '200'}, [], {}, 16, [], []);
legend([output_handle, input_handle], {'Output', 'Input'}, 'Location', 'southwest', 'Box', 'off');
axis square
box off


% =========
% beamform vals

curr = figure(713);
hippocampal_info = {{'Hippocampal ROI', '(Liu et al. 2019)'}, '', 'Voxel Activation [a.u.]', [0.5, 2.5], [-0.25, 0.6], 1:2, {'Rep. ON', 'Output'}, [], {}, 16, [], []};
plotBar(out_computation.beamform_vals, hippocampal_info, out_cfg.green_vec, out_cfg.swap_vec, hippocampal_figure, 0, 0, 1, 1);
yline(0, ':k');
axis square
box off

print_ttest(out_computation.beamform_vals(:, 1))
% 0.4995    0.1144         0       NaN    0.0002    4.3647   28.0000    0.8105
print_ttest(out_computation.beamform_vals(:, 2))
% 0.0925    0.0781         0       NaN    0.2459    1.1852   28.0000    0.2201

print_ttest(out_computation.beamform_vals(:, 2)-out_computation.beamform_vals(:, 1))

% ===========
% rsa vals

ou = compute_cluster_stats(out_computation_results.replay_locked_rsa_shuffle_val(:, 1), out_computation_results.replay_locked_rsa_shuffle_val(:, 2:end), 95, 2);

nexttile;
hold on
plotmse(out_computation_results.replay_locked_rsa, out_cfg.default_vec, [0, 1]);
yline(0, ':k');
main_rsa_significant = isfinite(ou.survived_len_UB);
main_rsa_significance_line = nan(1, size(out_computation_results.replay_locked_rsa, 2));
main_rsa_significance_line(main_rsa_significant) = 0.018;
plot(main_rsa_significance_line, 'k', 'LineWidth', 2);
figElements(main_figure, 'Replay onset', 'Time from replay onset [ms]', 'RSA betas [a.u.]', [1, size(out_computation_results.replay_locked_rsa, 2)], [-0.02, 0.025], [1, 126, 251, 376, 501], {'-300', '-50', '200', '450', '700'}, [], {}, 16, [], []);
axis square
box off



%% supplementary


% plot branch and swap together
curr=figure(7)
subplot(4, 11, 26:27)
plotmse(squeeze(out_computation_results.aux.swap_preds(:, 1, :))', out_cfg.branch_vec, [1, 1])
plotmse(squeeze(out_computation_results.aux.branch_preds(:, 1, :))', out_cfg.swap_vec, [0, 1]); hold on

plot([1, 1000], [0.5, 0.5], ':k')
figElements(curr, '', 'Time [ms]', 'Input Decod. Acc.', [125 1000], [.475, .55], [1, 250, 500, 750, 1000], {'', 'Stim ON', '500', '1000', '1500'}, [], {}, 18, [], [])

ou = compute_cluster_stats(squeeze(nanmean(out_computation_results.aux.diff_preds(:, 1, :), 3)), squeeze(nanmean(out_computation_results.aux.diff_preds(:, 2:end, :), 3)), 95, 2)

rel_vals = find(~isnan(ou.survived_mass_UB));
tmp_ub          = nan(1, size(ou.survived_mass_UB, 2));
tmp_ub(rel_vals) = 0.525;
plot(tmp_ub, 'linewidth', 2, 'color', 'k')

% decoding branch
ou = compute_cluster_stats(squeeze(nanmean(out_computation_results.aux.branch_preds(:, 1, :), 3)), squeeze(nanmean(out_computation_results.aux.branch_preds(:, 2:end, :), 3)), 95, 2)

rel_vals = find(~isnan(ou.survived_mass_UB));
tmp_ub          = nan(1, size(ou.survived_mass_UB, 2));
tmp_ub(rel_vals) = 0.52;
plot(tmp_ub, 'linewidth', 2, 'color', out_cfg.swap_vec)




% ==================== 
% rsa null

supplement_axes(3) = nexttile;
plotmse(out_computation_results.control_locked_rsa, out_cfg.control_color, [0, 1]);
yline(0, ':k');
figElements(supplement_figure, 'Control onset', 'Time from control onset [ms]', 'RSA betas [a.u.]', [1, size(out_computation_results.control_locked_rsa, 2)], [-0.02, 0.03], [1, 126, 251, 376, 501], {'-300', '-50', '200', '450', '700'}, [], {}, 16, [], []);
axis square
box off


% ==================
% swap - branch diff

diff_fig = figure(719);
subplot(2, 8, 1:2)
hold on
plotmse(out_computation_results.aux.diff, out_cfg.default_vec, [0, 1]);
yline(out_computation_results.aux.max_threshold, '--k');
yline(-out_computation_results.aux.max_threshold, '--k');
figElements(swap_branch_figure, 'Swap-Branch', 'Lag [ms]', 'Output Alignment [a.u.]', [], [-0.02, 0.04], [], {}, [], {}, 24, [], []);


% ==================== 
% attribute vals

plot_dat = [out_computation_results.aux.p_start_attr(:, 1), out_computation_results.aux.p_end_attr(:, 1), ...
            out_computation_results.aux.p_start_attr(:, 2), out_computation_results.aux.p_end_attr(:, 2), ...
            out_computation_results.aux.p_start_attr(:, 3), out_computation_results.aux.p_end_attr(:, 3)];

colStart = [84, 161, 140] ./ 255;

curr = figure();
figInfo = {'Face Attributes', 'Attribute / position', 'Attribute Probability', [], [0, 65], 1:6, {'A1_{Start}', 'A1_{End}', 'A2_{Start}', 'A2_{End}', 'A3_{Start}', 'A3_{End}'}, [], {}, 24, [], []};

plot([0, 7], [50, 50], ':k'); hold on
plotBar(plot_dat * 100, figInfo, colStart, colStart, curr, 0, 0, 0, 0);


% ===================
% across run sim 

curr = figure(6)
plotmse(squeeze(out_computation_results.aux.cross_run_only(1, :, :))', out_cfg.default_vec, [0, 1]);
yline(0, ':k');

empir_val = squeeze(out_computation_results.aux.cross_run_only_empir);
null_val  = squeeze(out_computation_results.aux.cross_run_only_null);

cluster = compute_cluster_stats(empir_val', squeeze(null_val)', 95, 2);

significant = false(1, size(empir_val, 2));
significant = significant | cluster.survived_len_UB(:)' == 1;

significance_line = nan(1, size(empir_val, 2));
significance_line(significant) = .021;
plot(significance_line, 'Color', out_cfg.default_vec, 'LineWidth', 1.5);

figElements(curr, 'Across Run Similarity', 'Time [ms]', 'RSA Betas [a.u.]', [1, size(empir_val, 2)], [-.02, .03], [126, 251, 376, 501], {'-250', 'Rep. ON', '250', '500'}, [], {}, 16, [], []);


end
