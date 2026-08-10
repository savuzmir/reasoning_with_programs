function [curr] = plotbarpaired(input, figInfo, colorVec1, colorVec2, curr, confInt, indivPoints, varargin)

blueVec = [ 0.0039, 0.4471, 0.6980];

nStates = size(input, 2);
b = bar(nanmean(input, 1), 'edgeColor', 'none'); hold on
b.FaceColor = 'flat';

if all(colorVec1==colorVec2) % means you don't want to color them separately so we can use nStates
    
    b.CData(:, :) = repmat(colorVec1, [nStates, 1]);
elseif any(colorVec1~=colorVec2) && isempty(varargin)
    
    b.CData(1:2:end, :) = repmat(colorVec1, [nStates/2, 1]);
    b.CData(2:2:end, :) = repmat(colorVec2, [nStates/2, 1]);
    
else
    
    % we select which one we want to color
    b.CData(1:nStates, :) = repmat(colorVec2, [nStates, 1]);
    b.CData(varargin{1}, :) = repmat(colorVec1, [1, 1]);
    
end

w = norminv(confInt(2));

if confInt(1)
    err = w*nanstd(input, [], 1)./sqrt(sum(~isnan(input), 1));
else
    err = nanstd(input, [], 1)./sqrt(sum(~isnan(input), 1));
end


errorbar(1:nStates, nanmean(input, 1), err,  '.', 'CapSize', 0, 'linewidth', 2, 'color', [1/255, 1/255, 1/255])

jitterVar = 0.06;

if indivPoints
    stateData = [];
    for i = 1:nStates
        X = zeros(sum(~isnan(input(:, i))), 1) + i;
        Y = input(:, i);
        Y = Y(~isnan(Y));
        
        % home made jitter 
        noise = normrnd(0, jitterVar, [size(X, 1), 1]);
       
        stateData(:, :, i) = [X+noise, Y]; 
    end

    for nStatePairs = 1:(nStates-1)
        for lin = 1:size(stateData, 1)
        
        plot([stateData(lin, 1, nStatePairs), stateData(lin, 1, nStatePairs+1)], [stateData(lin, 2, nStatePairs), stateData(lin, 2, nStatePairs+1)], 'color', blueVec, 'linewidth', 2); hold on

        end
    end
    
    % we do this again so it overlays the lines themselves
    for i = 1:nStates
            scatter(stateData(:, 1, i), stateData(:, 2, i), 'filled', 'k', ... 
                  'MarkerEdgeColor', [0.2 0.2 0.2],     ...
                  'MarkerFaceColor', [1 1 1], ...
                  'LineWidth', 2)%,                ...
                  %'jitter', 'on')
    end
    
    
end

figElements(curr, figInfo{:})
box off
end
