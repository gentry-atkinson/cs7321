% Global plot function for eye movement detections graphs
function EMD_Plot(eye_record,stimulus_record,method)

    global SUBJECT_NAME_NUMBER;

    for t=1:length(eye_record)
        if(eye_record(t).xy_movement_EMD_plot == 1 && eye_record(t).gaze_validity ==0)
            eye_record(t).xy_movement_EMD_plot_fixation_x = eye_record(t).x_pos_measured_deg;
        elseif(eye_record(t).xy_movement_EMD_plot == 2 && eye_record(t).gaze_validity ==0)
            eye_record(t).xy_movement_EMD_plot_saccade_x = eye_record(t).x_pos_measured_deg;
        elseif(eye_record(t).xy_movement_EMD_plot == 3 && eye_record(t).gaze_validity ==0)
            eye_record(t).xy_movement_EMD_plot_pursuit_x = eye_record(t).x_pos_measured_deg;
        end
    end


%% Plotting graph. Creating 4 positions in the screen
    
     bdwidth = 5;
     topbdwidth = 80; 
     set(0,'Units','pixels') 
     scnsize = get(0,'ScreenSize');
     pos1  = [bdwidth, 0.5*scnsize(4) + bdwidth, scnsize(3)/2 - 2*bdwidth, scnsize(4)/2 - (topbdwidth + bdwidth)];
     pos2 =  [pos1(1) + scnsize(3)/2, pos1(2), pos1(3), pos1(4)];
     pos3 =  [pos1(1), pos1(1), pos1(3), pos1(4)];
     pos4 =  [pos2(1), pos1(1), pos1(3), pos1(4)];

   
     
     %% Graph
     
     if (strcmp(method,'stimulus')) % stimulus vs eye gaze before detection
         figure('Name','Horizontal Eye Position','Position',pos4, 'NumberTitle','off')
         hold on
         grid on
         for t=1:(length(eye_record))
             if(eye_record(t).gaze_validity ~= 0)
               eye_record(t).x_pos_measured_deg = nan;
               eye_record(t).y_pos_measured_deg = nan;
             end
         end
         plot_y_pos_measured = plot([stimulus_record(1:end).x_stimulus_pos_measured_deg],'b-');
         plot_x_pos_measured = plot([eye_record(1:end).x_pos_measured_deg],'g-');
         legend('stimulus position', 'eye gaze postion', 'Location', 'Best');
         ylabel('Cooridinates - deg.')
         xlabel('Eye-position sequncial sample number')
         title('Eye Gaze Position')
      
     else % stimulus vs eye gaze after detection
  
         figure('Name',strcat('Subject ',SUBJECT_NAME_NUMBER,' Eye Movement'),'Position',pos1, 'NumberTitle','off')
         hold on
         grid on
         for t=1:(length(eye_record))
             if(eye_record(t).gaze_validity ~= 0)
               eye_record(t).x_pos_measured_deg = nan;
             end 
         end

                               plot([eye_record(1:end).x_pos_measured_deg],'c-');
% Here should be noise output. But in case of noisy data we don't know the
% exact eye position so I can't do it properly.
         plot_a_pos_measured = plot([stimulus_record(1:end).x_stimulus_pos_measured_deg],'b-');
         plot_b_pos_measured = plot([eye_record(1:end).xy_movement_EMD_plot_fixation_x],'r-');
         plot_c_pos_measured = plot([eye_record(1:end).xy_movement_EMD_plot_saccade_x],'k-');
         plot_d_pos_measured = plot([eye_record(1:end).xy_movement_EMD_plot_pursuit_x],'g-');

% This is an example of bad software architecture.
% It appears that we need to get information about fixations to draw
% centroids. Such information is available on higher levels of application.
% But because of bad planning the safiest way to get it here is the
% execution of EMD_Merge function. Again.
         [~,fixation_filtered_EMD, ~, ~] = EMD_Merge(eye_record);
         for i=1:length( fixation_filtered_EMD )
             plot(  [fixation_filtered_EMD(i).fixation_onset_smpl:fixation_filtered_EMD(i).fixation_offset_smpl], ...
                    fixation_filtered_EMD(i).fixation_x_pos_deg * ones(1, fixation_filtered_EMD(i).fixation_offset_smpl - fixation_filtered_EMD(i).fixation_onset_smpl + 1 ),...
                    'm-' );
         end
         
         legend('Original eye gaze position', 'Stimulus position', 'Fixation points','Saccade points','Pursuit points', 'Fixation centroids (actual merged fixations)', 'Location', 'Best');
         ylabel('Cooridinates - deg.')
         xlabel('Eye-position sequncial sample number')
         title(method)

     end
return