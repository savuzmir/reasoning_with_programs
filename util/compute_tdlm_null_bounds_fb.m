function [npThresh_lb, npThresh_ub, npThreshAll_lb, npThreshAll_ub] = compute_tdlm_null_bounds_fb(fb_tot, threshLev)


npThresh_ub = squeeze(prctile(abs(squeeze(nanmean(fb_tot, 1)))', threshLev));
npThresh_lb = npThresh_ub*-1;

npThreshAll_ub = max(npThresh_ub); 
npThreshAll_lb = npThreshAll_ub * -1; 

end

