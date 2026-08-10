function [out, keep_tr] = removenans(inp, dim)
% removes nans in either rows or columns
% assumes, there is an equal number of them across rows/columns

if dim == 1
    keep_tr = find(~isnan(inp(:, 1)));
    inp = inp(keep_tr, :);
else
    keep_tr = find(~isnan(inp(1, :)));
    inp = inp(:, keep_tr);
end
out = inp;
end