function out = estimate_betas(inp)
% inp = [nFeatures x nDatapoints]

beta_out   = [];
num_points = size(inp, 2);
for i = 1:size(inp, 1)
    curr_sub = squeeze(inp(i, :));
    curr_sub = removenans(curr_sub, 2);
    num_effective_points = length(curr_sub);
    full_dm  = [ones(num_effective_points, 1), (1:num_effective_points)'];

    [x] = ols(curr_sub', full_dm, [0, 1]);
    beta_out(i) = x;
end

out = beta_out;

end