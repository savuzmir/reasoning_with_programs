function tmp_out = average_lag_neighbors(inp, lag_smooth)

tmp_out = [];
    for np = 1:size(inp, 3)
        tmp_out(:, :, np) = q_smooth(inp(:, :, np), lag_smooth, 1);
    end
end