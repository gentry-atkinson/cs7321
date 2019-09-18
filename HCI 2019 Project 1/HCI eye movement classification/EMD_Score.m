% Calculate score values for each eye movement detection algorithm
function  EMD_Score(eye_record,stimulus_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD)

global Movement_Selection; % this will give the type of the eye movement sample

global FIXATION_POINT_QUANTITATIVE_COUNT_SCORE;
global FIXATION_POINT_QUANTITATIVE_SCORE;
global FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR;
global FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR;
global FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D;
global SACCADE_AMPLITUDE_QUANTITATIVE_SCORE;
global PURSUIT_QUANTITATIVE_SCORE;
global PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR;
global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR;
global PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR;
global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR;
global PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D;
global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D;
 
global SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD;%at runtime currently 3.0

global stopper; % this will stop doing any other stuff on the subject if the detection is not successful
if(stopper)
    display('Subject detection failed......no score calculations performed!');
else
    display('Score calculation starts.....')

        %this will enable or diable associated score method
    EMD_Score_Fixation_1D = 1;
    EMD_Score_Fixation_2D = 1;
    EMD_Score_Saccade = 1;
    if(Movement_Selection == '3' || Movement_Selection == '4' || Movement_Selection == '5')      
        EMD_Score_Pursuit = 1;
    else
        EMD_Score_Pursuit = 0;
    end

        %makes all the output variables NaN incase of values not calculated
    FIXATION_POINT_QUANTITATIVE_SCORE =NaN;
    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = NaN;
    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = NaN;
    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D = NaN;
    SACCADE_AMPLITUDE_QUANTITATIVE_SCORE = NaN;
    PURSUIT_QUANTITATIVE_SCORE =NaN;
    PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR =NaN;
    PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR =NaN;
    PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR =NaN;
    PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR =NaN;
    PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D =NaN;
    PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D =NaN;


        %if there is no data in the fixation filtered matrix, then this will
        %make the score detection zero for each appropreate value. Otherwise
        %the average output will give invalid results due to aggregation of NaN
        %values


    if(length(fixation_filtered_EMD)==1)
         EMD_Score_Fixation_1D = 0;
         EMD_Score_Fixation_2D = 0;

         FIXATION_POINT_QUANTITATIVE_SCORE = 0;
         if(Movement_Selection =='1' || Movement_Selection=='3')% 1D horizontal
            FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = 0;
         elseif (Movement_Selection=='2' || Movement_Selection=='4')%1D vertical
            FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = 0;
         elseif(Movement_Selection=='5')%2D
             FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = 0;
             FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = 0;
             FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D = 0;
         end
    end



    %%  EMD_Score_Fixation_1D
    % In this method, each fixation point in the stimulus is matched with the detected fixations from each model (IVT, IHMM, IKF & IMST). 
    % This is done by comparing the stimulus fixation sample 
    % (by extracting the sample number) and locating that sample number inside the detected fixations samples 
    % (exist or not). If exist, the detection program successfully detected the sample and increment the success counter by 1.
    % Continue this for  all stimulus fixation samples. The total success sample counter is divided by the total stimuli
    % samples available and multiply the result by 100 to get the percentage value.

    % Fixation Quantitative Score  = (successful fixation detection counter/ stimuli fixation counter) * 100

    % The difference between the detected fixation centroid and the 
    % stimuli coordinate position measured is obtained as a qualitative fixation score. This is done by using the same point-to-point 
    % comparison method. At the time of the successful matching of a stimuli fixation sample and detected fixation sample, the difference 
    % between the centroid of the detected fixation and coordinate position of the stimuli fixation is calculated.  This will provide 2 possible 
    % score results 1 in horizontal and 1 in vertical.  This difference is divided by the total successful detection counter to get an average 
    % difference between the detected fixation centroid and stimuli fixation coordinate.

    %after the corresponding samples are found ex if (t==a), then we need to
    %verify the samples are in the same coordinate, not in either sides. If
    %either sides, this will give higher values to the difference. Therefore it
    %is necessary to chekc the signs of coordinates to verify they are having
    %same sign not different signs.

    if(EMD_Score_Fixation_1D)

        stimuli_fixation_point_counter =0; %number of stimuli fixation points
        fixation_detection_success_counter =0;
        fixation_detected_quantity_counter = 0;
        fixation_success_quantity_counter = 0;
        
        total_fixation_coordinate_differance_HR = 0;
        total_fixation_coordinate_differance_VR = 0;
        
             for t=1:length(stimulus_record)
                 if(stimulus_record(t).xy_stimulus_movement_IVT==1)
                     stimuli_fixation_point_counter = stimuli_fixation_point_counter+1;
                     for k=1:length(fixation_filtered_EMD)
                        for a=fixation_filtered_EMD(k).fixation_onset_smpl:fixation_filtered_EMD(k).fixation_offset_smpl 
                           if(t == a) 
                               if((fixation_filtered_EMD(k).fixation_x_pos_deg>0 && stimulus_record(t).x_stimulus_pos_measured_deg>0 ) || (fixation_filtered_EMD(k).fixation_x_pos_deg <0 && stimulus_record(t).x_stimulus_pos_measured_deg <0 ))%sign should be same                           
                                   horizontal_fixation_coordinate_differance = abs(fixation_filtered_EMD(k).fixation_x_pos_deg - stimulus_record(t).x_stimulus_pos_measured_deg);                                                   
                                   vertical_fixation_coordinate_differance = abs(fixation_filtered_EMD(k).fixation_y_pos_deg - stimulus_record(t).y_stimulus_pos_measured_deg);
                                   if(horizontal_fixation_coordinate_differance >=SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD || vertical_fixation_coordinate_differance >=SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD )
                                       continue;
                                   else
                                       total_fixation_coordinate_differance_HR = total_fixation_coordinate_differance_HR + horizontal_fixation_coordinate_differance;
                                       total_fixation_coordinate_differance_VR = total_fixation_coordinate_differance_VR + vertical_fixation_coordinate_differance;
                                       fixation_detection_success_counter= fixation_detection_success_counter+1;
                                       break;
                                   end
                                   
                               end
                               
                          end
                        end

                     end
                 end
             end
             
             % this will give number of fixations detected to a number of
             % stimuli fixations available
             for t=1: length(eye_record)
                 if(eye_record(t).xy_movement_EMD == 1)
                     fixation_detected_quantity_counter = fixation_detected_quantity_counter + 1;
                     if(stimulus_record(t).xy_stimulus_movement_IVT==1)
                         fixation_amplitude_difference = abs(stimulus_record(t).x_stimulus_pos_measured_deg-eye_record(t).x_pos_measured_deg);
                         if(fixation_amplitude_difference <= SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD)
                            fixation_success_quantity_counter = fixation_success_quantity_counter + 1;
                         end
                     end
                 end
             end
             
%              display(fixation_detection_success_counter);
%              display(fixation_success_quantity_counter);
             FIXATION_POINT_QUANTITATIVE_COUNT_SCORE = (fixation_detected_quantity_counter/stimuli_fixation_point_counter)* 100;
             
             FIXATION_POINT_QUANTITATIVE_SCORE = (fixation_success_quantity_counter/stimuli_fixation_point_counter)* 100;

             if(Movement_Selection =='1' || Movement_Selection=='3')% 1D horizontal
                if(fixation_detection_success_counter ==0)
                    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = 0;
                else
    %                 display(total_fixation_coordinate_differance_HR);
    %                 display(fixation_detection_success_counter);
                    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = (total_fixation_coordinate_differance_HR/fixation_detection_success_counter);
                end

             elseif (Movement_Selection=='2' || Movement_Selection=='4')%1D vertical
                 if(fixation_detection_success_counter ==0)
                     FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR=0;
                 else
                    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = (total_fixation_coordinate_differance_VR/fixation_detection_success_counter);
                 end
             elseif(Movement_Selection=='5')%2D
                 if(fixation_detection_success_counter ==0)
                     FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = 0;
                     FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = 0;
                 else
                     FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = (total_fixation_coordinate_differance_HR/fixation_detection_success_counter);
                     FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = (total_fixation_coordinate_differance_VR/fixation_detection_success_counter);
                 end
             end

    end


    %% EMD_Score_Fixation_2D

    % Same method as in Fixation coordinate difference 1D is used but instead of separate horizontal and vertical components, the square root of 
    % the summation of the square of the horizontal and vertical differences are used. 
    %  
    % total coordinate difference = sqrt(horizontal difference ^2 + vertical difference ^2)
    % This total difference is divided by the total successful detection counter to get an average difference between the detected 
    % fixation centroid and stimuli fixation coordinate.
    % 
    % 
    % Fixation Qualitative Score_2D = (total coordinate difference/ successful fixation 	detection counter)

    % after the corresponding samples are found ex if (t==a), then we need to
    %verify the samples are in the same coordinate, not in either sides. If
    %either sides, this will give higher values to the difference. Therefore it
    %is necessary to chekc the signs of coordinates to verify they are having
    %same sign not different signs.

    if(EMD_Score_Fixation_2D)
        if(Movement_Selection =='5')%2d
            stimuli_fixation_point_counter =0; %number of stimuli fixation points
            fixation_detection_success_counter =0;   
            total_fixation_coordinate_differance = 0;
                 for t=1:length(stimulus_record)

                     if(stimulus_record(t).xy_stimulus_movement_IVT==1)
                         stimuli_fixation_point_counter = stimuli_fixation_point_counter+1;
                         for k=1:length(fixation_filtered_EMD)
                            for a=fixation_filtered_EMD(k).fixation_onset_smpl:fixation_filtered_EMD(k).fixation_offset_smpl 
                               if(t == a) 
                                    if((fixation_filtered_EMD(k).fixation_x_pos_deg >0 && stimulus_record(t).x_stimulus_pos_measured_deg>0 ) || (fixation_filtered_EMD(k).fixation_x_pos_deg < 0 && stimulus_record(t).x_stimulus_pos_measured_deg < 0 ))%sign should be same                           
                                       horizontal_fixation_coordinate_differance = abs(fixation_filtered_EMD(k).fixation_x_pos_deg -stimulus_record(t).x_stimulus_pos_measured_deg);    
                                    end

                                    if((fixation_filtered_EMD(k).fixation_y_pos_deg >0 && stimulus_record(t).y_stimulus_pos_measured_deg>0 ) || (fixation_filtered_EMD(k).fixation_y_pos_deg < 0 && stimulus_record(t).y_stimulus_pos_measured_deg < 0 ))%sign should be same                           
                                       vertical_fixation_coordinate_differance = abs(fixation_filtered_EMD(k).fixation_y_pos_deg -stimulus_record(t).y_stimulus_pos_measured_deg);
                                    end

                                    if(horizontal_fixation_coordinate_differance >=SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD || vertical_fixation_coordinate_differance >=SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD )
                                       continue;
                                    else
                                        fixation_coordinate_differance = sqrt(horizontal_fixation_coordinate_differance^2 + vertical_fixation_coordinate_differance^2);
                                        total_fixation_coordinate_differance = total_fixation_coordinate_differance + fixation_coordinate_differance;
                                        fixation_detection_success_counter= fixation_detection_success_counter+1;    
                                        break;
                                    end
                               end
                            end
                         end
                     end
                 end
                  if(fixation_detection_success_counter ==0)
                      FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D = 0;
                  else
                    FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D = (total_fixation_coordinate_differance/fixation_detection_success_counter);
                  end
        end
    end

    %% EMD_Score_Saccade
    % This score calculated as the quantitative amplitude fractional difference between the stimuli saccades and detected saccades 
    % (by each detection model). The method will calculate total cumulative saccadic amplitude and total cumulative saccades detected amplitude. 
    % Dividing the total detected saccade amplitude by the total stimuli amplitude, we can calculate percentage detection by each eye movement 
    % detection model.
    % 
    % Saccade Qualitative score = (total detected saccade amplitude / total stimulus amplitude) * 100
    % 
    % It is possible to have a saccade score >100 due to the fact the a possibility of an overshoot detected by a model. 
    % Hence this will increase the amplitude detected and the fraction of detected/stimulus. 


    if(EMD_Score_Saccade)
        stimuli_saccade_point_counter =0;
        total_stimulus_saccade_amplitude =0;
        for t=1:length(stimulus_record)
            if(stimulus_record(t).xy_stimulus_movement_IVT_saccade == 1 && stimulus_record(t).gaze_validity == 0 && stimulus_record(t).gaze_validity_r == 0) 
                stimuli_saccade_point_counter =stimuli_saccade_point_counter +1;
                total_stimulus_saccade_amplitude= total_stimulus_saccade_amplitude+ stimulus_record(t).xy_stimulus_movement_IVT_saccade_amplitude_deg;
            end
        end

        total_detected_saccade_amplitude = 0;
        for k=1:length(saccade_filtered_EMD)
    %         display(saccades_detected_EMD(k).saccade_amplitude_deg);
            total_detected_saccade_amplitude = total_detected_saccade_amplitude+ saccade_filtered_EMD(k).saccade_amplitude_deg ;
        end

    
        if(total_stimulus_saccade_amplitude == 0)
            SACCADE_AMPLITUDE_QUANTITATIVE_SCORE = 0;
        else
            SACCADE_AMPLITUDE_QUANTITATIVE_SCORE = (total_detected_saccade_amplitude/total_stimulus_saccade_amplitude)*100;
        end
    end

    %%  EMD_Score_Pursuit

    % 3.1.	Point-to-Point
    % In this method, each pursuit point in the stimulus is matched with the detected pursuit from each model 
    % (IVT, IHMM, IKF & IMST). This is done by comparing the stimulus pursuit sample (by extracting the sample number) and locating that
    % sample number inside the detected pursuit samples (exist or not). If exist, the detection program successfully detected the sample and 
    % increment the success counter by 1. Continue this for  all stimulus pursuit samples. The total success sample counter is divided by the
    % total stimuli samples available and multiply the result by 100 to get the percentage value.
    % 
    % 	Pursuit Quantitative Score  = (successful pursuit detection counter/ stimuli pursuit counter) * 100
    % 
    % 3.2.	Pursuit velocity difference 1D
    % In this method, the difference between the velocity of the stimulus and detected pursuit coordinate is calculated as a qualitative score. 
    % Same methodology as in the fixation difference is used with this and score is calculated for each horizontal and vertical cases. 
    % 
    % 3.3.	Pursuit velocity difference 2D
    % Instead of separate horizontal and vertical velocity difference, this method calculates the difference of the  xy_velocity value for each 
    % stimuli pursuit and detected pursuit. 
    % 
    % 3.4.	Pursuit coordinate difference 1D
    % The difference between the detected pursuit and the stimuli coordinate position measured is obtained as a qualitative pursuit score. This is 
    % done by using the same point-to-point comparison method. At the time of the successful matching of a stimuli pursuit sample and detected
    % pursuit sample, the difference between the detected pursuit and coordinate position of the stimuli pursuit is calculated.  This will provide
    % 2 possible score results 1 in horizontal and 1 in vertical.  This difference is divided by the total successful detection counter to get an 
    % average difference between the detected pursuit and stimuli pursuit coordinate.
    % 
    %  
    % 
    % 3.5.	Pursuit coordinate difference 2D
    % Same method as in Pursuit coordinate difference 1D is used but instead of separate horizontal and vertical components, the square root of 
    % the summation of the square of the horizontal and vertical differences are used. 
    %  
    % total coordinate difference = sqrt(horizontal difference ^2 + vertical difference ^2)
    % This total difference is divided by the total successful detection counter to get an average difference between the detected pursuit 
    % and stimuli pursuit coordinate.

    if(EMD_Score_Pursuit)
        stimuli_pursuit_point_counter = 0;
        pursuit_detection_success_counter = 0;
        total_velocity_difference = 0;
        hr_total_velocity_difference = 0;
        vr_total_velocity_difference = 0;
        total_coordinate_difference = 0;
        total_horizontal_coordinate_difference = 0;
        total_vertical_coordinate_difference = 0;

        for t=1:length(stimulus_record)
            if(stimulus_record(t).xy_stimulus_movement_IVT == 3 )
                stimuli_pursuit_point_counter = stimuli_pursuit_point_counter+1;
                for k=1:length(pursuit_detected_EMD)
                    for a=pursuit_detected_EMD(k).pursuit_onset_smpl:pursuit_detected_EMD(k).pursuit_offset_smpl
                      if(t==a)
                          pursuit_detection_success_counter =pursuit_detection_success_counter+1;
                          velocity_difference = abs(stimulus_record(t).xy_stimulus_velocity_measured_deg - eye_record(a).xy_velocity_measured_deg);
                          horizontal_velocity_difference = abs(stimulus_record(t).x_stimulus_velocity_measured_deg - eye_record(a).x_velocity_measured_deg);
                          vertical_velocity_difference = abs(stimulus_record(t).y_stimulus_velocity_measured_deg - eye_record(a).y_velocity_measured_deg);
                          total_velocity_difference = total_velocity_difference + velocity_difference;
                          hr_total_velocity_difference = hr_total_velocity_difference + horizontal_velocity_difference;
                          vr_total_velocity_difference = vr_total_velocity_difference + vertical_velocity_difference;

                          horizontal_coordinate_difference = abs(eye_record(a).x_pos_measured_deg -stimulus_record(t).x_stimulus_pos_measured_deg);
                          vertical_coordinate_difference = abs(eye_record(a).y_pos_measured_deg -stimulus_record(t).y_stimulus_pos_measured_deg);

                          coordinate_difference = sqrt(horizontal_coordinate_difference^2 + vertical_coordinate_difference^2);
                          total_coordinate_difference = total_coordinate_difference  + coordinate_difference; 

                          total_horizontal_coordinate_difference = total_horizontal_coordinate_difference + horizontal_coordinate_difference;
                          total_vertical_coordinate_difference   = total_vertical_coordinate_difference + vertical_coordinate_difference;

    %                       if(horizontal_coordinate_difference>3)
    %                          display(t);
    %                          display(stimulus_record(t).x_stimulus_pos_measured_deg);
    %                          display(eye_record(a).x_pos_measured_deg);
    %                       end
                          break;
                      end
                    end
                end
            end
        end

        PURSUIT_QUANTITATIVE_SCORE = (pursuit_detection_success_counter/stimuli_pursuit_point_counter)*100;
        if(Movement_Selection == '3')%1D HR pursuit
            if(pursuit_detection_success_counter ==0)
                PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR = 0;
                PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = 0;
            else
                PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR = (hr_total_velocity_difference/pursuit_detection_success_counter);
                PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR = total_horizontal_coordinate_difference/pursuit_detection_success_counter;
            end

        elseif(Movement_Selection == '4') %1D VR Pursuit
            if(pursuit_detection_success_counter ==0)
                PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR = 0;
                PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = 0;
            else
                PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR = (vr_total_velocity_difference/pursuit_detection_success_counter);
                PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR = total_vertical_coordinate_difference/pursuit_detection_success_counter;
            end
        elseif(Movement_Selection == '5') %2D Pursuit
            if(pursuit_detection_success_counter ==0)
                PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D = 0;
                PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D = 0;
            else
                PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D = (total_velocity_difference/pursuit_detection_success_counter);
                PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D = total_coordinate_difference/pursuit_detection_success_counter;
            end
        end







    end


    display('Score calculation ends.....')

    
end % global stopper ends


return

