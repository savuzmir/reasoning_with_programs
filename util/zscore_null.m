function out = zscore_null(inp)
    % function out = zscore_null(inp) 
    % computes z score of real data off the null
    % assumes real data is 1st element of 3rd dim or 1st element of 2nd dim

    if size(inp, 3) ~= 1
       out = (inp(:, :, 1) - nanmean(inp(:, :, 2:end), 3)) ./ nanstd(inp(:, :, 2:end), [], 3);
    elseif size(inp, 3) == 1 & size(inp, 2) ~= 1
       out = (inp(:, 1) - nanmean(inp(:, 2:end), 2)) ./ nanstd(inp(:, 2:end), [], 2);
    end
end