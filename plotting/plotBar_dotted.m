function [curr] = plotBar_dotted(input, figInfo, colorVec1, colorVec2, curr, confInt, indivPoints, paired_samples, varargin)
%PLOTBAR_DOTTED plotBar wrapper with optional dotted bar outlines.
%
% Usage:
%   plotBar_dotted(input, figInfo, col1, col2, curr, 0, 1, 1, ...
%       'dottedBars', [2 4]);
%
% Existing plotBar positional highlighting still works:
%   plotBar_dotted(input, figInfo, col1, col2, curr, 0, 1, 1, 1, ...
%       'dottedBars', [2]);
%
% Dotted indices refer to bar positions / input columns.

dotted_idx = [];
dotted_col = [0, 0, 0];
dotted_line_width = 3;
dotted_line_style = '-';
plotbar_args = {};

v = 1;
while v <= numel(varargin)
    if ischar(varargin{v}) || isstring(varargin{v})
        switch lower(char(varargin{v}))
            case {'dottedbars', 'dottedrows', 'dottedidx'}
                dotted_idx = varargin{v + 1};
                v = v + 2;
            case {'dottedcolor', 'dottedcolour'}
                dotted_col = varargin{v + 1};
                v = v + 2;
            case 'dottedlinewidth'
                dotted_line_width = varargin{v + 1};
                v = v + 2;
            case 'dottedlinestyle'
                dotted_line_style = varargin{v + 1};
                v = v + 2;
            otherwise
                v = v + 1;
        end
    else
        plotbar_args{end + 1} = varargin{v}; 
        v = v + 1;
    end
end

ax = gca;
bar_before = findobj(ax, 'Type', 'Bar');

curr = plotBar(input, figInfo, colorVec1, colorVec2, curr, confInt, indivPoints, paired_samples, plotbar_args{:});

bar_after = findobj(ax, 'Type', 'Bar');
new_bar = setdiff(bar_after, bar_before);
if isempty(new_bar)
    if isempty(bar_after)
        return
    end
    b = bar_after(1);
else
    b = new_bar(1);
end

bar_mean = nanmean(input, 1);
nStates = size(input, 2);
bar_width = b.BarWidth;
b.EdgeColor = 'none';

dotted_idx = dotted_idx(:)';
dotted_idx = dotted_idx(dotted_idx >= 1 & dotted_idx <= nStates);

for ii = 1:nStates
    y0 = min(0, bar_mean(ii));
    h = abs(bar_mean(ii));

    if ~isfinite(h)
        continue
    end
    if h == 0
        h = eps;
    end

    if ismember(ii, dotted_idx)
        line_style = dotted_line_style;
        line_width = dotted_line_width;
        edge_col = dotted_col;
    else
        line_style = '--';
        line_width = 3;
        edge_col = 'k';
    end

    rectangle(ax, 'Position', [ii - bar_width / 2, y0, bar_width, h], ...
        'EdgeColor', edge_col, ...
        'LineStyle', line_style, ...
        'LineWidth', line_width, ...
        'FaceColor', 'none');
end

end
