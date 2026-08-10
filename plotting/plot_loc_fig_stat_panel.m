function x=plot_loc_fig_stat_panel(curr, real_dat, null_dat, out_cfg, base_lim, plot_null_lim, ylims, varargin)

x=compute_cluster_stats(squeeze(nanmean(real_dat, 3)), squeeze(nanmean(null_dat, 3)), out_cfg.perm_thresh, 2);

if ~isempty(varargin)
    plotmse(q_smooth(squeeze(real_dat)', out_cfg.smooth_param, 1), varargin{1}, [0, 1]); 
else
    plotmse(q_smooth(squeeze(real_dat)', out_cfg.smooth_param, 1), [0, 1]);
end

rel_tp = nan(1, 200);
rel_tp(find(x.survived_mass_UB==1)) = plot_null_lim;

if ~isempty(varargin)   
    plot(rel_tp, 'linewidth', 2, 'color', varargin{1}); hold on
else
    plot(rel_tp, 'linewidth', 2, 'color', [45, 45, 45]./255); hold on
end
plot(repmat(base_lim * 100, [1, 200]), ':k')

figElements(curr, '', 'Time [ms]', '. Attr. Decod. Acc. [%]', [1, 50], ylims, [1, 15, 30, 50], {'Stim ON', '150', '300', '500'}, [], {}, 24, [], []);

end
