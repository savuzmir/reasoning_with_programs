function out = plot_object_role_results()

% load prelims and data 

out_cfg = load_config_info();
out_op_results = load('out_op_results.mat');

%% beh corr plots

mean_probe_effect = squeeze(mean(mean(out_op_results.beh.acc_per_role([1, 3], :, :), 2, 'omitnan'), 1, 'omitnan')) .* 100;
mean_role_effect = squeeze(mean(out_op_results.beh.role_acc_per_role(:, 1, :), 1, 'omitnan')) .* 100;

[behavior_rho, behavior_p] = partialcorr(mean_probe_effect, mean_role_effect, out_op_results.beh.func_role_acc, 'Type', 'Spearman');

curr = figure(7)
nexttile;
scatterfit(mean_probe_effect, mean_role_effect, 1);
hold on
plot([50, 100], [50, 100], ':k');
figElements(curr, sprintf('Partial \\rho = %.2f, p = %.3g', behavior_rho, behavior_p), 'Reasoning Accuracy [%]', 'Role Localizer Accuracy [%]', [50, 100], [50, 100], [], {}, [], {}, 16, [], []);
axis square
box off

%% decoder plots 

% decoder fig
decoder_fig = figure(706);
tiledlayout(decoder_fig, 1, 4, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot_loc_fig_stat_panel(decoder_fig, out_op_results.type_decod(:, 1, :) * 100, out_op_results.type_decod(:, 2:end, :) * 100, out_cfg, 1/2, 52.5, [48.5, 54], out_cfg.default_vec);
figElements(decoder_fig, 'Type Code', 'Time [ms]', 'Op. Decod. Acc. [%]', [1, 50], [48.5, 54], [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);
box off

nexttile;
plot_loc_fig_stat_panel(decoder_fig, out_op_results.att_decod(:, 1, :) * 100, out_op_results.att_decod(:, 2:end, :) * 100, out_cfg, 1/3, 37, [32, 38], out_cfg.default_vec);
figElements(decoder_fig, 'Attribute Code', 'Time [ms]', 'Op. Decod. Acc. [%]', [1, 50], [32, 38], [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);
box off

nexttile;

% get crosval peaks - crosval wind locked to 300 msec after
rt_resp_tp   = out_op_results.rt_type_decod_resp;
rt_resp_att  = out_op_results.rt_att_decod_resp;
rt_on_tp     = out_op_results.rt_type_decod_mn;
rt_on_att    = out_op_results.rt_att_decod_mn;

[crosval_pred_tp_resp, tp_x]    = compute_crosval_acc(rt_resp_tp (out_cfg.crosval_wind, :)-1/2);
[crosval_pred_att_resp, at_x] = compute_crosval_acc(rt_resp_att (out_cfg.crosval_wind, :));

[crosval_pred_tp_mn, tp_x]    = compute_crosval_acc(rt_on_tp(out_cfg.crosval_wind, :));
[crosval_pred_att_mn, at_x] = compute_crosval_acc(rt_on_att(out_cfg.crosval_wind, :));

joint_acc_vals = [nanmean([crosval_pred_tp_mn', crosval_pred_tp_resp'], 2), nanmean([crosval_pred_att_mn', crosval_pred_att_resp'], 2)];
[a,b,c,d]=ttest(joint_acc_vals)
% 3.23, p = 0.003, 3.70, p = 0.0009
% 
reasoning_bar_info = {'Reasoning Task', 'Representation', 'Op. Decod. Acc_{\Delta} [%]', [.5, 2.5], [], 1:2, {'Type', 'Attribute'}, [], {}, 16, [], []};
plotBar(joint_acc_vals .* 100, reasoning_bar_info, dark_gray, dark_gray, curr, 0, 0, 1, 1);
axis square


%% role plots
% =============================
% sig lags vs. independent lags

full_rp_tp   = [];

for k = 1:29
    foo = out_op_results.loc_tp_rep(:, :, :, k);
    rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;
    all = find(out_op_results.trial_acc{k} < 2);
    foo(all, :, :) = nan;
    full_rp_tp(:, :, k) = squeeze(nanmean(foo));
end

% take held out lags from a and test them on b
f = zscore_null(permute(full_rp_tp, [3, 1, 2]))';

orig_tp = [];
tp_lags =[];
for i = 1:29
    train = setdiff(1:29, i);
    [a,b,c,d]=ttest(f(:, train)');
    rel_idx = find(b<.05 & d.tstat > 0)';
    rel_idx(rel_idx>10) = [];
    tp_lags{i} = rel_idx;
    orig_tp(i) = nanmean(f(rel_idx, i));
end

print_ttest(orig_tp)
% 0.5457    0.1689         0       NaN    0.0032    3.2308   27.0000    0.6106

% do the opposite
full_rp_att = [];

for k = 1:29
    foo = out_op_results.loc_att_rep(:, :, :, k);
    rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;
    all = find(out_op_results.trial_acc{k} < 2);
    foo(all, :, :) = nan;
    full_rp_att(:, :, k) = squeeze(nanmean(foo));
end

% take held out lags from a and test them on b
f = zscore_null(permute(full_rp_att, [3, 1, 2]))';

att_lags = [];
orig_att = [];
for i = 1:29
    train = setdiff(1:29, i);
    [a,b,c,d]=ttest(f(:, train)');
    rel_idx = find(b<.05 & d.tstat > 0)';
    rel_idx(rel_idx>10) = [];
    att_lags{i} = rel_idx;
    orig_att(i) = nanmean(f(rel_idx, i));
end

print_ttest(orig_att)
% 0.4737    0.1774         0       NaN    0.0125    2.6695   28.0000    0.4957

% generate null
f = zscore_null(permute(full_rp_att, [1, 3, 2]));

att_test =[];
for i = 1:29
    att_test(i) = nanmean(f(tp_lags{i}, i, 1));
end

f = zscore_null(permute(full_rp_tp, [1, 3, 2]));

tp_test = [];
for i = 1:29
    tp_test(i) = nanmean(f(att_lags{i}, i, 1));
end

print_ttest(nanmean([orig_tp', orig_att'], 2))
% 0.5072    0.1283         0       NaN    0.0005    3.9542   28.0000    0.7343

print_ttest(nanmean([orig_tp', orig_att'], 2)-nanmean([att_test', tp_test'], 2))
% 0.4146    0.1794         0       NaN    0.0284    2.3105   28.0000    0.4290

predicted = orig_tp + orig_att;
control = att_test + tp_test;

% on held out bars
curr = figure(7)

subplot(3, 9, 1:2)
figInfo = {'Independent ', 'Reactivation', 'Sequenceness [z-scored]', [-0.2, 3.2], [-0.2, 1], [1, 2], {'Type', 'Attribute', '', ''}, [], {}, 12, [], []};
plotBar([orig_tp', orig_att'], figInfo, out_cfg.green_vec + .15, out_cfg.green_vec - .15, curr, 0, 0, 1, 1); axis square
subplot(3, 8, 4:5)
figInfo = {'', 'Lag', 'Sequenceness [z-scored]', [-0.2, 3.2], [-0.2, 1], [1, 2], {'Predicted', 'Control', '', ''}, [], {}, 12, [], []};
plotBar([predicted'./2, control'./2], figInfo, out_cfg.green_vec, out_cfg.default_vec, curr, 0, 0, 1, 1); axis square

% compute lag distribution and build shuffle distribution

% compute-out-of-sample lag prediction
cv_lags_perm = {};

for k = 1:2

    if k == 1
        tmp = full_rp_att;
    else
        tmp = full_rp_tp;
    end

    for np = 1:1000

        t = permute(tmp, [1, 3, 2]);
        t_v = t(:, :, np);
        t(:, :, np) = t(:, :, 1);
        t(:, :, 1)  = t_v;

        foo = zscore_null(t);

        for i = 1:29
            train = setdiff(1:29, i);
            [~,b,~,d]=ttest(foo(:, train)');
            rel_idx = find(b<.05 & d.tstat > 0)'; 
            rel_idx(rel_idx>10) = [];
            cv_lags_perm{i, k, np} = rel_idx;
        end
    end
end

rel_p = 1;

K = 20;                                
[S,C,P] = size(cv_lags_perm);
edges = 0.5:1:(K+0.5);
x = 1:K;

% ----- gather all lags into one vector -----
v_real = [];
for s = 1:29
    for c = 2 % need to update to plot both
        xrc = cv_lags_perm{s, c, 1};
        if ~isempty(xrc)
            xrc = xrc(~isnan(xrc) & xrc>=1 & xrc<=K);
            v_real = [v_real; round(xrc(:))];
        end
    end
end

m_real = numel(v_real);
counts_real = histcounts(v_real, edges);

circular = 0;

% ----- collapse per permutation -----
counts_null = zeros(P, K);
D_null      = nan(P,1);
MPD_null    = nan(P,1);
m_null      = zeros(P,1);

for p = 1:1000
    v = [];
    for s = 1:S
        for c = 2 % 1:1
            xpc = cv_lags_perm{s,c,p};
            if ~isempty(xpc)
                xpc = xpc(~isnan(xpc) & xpc>=1 & xpc<=K);
                v = [v; round(xpc(:))];
            end
        end
    end
    m = numel(v);
    m_null(p) = m;
    counts_null(p,:) = histcounts(v, edges);
    if m > 0
        pp = counts_null(p,:) / m;
        D_null(p) = sum(pp.^2);
        if m >= 2
            v = v(:);
            Dm = abs(v - v.');
            if circular
                Dm = min(Dm, K - Dm);
            end
            MPD_null(p) = mean(Dm(triu(true(m),1)));
        end
    end
end

p_lag = nan(1,K);
for k = 1:K
    nullk = counts_null(:,k);
    p_lag(k) = (1 + sum(nullk >= counts_real(k))) / (1 + P);
end

curr = figure(6)
mu = mean(counts_null,1);
lo = prctile(counts_null, 1, 1);
hi = prctile(counts_null, 95, 1);

curr=figure(3); hold on;
b = bar(x, counts_real, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', out_cfg.green_vec + 0.15);

plot([1, 20], [max(hi), max(hi)], '--', 'color', out_cfg.green_vec + 0.15); hold on
figElements(curr, '', 'Lag', 'Cross-validated Counts', [0, 19], [], [0, 10, 19, 30, 40, 50, 60], {'0', '100', '200', '300', '400', '500', '600'}, [], {}, 16, [], []); 




% ===========
% seq plots 

% loc-tp-att
full_rp   = [];
corr_rp   = [];
incorr_rp = [];

for k = 1:29
    foo = out_op_results.loc_tp_att_rep(:, :, :, k);

    rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;

    all = find(out_op_results.trial_acc{k} < 0);
    ir = out_op_results.trial_acc{k} < 1;
    cr = ~ir;

    full_rp(:, :, k) = squeeze(nanmean(foo));
    corr_rp(:, :, k) = squeeze(nanmean(foo(cr, :, :), 1));
    incorr_rp(:, :, k) = squeeze(nanmean(foo(ir, :, :), 1));
end


curr = figure(6)
plot_tdlm_fb(average_lag_neighbors(permute(full_rp, [3, 1, 2]), 2), curr, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
figElements(curr, 'Object\rightarrowType', 'Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.015, .015], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off

% all trials against 0
print_ttest(squeeze(full_rp(3, 1, :)))
% 0.0042    0.0013         0       NaN    0.0038    3.1746   26.0000    0.6110

% correct trials 
print_ttest(zscore_null(squeeze(corr_rp(3, :, :))'))
% 0.6586    0.2412         0       NaN    0.0112    2.7308   26.0000    0.5255


% ==================
% independent splits

% compute over trials raw cases
ent_rol_values_indiv = nan(92, 20, 29, 2);
for i = 1:2

    if i == 1
        foo = out_op_results.loc_tp_rep;
    else
        foo = out_op_results.loc_att_rep;
    end

    for j = 1:29

        rel_foo = foo(:, :, :, j);
        rm = find(out_op_results.trial_entrop{j} < out_cfg.entrop_thresh);
        rel_foo(rm, :, :) = nan;
        all = find(out_op_results.trial_acc{j} < 2);
        rel_foo(all, :, :) = nan;

        ent_rol_values_indiv(1:size(foo, 1), :, j, i) = zscore_null(rel_foo);
    end

end

% cv a - tp
rel_dat = squeeze(nanmean(ent_rol_values_indiv(1:2:end, 1:17, :, 1)));
joi_a = rel_dat;
% cv a - att
rel_dat = squeeze(nanmean(ent_rol_values_indiv(1:2:end, 4:end, :, 2)));
joi_b = rel_dat;

joi_tot = nan(17, 29, 2);

joi_tot(:, :, 1) = joi_a;
joi_tot(:, :, 2) = joi_b;

[a,b,c,d]=ttest(nanmean(joi_tot, 3)')

% cv b
rel_dat = squeeze(nanmean(ent_rol_values_indiv(2:2:end, 1:17, :, 1)));
joi_a = rel_dat;
rel_dat = squeeze(nanmean(ent_rol_values_indiv(2:2:end, 4:end, :, 2)));
joi_b = rel_dat;

joi_tot = nan(17, 29, 2);

joi_tot(:, :, 1) = joi_a;
joi_tot(:, :, 2) = joi_b;

[a,b,c,d]=ttest(nanmean(joi_tot, 3)')

values_indiv = nan(92, 20, 29);

for j = 1:29
    foo = out_op_results.loc_tp_att_rep(:, :, :, j);
    rm = find(out_op_results.trial_entrop{j} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;
    values_indiv(1:size(foo, 1), :, j) = zscore_null(foo);
end

% significant across two folds
% cv a
cv_a = squeeze(nanmean(values_indiv(1:2:end, 3, :)));
print_ttest(cv_a)
% 0.2333    0.0928         0       NaN    0.0188    2.5138   25.0000    0.4930

% cv b
cv_b = squeeze(nanmean(values_indiv(2:2:end, 3, :)))
print_ttest(cv_b)
%  0.2640    0.0883         0       NaN    0.0060    2.9902   26.0000    0.5755

curr = figure(6)
subplot(3, 9, 19:20)
figInfo = {'', 'Split', 'Sequencenesss [z-scored]', [0, 3], [], [], {'', ''}, [], {}, 16, 1, []};
full_group = [cv_a, cv_b];
plotBar(full_group, figInfo, out_cfg.green_vec, out_cfg.green_vec, curr, 0, 0, 1, 1); axis square


% ===========
% loc-op

full_rp   = [];
full_rp_all = nan(92, 20, 29);
corr_rp   = [];
incorr_rp = [];

for k = 1:29
    foo = out_op_results.loc_op_rep(:, :, :, k);

    rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;

    all = find(out_op_results.trial_acc{k} < 0);
    ir = out_op_results.trial_acc{k} < 1;
    cr = ~ir;

    full_rp_all(1:size(foo, 1), :, k) = zscore_null(foo);
    full_rp(:, :, k) = squeeze(nanmean(foo));
    corr_rp(:, :, k) = squeeze(nanmean(foo(cr, :, :), 1));
    incorr_rp(:, :, k) = squeeze(nanmean(foo(ir, :, :), 1));
end

% Example: average over dimensions 1 and 2 first
corr_mean   = zscore_null(squeeze(nanmean(corr_rp(6, :, :), 1))');
incorr_mean = zscore_null(squeeze(nanmean(incorr_rp(6, :, :), 1))');

keep = ~isnan(corr_mean) & ~isnan(incorr_mean);

T = table(corr_mean(keep), incorr_mean(keep), ...
    'VariableNames', {'Correct','Incorrect'});

within = table(categorical({'Correct'; 'Incorrect'}), ...
    'VariableNames', {'Accuracy'});

rm = fitrm(T, 'Correct-Incorrect ~ 1', ...
    'WithinDesign', within);

a = ranova(rm, 'WithinModel', 'Accuracy');

F = a.F(1);
p = a.pValue(1);
eta2p = a.SumSq(1) / (a.SumSq(1) + a.SumSq(2));

fprintf('Accuracy main effect: F(%d,%d) = %.2f, p = %.4f, eta_p^2 = %.3f\n', ...
    a.DF(1), a.DF(2), F, p, eta2p);


curr = figure(6)
plot_tdlm_fb(average_lag_neighbors(permute(corr_rp, [3, 1, 2]), 2), curr, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
figElements(curr, '', 'Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.015, .015], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off

print_ttest(squeeze(full_rp(6, 1, :))')
% 0.0020    0.0007         0       NaN    0.0073    2.8921   28.0000    0.5371

print_ttest(zscore_null(squeeze(corr_rp(6, :, :))'))
% 0.6290    0.2346         0       NaN    0.0121    2.6816   28.0000    0.4980

print_ttest(zscore_null(squeeze(incorr_rp(6, :, :))'))
% -0.0406    0.1598         0       NaN    0.8013   -0.2543   26.0000   -0.0489


% =================
% compound result across session 
participant_accuracy = [out_all_object.out_object_results(:).tot_acc];

accuracy_median = nanmedian(participant_accuracy);
high_accuracy = find(participant_accuracy > accuracy_median);
low_accuracy = find(participant_accuracy <= accuracy_median);

high_session_t = nan(60, 1);
low_session_t = nan(60, 1);

% zscore

for trial_start = 1:60

    high_window = nanmean(full_rp_all(trial_start:trial_start + 30, 6, high_accuracy));
    low_window = nanmean(full_rp_all(trial_start:trial_start + 30, 6, low_accuracy));

    [~, ~, ~, high_stats] = ttest(high_window);
    [~, ~, ~, low_stats] = ttest(low_window);

    high_session_t(trial_start) = high_stats.tstat;
    low_session_t(trial_start) = low_stats.tstat;
end

[high_session_beta, ~, high_session_stats] = glmfit((1:60)', high_session_t);
[low_session_beta, ~, low_session_stats] = glmfit((1:60)', low_session_t);
session_slope = [high_session_beta(2), low_session_beta(2)];
session_slope_sem = [high_session_stats.se(2), low_session_stats.se(2)];

% plot 
[a,b,c] = glmfit(1:60, high_session_t);
c.t(2)
[a,b,c2] = glmfit(1:60, low_session_t);
c2.t(2)

ub_se = c.beta(2) + c.se(2);
lb_se = c.beta(2) - c.se(2);

ub_se2 = c2.beta(2) + c2.se(2);
lb_se2 = c2.beta(2) - c2.se(2);

curr = figure(67)
subplot(3, 9, 19:20)
errorbar(0.25, c.beta(2), c.se(2), c.se(2), ...
    'o', ...                    % circular marker
    'MarkerSize', 4, ... 
    'MarkerFaceColor', out_cfg.green_vec - .32, ...
    'MarkerEdgeColor', 'k', ...
    'Color', out_cfg.green_vec - .32, ...
    'LineWidth', 2, ...
    'CapSize', 0);              % widen the little 0T" caps
hold on 

errorbar(0.75, c2.beta(2), c2.se(2), c2.se(2), ...
    'o', ...                    % circular marker
    'MarkerSize', 4, ... 
    'MarkerFaceColor', out_cfg.green_vec - .32, ...
    'MarkerEdgeColor', 'k', ...
    'Color', out_cfg.green_vec - .32, ...
    'LineWidth', 2, ...
    'CapSize', 0);              % widen the little 0T" caps
hold on 

plot([0, 3], [0, 0], ':k')
figElements(curr, '', 'Across Participants', '', [0, 1], [], [0.25, 0.75], {'High Acc.', 'Low Acc.'}, [], {}, 16, [], []);

box off


%% supplementary materials

% =============================
% behavioural confusion matrix 
decoder_fig = figure(706);
tiledlayout(decoder_fig, 1, 4, 'TileSpacing', 'compact', 'Padding', 'compact');

role_confusion = nanmean(out_op_results.aux.beh_conf, 3);
role_labels = {'Hands?', 'Swap_{Limb}', 'Crown?', 'Swap_{Hat}', 'Round?', 'Swap_{Shape}'};

nexttile;
imagesc(role_confusion * 100);
axis square;
caxis([50, 100]);
colorbar;
colormap(decoder_fig);
figElements(decoder_fig, 'Behavioral Confusion Matrix', [], [], [.5, 6.5], [.5, 6.5], 1:6, role_labels, 1:6, role_labels, 16, [], []);
for row = 1:6
    for column = 1:6
        text(column, row, sprintf('%.0f', role_confusion(row, column) .* 100), 'HorizontalAlignment', 'center', 'FontSize', 9, 'Color', 'w');
    end
end


% ===============
% decoder rl vals 

% decoder fig
decoder_fig = figure(706);
tiledlayout(decoder_fig, 1, 4, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot_loc_fig_stat_panel(decoder_fig, out_op_results.aux.tp_decod_op(:, 1, :) * 100, out_op_results.aux.tp_decod_op(:, 2:end, :) * 100, out_cfg, 1/2, 52.5, [48.5, 54], out_cfg.default_vec);
figElements(decoder_fig, 'Type Code', 'Time [ms]', 'Op. Decod. Acc. [%]', [1, 50], [48.5, 54], [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);
box off

nexttile;
plot_loc_fig_stat_panel(decoder_fig, out_op_results.aux.att_decod_op(:, 1, :) * 100, out_op_results.aux.att_decod_op(:, 2:end, :) * 100, out_cfg, 1/3, 37, [32, 38], out_cfg.default_vec);
figElements(decoder_fig, 'Attribute Code', 'Time [ms]', 'Op. Decod. Acc. [%]', [1, 50], [32, 38], [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);
box off


% ====================
% simulation framework 
zero_density_idx = find(out_op_results.aux.sim_value_dens == 0, 1);
plot_density_idx = find(out_op_results.aux.sim_value_dens == 30, 1);
simulation_sequence_absent = squeeze(out_op_results.aux.sim_value_seq(:, zero_density_idx, :, :));
simulation_sequence_present = squeeze(out_op_results.aux.sim_value_seq(:, plot_density_idx, :, :));

% compute power
simulation_peak_n           = sum(isfinite(out_op_results.aux.sim_peak_val), 1);
simulation_peak_dz          = nanmean(out_op_results.aux.sim_peak_val, 1) ./ nanstd(out_op_results.aux.sim_peak_val, 0, 1);
simulation_power_alpha      = .05;
simulation_power_df         = simulation_peak_n - 1;
simulation_power_critical_t = tinv(1 - simulation_power_alpha ./ 2, simulation_power_df);

simulation_power_ncp  = abs(simulation_peak_dz) .* sqrt(simulation_peak_n);
simulation_peak_power = nctcdf(-simulation_power_critical_t, simulation_power_df, simulation_power_ncp) + 1 - nctcdf(simulation_power_critical_t, simulation_power_df, simulation_power_ncp);

simulation_density_upper_bound = nan(1, numel(out_op_results.aux.sim_value_dens));

for density_idx = 1:numel(out_op_results.aux.sim_value_dens)
    density_sequence = squeeze(out_op_results.aux.sim_value_seq(:, density_idx, :, :));
    density_sequence = smooth_tdlm_lags(density_sequence, 2);

    [~, ~, ~, simulation_density_upper_bound(density_idx)] = compute_tdlm_null_bounds_fb(density_sequence(:, :, 2:end), 99);
end

simulation_fig = figure(710);
clf(simulation_fig);
tiledlayout(simulation_fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

subplot(2, 7, 1)
simulation_bar_info = {'Simulation', '', 'Op. Decod. Acc_{\Delta} [%]', [-.5, 2.5], [0, 3], 1, {''}, [], {}, 16, [], []};
plotBar(out_op_results.aux.sim_op_decod, simulation_bar_info, out_cfg.default_vec, out_cfg.default_vec, simulation_fig, 0, 0, 1, 1);
axis square

subplot(2, 7, 2:4)
hold on
present_handle = plot_tdlm_fb(smooth_tdlm_lags(simulation_sequence_present, 2), simulation_fig, [], 99, [], out_cfg.green_vec);
absent_handle = plot_tdlm_fb(smooth_tdlm_lags(simulation_sequence_absent, 2), simulation_fig, [], 99, [], [255, 211, 81] ./ 255);
yline(0, ':k');
simulation_legend = legend([absent_handle, present_handle], {'0/min', '30/min'}, 'Location', 'best');
legend box off
title(simulation_legend, 'Density');
figElements(simulation_fig, 'Simulation', 'Object-Operation Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.003, .006], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off

simulation_peak_ax = subplot(2, 7, 5:6);
yyaxis left
plotmse(simulation_peak_values, out_cfg.green_vec, [0, 1], .2);
hold on
plot(1:numel(simulation_density_grid), simulation_density_upper_bound, '--', 'Color', out_cfg.green_vec, 'LineWidth', 1.25);
yline(0, ':k');
axis square
figElements(simulation_fig, 'At Peak', 'Transitions per minute', 'Sequenceness [a.u.]', [.75, numel(out_op_results.aux.sim_value_dens) + .25], [], 1:numel(out_op_results.aux.sim_value_dens), arrayfun(@num2str, out_op_results.aux.sim_value_dens, 'UniformOutput', false), [], {}, 16, [], []);
simulation_peak_ax.YAxis(1).Color = out_cfg.green_vec;

yyaxis right
plot(1:numel(simulation_density_grid), simulation_peak_power .* 100, ...
    '-o', 'Color', out_cfg.default_vec, 'MarkerFaceColor', out_cfg.default_vec, ...
    'LineWidth', 1.5, 'MarkerSize', 4);hold on
plot([1, 13], [80, 80], '-k')
ylabel('Power [%]');
ylim([0, 100]);
yticks(0:20:100);
simulation_peak_ax.YAxis(2).Color = out_cfg.default_vec;
box off



% ====================
% indiv loc-tp and loc-at

% loc-tp
full_rp   = [];
corr_rp   = [];

for k = 1:29
    foo = out_op_results.loc_tp_rep(:, :, :, k);

    rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;

    all = find(out_op_results.trial_acc{k} < 2);
    ir = out_op_results.trial_acc{k} < 2;
    cr = ~ir;

    full_rp(:, :, k) = squeeze(nanmean(foo));
    corr_rp(:, :, k) = squeeze(nanmean(foo(cr, :, :), 1));
end


curr = figure(6)
plot_tdlm_fb(average_lag_neighbors(permute(corr_rp, [3, 1, 2]), 2), curr, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
figElements(curr, 'Object\rightarrowType', 'Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.015, .015], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off

% all trials against 0
print_ttest(squeeze(full_rp(3, 1, :)))
% 0.0035    0.0015         0       NaN    0.0238    2.3963   27.0000    0.4529

% correct trials 
print_ttest(zscore_null(squeeze(corr_rp(3, :, :))'))
% 0.6613    0.1960         0       NaN    0.0023    3.3748   27.0000    0.6378 - 2
% 0.5610    0.2044         0       NaN    0.0107    2.7441   27.0000    0.5186 - 1


% loc-at
full_rp   = [];
corr_rp   = [];
incorr_rp = [];

for k = 1:29
    foo = out_op_results.loc_att_rep(:, :, :, k);

    rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
    foo(rm, :, :) = nan;

    all = find(out_op_results.trial_acc{k} < 0);
    ir = out_op_results.trial_acc{k} < 2;
    cr = ~ir;

    full_rp(:, :, k) = squeeze(nanmean(foo));
    corr_rp(:, :, k) = squeeze(nanmean(foo(cr, :, :), 1));
end


curr = figure(6)
plot_tdlm_fb(average_lag_neighbors(permute(corr_rp, [3, 1, 2]), 2), curr, [], out_cfg.perm_thresh_lag, [], green);
yline(0, ':k');
figElements(curr, 'Object\rightarrowType', 'Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.015, .015], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off

% all trials against 0
print_ttest(squeeze(full_rp(6, 1, :)))
% 0.0017    0.0008         0       NaN    0.0381    2.1769   28.0000    0.4042

% correct trials 
print_ttest(zscore_null(squeeze(corr_rp(6, :, :))'))
% 0.4888    0.1971         0       NaN    0.0194    2.4794   28.0000    0.4604 - 2


% ====================
% representational order 

[~, object_peak_idx]    = max(q_smooth(out_op_results.aux.obj_decod_fn(:, :)', out_cfg.smooth_nr, 1), [], 2);
[~, type_peak_idx]      = max(q_smooth(squeeze(out_op_results.aux.tp_decod_op(:, 1, :))', out_cfg.smooth_nr, 1), [], 2);
[~, attribute_peak_idx] = max(q_smooth(squeeze(out_op_results.aux.att_decod_op(:, 1, :))', out_cfg.smooth_nr, 1), [], 2);
rel_indices = [object_peak_idx, type_peak_idx, attribute_peak_idx];
diff_vals = all(diff(rel_indices, 1, 2) > 0, 2);

rng(cfg.random_seed);
order_null = nan(1001, 1);
order_null(1) = mean(diff_vals);
for permutation = 2:1001
    shuffled_peaks = rel_indices;
    for s = 1:n_sub
        shuffled_peaks(s, :) = shuffled_peaks(s, randperm(3));
    end
    order_null(permutation) = mean(all(diff(shuffled_peaks, 1, 2) > 0, 2));
end
order_upper = prctile(order_null(2:end), 97.5);

order_fig = figure(708);
tiledlayout(order_fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile
object_order_curve    = q_smooth(normalize_bound(nanmean(out_op_results.aux.obj_decod_fn', 1), 0, 1), out_cfg.smooth_nr, 1);
type_order_curve      = q_smooth(normalize_bound(nanmean(squeeze(out_op_results.aux.tp_decod_op(:, 1, :))'), 0, 1), out_cfg.smooth_nr, 1);
attribute_order_curve = q_smooth(normalize_bound(nanmean(squeeze(out_op_results.aux.att_decod_op(:, 1, :))'), 0, 1), out_cfg.smooth_nr, 1);
object_order_handle   = plot(object_order_curve, 'Color', [0, .35, .75], 'LineWidth', 2);
hold on
type_order_handle = plot(type_order_curve, 'Color', dark_gray, 'LineWidth', 2);
attribute_order_handle = plot(attribute_order_curve, 'Color', [.9, .15, .15], 'LineWidth', 2);
legend([object_order_handle, type_order_handle, attribute_order_handle], {'Object', 'Type', 'Attribute'}, 'Location', 'best');
legend box off
figElements(order_fig, 'Representation Order', 'Time [ms]', 'Decoding Accuracy [a.u.]', [1, 51], [], [1, 31, 51], {'Stim ON', '300', '500'}, [], {}, 16, [], []);
box off

nexttile
bar((sum(correct_order)./29)*100);
hold on
ylim([0, 50])
yline(order_upper .* 100, '--k');


% ====================
% object decoder  + seq vals in op loc 

cross_task_correlation = corr(out_op_results.aux.obj_decod_fn', out_op_results.aux.obj_decod_fn', 'Rows', 'pairwise');

match_fig = figure(702);
clf(match_fig);
set(match_fig, 'Name', 'Object decoder localizer comparison', 'Color', 'w');
tiledlayout(match_fig, 1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
func_line = plotmse(out_op_results.aux.obj_decod_fn', out_cfg.green_vec, [0, 1]);
hold on
role_line = plotmse(out_op_results.aux.obj_decod_op', [40, 40, 40] ./ 255, [0, 1]);
yline(1/12, ':k');
legend([func_line(1), role_line(1)], {'Functional', 'Role'}, 'Location', 'best');
legend box off
figElements(match_fig, '', 'Time [ms]', 'Obj. Decod. Acc', [], [], [1, 16, 31, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);
box off

replay_fig = figure(703);

nexttile;
imagesc(cross_task_correlation);
axis square;
colormap(out_cfg.curr_palette)
caxis([-1, 1]);
colorbar;
figElements(match_fig, 'Cross-task correlation', 'role loc [ms]', 'func loc [ms]', [], [], [1, 16, 31, 50], {'Stim ON', '150', '300', '500'}, [1, 16, 31, 50], {'Stim ON', '150', '300', '500'}, 16, [], []);

nexttile;
mean_replay_peak = nanmean(out_op_results.aux.indiv_seq_vals_op_loc.joi, 2);
bar_info = {'', 'Object \rightarrow Role', 'Sequenceness [z-scored]', [.5, 1.5], [], 1, {''}, [], {}, 16, 1, []};
plotBar(mean_replay_peak, bar_info, out_cfg.green_vec, out_cfg.green_vec, replay_fig, 0, 0, 1, 1);
axis square

nexttile;
hold on
h_type = plot_tdlm_fb(smooth_tdlm_lags(out_op_results.aux.indiv_seq_vals_op_loc.tp, 2), replay_fig, [], out_cfg.perm_thresh_lag, [], min(out_cfg.green_vec + .20, 1));
h_attribute = plot_tdlm_fb(smooth_tdlm_lags(out_op_results.aux.indiv_seq_vals_op_loc.att, 2), replay_fig, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
h_operation = plot_tdlm_fb(smooth_tdlm_lags(out_op_results.aux.indiv_seq_vals_op_loc.op, 2), replay_fig, [], out_cfg.perm_thresh_lag, [], max(out_cfg.green_vec - .20, 0));
yline(0, ':k');
legend([h_type, h_attribute, h_operation], {'Object\rightarrowType', 'Object\rightarrowAttribute', 'Object\rightarrowOperation'}, 'Location', 'best');
legend box off
figElements(replay_fig, [], 'Lag [ms]', 'Sequenceness [z-scored]', [], [], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off


%% conf mats

decoder_fig = figure(701);

subplot(1, 2, 1);
type_confusion_peak = squeeze(nanmean(out_op_results.aux.tp_cm, 3));
imagesc(type_confusion_peak .* 100);
axis square; colormap(out_cfg.curr_palette);
caxis([-1.5, 1.5]);
cb = colorbar;
cb.Label.String = 'Op. Decod. Acc._{\Delta} [%]';
cb.Label.FontSize = 16;
figElements(decoder_fig, [], [], [], [], [], 1:2, type_labels, 1:2, type_labels, 16, [], []);

subplot(1, 2, 2);
attribute_confusion_peak = squeeze(nanmean(out_op_results.aux.att_cm, 3));
imagesc(attribute_confusion_peak .* 100);
axis square; colormap(out_cfg.curr_palette);
caxis([-1.5, 1.5]);
cb = colorbar;
cb.Label.String = 'Op. Decod. Acc._{\Delta} [%]';
cb.Label.FontSize = 16;
figElements(decoder_fig, [], [], [], [], [], 1:3, attribute_labels, 1:3, attribute_labels, 16, [], []);

%% op-op loc

curr = figure;
plotmse(q_smooth(out_op_results.aux.op_decod_fn .* 100, out_cfg.smooth_nr, 1), out_cfg.default_vec, [0, 1]);
yline(100/6, ':k');
[~, operation_p] = ttest(q_smooth(out_op_results.aux.op_decod_fn, out_cfg.smooth_nr, 1).* 100, 100/6);
hold on
plot_sigline(curr, operation_p, out_cfg.default_vec, 18.5);
figElements(curr, '', 'Time [ms]', 'Op. Decod. Acc. [%]', [1, 50], [15.5, 19], [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 16, [], []);

%% op-att

full_rp_tp_att   = [];

for k = 1:29
    foo = out_op_results.aux.seq_tp_att(:, :, :, k);
     rm = find(out_op_results.trial_entrop{k} < out_cfg.entrop_thresh);
     foo(rm, :, :) = nan;
     all = find(out_op_results.trial_acc{k} < 0);
     foo(all, :, :) = nan;
    full_rp_tp_att(:, :, k) = squeeze(nanmean(foo));
end


curr = figure(6)
plot_tdlm_fb(average_lag_neighbors(permute(full_rp_tp_att, [3, 1, 2]), 2), curr, [], out_cfg.perm_thresh_lag, [], out_cfg.green_vec);
yline(0, ':k');
figElements(curr, 'Object\rightarrowType', 'Lag [ms]', 'Sequenceness [a.u.]', [1, 20], [-.015, .015], [1, 10, 20], {'10', '100', '200'}, [], {}, 16, [], []);
box off


end
