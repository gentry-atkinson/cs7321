% I-VT, eye movement detection by Velocity Threshold Model
function [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD]= EMD_IVT(eye_record)

    display('>>> EMD_IVT starts..................................................................');
    
    global FIX_PER;
    global SAC_PER;
    global PUR_PER;
    global NOISE_PER;
    global SACCADE_DETECTION_THRESHOLD_DEG_SEC;
    global FIXATION_DETECTION_THRESHOLD_DEG_SEC;

 %% YOU MUST INITIALIZE THE VARIABLES THAT ARE RELATED TO YOUR CLASSIFICATION METHOD HERE 
 %% IVT RELATED PARAMETERS
 SACCADE_DETECTION_THRESHOLD_DEG_SEC = 100;
 FIXATION_DETECTION_THRESHOLD_DEG_SEC =30;
 %  PURSUIT_DETECTION_THRESHOLD_DEG_SEC  = 10;
    
    %% I-VT algorithm
    fixation_counter = 0;
    saccade_counter = 0;
    pursuit_counter = 0;
    noise_counter = 0;
    
    for t=1:length(eye_record)
      if(isempty(eye_record(t).xy_velocity_measured_deg)||isnan(eye_record(t).xy_velocity_measured_deg))
            % NOISE
            % NOISE MUST BE IDENTIFIED AS NUMBER 4
            eye_record(t).xy_movement_EMD = 4; 
            noise_counter = noise_counter + 1; 
      else
          if(abs(eye_record(t).xy_velocity_measured_deg) >= SACCADE_DETECTION_THRESHOLD_DEG_SEC)
              % SACCADE
              % SACCADES MUST BE IDENTIFIED AS NUMBER 2
              eye_record(t).xy_movement_EMD = 2; 
              saccade_counter = saccade_counter + 1;
          elseif(abs(eye_record(t).xy_velocity_measured_deg) < FIXATION_DETECTION_THRESHOLD_DEG_SEC)
              % FIXATION
              % FIXATIONS MUST BE IDENTIFIED AS NUMBER 1
              eye_record(t).xy_movement_EMD = 1; 
              fixation_counter = fixation_counter + 1;
          else
              % PURSUIT
              % PURSUITS MUST BE IDENTIFIED AS NUMBER 3
             eye_record(t).xy_movement_EMD = 3; 
             pursuit_counter = pursuit_counter + 1;      
          end
      end
    end


    FIX_PER     = 100 * fixation_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    SAC_PER     = 100 * saccade_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    PUR_PER     = 100 * pursuit_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    NOISE_PER   = 100 * noise_counter /(saccade_counter + fixation_counter + pursuit_counter + noise_counter);


    %% Call the EMD_Merge for grouping and Merging Saccades, Fixations and Pursuits 
    [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_Merge(eye_record);


return 
