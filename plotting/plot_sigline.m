function plot_sigline(curr, pvals, color, position, varargin)

figure(curr)
% weight according to sig
b1_05  = nan(length(pvals), 1);
b1_01  = nan(length(pvals), 1);
b1_001 = nan(length(pvals), 1);

b1_05(pvals <= 0.05) = position;
b1_01(pvals <= 0.01) = position;
b1_001(pvals<=0.001) = position;

if ~isempty(varargin)

    plot(varargin{1}, b1_05, 'color', color, 'linewidth', 1.5); hold on
    plot(varargin{1}, b1_01, 'color', color, 'linewidth', 2.5); hold on
    plot(varargin{1}, b1_001, 'color', color, 'linewidth', 3.5)
    
else

    plot(1:length(pvals), b1_05, 'color', color, 'linewidth', 1.5); hold on
    plot(1:length(pvals), b1_01, 'color', color, 'linewidth', 2.5); hold on
    plot(1:length(pvals), b1_001, 'color', color, 'linewidth', 3.5)

end


end