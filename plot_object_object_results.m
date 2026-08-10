function out = plot_object_object_results()

% load prelims

out_cfg = load_config_info();
out_all_object = load('...\data\object_fig_results.mat');

%% prepare data

correct       = nan(out_cfg.n_trial, out_cfg.n_lag, out_cfg.n_perm, out_cfg.n_sub);
incorrect     = nan(out_cfg.n_trial, out_cfg.n_lag, out_cfg.n_perm, out_cfg.n_sub);

correct_corr = correct;
correct_incorr = correct;

mean_accuracy = [out_all_object.out_object_results(:).tot_acc];
thinking_time = [out_all_object.out_object_results(:).thinking_time];

for s = 1:out_cfg.n_sub

    co = out_all_object.out_object_results(s).corr_path;
    in = out_all_object.out_object_results(s).incorr_path;

    entropy = out_all_object.out_object_results(s).trial_entrop;
    remove = find(entropy < out_cfg.entrop_thresh);

    co(co == 0) = nan;
    in(in == 0) = nan;
    co(remove, :, :) = nan;
    in(remove, :, :) = nan;

    correct(1:size(co, 1), :, :, s) = co;
    incorrect(1:size(in, 1), :, :, s) = in;

    %
    remove = out_all_object.out_object_results(s).trial_acc > 0;
    corr_co = co;
    incorr_co = co;
    corr_co(~remove, :, :) = nan;
    incorr_co(remove, :, :) = nan;
    correct_corr(1:size(co, 1), :, :, s) = corr_co;
    correct_incorr(1:size(in, 1), :, :, s) = incorr_co;

end

%% stats

print_ttest(squeeze(nanmean(nanmean(correct(:, out_cfg.peak_lags, 1, :), 2), 1)))
% -0.0019    0.0006         0       NaN    0.0040   -3.1364   28.0000   -0.5824

print_ttest(correct_z) % without entropy-removal
% -0.7269    0.1921         0       NaN    0.0007   -3.7834   28.0000   -0.7026

corr_co_z   = zscore_null(squeeze(nanmean(nanmean(correct_corr(:, out_cfg.peak_lags, :, :), 2), 1))');
incorr_co_z = zscore_null(squeeze(nanmean(nanmean(correct_incorr(:, out_cfg.peak_lags, :, :), 2), 1))');

print_ttest(corr_co_z)
%  -0.7475    0.1963         0       NaN    0.0007   -3.8070   28.0000   -0.7069
print_ttest(incorr_co_z)
% 0.0260    0.2471         0       NaN    0.9170    0.1052   26.0000    0.0203

print_ttest(corr_co_z-incorr_co_z)
% -0.7797    0.3424         0       NaN    0.0312   -2.2774   26.0000   -0.4383

accuracy_median = median(tot_acc, 'omitnan');
high_accuracy = mean_accuracy > accuracy_median;
low_accuracy = mean_accuracy <= accuracy_median;

corr_z = zscore_null(squeeze(nanmean(nanmean(correct(:, out_cfg.peak_lags, :, :), 2), 1))');
incorr_z = zscore_null(squeeze(nanmean(nanmean(incorrect(:, out_cfg.peak_lags, :, :), 2), 1))');

corr_z_high   = corr_z(high_accuracy);
corr_z_low    = corr_z(low_accuracy);
incorr_z_high = incorr_z(high_accuracy);
incorr_z_low  = incorr_z(low_accuracy);

print_ttest(corr_z_high)
% -0.8100    0.2844         0       NaN    0.0137   -2.8478   13.0000   -0.7611

print_ttest(corr_z_low)
% -0.6553    0.2874         0       NaN    0.0388   -2.2800   14.0000   -0.5887


print_ttest(incorr_z_high)
% 0.1259    0.3315         0       NaN    0.7103    0.3796   13.0000    0.1015

print_ttest(incorr_z_low)
% -0.9140    0.2879         0       NaN    0.0067   -3.1751   14.0000   -0.8198

print_ttest(incorr_z_high, 2, incorr_z_low)
% 0.1259    0.3315   -0.9140    0.2879    0.0248    2.3774   27.0000    0.8835

%% main values

object_labels = arrayfun(@(x) sprintf('Obj_{%02d}', x), 1:12, 'UniformOutput', false);
chance_percent = 100 ./ 12;
decoder_ticks = [1, 15, 30, 50];

figs.main = figure('Name', 'Object-object manuscript result panels', 'Color', 'w', 'Position', [40, 40, 1800, 850]);

subplot(2, 14, 1:3)
plotmse(q_smooth(out_all_object.out_obj_decod_results .* 100, out_cfg.smooth_param, 1), out_cfg.default_vec, [0, 1]);
yline(chance_percent, ':k');
figElements(figs.main, 'Functional Localizer', 'Time [ms]', 'Object Decoding Accuracy [%]', [], [5, 30], decoder_ticks, {'Stim ON', '150', '300', '500'}, [], {}, 14, [], []);
axis square
box off

subplot(2, 14, 4:8)
imagesc(out_all_object.out_obj_decod_results_cm);
caxis([chance_percent - 1, chance_percent + 5]);
axis square
colormap(figs.main, out_cfg.curr_palette);
decoder_colorbar = colorbar;
decoder_colorbar.Label.String = 'Object Decoding Accuracy [%]';
figElements(figs.main, 'Functional-localizer Confusion', 'Predicted Object', 'Presented Object', [.5, 12.5], [.5, 12.5], 1:12, object_labels, 1:12, object_labels, 11, [], []);

lag_correct = smooth_tdlm_lags(permute(squeeze(mean(correct, 1, 'omitnan')), [3, 1, 2]), out_cfg.lag_smooth);

subplot(2, 14, 9:11)
plot_tdlm_fb(lag_correct, figs.main, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
box off
figElements(figs.main, 'Correct Path', 'Object-Object Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.004, .006], [1, 10, 20], {'0', '100', '200'}, [], {}, 14, [], []);
axis square

subplot(2, 14, 12:14)
trial_outcome_info = {'Within Participants', 'Trial Accuracy', 'Sequenceness [z-scored]', [.5, 2.5], [-1.1, .5], 1:2, {'Correct', 'Incorrect'}, [], {}, 14, [], []};
plotBar([corr_co_z, incorr_co_z], trial_outcome_info, out_cfg.green_vec, out_cfg.green_vec, figs.main, 0, 0, 1, 1);
yline(0, ':k');
axis square
box off

subplot(2, 14, 18:20)
high_path_info = {'High Accuracy', 'Path', 'Sequenceness [z-scored]', [.5, 2.5], [-1.3, .5], 1:2, {'Correct', 'Incorrect'}, [], {}, 14, [], []};
plotBar([corr_z(high_accuracy), incorr_z(high_accuracy)], high_path_info, out_cfg.green_vec, out_cfg.gray_vec, figs.main, 0, 0, 1, 1);
yline(0, ':k');
axis square
box off

subplot(2, 14, 21:23)
low_path_info = {'Low Accuracy', 'Path', 'Sequenceness [z-scored]', [.5, 2.5], [-1.3, .5], 1:2, {'Correct', 'Incorrect'}, [], {}, 14, [], []};
plotBar([corr_z(low_accuracy), incorr_z(low_accuracy)], low_path_info, out_cfg.green_vec, out_cfg.gray_vec, figs.main, 0, 0, 1, 1);
yline(0, ':k');
axis square
box off

depth_replay = out_all_object.aux.depth_replay_correct;

subplot(2, 14, 24:28)
depth_info = {'', 'Program Depth', 'Sequenceness [z-scored]', [.5, 2.5], [-.75, .2], 1:2, {'Shallow', 'Deep'}, [], {}, 14, [], []};
plotBar(depth_replay, depth_info, out_cfg.orange_vec, out_cfg.purple_vec, figs.main, 0, 0, 1, 1);
yline(0, ':k');
axis square
box off

%% supplementary figs

figs.supplementary = figure('Name', 'Object-object supplementary panels b-i', 'Color', 'w', 'Position', [50, 50, 1650, 1050]);

trial_acc = {};
for k = 1:29
    trial_acc{k} = out_all_object.out_object_results(k).trial_acc;
end

[correct_trials, incorrect_trials] = object_object_split_trials(correct, trial_acc);
correct_trial_z   = object_object_subject_z(correct_trials, out_cfg.peak_lags);
incorrect_trial_z = object_object_subject_z(incorrect_trials, out_cfg.peak_lags);
trial_outcome_z   = [correct_trial_z, incorrect_trial_z];

lag_correct_trials = smooth_tdlm_lags(permute(squeeze(mean(correct_trials, 1, 'omitnan')), [3, 1, 2]), out_cfg.lag_smooth);
lag_incorrect_trials = smooth_tdlm_lags(permute(squeeze(mean(incorrect_trials, 1, 'omitnan')), [3, 1, 2]), out_cfg.lag_smooth);

figs.trial_lags = figure('Name', 'Correct-path replay by trial outcome', 'Color', 'w');

% b: incorrect-path replay and thinking time
subplot(4, 12, 1:6)
scatterfit(incorr_z, thinking_time', 1, figs.supplementary, out_cfg.gray_vec);
axis square
figElements(figs.supplementary, 'Incorrect Paths', 'Sequenceness [z-scored]', 'Thinking Time [sec]', [-3.5, 3], [9, 21.5], [], {}, [], {}, 14, [], []);
text(-.10, 1.08, 'b', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

% c: behavioural accuracy by question depth
subplot(4, 12, 7:12)
hold on

question_depth_info = {'', 'Question Depth', 'Accuracy [%]', [.5, 2.5], [0, 105], 1:2, {'Shallow', 'Deep'}, [], {}, 14, [], []};
plotBar(out_all_object.aux.question_depth_acc, question_depth_info, out_cfg.orange_vec, out_cfg.purple_vec, figs.supplementary, [0, .975], 1, 1);

yline(50, ':k');
text(-.10, 1.08, 'c', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);
box off

% d: shallow/deep replay during early and late task halves
subplot(4, 12, 13:16)
session_depth_info = {'', 'Program Depth', 'Sequenceness [z-scored]', [.5, 4.5], [-.75, .2], 1:4, {'Shallow', 'Deep', 'Shallow', 'Deep'}, [], {}, 14, [], []};
plotBar(out_all_object.aux.session_depth_replay_joint, session_depth_info, out_cfg.orange_vec, out_cfg.purple_vec, figs.supplementary, 0, 0, 1);
yline(0, ':k');
text(1.5, -.68, 'Early Blocks', 'HorizontalAlignment', 'center', 'FontSize', 10);
text(3.5, -.68, 'Late Blocks', 'HorizontalAlignment', 'center', 'FontSize', 10);
text(-.18, 1.08, 'd', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

% e: behavioural accuracy across the session
subplot(4, 12, 17:20)
end_handle = plotmse(out_all_object.aux.block_accuracy_end, out_cfg.end_vec, [0, 1]);
hold on
path_handle = plotmse(out_all_object.aux.block_accuracy_path, out_cfg.path_vec, [0, 1]);
yline(50, ':k');
figElements(figs.supplementary, 'Accuracy Across Session', 'Blocks', 'Accuracy [%]', [1, 8], [45, 100], 1:8, {'1', '2', '3', '4', '5', '6', '7', '8'}, [], {}, 14, [], []);
legend([end_handle, path_handle], {'END', 'PATH'}, 'Box', 'off', 'Location', 'best');
text(-.18, 1.08, 'e', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

indiv_vals = [];

for s = 1:out_cfg.n_sub

    for k = [0, 1, 2]

    co = out_all_object.out_object_results(s).corr_path;
    entropy = out_all_object.out_object_results(s).trial_entrop;
    remove = find(entropy < out_cfg.entrop_thresh);
    co(co == 0) = nan;
    co(remove, :, :) = nan;        

    remove = out_all_object.out_object_results(s).trial_acc ~= k;
    co(remove, :, :) = nan;
    indiv_vals(:, 2 - k+1, s) = zscore_null(squeeze(nanmean(nanmean(co(:, out_cfg.peak_lags, :), 2), 1))');

    end

end

% f: correct-path replay by trial accuracy
subplot(4, 12, 21:24)
correct_accuracy_info = {'Within Participants', 'Trial Accuracy', 'Sequenceness [z-scored]', [.5, 3.5], [-1.1, .5], 1:3, {'2/2', '1/2', '0/2'}, [], {}, 14, [], []};
plotBar(squeeze(indiv_vals)', correct_accuracy_info, out_cfg.green_vec, out_cfg.green_vec, figs.supplementary, 0, 0, 1);
yline(0, ':k');
text(-.18, 1.08, 'f', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

% g: correct-path lag profiles on correct and incorrect trials
subplot(4, 12, 25:26)
plot_tdlm_fb(lag_correct_trials, figs.supplementary, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
box off
figElements(figs.supplementary, 'Correct trials', 'Object-Object Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.005, .01], [1, 10, 20], {'0', '100', '200'}, [], {}, 12, [], []);
text(-.28, 1.08, 'g', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

subplot(4, 12, 27:28)
plot_tdlm_fb(lag_incorrect_trials, figs.supplementary, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
box off
figElements(figs.supplementary, 'Incorrect trials', 'Object-Object Lag [ms]', '', [1, 20], [-.02, .01], [1, 10, 20], {'0', '100', '200'}, [], {}, 12, [], []);

% h: replay-strength correlations with behavioural accuracy
subplot(4, 12, 29:30)
scatterfit(corr_z, mean_accuracy' .* 100, 1, figs.supplementary, out_cfg.green_vec);
axis square
figElements(figs.supplementary, 'Correct Path', 'Sequenceness [z-scored]', 'Accuracy [%]', [-3.5, 2], [60, 100], [], {}, [], {}, 12, [], []);
text(-.28, 1.08, 'h', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

subplot(4, 12, 31:32) % vals in ms are pearson not spearman
scatterfit(incorr_z, mean_accuracy' .* 100, 1, figs.supplementary, out_cfg.gray_vec);
axis square
figElements(figs.supplementary, 'Incorrect Paths', 'Sequenceness [z-scored]', '', [-3.5, 2], [60, 100], [], {}, [], {}, 12, [], []);

% i: incorrect-path replay by trial accuracy
subplot(4, 12, 33:36)
incorrect_accuracy_info = {'Within Participants', 'Trial Accuracy', 'Sequenceness [z-scored]', [.5, 3.5], [-1.1, .5], 1:3, {'2/2', '1/2', '0/2'}, [], {}, 14, [], []};
plotBar(out_all_object.aux.incorr_indiv', incorrect_accuracy_info, out_cfg.gray_vec, out_cfg.gray_vec, figs.supplementary, 0, 0, 1);
yline(0, ':k');
text(-.18, 1.08, 'i', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);

subplot(4, 12, 37:40)
depth_start_info = {'Across Participants', 'Depth from Start', 'Sequenceness [z-scored]', [], [-.08, .08], 1:4, {'Close', 'Far', 'Close', 'Far'}, [], {}, 14, [], []};
plotBar_dotted(out_all_object.aux.depth_incorr, depth_start_info, out_cfg.gray_vec, out_cfg.gray_vec, figs.supplementary, 0, 0, 0, 'dottedBars', [3, 4]);
yline(0, ':k');
hold on
low_handle = plot(nan, nan, 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
high_handle = plot(nan, nan, 'Color', 'k', 'LineStyle', '-', 'LineWidth', 1.5);
legend([low_handle, high_handle], {'Low. Acc.', 'High Acc.'}, 'Box', 'off', 'Location', 'best');
text(-.18, 1.08, 'j', 'Units', 'normalized', 'FontWeight', 'bold', 'FontSize', 18);


end
