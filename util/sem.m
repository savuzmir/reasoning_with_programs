function out = sem(inp, dim)
% computes standard error of the mean
out = (nanstd(inp, [], dim)./ sqrt(sum(~isnan(inp), dim)));
end
