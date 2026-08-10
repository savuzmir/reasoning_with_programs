function effect = extract_three_step_computation_effect( ...
    three_step_values, subject_ids, ent_rol_lag, steps)

swap_output = three_step_values.three_step_seq_swap( ...
    :, ent_rol_lag, :, steps, 2, subject_ids);
swap_input = three_step_values.three_step_seq_swap( ...
    :, ent_rol_lag, :, steps, 1, subject_ids);

swap_output = mean(swap_output, 4, 'omitnan');
swap_output = mean(swap_output, 1, 'omitnan');
swap_input = mean(swap_input, 4, 'omitnan');
swap_input = mean(swap_input, 1, 'omitnan');

effect = squeeze(swap_output - swap_input)';

end
