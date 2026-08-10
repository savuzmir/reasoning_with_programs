function out = print_ttest(a, varargin)
% Output order:
% [mean_group1, SEM_group1, mean_group2, SEM_group2, p, t, df, Cohen_d]
%
% Usage:
%   print_ttest(a)          % one-sample t-test against zero
%   print_ttest(a, 1, b)    % paired-samples t-test
%   print_ttest(a, 2, b)    % independent-samples t-test

a = a(:);

mean1 = nanmean(a);
sem1  = sem(a, 1);

if isempty(varargin)
    % One-sample t-test against zero
    valid = ~isnan(a);
    x = a(valid);

    [~, p, ~, stats] = ttest(x);

    mean2 = 0;
    sem2  = NaN;

    % One-sample Cohen's d
    cohen_d = nanmean(x) ./ nanstd(x, 0);

else
    paired = varargin{1} == 1;
    b = varargin{2}(:);

    mean2 = nanmean(b);
    sem2  = sem(b, 1);

    if paired
        % Retain only complete pairs
        valid = ~isnan(a) & ~isnan(b);
        x = a(valid);
        y = b(valid);

        [~, p, ~, stats] = ttest(x, y);

        % Cohen's dz for paired samples
        differences = x - y;
        cohen_d = nanmean(differences) ./ nanstd(differences, 0);

    else
        % Remove NaNs separately for independent groups
        x = a(~isnan(a));
        y = b(~isnan(b));

        [~, p, ~, stats] = ttest2(x, y);

        % Cohen's d using the pooled standard deviation
        n1 = numel(x);
        n2 = numel(y);

        pooled_sd = sqrt( ...
            ((n1 - 1) .* nanstd(x, 0).^2 + ...
             (n2 - 1) .* nanstd(y, 0).^2) ./ ...
            (n1 + n2 - 2));

        cohen_d = (nanmean(x) - nanmean(y)) ./ pooled_sd;
    end
end

out = [mean1, sem1, mean2, sem2, ...
       p, stats.tstat, stats.df, cohen_d];

end
