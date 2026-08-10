function out = zscore_ind(inp1, inp2)
out  = (inp1-nanmean(inp2))./nanstd(inp2);
