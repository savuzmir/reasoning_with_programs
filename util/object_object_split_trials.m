function [correct_trials, incorrect_trials] = ...
        object_object_split_trials(replay, trial_acc)
% OBJECT_OBJECT_SPLIT_TRIALS Split replay arrays by behavioural outcome.

correct_trials = replay;
incorrect_trials = replay;

for s = 1:size(replay, 4)
    accuracy = trial_acc{s}(:);
    n = min(size(replay, 1), numel(accuracy));
    trial_index = (1:n)';
    correct_trials(trial_index(accuracy(1:n) < 1), :, :, s) = nan;
    incorrect_trials(trial_index(accuracy(1:n) ~= 0), :, :, s) = nan;
    correct_trials((n + 1):end, :, :, s) = nan;
    incorrect_trials((n + 1):end, :, :, s) = nan;
end

end
