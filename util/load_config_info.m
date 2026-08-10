function out_cfg = load_config_info()

out_cfg = struct;

%% cols

out_cfg.default_vec = [75, 75, 75] ./ 255;
out_cfg.green_vec = [84, 161, 140] ./ 255;
out_cfg.gray_vec = [148, 149, 153] ./ 255;
out_cfg.orange_vec = [230, 159, 1] ./ 255;
out_cfg.purple_vec = [204, 121, 167] ./ 255;
out_cfg.end_vec = [225, 190, 106] ./ 255;
out_cfg.path_vec = [64, 176, 166] ./ 255;
out_cfg.branch_vec = [76, 139, 203] ./ 255;
out_cfg.swap_vec = [230, 111, 98] ./ 255;

palette_file = load('RdGy.mat');
out_cfg.curr_palette = flip(palette_file.cmap_interp);

% plotting related
out_cfg.smooth_param = 3; % visual smoothing of ts
out_cfg.perm_thresh = 97.5;

% RSA
out_cfg.rsa_start_window = 24:215;
out_cfg.rsa_end_window = 110:300;
out_cfg.rsa_shallow_window = 24:150;
out_cfg.rsa_deep_window = 174:300;
out_cfg.n_perm = 1001;
out_cfg.empir_idx = 1;
out_cfg.null_idx = 2:out_cfg.n_perm;

% replay related
out_cfg.n_trial = 92;
out_cfg.n_lag = 20;
out_cfg.n_sub = 29;
out_cfg.entrop_thresh = .1687;
out_cfg.peak_lags = 7:9;
out_cfg.perm_thresh_lag = 95;
out_cfg.lag_smooth = 2; % neighbor averaging

out_cfg.crosval_wind = 1:150; % 300 msec window for cross-validating based on liu2019

end
