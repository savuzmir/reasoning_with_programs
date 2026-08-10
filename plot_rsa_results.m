function results = plot_rsa_results()

% load prelims data

out_cfg = load_config_info();

rsa_struct = load('...\data\rsa_results.mat');

%======================================================
%% main 

main_fig = figure(771);
clf(main_fig);
set(main_fig, 'Color', 'w');

subplot(2, 3, 1);
out_cfg.col_val = out_cfg.default_vec;
results.main.B = plot_rsa_message_passing_results(rsa_struct.pr_sim, out_cfg.rsa_start_window, 1, out_cfg, 1, main_fig);
title('Reasoning Start');

subplot(2, 3, 2);
out_cfg.col_val = out_cfg.default_vec;
results.main.C = plot_rsa_message_passing_results(rsa_struct.pr_sim, out_cfg.rsa_end_window, 1, out_cfg, 2, main_fig);
title('Reasoning End');

program_object = [rsa_struct.betas(:, 1), rsa_struct.betas(:, 2)];

subplot(2, 3, 3);
bar_info = {'Reasoning End', 'Similarity', 'RSA Betas [a.u.]', [.5, 2.5], [-.02, .04], 1:2, {'Program', 'Object'}, [], {}, 18, [], []};
plotBar(program_object, bar_info, out_cfg.default_vec, out_cfg.default_vec, main_fig, 0, 0, 1);
yline(0, ':k');

print_ttest(program_object(:, 1))
% 0.0166    0.0058         0       NaN    0.0075    2.8811   28.0000    0.5350
print_ttest(program_object(:, 2))
% -0.0113    0.0053         0       NaN    0.0444   -2.1054   28.0000   -0.3910
print_ttest(program_object(:, 1)-program_object(:, 2))
% 0.0166    0.0058   -0.0113    0.0053    0.0156    2.5763   28.0000    0.4784

subplot(2, 3, 4);
out_cfg.col_val = out_cfg.orange_vec;
results.main.E = plot_rsa_message_passing_results(rsa_struct.sh_sim, out_cfg.rsa_shallow_window, 1, out_cfg, 1, main_fig);
plot(squeeze(nanmean(c_container(subject_ids, out_cfg.rsa_shallow_window, 1, 1), 1)), 'color', min(out_cfg.purple_vec + .15, 1));
title('Reasoning Start');
shallow_legend = plot(nan, nan, 'Color', out_cfg.orange_vec, 'LineWidth', 1.5);
deep_legend = plot(nan, nan, 'Color', min(out_cfg.purple_vec + .15, 1), 'LineWidth', 1.5);
legend([shallow_legend, deep_legend], {'Shallow', 'Deep'}, 'Location', 'best');
legend box off;

subplot(2, 3, 5); % axis labels need to be changed
out_cfg.col_val = out_cfg.purple_vec;
results.main.F = plot_rsa_message_passing_results(rsa_struct.dp_sim, out_cfg.rsa_deep_window, 1, out_cfg, 2, main_fig);
plot(squeeze(nanmean(e_container(subject_ids, out_cfg.rsa_deep_window, 1, 2), 1)), 'color', min(out_cfg.orange_vec + .15, 1));
title('Reasoning End');
shallow_legend = plot(nan, nan, 'Color', min(out_cfg.orange_vec + .15, 1), 'LineWidth', 1.5);
deep_legend = plot(nan, nan, 'Color', out_cfg.purple_vec, 'LineWidth', 1.5);
legend([shallow_legend, deep_legend], {'Shallow', 'Deep'}, 'Location', 'best');
legend box off;

subplot(2, 3, 6);
axis off;

%======================================================
%% supplementary

accuracy_median = median(rsa_struct.beh_acc, 'omitnan');
high = mean_accuracy > accuracy_median;
low = mean_accuracy <= accuracy_median;

split_fig = figure(772);
clf(split_fig);
set(split_fig, 'Name', 'RSA split by participant accuracy', 'Color', 'w');

subplot(2, 2, 1);
out_cfg.col_val = out_cfg.default_vec;
results.accuracy_split.start.high = plot_rsa_message_passing_results(rsa_struct.pr_sim(high, :, :, :), out_cfg.rsa_start_window, 1, out_cfg, 1, split_fig);
out_cfg.col_val = out_cfg.gray_vec;
results.accuracy_split.start.low = plot_rsa_message_passing_results(rsa_struct.pr_sim(low, :, :, :), out_cfg.rsa_start_window, 1, out_cfg, 1, split_fig);
title('Reasoning Start');
high_legend = plot(nan, nan, 'Color', out_cfg.default_vec, 'LineWidth', 1.5);
low_legend = plot(nan, nan, 'Color', out_cfg.gray_vec, 'LineWidth', 1.5);
legend([high_legend, low_legend], {'High Accuracy', 'Low Accuracy'}, 'Location', 'best');
legend box off;

subplot(2, 2, 2);
out_cfg.col_val = out_cfg.default_vec;
results.accuracy_split.end.high = plot_rsa_message_passing_results(rsa_struct.pr_sim(high, :, :, :), out_cfg.rsa_end_window, 1, out_cfg, 2, split_fig);
out_cfg.col_val = out_cfg.gray_vec;
results.accuracy_split.end.low = plot_rsa_message_passing_results(rsa_struct.pr_sim(low, :, :, :), out_cfg.rsa_end_window, 1, out_cfg, 2, split_fig);
title('Reasoning End');
high_legend = plot(nan, nan, 'Color', out_cfg.default_vec, 'LineWidth', 1.5);
low_legend = plot(nan, nan, 'Color', out_cfg.gray_vec, 'LineWidth', 1.5);
legend([high_legend, low_legend], {'High Accuracy', 'Low Accuracy'}, 'Location', 'best');
legend box off;

subplot(2, 2, 3);
out_cfg.col_val = out_cfg.orange_vec;
results.accuracy_split.shallow.high = plot_rsa_message_passing_results(rsa_struct.sh_sim(high, :, :, :), out_cfg.rsa_start_window, 1, out_cfg, 1, split_fig);
out_cfg.col_val = min(out_cfg.orange_vec + .15, 1);
results.accuracy_split.shallow.low = plot_rsa_message_passing_results(rsa_struct.sh_sim(low, :, :, :), out_cfg.rsa_start_window, 1, out_cfg, 1, split_fig);
title('Reasoning Start | Shallow');
high_legend = plot(nan, nan, 'Color', out_cfg.orange_vec, 'LineWidth', 1.5);
low_legend = plot(nan, nan, 'Color', min(out_cfg.orange_vec + .15, 1), 'LineWidth', 1.5);
legend([high_legend, low_legend], {'High Accuracy', 'Low Accuracy'}, 'Location', 'best');
legend box off;

subplot(2, 2, 4);
out_cfg.col_val = out_cfg.purple_vec;
results.accuracy_split.deep.high = plot_rsa_message_passing_results(rsa_struct.dp_sim(high, :, :, :), out_cfg.rsa_end_window, 1, out_cfg, 2, split_fig);
out_cfg.col_val = min(out_cfg.purple_vec + .15, 1);
results.accuracy_split.deep.low = plot_rsa_message_passing_results(rsa_struct.dp_sim(low, :, :, :), out_cfg.rsa_end_window, 1, out_cfg, 2, split_fig);
title('Reasoning End | Deep');
high_legend = plot(nan, nan, 'Color', out_cfg.purple_vec, 'LineWidth', 1.5);
low_legend = plot(nan, nan, 'Color', min(out_cfg.purple_vec + .15, 1), 'LineWidth', 1.5);
legend([high_legend, low_legend], {'High Accuracy', 'Low Accuracy'}, 'Location', 'best');
legend box off;

% corrrect incorrect

condition_fig = figure(774);
clf(condition_fig);
set(condition_fig, 'Name', 'RSA on correct and incorrect trials', 'Color', 'w');

subplot(1, 3, 1:2);
all_line = plotmse(rsa_struct.pr_sim(:, out_cfg.rsa_end_window, 1, 2), out_cfg.default_vec, [0, 1]);
hold on
correct_line = plotmse(rsa_struct.correct_ts, out_cfg.gray_vec, [0, 1]);
tp_vals = [find(out_cfg.rsa_end_window == 150), find(out_cfg.rsa_end_window == 200), find(out_cfg.rsa_end_window == 250), find(out_cfg.rsa_end_window == 300)];
figElements(condition_fig, '', 'Time [ms]', 'RSA Betas [a.u.]', [1, length(out_cfg.rsa_end_window)], [-0.02, 0.04], tp_vals, {'-1500', '-1000', '-500', 'Stim OFF'}, [], {}, 18, [], []);
plot([1, length(out_cfg.rsa_end_window)], [0, 0], ':k');
legend([all_line, correct_line], {'All', 'Correct'}, 'Location', 'best');
legend box off

rsa_vals = [rsa_struct.correct_roi, rsa_struct.incorrect_roi];

subplot(1, 3, 3);
bar_info = {'Program Similarity', 'Trials', 'RSA Betas [z-scored]', [.5, 2.5], [], 1:2, {'Incorrect', 'Correct'}, [], {}, 18, [], []};
plotBar(rsa_vals, bar_info, out_cfg.default_vec, out_cfg.default_vec, condition_fig, 0, 0, 0);

end
