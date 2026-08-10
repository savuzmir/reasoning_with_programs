function results = plot_behaviour_results()

% load prelims 
out_cfg = load_config_info();
behavioural_out = load('...\data\behaviour_results.mat');

% stats 

for condition = 1:4
    print_ttest(behavioural_out.accuracy_by_probe(:, condition) - 50)
end

print_ttest(behavioural_out.accuracy_by_probe(:, 1), 1, behavioural_out.accuracy_by_probe(:, 2));
print_ttest(behavioural_out.accuracy_by_probe(:, 3), 1, behavioural_out.accuracy_by_probe(:, 4));

print_ttest(behavioural_out.path_accuracy_by_end(:, 2), 1, behavioural_out.path_accuracy_by_end(:, 1));

print_ttest(behavioural_out.accuracy_by_length(:, 1), 1, behavioural_out.accuracy_by_length(:, 2));
print_ttest(behavioural_out.accuracy_by_length(:, 4), 1, behavioural_out.accuracy_by_length(:, 2));
print_ttest(behavioural_out.thinking_by_length(:, 2), 1, behavioural_out.thinking_by_length(:, 1));

print_ttest(behavioural_out.program_structure_accuracy(:, 1));
print_ttest(behavioural_out.program_structure_accuracy(:, 2));
print_ttest(behavioural_out.program_structure_accuracy(:, 2), 1, behavioural_out.program_structure_accuracy(:, 1));

print_ttest(behavioural_out.program_structure_accuracy(:, 3));
print_ttest(behavioural_out.program_structure_accuracy(:, 4));
print_ttest(behavioural_out.program_structure_accuracy(:, 4), 1, behavioural_out.program_structure_accuracy(:, 3));

print_ttest(parametric.betas.thinking.branch);

print_ttest(estimate_betas(behavioural_out.feature_distance));
print_ttest(estimate_betas(behavioural_out.thinking_by_branch_short));
print_ttest(estimate_betas(behavioural_out.thinking_by_branch_long));

% program structure: PATH and END object-vs-face contrasts 
print_ttest(behavioural_out.program_structure_accuracy(:, 1) - behavioural_out.program_structure_accuracy(:, 2))
%  -7.9773    2.7499         0       NaN    0.0072   -2.9009   28.0000   -0.5387
print_ttest(behavioural_out.program_structure_accuracy(:, 3) - behavioural_out.program_structure_accuracy(:, 4))
%  -8.3246    2.4992         0       NaN    0.0024   -3.3309   28.0000   -0.6185
print_ttest(behavioural_out.program_structure_accuracy)

% PATH accuracy by undirected distance from the correct path 
print_ttest(behavioural_out.path_undirected(:, 2) - behavioural_out.path_undirected(:, 3))
%  -8.4896    3.0027         0       NaN    0.0086   -2.8273   28.0000   -0.5250
print_ttest(behavioural_out.path_undirected(:, 1) - behavioural_out.path_undirected(:, 3))
% -9.9460    2.5182         0       NaN    0.0005   -3.9496   28.0000   -0.7334

% PATH probe reachability contrast (supplementary panel 11).
print_ttest(behavioural_out.path_reachability(:, 1) - behavioural_out.path_reachability(:, 2))
% -17.2057    3.8383         0       NaN    0.0001   -4.4827   28.0000   -0.8324

% 2 x 2 repeated-measures ANOVA: direction (down/up) x distance (1/2)
anova_complete = all(isfinite(behavioural_out.path_direction_12), 2);
anova_values = array2table(behavioural_out.path_direction_12(anova_complete, :), 'VariableNames', {'Down1', 'Up1', 'Down2', 'Up2'});
within_design = table(categorical({'Downstream'; 'Upstream'; 'Downstream'; 'Upstream'}), categorical({'1'; '1'; '2'; '2'}), 'VariableNames', {'Direction', 'Distance'});
path_direction_rm = fitrm(anova_values, 'Down1-Up2 ~ 1', 'WithinDesign', within_design);
path_direction_anova = ranova(path_direction_rm, 'WithinModel', 'Direction*Distance');
disp(path_direction_anova)

% main effect of PATH distance: Target, 1, 2
path_dat = behavioural_out.path_undirected(:, 1:3);
keep = all(isfinite(path_dat), 2);
T_path = array2table(path_dat(keep, :), 'VariableNames', {'Target', 'Dist1', 'Dist2'});
W_path = table(categorical({'Target'; '1'; '2'}), 'VariableNames', {'Distance'});
rm_path = fitrm(T_path, 'Target-Dist2 ~ 1', 'WithinDesign', W_path);
anova_path = ranova(rm_path, 'WithinModel', 'Distance')

%                               SumSq      DF     MeanSq        F         pValue       pValueGG      pValueHF      pValueLB
%                             _________    __    _________    ______    __________    __________    __________    __________
%
%     (Intercept)             6.408e+05     1    6.408e+05    2732.1    1.8356e-29    1.8356e-29    1.8356e-29    1.8356e-29
%     Error                      6567.2    28       234.54
%     (Intercept):Distance       1673.5     2       836.73    6.5045     0.0028834     0.0039808     0.0032413      0.016516
%     Error(Distance)            7203.8    56       128.64

% main effect of END-probe structure
end_dat = behavioural_out.end_node13(:, 1:3);
keep = all(isfinite(end_dat), 2);
T_end = array2table(end_dat(keep, :), 'VariableNames', {'Target', 'Alternative', 'NotConnected'});
W_end = table(categorical({'Target'; 'Alternative'; 'Not connected'}), 'VariableNames', {'END_distance'});
rm_end = fitrm(T_end, 'Target-NotConnected ~ 1', 'WithinDesign', W_end);
anova_end = ranova(rm_end, 'WithinModel', 'END_distance')

%                                   SumSq       DF      MeanSq        F         pValue       pValueGG      pValueHF      pValueLB
%                                 __________    __    __________    ______    __________    __________    __________    __________
%
%     (Intercept)                 4.8631e+05     1    4.8631e+05    528.86    2.8754e-19    2.8754e-19    2.8754e-19    2.8754e-19
%     Error                            24828    27        919.56
%     (Intercept):END_distance          8549     2        4274.5    9.0618    0.00040416    0.00078117    0.00058463     0.0056027
%     Error(END_distance)              25472    54        471.71

% ========================================================
%% Main behavioural figure: panels a-i

curr = figure(661);
clf(curr);
set(curr, 'Name', 'Behavioural results', 'Color', 'w');

% a: accuracy by question and probe type
subplot(3, 3, 1);
plotBar_pairedCol(behavioural_out.accuracy_by_probe, out_cfg.colors.end_probe, out_cfg.colors.path, 1);
hold on;
plot([0, 5], [50, 50], ':k', 'LineWidth', 1);
probe_labels = {'Object', 'Face', 'Object', 'Face'};
question_labels = {'END', 'END', 'PATH', 'PATH'};
joint_labels = strjust(pad([probe_labels; question_labels]), 'center');
figElements(curr, 'Question Type', '', 'Accuracy [%]', [0.5, 4.5], [0, 105], 1:4, joint_labels, [], {}, 24, [], []);

% b: END/PATH relationship across participants
subplot(3, 3, 2);
hold on;
for sb = 1:n_sub
    plot([behavioural_out.total_accuracy(sb, 1), behavioural_out.total_accuracy(sb, 1)], behavioural_out.total_accuracy(sb, 2) + [-1, 1] .* behavioural_out.total_accuracy_error(sb, 2), 'k', 'LineWidth', 1);
    plot(behavioural_out.total_accuracy(sb, 1) + [-1, 1] .* behavioural_out.total_accuracy_error(sb, 1), [behavioural_out.total_accuracy(sb, 2), behavioural_out.total_accuracy(sb, 2)], 'k', 'LineWidth', 1);
end
scatterfit(behavioural_out.total_accuracy(:, 1), behavioural_out.total_accuracy(:, 2), 1, curr, out_cfg.colors.green);
legend off;
plot([40, 100], [40, 100], ':k', 'LineWidth', 0.8);
axis square;
figElements(curr, 'Across Participants', 'END Accuracy [%]', 'PATH Accuracy [%]', [40, 100], [40, 100], [], {}, [], {}, 24, [], []);

% c: PATH accuracy conditional on the END response from the same trial
subplot(3, 3, 3);
fig_info = {'Within Participants', 'END response', 'PATH Accuracy [%]', [0.5, 2.5], [0, 105], [1, 2], {'Incorrect', 'Correct'}, [], {}, 24, [], []};
plotBar(behavioural_out.path_accuracy_by_end, fig_info, out_cfg.colors.path, out_cfg.colors.path, curr, 0, 1, 1, 1);
hold on;
plot([0.5, 2.5], [50, 50], ':k', 'LineWidth', 1);
axis square;

% d: PATH accuracy by undirected distance from the correct path
subplot(3, 3, 4);
plotmse(behavioural_out.path_undirected(:, 1:3), out_cfg.colors.path, [0, 1], 0.2);
axis square;
figElements(curr, 'PATH', 'Distance from Correct Path', 'Accuracy [%]', [1, 3], [75, 100], 1:3, {'Target', '1', '2'}, [], {}, 24, [], []);

% e: accuracy by program length
subplot(3, 3, 5);
plotBar_pairedCol(behavioural_out.accuracy_by_length, out_cfg.colors.end_probe, out_cfg.colors.path, 2);
hold on;
plot([0, 5], [50, 50], ':k', 'LineWidth', 1);
length_labels = {'3 Objects', '4 Objects', '3 Objects', '4 Objects'};
question_labels = {'END', 'END', 'PATH', 'PATH'};
joint_labels = strjust(pad([length_labels; question_labels]), 'center');
figElements(curr, 'Program Length', '', 'Accuracy [%]', [0.5, 4.5], [0, 105], 1:4, joint_labels, [], {}, 24, [], []);

% f: thinking time by program length
subplot(3, 3, 6);
fig_info = {'Program Length', '', 'Thinking Time [sec]', [0.5, 2.5], [5, 22.5], [1, 2], {'3 Objects', '4 Objects'}, [], {}, 24, [], []};
plotBar(behavioural_out.thinking_by_length, fig_info, out_cfg.colors.thinking, out_cfg.colors.thinking, curr, 0, 1, 1, 1);
axis square;

% g: task schematic (added during figure assembly)
subplot(3, 3, 7);
axis off;

% h: program-structure accuracy (+1 branch / -1 swap)
subplot(3, 3, 8);
plotBar_pairedCol(behavioural_out.program_structure_accuracy, out_cfg.colors.path, out_cfg.colors.end_probe, 1);
hold on;
plot([0.5, 4.5], [0, 0], ':k', 'LineWidth', 1);
finite_betas = abs(behavioural_out.program_structure_accuracy(~isnan(behavioural_out.program_structure_accuracy)));
if isempty(finite_betas) || max(finite_betas) == 0
    beta_limit = 1;
else
    beta_limit = 1.15 .* max(finite_betas);
end
probe_labels = {'Object', 'Face', 'Object', 'Face'};
question_labels = {'PATH', 'PATH', 'END', 'END'};
joint_labels = strjust(pad([probe_labels; question_labels]), 'center');
figElements(curr, 'Program Structure', '', 'Accuracy_{\Delta} +1 Branch | -1 Swap [%]', [0.5, 4.5], [-beta_limit, beta_limit], 1:4, joint_labels, [], {}, 24, [], []);

% i: length-controlled thinking time by number of branches
subplot(3, 3, 9);
plotmse(behavioural_out.thinking_by_branch_centered, out_cfg.colors.time, [0, 1]);
hold on;
plot([1, 3], [0, 0], ':k', 'LineWidth', 1);
axis square;
figElements(curr, '', 'Number of Branches', 'Thinking Time_{\Delta} [sec]', [1, 3], [-1, 1], 1:3, {'Min', '', 'Max'}, [], {}, 24, [], []);

results.figure.main = curr;

% ========================================================
%% supplementary fig

supp = figure(662);
clf(supp);
set(supp, 'Name', 'Supplementary behavioural results', 'Color', 'w');

% 1: END-Face accuracy by sampled feature distance
subplot(3, 5, 1);
plotmse(behavioural_out.feature_distance, out_cfg.colors.end_probe, [0, 1]);
axis square;
figElements(supp, 'END_{Face}', 'Attribute Distance from END_{Face} Sampled', 'Accuracy [%]', [1, 4], [50, 90], 1:4, {'0', '1', '2', '3'}, [], {}, 24, [], []);

% 2: thinking time by branch number, 3
subplot(3, 5, 2);
plotmse(behavioural_out.thinking_by_branch_short, out_cfg.colors.gray, [0, 1]);
axis square;
figElements(supp, '3 Objects', 'Number of Branches', 'Thinking Time [sec]', [1, 3], [14, 19], 1:3, {'1', '2', '3'}, [], {}, 24, [], []);

% 3: thinking time by branch number, 4
subplot(3, 5, 3);
plotmse(behavioural_out.thinking_by_branch_long, out_cfg.colors.gray, [0, 1]);
axis square;
figElements(supp, '4 Objects', 'Number of Branches', 'Thinking Time [sec]', [1, 3], [14, 19], 1:3, {'1', '2', '3'}, [], {}, 24, [], []);

% 4: PATH accuracy by branch number, 3
subplot(3, 5, 4);
plotmse(100 .* behavioural_out.path_object_by_branch_short, out_cfg.colors.object, [0, 1]);
plotmse(100 .* behavioural_out.path_face_by_branch_short, out_cfg.colors.face, [0, 1]);
axis square;
figElements(supp, '3 Objects_{PATH}', 'Number of Branches', 'Accuracy [%]', [1, 3], [50, 100], 1:3, {'1', '2', '3'}, [], {}, 24, [], []);

% 5: END accuracy by branch number, 3
subplot(3, 5, 5);
plotmse(100 .* behavioural_out.end_object_by_branch_short, out_cfg.colors.object, [0, 1]);
plotmse(100 .* behavioural_out.end_face_by_branch_short, out_cfg.colors.face, [0, 1]);
axis square;
figElements(supp, '3 Objects_{END}', 'Number of Branches', 'Accuracy [%]', [1, 3], [50, 100], 1:3, {'1', '2', '3'}, [], {}, 24, [], []);

% 6: PATH accuracy by branch number, 4
subplot(3, 5, 6);
plotmse(100 .* behavioural_out.path_object_by_branch_long, out_cfg.colors.object, [0, 1]);
plotmse(100 .* behavioural_out.path_face_by_branch_long, out_cfg.colors.face, [0, 1]);
axis square;
figElements(supp, '4 Objects_{PATH}', 'Number of Branches', 'Accuracy [%]', [1, 3], [50, 100], 1:3, {'2', '3', '4'}, [], {}, 24, [], []);

% 7: END accuracy by branch number, 4
subplot(3, 5, 7);
plotmse(100 .* behavioural_out.end_object_by_branch_long, out_cfg.colors.object, [0, 1]);
plotmse(100 .* behavioural_out.end_face_by_branch_long, out_cfg.colors.face, [0, 1]);
axis square;
figElements(supp, '4 Objects_{END}', 'Number of Branches', 'Accuracy [%]', [1, 3], [50, 100], 1:3, {'2', '3', '4'}, [], {}, 24, [], []);

% 8: response-termination occupancy across planning time
subplot(3, 5, 8);
plotmse(100 .* behavioural_out.termination_occupancy, out_cfg.colors.gray, [0, 1]);
axis square;
figElements(supp, '', 'Time from STIM ON [sec]', 'Termination Occupancy [%]', [1, size(behavioural_out.termination_occupancy, 2)], [0, 5], [1, 15, size(behavioural_out.termination_occupancy, 2)], {'5', '12.5', '20'}, [], {}, 24, [], []);

% 9: termination probability across blocks
subplot(3, 5, 9);
plotmse(100 .* behavioural_out.termination_frequency, out_cfg.colors.gray, [0, 1]);
axis square;
figElements(supp, '', 'Blocks', 'Termination Probability [% trials]', [1, 8], [20, 100], 1:8, {'1', '2', '3', '4', '5', '6', '7', '8'}, [], {}, 24, [], []);

% 10: thinking time across blocks
subplot(3, 5, 10);
plotmse(behavioural_out.termination_thinking, out_cfg.colors.gray, [0, 1]);
axis square;
figElements(supp, '', 'Blocks', 'Thinking Time [sec]', [1, 8], [10, 20], 1:8, {'1', '2', '3', '4', '5', '6', '7', '8'}, [], {}, 24, [], []);

% 11: PATH-probe directed reachability
subplot(3, 5, 11);
reachability_bar_info = {'', 'PATH Probe', 'Accuracy [%]', [0.5, 2.5], [60, 100], 1:2, {'Reachable', 'Unreachable'}, [], {}, 24, [], []};
plotbarpaired(behavioural_out.path_reachability, reachability_bar_info, out_cfg.colors.path, out_cfg.colors.gray, supp, [0, 0.975], 0);
axis square;

% 12: END-probe structure
subplot(3, 5, 12);
plotmse(behavioural_out.end_node13, out_cfg.colors.end_probe, [0, 1], 0.2);
axis square;
figElements(supp, 'END', 'END Probe', 'Accuracy [%]', [1, size(behavioural_out.end_node13, 2)], [60, 100], 1:size(behavioural_out.end_node13, 2), {'Target', 'Alt.', 'Dist.'}, [], {}, 24, [], []);



end
