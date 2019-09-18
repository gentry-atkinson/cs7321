% This function separates stimulus samples into saccades
function [stimulus_saccades_detected_IVT,stimulus_record] = xy_Saccade_detection_parameters_stimulus(stimulus_record)

global DELTA_T_SEC;
global STIMULUS_SACCADE_AMPLITUDE;
global SUM_STIMULUS_SACCADE_AMPLITUDE;

global STIMULUS_SACCADE_AMPLITUDE_AVR;
global STIMULUS_SACCADE_CORRUPTED_PER;
global STIMULUS_SACCADE_MICRO_PER;

global STIMULUS_SACCADE_COUNTER;
 
global STI_SAC_PER;
global SUBJECT_FILE_NAME
global SUBJECT_FILES_OUTPUT_DIR;

%global stimulus_saccades_detected_IVT;% strucutre hold detected stimulus saccades

stimulus_saccade_detection_threshold_deg_sec = 30;
stimulus_fixation_detection_threshold_deg_sec =5;

stimulus_saccade_counter = 0;
stimulus_fixation_counter = 0;
stimulus_pursuit_counter = 0;
stimulus_saccade_detected_counter = 0;
qualified_saccades_duration_sec = 0;
stimulus_noise_counter = 0;




%% IVT - Algorithm for the Stimulus calculation
for t=1:length(stimulus_record)
    
  if(isempty(stimulus_record(t).xy_stimulus_velocity_measured_deg)||isnan(stimulus_record(t).xy_stimulus_velocity_measured_deg))
        % NOISE
        stimulus_record(t).xy_stimulus_movement_IVT = 4; 
        stimulus_noise_counter = stimulus_noise_counter+ 1;
  else
      if(abs(stimulus_record(t).xy_stimulus_velocity_measured_deg) >= stimulus_saccade_detection_threshold_deg_sec)
           % SACCADE
           stimulus_record(t).xy_stimulus_movement_IVT = 2;
           stimulus_saccade_counter = stimulus_saccade_counter + 1;
           
      elseif(abs(stimulus_record(t).xy_stimulus_velocity_measured_deg) < stimulus_fixation_detection_threshold_deg_sec)
           % FIXATION
           stimulus_record(t).xy_stimulus_movement_IVT = 1;
           stimulus_fixation_counter = stimulus_fixation_counter + 1;
            
      else
          % PURSUIT
          stimulus_record(t).xy_stimulus_movement_IVT = 3;
          stimulus_pursuit_counter = stimulus_pursuit_counter + 1;      
      end
  end
  
  
%   display(stimulus_record(t).xy_stimulus_movement_IVT);
end



STI_SAC_PER = 100 * stimulus_saccade_counter / (stimulus_saccade_counter + stimulus_fixation_counter + stimulus_pursuit_counter);
% display(length(stimulus_record));
% display(stimulus_saccade_counter);
% display(stimulus_fixation_counter);
% display(stimulus_pursuit_counter);
% display(stimulus_noise_counter);


%% Identifying stimulus saccades 
% creating filtered saccade structure
for t=2:length(stimulus_record)
   if(stimulus_record(t).xy_stimulus_movement_IVT == 2)
%       if(stimulus_record(t-1).gaze_validity==0)       
%           stimulus_record(t-1).xy_stimulus_movement_IVT_saccade = 1;                    
%       end
      if(stimulus_record(t).gaze_validity==0)       
          stimulus_record(t).xy_stimulus_movement_IVT_saccade = 1;    
%           stimulus_record(t).xy_stimulus_movement_IVT = 2;                    
      end
      
   end
end


for t=1:length(stimulus_record)
    if(stimulus_record(t).xy_stimulus_movement_IVT_saccade == 1)
           
    else
       stimulus_record(t).xy_stimulus_movement_IVT_saccade = 0;
    end
end

% filling out additional information about stimulus saccades
% the values are chosen to have any number that is extremly unlikely to
% hapen during the life span of this program
stimulus_saccade_onset_x_pos_deg = 100000; 
stimulus_saccade_onset_y_pos_deg = 100000; 
stimulus_saccade_end_x_pos_deg = 100000;
stimulus_saccade_end_y_pos_deg = 100000;
stimulus_saccade_onset_time_smpl = 100000; 
stimulus_saccade_end_time_smpl = 100000;



for t=1:length(stimulus_record)-1
    if(stimulus_record(t).xy_stimulus_movement_IVT_saccade == 1)     

       if(stimulus_saccade_onset_x_pos_deg == 100000)
          stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg;
          stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg;
          stimulus_saccade_onset_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg;
          stimulus_saccade_onset_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg;
          stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_time_sec = (t-1)*DELTA_T_SEC; 
          %display(stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_time_sec);
          stimulus_saccade_onset_time_smpl = t;
          stimulus_saccade_detected_counter = stimulus_saccade_detected_counter + 1;  

       end
       
       % test if the next consequtive sample is a part of a saccade or not    
       if(stimulus_record(t+1).xy_stimulus_movement_IVT_saccade == 0)
           stimulus_saccade_end_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg;
           stimulus_saccade_end_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg;
           
           stimulus_record(t).xy_stimulus_movement_IVT_saccade_end_time_sec = (t-1)*DELTA_T_SEC;     
           stimulus_saccade_end_time_smpl = t;
           
           for k=stimulus_saccade_onset_time_smpl:stimulus_saccade_end_time_smpl
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_onset_x_pos_deg = stimulus_saccade_onset_x_pos_deg;
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_onset_y_pos_deg = stimulus_saccade_onset_y_pos_deg;
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_end_x_pos_deg = stimulus_saccade_end_x_pos_deg; 
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_end_y_pos_deg = stimulus_saccade_end_y_pos_deg; 
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_onset_time_sec = (stimulus_saccade_onset_time_smpl - 1)*DELTA_T_SEC;                    
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_end_time_sec = (stimulus_saccade_end_time_smpl - 1)*DELTA_T_SEC;  
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_amplitude_deg = sqrt((stimulus_saccade_onset_x_pos_deg - stimulus_saccade_end_x_pos_deg)^2 + (stimulus_saccade_onset_y_pos_deg - stimulus_saccade_end_y_pos_deg)^2);

               stimulus_record(k).xy_stimulus_movement_IVT_saccade_onset_time_smpl = stimulus_saccade_onset_time_smpl;  
               stimulus_record(k).xy_stimulus_movement_IVT_saccade_offset_time_smpl = stimulus_saccade_end_time_smpl;  
              
           end
            stimulus_saccade_onset_x_pos_deg = 100000; 
            stimulus_saccade_onset_y_pos_deg = 100000; 
            stimulus_saccade_end_x_pos_deg = 100000;
            stimulus_saccade_end_y_pos_deg = 100000;
            stimulus_saccade_onset_time_smpl = 100000; 
            stimulus_saccade_end_time_smpl = 100000;        
       end
           
    end       
end

%creating an array to hold filtered final stimulus data
stimulus_saccades_detected_IVT.stimulus_saccade_onset_sec = 0;
stimulus_saccades_detected_IVT.stimulus_saccade_onset_x_deg = 0;
stimulus_saccades_detected_IVT.stimulus_saccade_offset_x_deg = 0;
stimulus_saccades_detected_IVT.stimulus_saccade_onset_time_smpl = 0;
stimulus_saccades_detected_IVT.stimulus_saccade_offset_time_smpl = 0;

for t=1:length(stimulus_record)
    if(stimulus_record(t).xy_stimulus_movement_IVT_saccade == 1) 
         stimulus_saccade_detected_counter = stimulus_saccade_detected_counter + 1;
         stimulus_saccades_detected_IVT(stimulus_saccade_detected_counter).stimulus_saccade_onset_sec = stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_time_sec;
         stimulus_saccades_detected_IVT(stimulus_saccade_detected_counter).stimulus_saccade_onset_x_deg = stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_x_pos_deg;
         stimulus_saccades_detected_IVT(stimulus_saccade_detected_counter).stimulus_saccade_offset_x_deg = stimulus_record(t).xy_stimulus_movement_IVT_saccade_end_x_pos_deg;
         stimulus_saccades_detected_IVT(stimulus_saccade_detected_counter).stimulus_saccade_onset_time_smpl = stimulus_record(t).xy_stimulus_movement_IVT_saccade_onset_time_smpl;
         stimulus_saccades_detected_IVT(stimulus_saccade_detected_counter).stimulus_saccade_offset_time_smpl = stimulus_record(t).xy_stimulus_movement_IVT_saccade_offset_time_smpl;
         
         
         if(t ~=1)
%             display(stimulus_record(t).xy_stimulus_movement_IVT_saccade_offset_time_smpl);
%             display(stimulus_record(t).x_stimulus_pos_measured_deg);
%             display(stimulus_record(t).xy_stimulus_movement_IVT_saccade_offset_time_smpl-1);
%             display(stimulus_record(t-1).x_stimulus_pos_measured_deg);
              stimulus_record(t).xy_stimulus_movement_IVT_saccade_amplitude_deg = sqrt((stimulus_record(t).x_stimulus_pos_measured_deg-stimulus_record(t-1).x_stimulus_pos_measured_deg)^2 + (stimulus_record(t).y_stimulus_pos_measured_deg-stimulus_record(t-1).y_stimulus_pos_measured_deg)^2);
         end
%          display(stimulus_record(t).xy_stimulus_movement_IVT_saccade_amplitude_deg);
    end
end

%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit = 0;    
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_x_pos_deg = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_x_pos_deg = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_y_pos_deg = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_y_pos_deg = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_sec = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_sec = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_smpl = 0;
%     stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_smpl = 0;

%% Pursuit detection


%Identifying pursuits 
% creating filtered pursuits structure
for t=2:length(stimulus_record)
   if(stimulus_record(t).xy_stimulus_movement_IVT == 3)
      if(stimulus_record(t-1).gaze_validity==0)       
          stimulus_record(t-1).xy_stimulus_movement_EMD_pursuit = 1;  
          % these lines are supposed to expand the saccade one sample up
          % and one sample down
%           it is temporary "hack" - will need to fix it later for better
%           eye movement detecton
%           eye_record(t-1).xy_movement_IVT = 2;          
      end
      if(stimulus_record(t).gaze_validity==0)       
          stimulus_record(t).xy_stimulus_movement_EMD_pursuit = 1;   
          stimulus_record(t).xy_stimulus_movement_IVT = 3;                  
      end
       
   end
end

for t=1:length(stimulus_record)
   if(stimulus_record(t).xy_stimulus_movement_IVT == 3 && stimulus_record(t).gaze_validity==0)
          stimulus_record(t).xy_stimulus_movement_EMD_pursuit = 1;       
   else
          stimulus_record(t).xy_stimulus_movement_EMD_pursuit = 0;         
   end
end



pursuit_group_flag = 1;

for t=1:length(stimulus_record)-1
    
  if(stimulus_record(t).xy_stimulus_movement_EMD_pursuit == 1) 
       
    if(pursuit_group_flag)
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg;
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg;
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_sec = (t-1)*DELTA_T_SEC;
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_smpl = t;
        pursuit_group_flag = 0;
        
        pursuit_onset_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg; 
        pursuit_onset_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg; 
        pursuit_onset_time_smpl = t;
        
    end
    
    if(stimulus_record(t+1).xy_stimulus_movement_EMD_pursuit == 0)
        
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg;
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg;
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_sec = (t-1)*DELTA_T_SEC;
        stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_smpl = t;
        
        pursuit_offset_x_pos_deg = stimulus_record(t).x_stimulus_pos_measured_deg ;
        pursuit_offset_y_pos_deg = stimulus_record(t).y_stimulus_pos_measured_deg; 
        pursuit_offset_time_smpl = t;
        
        for k=pursuit_onset_time_smpl:pursuit_offset_time_smpl
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_onset_x_pos_deg = pursuit_onset_x_pos_deg;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_onset_y_pos_deg = pursuit_onset_y_pos_deg;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_onset_time_sec = (pursuit_onset_time_smpl-1)*DELTA_T_SEC;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_onset_time_smpl = pursuit_onset_time_smpl;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_offset_x_pos_deg = pursuit_offset_x_pos_deg;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_offset_y_pos_deg = pursuit_offset_y_pos_deg;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_offset_time_sec = (pursuit_offset_time_smpl-1)*DELTA_T_SEC;
            stimulus_record(k).xy_stimulus_movement_EMD_pursuit_offset_time_smpl = pursuit_offset_time_smpl;
        end
%         display(stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_time_smpl);
%         display(stimulus_record(t).xy_stimulus_movement_EMD_pursuit_onset_x_pos_deg);
%         display(stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_time_smpl);
%         display(stimulus_record(t).xy_stimulus_movement_EMD_pursuit_offset_x_pos_deg);
        pursuit_group_flag = 1;
    end
        
  end
end

 


return
