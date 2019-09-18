% Global grouping, mering algorithm for fixation,saccade and pursuits
function [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_Merge(eye_record)

        global DELTA_T_SEC;
        global SUBJECT_NAME_NUMBER;
        global SUBJECT_FILES_OUTPUT_DIR;% directory to where subject files are going to be stored
        
        global SUM_SACCADE_AMPLITUDE;
        global MINIMUM_SACCADE_RANGE_DEG;
        global SACCADE_AMPLITUDE_AVR;
        global SACCADE_CORRUPTED_PER;
        global SACCADE_MICRO_PER;
        global SACCADE_COUNTER;
        
        global BLINK_DURATION_SEC
        global FIXATION_MERGE_DISTANCE_THRESHOLD_DEG
        global FIXATION_MINIMUM_DURATION_SEC;
        global SUM_FIXATION_DURATION_SEC;
        global FIXATION_DURATION_AVR_SEC;
        global FIXATION_COUNTER;
        global TOTAL_EYE_PATH_DEG;
        global stopper; % this will stop doing any other stuff on the subject if the detection is not successful
        
        stopper = 0;
        
        %% Saccade grouping
 
            % This step simply increase the saccade 1 sample backward and
            % forward to increase the efficiency.
        for t=2:length(eye_record)
           if(eye_record(t).xy_movement_EMD == 2)
              if(eye_record(t-1).gaze_validity==0)       
                  eye_record(t-1).xy_movement_EMD = 2;  
              end
           end
        end

        
         % This will simply group consecutive saccades detected by each algorithm and assign saccade properties to each and every saccadic point.
            
         saccade_detected_counter   = 0;
         saccade_group_flag         = 1;
         
         for t=1:length(eye_record)-1
          if(eye_record(t).xy_movement_EMD == 2 ) 
            if(saccade_group_flag)
                eye_record(t).xy_movement_EMD_saccade_onset_x_pos_deg = eye_record(t).x_pos_measured_deg;
                eye_record(t).xy_movement_EMD_saccade_onset_y_pos_deg = eye_record(t).y_pos_measured_deg;
                eye_record(t).xy_movement_EMD_saccade_onset_time_sec = (t-1)*DELTA_T_SEC;
                eye_record(t).xy_movement_EMD_saccade_onset_time_smpl = t;
                saccade_group_flag = 0;

                saccade_onset_x_pos_deg = eye_record(t).x_pos_measured_deg; 
                saccade_onset_y_pos_deg = eye_record(t).y_pos_measured_deg; 
                saccade_onset_time_smpl = t;
                
                saccade_detected_counter = saccade_detected_counter + 1;    
            end

            if((eye_record(t+1).xy_movement_EMD ~= 2 || (t+1)==length(eye_record)) )

                eye_record(t).xy_movement_EMD_saccade_offset_x_pos_deg = eye_record(t).x_pos_measured_deg;
                eye_record(t).xy_movement_EMD_saccade_offset_y_pos_deg = eye_record(t).y_pos_measured_deg;
                eye_record(t).xy_movement_EMD_saccade_offset_time_sec = (t-1)*DELTA_T_SEC;
                eye_record(t).xy_movement_EMD_saccade_offset_time_smpl = t;

                saccade_offset_x_pos_deg = eye_record(t).x_pos_measured_deg; 
                saccade_offset_y_pos_deg = eye_record(t).y_pos_measured_deg; 
                if((t+1)==length(eye_record))
                    saccade_offset_time_smpl = t+1;
                else
                    saccade_offset_time_smpl = t;
                end
                

                for k=saccade_onset_time_smpl:saccade_offset_time_smpl
                    eye_record(k).xy_movement_EMD_saccade_onset_x_pos_deg = saccade_onset_x_pos_deg;
                    eye_record(k).xy_movement_EMD_saccade_onset_y_pos_deg = saccade_onset_y_pos_deg;
                    eye_record(k).xy_movement_EMD_saccade_onset_time_sec = (saccade_onset_time_smpl-1)*DELTA_T_SEC;
                    eye_record(k).xy_movement_EMD_saccade_onset_time_smpl = saccade_onset_time_smpl;
                    eye_record(k).xy_movement_EMD_saccade_offset_x_pos_deg = saccade_offset_x_pos_deg;
                    eye_record(k).xy_movement_EMD_saccade_offset_y_pos_deg = saccade_offset_y_pos_deg;
                    eye_record(k).xy_movement_EMD_saccade_offset_time_sec = (saccade_offset_time_smpl-1)*DELTA_T_SEC;
                    eye_record(k).xy_movement_EMD_saccade_offset_time_smpl = saccade_offset_time_smpl;
                    eye_record(k).xy_movement_EMD_saccade_amplitude_deg = sqrt((saccade_onset_x_pos_deg - saccade_offset_x_pos_deg)^2 + (saccade_onset_y_pos_deg - saccade_offset_y_pos_deg)^2);
                end
                saccade_group_flag = 1;
            end
          end
         end

 
                % This sub section will further process individual sub
                % groups of saccades and create a seperate array to hold
                % all the saccadic groups before filtering.
                
        saccade_detected_EMD.saccade_amplitude_deg  = 0;
        saccade_detected_EMD.saccade_onset_x_degg   = 0;
        saccade_detected_EMD.saccade_onset_y_deg    = 0;
        saccade_detected_EMD.saccade_offset_x_deg   = 0;
        saccade_detected_EMD.saccade_offset_y_deg   = 0;
        saccade_detected_EMD.saccade_onset_sec      = 0;
        saccade_detected_EMD.saccade_offset_sec     = 0;
        saccade_detected_EMD.saccade_onset_smpl     = 0;
        saccade_detected_EMD.saccade_offset_smpl    = 0;
        
        saccade_detected_counter = 0;
        saccade_detected_onset_smpl = 0;
        for t=1: length(eye_record)
          if(eye_record(t).xy_movement_EMD == 2 && eye_record(t).gaze_validity ==0)
 
              if(saccade_detected_onset_smpl == 0)
                saccade_detected_onset_smpl  = eye_record(t).xy_movement_EMD_saccade_onset_time_smpl; 
                saccade_detected_counter = saccade_detected_counter +1;

                saccade_detected_EMD(saccade_detected_counter).saccade_onset_x_deg      = eye_record(t).xy_movement_EMD_saccade_onset_x_pos_deg;
                saccade_detected_EMD(saccade_detected_counter).saccade_onset_y_deg      = eye_record(t).xy_movement_EMD_saccade_onset_y_pos_deg;
                saccade_detected_EMD(saccade_detected_counter).saccade_offset_x_deg     = eye_record(t).xy_movement_EMD_saccade_offset_x_pos_deg;
                saccade_detected_EMD(saccade_detected_counter).saccade_offset_y_deg     = eye_record(t).xy_movement_EMD_saccade_offset_y_pos_deg;
                saccade_detected_EMD(saccade_detected_counter).saccade_onset_sec        = eye_record(t).xy_movement_EMD_saccade_onset_time_sec;
                saccade_detected_EMD(saccade_detected_counter).saccade_offset_sec       = eye_record(t).xy_movement_EMD_saccade_offset_time_sec;
                saccade_detected_EMD(saccade_detected_counter).saccade_onset_smpl       = eye_record(t).xy_movement_EMD_saccade_onset_time_smpl;
                saccade_detected_EMD(saccade_detected_counter).saccade_offset_smpl      = eye_record(t).xy_movement_EMD_saccade_offset_time_smpl;
                saccade_detected_EMD(saccade_detected_counter).saccade_amplitude_deg    = eye_record(t).xy_movement_EMD_saccade_amplitude_deg;
                SUM_SACCADE_AMPLITUDE = SUM_SACCADE_AMPLITUDE + abs(eye_record(t).xy_movement_EMD_saccade_amplitude_deg);
              else
                  if(saccade_detected_onset_smpl == eye_record(t).xy_movement_EMD_saccade_onset_time_smpl )
                      continue;
                  else
                        saccade_detected_onset_smpl  = eye_record(t).xy_movement_EMD_saccade_onset_time_smpl;
                        saccade_detected_counter = saccade_detected_counter +1;

                        saccade_detected_EMD(saccade_detected_counter).saccade_onset_x_deg      = eye_record(t).xy_movement_EMD_saccade_onset_x_pos_deg;
                        saccade_detected_EMD(saccade_detected_counter).saccade_onset_y_deg      = eye_record(t).xy_movement_EMD_saccade_onset_y_pos_deg;
                        saccade_detected_EMD(saccade_detected_counter).saccade_offset_x_deg     = eye_record(t).xy_movement_EMD_saccade_offset_x_pos_deg;
                        saccade_detected_EMD(saccade_detected_counter).saccade_offset_y_deg     = eye_record(t).xy_movement_EMD_saccade_offset_y_pos_deg;
                        saccade_detected_EMD(saccade_detected_counter).saccade_onset_sec        = eye_record(t).xy_movement_EMD_saccade_onset_time_sec;
                        saccade_detected_EMD(saccade_detected_counter).saccade_offset_sec       = eye_record(t).xy_movement_EMD_saccade_offset_time_sec;
                        saccade_detected_EMD(saccade_detected_counter).saccade_onset_smpl       = eye_record(t).xy_movement_EMD_saccade_onset_time_smpl;
                        saccade_detected_EMD(saccade_detected_counter).saccade_offset_smpl      = eye_record(t).xy_movement_EMD_saccade_offset_time_smpl;
                        saccade_detected_EMD(saccade_detected_counter).saccade_amplitude_deg    = eye_record(t).xy_movement_EMD_saccade_amplitude_deg;
                        SUM_SACCADE_AMPLITUDE = SUM_SACCADE_AMPLITUDE + abs(eye_record(t).xy_movement_EMD_saccade_amplitude_deg);
                 end
              end

          end
        end
 
        
        
            % This sub section will filter the detected saccades and create
            % filtered saccadic array with the properties and write data
            % into files.
        latency                         = 0;
        corrupted_saccades_counter      = 0;
        micro_saccade_counter           = 0;
        saccade_total_amplitude         = 0;
        filtered_saccade_counter        = 0;
        qualified_saccades_duration_sec = 0;
 
        saccade_filtered_EMD_check = 1;
        FID_saccades_trajectories = fopen(strcat(SUBJECT_FILES_OUTPUT_DIR, SUBJECT_NAME_NUMBER,'_saccade_trajectories.txt'), 'wt');
        FID_saccades_data = fopen(strcat(SUBJECT_FILES_OUTPUT_DIR, SUBJECT_NAME_NUMBER,'_Saccade_data_filtered.txt'), 'wt'); 
        fprintf(FID_saccades_data,'Onset_sample, Offset_sample, Onset_x_pos, Onset_y_pos, Offset_x_pos, Offset_y_pos, Saccade_Amplitude, Saccade_Duration  \n');
        
        for t=1:length(saccade_detected_EMD)
            if(length(saccade_detected_EMD)==1)
                break;
            end
            if(t>1)
                latency = 1000*(saccade_detected_EMD(t).saccade_onset_sec  - saccade_detected_EMD(t-1).saccade_offset_sec);
            end

            % detecting a saccade that is corrupted by noise. if the eye-position sample before or after the saccade is corrupted by noise
            eye_pos_sample_prior_saccade = saccade_detected_EMD(t).saccade_onset_smpl - 1;

            if(eye_pos_sample_prior_saccade == 0) %if the this is the first sample
                eye_pos_sample_prior_saccade = 1;
            end
            if((saccade_detected_EMD(t).saccade_offset_smpl)~=length(eye_record)) %not the last sample
                eye_pos_sample_after_saccade = saccade_detected_EMD(t).saccade_offset_smpl + 1;
            else
                eye_pos_sample_after_saccade = length(eye_record);
            end

            if((eye_record(eye_pos_sample_prior_saccade).gaze_validity > 0)||(eye_record(eye_pos_sample_after_saccade).gaze_validity > 0))
                corrupted_saccades_counter = corrupted_saccades_counter + 1;
            else
                if(abs(saccade_detected_EMD(t).saccade_amplitude_deg) > MINIMUM_SACCADE_RANGE_DEG)
                    saccade_filtered_EMD_check = 0;
                    filtered_saccade_counter = filtered_saccade_counter + 1;
                    saccade_filtered_EMD(filtered_saccade_counter) =  saccade_detected_EMD(t);
                    saccade_total_amplitude = saccade_total_amplitude + abs(saccade_detected_EMD(t).saccade_amplitude_deg);
                    sac_dur_sec = (saccade_detected_EMD(t).saccade_offset_sec - saccade_detected_EMD(t).saccade_onset_sec);
                    qualified_saccades_duration_sec = qualified_saccades_duration_sec + sac_dur_sec;
                    for m=saccade_detected_EMD(t).saccade_onset_smpl:saccade_detected_EMD(t).saccade_offset_smpl
                        eye_record(m).xy_movement_EMD_plot = 2; % 1-fixation, 2- saccade, 3-pursuit
                        fprintf(FID_saccades_trajectories, '%2.4f,%2.4f ', eye_record(m).x_pos_measured_deg,eye_record(m).y_pos_measured_deg);
                    end % end for
                    fprintf(FID_saccades_data,'%d   ,%d     ,%0.2f  ,%0.2f  ,%0.2f  ,%0.2f  ,%0.2f  ,%0.2f  \n',saccade_detected_EMD(t).saccade_onset_smpl,saccade_detected_EMD(t).saccade_offset_smpl,saccade_detected_EMD(t).saccade_onset_x_deg,saccade_detected_EMD(t).saccade_onset_y_deg,saccade_detected_EMD(t).saccade_offset_x_deg,saccade_detected_EMD(t).saccade_offset_y_deg,saccade_detected_EMD(t).saccade_amplitude_deg,sac_dur_sec);
                    fprintf(FID_saccades_trajectories,'\n');
                    
                else
                    micro_saccade_counter = micro_saccade_counter + 1;
                end %end if
            end %endif
        end %end for
        
        SACCADE_CORRUPTED_PER = 100*corrupted_saccades_counter/length(saccade_detected_EMD);
        SACCADE_MICRO_PER = 100*micro_saccade_counter/(length(saccade_detected_EMD)-corrupted_saccades_counter);
        SACCADE_AMPLITUDE_AVR = saccade_total_amplitude/(length(saccade_detected_EMD)-corrupted_saccades_counter - micro_saccade_counter);
        SACCADE_COUNTER = length(saccade_detected_EMD)-corrupted_saccades_counter - micro_saccade_counter;
        
        
        
        fclose(FID_saccades_data);
        fclose(FID_saccades_trajectories);
        
        
 
        
        %% Fixation grouping
        
        % minimum fixation duration equals sampling interval to "pick" the smallest fixations
        fix_min_duration_sec = DELTA_T_SEC;
        fixation_min_duration_smpl = round(fix_min_duration_sec/DELTA_T_SEC); 
        fixation_counter = 0;
        fixation_detected_counter = 0;
        fixation_break = 1;
        fixation_x_pos_deg = 0;
        fixation_y_pos_deg = 0;
        fixation_dur_sec = 0;
        qualified_fixations_duration_sec = 0;
        fix_count = 0;
        
        fixation_detected_EMD.fixation_x_pos_deg        = 0;
        fixation_detected_EMD.fixation_y_pos_deg        = 0;
        fixation_detected_EMD.fixation_onset_sec        = 0;
        fixation_detected_EMD.fixation_offset_sec       = 0;
        fixation_detected_EMD.fixation_onset_smpl       = 0;
        fixation_detected_EMD.fixation_offset_smpl      = 0;
        fixation_detected_EMD.fixation_duration_sec     = 0;
        fixation_detected_EMD.latency_sec               = 0;
        fixation_detected_EMD.fixation_prev_dist_deg    = 0;
        
        for t=1:length(eye_record)
            if(eye_record(t).xy_movement_EMD == 1)
                fixation_counter = fixation_counter + 1;
                fix_count = fix_count + 1;
            else     
                if(fixation_break == 0)
                    for k=(t - fixation_counter):(t-1)
                        fixation_x_pos_deg = fixation_x_pos_deg + eye_record(k).x_pos_measured_deg;
                        fixation_y_pos_deg = fixation_y_pos_deg + eye_record(k).y_pos_measured_deg;
                    end
                    fixation_x_pos_deg = fixation_x_pos_deg / (fixation_counter);
                    fixation_y_pos_deg = fixation_y_pos_deg / (fixation_counter);
                    
                    for k=(t - fixation_counter):(t-1)  
                        eye_record(k).xy_movement_EMD_fixation_onset_time_sec = (t - fixation_counter)*DELTA_T_SEC;
                        eye_record(k).xy_movement_EMD_fixation_offset_time_sec = (t - 1)*DELTA_T_SEC;
                        fixation_dur_sec = eye_record(k).xy_movement_EMD_fixation_offset_time_sec - eye_record(k).xy_movement_EMD_fixation_onset_time_sec;
                        eye_record(k).xy_movement_EMD_fixation_duration_time_sec = fixation_dur_sec;
%                         eye_record(k).xy_movement_EMD_fixation = 1;              
                    end   
                    
                    % recording data about this fixation into the fixation array
                    fixation_detected_counter = fixation_detected_counter + 1;
                    fixation_detected_EMD(fixation_detected_counter).fixation_x_pos_deg = fixation_x_pos_deg;
                    fixation_detected_EMD(fixation_detected_counter).fixation_y_pos_deg = fixation_y_pos_deg;
                    fixation_detected_EMD(fixation_detected_counter).fixation_onset_sec = (t - fixation_counter)*DELTA_T_SEC;
                    fixation_detected_EMD(fixation_detected_counter).fixation_offset_sec = (t - 1)*DELTA_T_SEC;
                    fixation_detected_EMD(fixation_detected_counter).fixation_onset_smpl = (t - fixation_counter);
                    fixation_detected_EMD(fixation_detected_counter).fixation_offset_smpl = (t - 1);
                    fixation_detected_EMD(fixation_detected_counter).fixation_duration_sec = fixation_dur_sec; 
                    if(fixation_detected_counter > 1)
                        fixation_detected_EMD(fixation_detected_counter).latency_sec = (fixation_detected_EMD(fixation_detected_counter).fixation_onset_sec - fixation_detected_EMD(fixation_detected_counter-1).fixation_offset_sec);
                        fixation_detected_EMD(fixation_detected_counter).fixation_prev_dist_deg = sqrt((fixation_detected_EMD(fixation_detected_counter).fixation_x_pos_deg - fixation_detected_EMD(fixation_detected_counter-1).fixation_x_pos_deg)^2 + (fixation_detected_EMD(fixation_detected_counter).fixation_y_pos_deg - fixation_detected_EMD(fixation_detected_counter-1).fixation_y_pos_deg)^2);
                    end
                    
                end
                
                % resseting the counters
                fixation_counter = 0;
                fixation_x_pos_deg = 0;
                fixation_y_pos_deg = 0; 
                fixation_break = 1;
            end
            
            if(fixation_counter >= fixation_min_duration_smpl)
                fixation_break = 0;
            end
        end
        
    
        
        % time interval since last fixation
        latency = 0;
        % the distance from previous fixation
        fixation_prev_dist_deg = 0;
        
        for t=1:length(fixation_detected_EMD)
%             for m=fixation_detected_EMD(t).fixation_onset_smpl:fixation_detected_EMD(t).fixation_offset_smpl
% %                 eye_record(m).xy_movement_EMD_plot = 1; % 1-fixation, 2- saccade, 3-pursuit
%             end
            qualified_fixations_duration_sec = qualified_fixations_duration_sec + fixation_detected_EMD(t).fixation_duration_sec;
        end

        
        
%         display(length(fixation_detected_EMD));
        % Merging fixations based on the temporal and spacial filter
        fixation_filtered_EMD.fixation_x_pos_deg = 0;
        fixation_filtered_EMD.fixation_y_pos_deg = 0;
        fixation_filtered_EMD.fixation_onset_sec = 0;
        fixation_filtered_EMD.fixation_offset_sec = 0;
        fixation_filtered_EMD.fixation_onset_smpl = 0;
        fixation_filtered_EMD.fixation_offset_smpl = 0;
        fixation_filtered_EMD.fixation_duration_sec = 0;
        fixation_filtered_EMD.latency = 0;
        fixation_filtered_EMD.latency_sec = 0;
        fixation_filtered_EMD.fixation_prev_dist_deg = 0;
        
        % the flag that is responcible for merge detection
        flag_merge = 1;
        flag_filtered_fix_cleared = 0;
        
        while(flag_merge)
          flag_merge = 0;
          fixation_filtered_counter = 1;
          % this starts fixation merging from the second fixation  
          t = 2;
          while(t <= length(fixation_detected_EMD))
            if(fixation_detected_EMD(t).latency_sec <= BLINK_DURATION_SEC && fixation_detected_EMD(t).fixation_prev_dist_deg <= FIXATION_MERGE_DISTANCE_THRESHOLD_DEG)
                              % this flag indicates if filtered fixation array was cleared or not    
                              flag_filtered_fix_cleared = 0;
                              % set the flag for merge indicating that two fixations are        
                              flag_merge = 1;
                              % the onset of the first fixation in a fixation pair is assigned to the onset of the merged fixation       
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_sec  = fixation_detected_EMD(t-1).fixation_onset_sec;
                              % the offset of the second fixation in a fixation pair is assigned to the offset of the merged fixation   
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_sec = fixation_detected_EMD(t).fixation_offset_sec;
                              % similar thing is done to the onset and the offset of the fixations measured in samples
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_smpl  = fixation_detected_EMD(t-1).fixation_onset_smpl;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_smpl = fixation_detected_EMD(t).fixation_offset_smpl;
                       
                              % the duration of the fixation is calculated as offset minus the onset       
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_duration_sec = fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_sec - fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_sec;
                              % coordinates of the merged fixation are calculated as the average in fixation pair       
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_x_pos_deg = (fixation_detected_EMD(t-1).fixation_x_pos_deg + fixation_detected_EMD(t).fixation_x_pos_deg)/2;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_y_pos_deg = (fixation_detected_EMD(t-1).fixation_y_pos_deg + fixation_detected_EMD(t).fixation_y_pos_deg)/2;
                              % latency of the new fixation equals to the latency of the first fixation in the pair
                              fixation_filtered_EMD(fixation_filtered_counter).latency_sec = fixation_detected_EMD(t-1).latency_sec;
                              % distance between new merged fixation and the fixation preceeding merged fixation is calcuated as euclidean distance
                              if(t>2)
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_prev_dist_deg = sqrt((fixation_filtered_EMD(fixation_filtered_counter).fixation_x_pos_deg - fixation_detected_EMD(t-2).fixation_x_pos_deg)^2 + (fixation_filtered_EMD(fixation_filtered_counter).fixation_y_pos_deg - fixation_detected_EMD(t-2).fixation_y_pos_deg)^2); 
                              else
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_prev_dist_deg = 0;
                              end
                              % skip one fixation to concider next possible fixation       
                              t = t + 2;
                              fixation_filtered_counter = fixation_filtered_counter + 1;
                              % if there is a fixation at the end of the list with no pair to compare following logic would allow to copy this fixation to the filtered list       
                              if(t - 1 == length(fixation_detected_EMD))
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_sec  = fixation_detected_EMD(t-1).fixation_onset_sec;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_sec = fixation_detected_EMD(t-1).fixation_offset_sec;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_smpl  = fixation_detected_EMD(t-1).fixation_onset_smpl;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_smpl = fixation_detected_EMD(t-1).fixation_offset_smpl;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_duration_sec = fixation_detected_EMD(t-1).fixation_duration_sec;      
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_x_pos_deg = fixation_detected_EMD(t-1).fixation_x_pos_deg;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_y_pos_deg = fixation_detected_EMD(t-1).fixation_y_pos_deg;
                                fixation_filtered_EMD(fixation_filtered_counter).latency_sec = fixation_detected_EMD(t-1).latency_sec;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_prev_dist_deg = fixation_detected_EMD(t-1).fixation_prev_dist_deg; 
                                fixation_filtered_counter = fixation_filtered_counter + 1; 

                              end
            else
                              % this flag indicates if filtered fixation array was cleared or not    
                              flag_filtered_fix_cleared = 0;
                     
                              % in case if a pair of fixations matching the criteria are not found
                              % all fixation parameters are copied over
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_sec  = fixation_detected_EMD(t-1).fixation_onset_sec;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_sec = fixation_detected_EMD(t-1).fixation_offset_sec;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_smpl  = fixation_detected_EMD(t-1).fixation_onset_smpl;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_smpl = fixation_detected_EMD(t-1).fixation_offset_smpl;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_duration_sec = fixation_detected_EMD(t-1).fixation_duration_sec;      
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_x_pos_deg = fixation_detected_EMD(t-1).fixation_x_pos_deg;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_y_pos_deg = fixation_detected_EMD(t-1).fixation_y_pos_deg;
                              fixation_filtered_EMD(fixation_filtered_counter).latency_sec = fixation_detected_EMD(t-1).latency_sec;
                              fixation_filtered_EMD(fixation_filtered_counter).fixation_prev_dist_deg = fixation_detected_EMD(t-1).fixation_prev_dist_deg; 
                              fixation_filtered_counter = fixation_filtered_counter + 1; 
                              t = t + 1;
                     
                              % in case of the full copying of the detected into filtered array this logic will copy the last fixation into that array
                              if( t - 1 == length(fixation_detected_EMD))
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_sec  = fixation_detected_EMD(t-1).fixation_onset_sec;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_sec = fixation_detected_EMD(t-1).fixation_offset_sec;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_smpl  = fixation_detected_EMD(t-1).fixation_onset_smpl;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_smpl = fixation_detected_EMD(t-1).fixation_offset_smpl;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_duration_sec = fixation_detected_EMD(t-1).fixation_duration_sec;      
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_x_pos_deg = fixation_detected_EMD(t-1).fixation_x_pos_deg;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_y_pos_deg = fixation_detected_EMD(t-1).fixation_y_pos_deg;
                                fixation_filtered_EMD(fixation_filtered_counter).latency_sec = fixation_detected_EMD(t-1).latency_sec;
                                fixation_filtered_EMD(fixation_filtered_counter).fixation_prev_dist_deg = fixation_detected_EMD(t-1).fixation_prev_dist_deg; 
                              end
            end % end if
          end % end while
          
          if(~flag_filtered_fix_cleared)
            fixation_detected_EMD = fixation_filtered_EMD;
          end
          
          % this flag allows the loop to continue interating merging fixations together
          if(flag_merge == 1)
            clear fixation_filtered_EMD;
            flag_filtered_fix_cleared = 1;
          end
        end % end while
        
        
        
        % Filtering the fixations on the assumption that fixation duration should be more than 100 ms.
        fixation_filtered_counter = 1;
        qualified_fixations_duration_sec = 0;
        clear fixation_filtered_EMD;
        flag_filtered_fix_cleared = 1;

        % display(length(fixation_detected_EMD));

        % filtering fixations based on the detection criteria
        for t=1:length(fixation_detected_EMD)
            %display(fixation_detected_EMD(t).fixation_duration_sec);
            if(fixation_detected_EMD(t).fixation_duration_sec >= FIXATION_MINIMUM_DURATION_SEC)
              flag_filtered_fix_cleared = 0;
              fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_sec  = fixation_detected_EMD(t).fixation_onset_sec;
              fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_sec = fixation_detected_EMD(t).fixation_offset_sec;
              fixation_filtered_EMD(fixation_filtered_counter).fixation_onset_smpl  = fixation_detected_EMD(t).fixation_onset_smpl;
              fixation_filtered_EMD(fixation_filtered_counter).fixation_offset_smpl = fixation_detected_EMD(t).fixation_offset_smpl;
              fixation_filtered_EMD(fixation_filtered_counter).fixation_duration_sec = fixation_detected_EMD(t).fixation_duration_sec;      
              fixation_filtered_EMD(fixation_filtered_counter).fixation_x_pos_deg = fixation_detected_EMD(t).fixation_x_pos_deg;
              fixation_filtered_EMD(fixation_filtered_counter).fixation_y_pos_deg = fixation_detected_EMD(t).fixation_y_pos_deg;  
              qualified_fixations_duration_sec = qualified_fixations_duration_sec + fixation_filtered_EMD(fixation_filtered_counter).fixation_duration_sec;
              fixation_filtered_counter = fixation_filtered_counter + 1; 
              %display(length(fixation_filtered_EMD));
            end
        end

        if(flag_filtered_fix_cleared)
            fixation_filtered_EMD.fixation_x_pos_deg = 0;
            fixation_filtered_EMD.fixation_y_pos_deg = 0;
            fixation_filtered_EMD.fixation_onset_sec = 0;
            fixation_filtered_EMD.fixation_offset_sec = 0;
            fixation_filtered_EMD.fixation_onset_smpl = 0;
            fixation_filtered_EMD.fixation_offset_smpl = 0;
            fixation_filtered_EMD.fixation_duration_sec = 0;
            fixation_filtered_EMD.latency = 0;
            fixation_filtered_EMD.latency_sec = 0;
            fixation_filtered_EMD.fixation_prev_dist_deg = 0;
        end

        SUM_FIXATION_DURATION_SEC = qualified_fixations_duration_sec;
        FIXATION_COUNTER = fixation_filtered_counter;
        FIXATION_DURATION_AVR_SEC = SUM_FIXATION_DURATION_SEC/FIXATION_COUNTER;

        FID_fixations = fopen(strcat(SUBJECT_FILES_OUTPUT_DIR, SUBJECT_NAME_NUMBER, '_Fixations_data_filtered.txt'), 'wt');
        fprintf(FID_fixations, 'fixation_number,   start_sample,   end_sample,   fix_x_pos,   fix_y_pos ,   fix_dur \n'); 
        
        
        % time interval since last fixation
        latency = 0;
        % the distance from previous fixation
        TOTAL_EYE_PATH_DEG = 0;
        fixation_prev_dist_deg = 0;
        if(~flag_filtered_fix_cleared)
          for t=1:length(fixation_filtered_EMD)

            fprintf(FID_fixations, '%d,  %d,  %d, %.2f,  %.2f,  %.0f\n', t, fixation_filtered_EMD(t).fixation_onset_smpl, fixation_filtered_EMD(t).fixation_offset_smpl,  fixation_filtered_EMD(t).fixation_x_pos_deg, fixation_filtered_EMD(t).fixation_y_pos_deg, 1000*fixation_filtered_EMD(t).fixation_duration_sec); 
            qualified_fixations_duration_sec = qualified_fixations_duration_sec + fixation_filtered_EMD(t).fixation_duration_sec;
            % calculating total path travelled between qualified fixations
            if(t>1)
               TOTAL_EYE_PATH_DEG = TOTAL_EYE_PATH_DEG + sqrt(((fixation_filtered_EMD(t).fixation_x_pos_deg - fixation_filtered_EMD(t-1).fixation_x_pos_deg)^2+(fixation_filtered_EMD(t).fixation_y_pos_deg - fixation_filtered_EMD(t-1).fixation_y_pos_deg)^2));  
            end
          end
        end


%         display(length(fixation_filtered_EMD));
        fixation_counter_new = 0;
        if(length(fixation_filtered_EMD)>1)
            for t=1: length(fixation_filtered_EMD)
                for m=fixation_filtered_EMD(t).fixation_onset_smpl:fixation_filtered_EMD(t).fixation_offset_smpl
                    eye_record(m).xy_movement_EMD_plot = 1; % 1-fixation, 2- saccade, 3-pursuit
                    fixation_counter_new = fixation_counter_new + 1;
                end
            end
        end
        
%         display(fixation_counter_new);
        
        %% Pursuit grouping

         pursuit_group_flag = 1;
         for t=1:length(eye_record)-1
          if(eye_record(t).xy_movement_EMD == 3 ) 
            if(pursuit_group_flag)
                eye_record(t).xy_movement_EMD_pursuit_onset_x_pos_deg = eye_record(t).x_pos_measured_deg;
                eye_record(t).xy_movement_EMD_pursuit_onset_y_pos_deg = eye_record(t).y_pos_measured_deg;
                eye_record(t).xy_movement_EMD_pursuit_onset_time_sec = (t-1)*DELTA_T_SEC;
                eye_record(t).xy_movement_EMD_pursuit_onset_time_smpl = t;
                pursuit_group_flag = 0;

                pursuit_onset_x_pos_deg = eye_record(t).x_pos_measured_deg; 
                pursuit_onset_y_pos_deg = eye_record(t).y_pos_measured_deg; 
                pursuit_onset_time_smpl = t;
                

            end

            if(eye_record(t+1).xy_movement_EMD ~= 3 || (t+1)==length(eye_record))

                eye_record(t).xy_movement_EMD_pursuit_offset_x_pos_deg = eye_record(t).x_pos_measured_deg;
                eye_record(t).xy_movement_EMD_pursuit_offset_y_pos_deg = eye_record(t).y_pos_measured_deg;
                eye_record(t).xy_movement_EMD_pursuit_offset_time_sec = (t-1)*DELTA_T_SEC;
                eye_record(t).xy_movement_EMD_pursuit_offset_time_smpl = t;

                pursuit_offset_x_pos_deg = eye_record(t).x_pos_measured_deg; 
                pursuit_offset_y_pos_deg = eye_record(t).y_pos_measured_deg; 
                
                if((t+1)==length(eye_record))
                    pursuit_offset_time_smpl = t+1;
                else
                    pursuit_offset_time_smpl = t;
                end

                for k=pursuit_onset_time_smpl:pursuit_offset_time_smpl
                    eye_record(k).xy_movement_EMD_pursuit_onset_x_pos_deg = pursuit_onset_x_pos_deg;
                    eye_record(k).xy_movement_EMD_pursuit_onset_y_pos_deg = pursuit_onset_y_pos_deg;
                    eye_record(k).xy_movement_EMD_pursuit_onset_time_sec = (pursuit_onset_time_smpl-1)*DELTA_T_SEC;
                    eye_record(k).xy_movement_EMD_pursuit_onset_time_smpl = pursuit_onset_time_smpl;
                    eye_record(k).xy_movement_EMD_pursuit_offset_x_pos_deg = pursuit_offset_x_pos_deg;
                    eye_record(k).xy_movement_EMD_pursuit_offset_y_pos_deg = pursuit_offset_y_pos_deg;
                    eye_record(k).xy_movement_EMD_pursuit_offset_time_sec = (pursuit_offset_time_smpl-1)*DELTA_T_SEC;
                    eye_record(k).xy_movement_EMD_pursuit_offset_time_smpl = pursuit_offset_time_smpl;
                end
                pursuit_group_flag = 1;
            end
          end
         end

            % Creating pursuit detected array.
            
        pursuit_detected_EMD.pursuit_onset_x_deg = 0;
        pursuit_detected_EMD.pursuit_onset_y_deg = 0;
        pursuit_detected_EMD.pursuit_offset_x_deg = 0;
        pursuit_detected_EMD.pursuit_offset_y_deg = 0;
        pursuit_detected_EMD.pursuit_onset_sec = 0;
        pursuit_detected_EMD.pursuit_offset_sec = 0;
        pursuit_detected_EMD.pursuit_onset_smpl = 0;
        pursuit_detected_EMD.pursuit_offset_smpl = 0;
        
        pursuit_detected_counter = 0;
        pursuit_detected_onset_smpl = 0;
        for t=1: length(eye_record)
          if(eye_record(t).xy_movement_EMD == 3)
              eye_record(t).xy_movement_EMD_plot = 3; % for the plot, 1-fixation, 2- saccade, 3-pursuit
              if(pursuit_detected_onset_smpl == 0)
                pursuit_detected_onset_smpl  = eye_record(t).xy_movement_EMD_pursuit_onset_time_smpl; 
                pursuit_detected_counter = pursuit_detected_counter +1;

                pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_x_deg = eye_record(t).xy_movement_EMD_pursuit_onset_x_pos_deg;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_y_deg = eye_record(t).xy_movement_EMD_pursuit_onset_y_pos_deg;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_x_deg = eye_record(t).xy_movement_EMD_pursuit_offset_x_pos_deg;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_y_deg = eye_record(t).xy_movement_EMD_pursuit_offset_y_pos_deg;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_sec = eye_record(t).xy_movement_EMD_pursuit_onset_time_sec;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_sec = eye_record(t).xy_movement_EMD_pursuit_offset_time_sec;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_smpl = eye_record(t).xy_movement_EMD_pursuit_onset_time_smpl;
                pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_smpl = eye_record(t).xy_movement_EMD_pursuit_offset_time_smpl;

              else
                  if(pursuit_detected_onset_smpl == eye_record(t).xy_movement_EMD_pursuit_onset_time_smpl )
                      continue;
                  else
                        pursuit_detected_onset_smpl  = eye_record(t).xy_movement_EMD_pursuit_onset_time_smpl; 
                        pursuit_detected_counter = pursuit_detected_counter +1;

                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_x_deg = eye_record(t).xy_movement_EMD_pursuit_onset_x_pos_deg;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_y_deg = eye_record(t).xy_movement_EMD_pursuit_onset_y_pos_deg;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_x_deg = eye_record(t).xy_movement_EMD_pursuit_offset_x_pos_deg;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_y_deg = eye_record(t).xy_movement_EMD_pursuit_offset_y_pos_deg;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_sec = eye_record(t).xy_movement_EMD_pursuit_onset_time_sec;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_sec = eye_record(t).xy_movement_EMD_pursuit_offset_time_sec;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_onset_smpl = eye_record(t).xy_movement_EMD_pursuit_onset_time_smpl;
                        pursuit_detected_EMD(pursuit_detected_counter).pursuit_offset_smpl = eye_record(t).xy_movement_EMD_pursuit_offset_time_smpl;
                 end
              end

          end
        end
        
         
        FID_pursuit_data = fopen(strcat(SUBJECT_FILES_OUTPUT_DIR, SUBJECT_NAME_NUMBER,'_Pursuit_data_detected.txt'), 'wt'); 
        fprintf(FID_pursuit_data,'Pursuit Number    Onset_sample, Offset_sample, Onset_x_pos, Onset_y_pos, Offset_x_pos, Offset_y_pos  \n');
        
        for t=1: length(pursuit_detected_EMD)
            fprintf(FID_pursuit_data,'%d   ,%d   ,%d     ,%0.2f  ,%0.2f  ,%0.2f  ,%0.2f \n',t,pursuit_detected_EMD(t).pursuit_onset_smpl,pursuit_detected_EMD(t).pursuit_offset_smpl,pursuit_detected_EMD(t).pursuit_onset_x_deg,pursuit_detected_EMD(t).pursuit_onset_y_deg,pursuit_detected_EMD(t).pursuit_offset_x_deg,pursuit_detected_EMD(t).pursuit_offset_y_deg);
        end
        fclose(FID_pursuit_data);
        
% if saccade filtered not assigned, this means the detection algorithm is
% unsuccessful of detection. We need to stop any other processing on this
% particular subject, so we assgin stopper=1 and this global parameter can
% access by any other methods to stop processing this subject any more. In
% addtion to that, at runtime, this will create a log on the detection
% method name with the subject number, and related threshold so that we can
% confirm which subjet at what threshold not detecting correctly.
if(saccade_filtered_EMD_check)
    stopper = 1;
    saccade_filtered_EMD=nan;
end

return