function z = object_object_subject_z(replay, lags)

n_sub = size(replay, 4);
z = nan(n_sub, 1);

for s = 1:n_sub
    values = squeeze(mean(mean( ...
        replay(:, lags, :, s), 1, 'omitnan'), 2, 'omitnan'));
    z(s) = zscore_ind(values(1), values(2:end));
end

end
