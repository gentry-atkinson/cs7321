function stimulus_record = initialize_stimulus_record(stimulus_record_length) 

stimulus_record = repmat(struct('xy_stimulus_movement_IVT', 0,  'xy_stimulus_movement_IVT_saccade', 0, 'xy_stimulus_movement_IVT_saccade_onset_x_pos_deg', 0, 'xy_stimulus_movement_IVT_saccade_end_x_pos_deg', 0, 'xy_stimulus_movement_IVT_saccade_onset_y_pos_deg', 0, 'xy_stimulus_movement_IVT_saccade_end_y_pos_deg', 0, 'xy_stimulus_movement_IVT_saccade_onset_time_sec', 0,  'xy_stimulus_movement_IVT_saccade_end_time_sec', 0, 'xy_stimulus_movement_IVT_saccade_amplitude_deg', 0, 'xy_stimulus_movement_IVT_saccade_onset_time_smpl', 0,  'xy_stimulus_movement_IVT_saccade_offset_time_smpl', 0),1,stimulus_record_length);
 
for t=1:stimulus_record_length
        %stimulus
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit = 0;    
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_x_pos_deg = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_x_pos_deg = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_y_pos_deg = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_y_pos_deg = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_sec = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_sec = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_smpl = 0;
    stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_smpl = 0;

end

return
 
 