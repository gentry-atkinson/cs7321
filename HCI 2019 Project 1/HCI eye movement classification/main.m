
function main(eye_data)
 
 
global DELTA_T_SEC 
global score_IVT;
 

%% Eye Data
gaze_validity_temp          = eye_data.gaze_validity;
gaze_validity_temp_left     = eye_data.gaze_validity_left;
x_pos_measured_deg          = eye_data.x_pos_measured_deg;
y_pos_measured_deg          = eye_data.y_pos_measured_deg;
x_stimulus_pos_measured_deg = eye_data.x_stimulus_pos_measured_deg;
y_stimulus_pos_measured_deg = eye_data.y_stimulus_pos_measured_deg;

 
data_record_length = length(gaze_validity_temp);



%% HORIZONTAL PLANE EYE POSITION PROCESSING
x_velocity_measured_deg = zeros(1, length(x_pos_measured_deg));
for t=2:data_record_length
     if((gaze_validity_temp(t) == 0) && (gaze_validity_temp(t-1) == 0))
        x_velocity_measured_deg(t) = (x_pos_measured_deg(t) - x_pos_measured_deg(t-1))/DELTA_T_SEC;            
     else
        x_velocity_measured_deg(t) = nan;
     end
end 

%% VERTICAL PLANE EYE POSITION PROCESSING
y_velocity_measured_deg = zeros(1, length(y_pos_measured_deg));
for t=2:data_record_length 
     if((gaze_validity_temp(t) == 0) && (gaze_validity_temp(t-1) == 0 ))
         y_velocity_measured_deg(t) = (y_pos_measured_deg(t) - y_pos_measured_deg(t-1))/DELTA_T_SEC;
     else
        y_velocity_measured_deg(t) = nan;
     end
end

%% 2D velocity calculation 
xy_velocity_measured_deg = zeros(1, length(x_pos_measured_deg));
xy_velocity_measured_deg(1)=0;
for t=2:data_record_length
     if((gaze_validity_temp(t) == 0) && (gaze_validity_temp(t-1) == 0 ))
        xy_velocity_measured_deg(t) = sqrt(((x_pos_measured_deg(t) - x_pos_measured_deg(t-1))^2+(y_pos_measured_deg(t) - y_pos_measured_deg(t-1))^2))/DELTA_T_SEC;
     else
        xy_velocity_measured_deg(t) = nan;
     end
end


%% 2D stimulus velocity calculation
xy_stimulus_velocity_measured_deg = zeros(1, length(x_stimulus_pos_measured_deg));
x_stimulus_velocity_measured_deg = zeros(1, length(x_stimulus_pos_measured_deg));
y_stimulus_velocity_measured_deg = zeros(1, length(x_stimulus_pos_measured_deg));
xy_stimulus_velocity_measured_deg(1) = 0;
x_stimulus_velocity_measured_deg(1) = 0;
y_stimulus_velocity_measured_deg(1) = 0;

for t=2: data_record_length
    if((gaze_validity_temp(t) == 0) && (gaze_validity_temp_left(t)==0)  && (gaze_validity_temp(t-1) == 0 ) && (gaze_validity_temp_left(t-1) == 0 ))
        xy_stimulus_velocity_measured_deg(t) = sqrt(((x_stimulus_pos_measured_deg(t) - x_stimulus_pos_measured_deg(t-1))^2+(y_stimulus_pos_measured_deg(t) - y_stimulus_pos_measured_deg(t-1))^2))/DELTA_T_SEC;
        x_stimulus_velocity_measured_deg(t) = (x_stimulus_pos_measured_deg(t) - x_stimulus_pos_measured_deg(t-1))/DELTA_T_SEC;
        y_stimulus_velocity_measured_deg(t) = (y_stimulus_pos_measured_deg(t) - y_stimulus_pos_measured_deg(t-1))/DELTA_T_SEC;
    else
        xy_stimulus_velocity_measured_deg(t) = nan;
        x_stimulus_velocity_measured_deg(t) = nan;
        y_stimulus_velocity_measured_deg(t) = nan;
    end
end


    %% Initialize eye_record and stimulus_record
eye_record = initialize_eye_record(length(x_pos_measured_deg)); 
stimulus_record = initialize_stimulus_record(length(x_stimulus_pos_measured_deg)); 


    %% Assign data to eye_record and stimulus_record
for t=1:data_record_length
   eye_record(t).gaze_validity = gaze_validity_temp(t);
   eye_record(t).gaze_validity_r = gaze_validity_temp_left(t);
   eye_record(t).xy_velocity_measured_deg = xy_velocity_measured_deg(t);
   eye_record(t).x_velocity_measured_deg = x_velocity_measured_deg(t);
   eye_record(t).y_velocity_measured_deg = y_velocity_measured_deg(t);
   eye_record(t).x_pos_measured_deg = x_pos_measured_deg(t);
   eye_record(t).y_pos_measured_deg = y_pos_measured_deg(t);
end


    %temporay holds for gaze validity lost in stimulus
   temp_xy_stimulus_velocity = 0;
   temp_x_stimulus_velocity = 0;
   temp_y_stimulus_velocity = 0;
   temp_x_stimulus_pos = 0;
   temp_y_stimulus_pos = 0;
for t=1:data_record_length
   stimulus_record(t).gaze_validity = gaze_validity_temp(t);
   stimulus_record(t).gaze_validity_r = gaze_validity_temp_left(t);
        
   if((gaze_validity_temp(t) == 0) && (gaze_validity_temp_left(t)==0))
       temp_xy_stimulus_velocity = xy_stimulus_velocity_measured_deg(t);
       temp_x_stimulus_velocity = x_stimulus_velocity_measured_deg(t);
       temp_y_stimulus_velocity = y_stimulus_velocity_measured_deg(t);
       temp_x_stimulus_pos = x_stimulus_pos_measured_deg(t);
       temp_y_stimulus_pos = y_stimulus_pos_measured_deg(t);
       
       stimulus_record(t).xy_stimulus_velocity_measured_deg = xy_stimulus_velocity_measured_deg(t);
       stimulus_record(t).x_stimulus_velocity_measured_deg = x_stimulus_velocity_measured_deg(t);
       stimulus_record(t).y_stimulus_velocity_measured_deg = y_stimulus_velocity_measured_deg(t);

       stimulus_record(t).x_stimulus_pos_measured_deg = x_stimulus_pos_measured_deg(t);
       stimulus_record(t).y_stimulus_pos_measured_deg = y_stimulus_pos_measured_deg(t);
       
   else %replace the values from previous good gaze validity positions
       stimulus_record(t).xy_stimulus_velocity_measured_deg = temp_xy_stimulus_velocity;
       stimulus_record(t).x_stimulus_velocity_measured_deg = temp_x_stimulus_velocity;
       stimulus_record(t).y_stimulus_velocity_measured_deg = temp_y_stimulus_velocity;

       stimulus_record(t).x_stimulus_pos_measured_deg = temp_x_stimulus_pos;
       stimulus_record(t).y_stimulus_pos_measured_deg = temp_y_stimulus_pos;
   end
end

 
 %% This function breaks stimulus signal into saccades, pursuits and fixations 
[stimulus_saccades_detected_EMD,stimulus_record]=xy_Saccade_detection_parameters_stimulus(stimulus_record);
 
 
    
%% Call detection algorithm. 
    % Remove the next comment to display the graph of stimulus signal Vs eye_record signal
    
     EMD_Plot(eye_record, stimulus_record,'stimulus');
    
    % This will call the detection algorithm and inside the detection
    % algorithm, grouping/merging function EMD_Merge()
    
% if(score_IVT)    
    [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_IVT(eye_record);
    
% UNCOMMENT CLASSIFICATION ALGORITHM HERE THAT YOU INTEND TO CLASSIFY    
%     [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_HMM(eye_record);
%     [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_IDT(eye_record);
%     [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_MST(eye_record);
%     [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_IKF(eye_record);
    [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_KMeans(eye_record);
    EMD_Score(eye_record,stimulus_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD);
    
    
    % Remove the next comment to display the graph of the eye movement
    % detection after the grouping and merging 
    
     EMD_Plot(eye_record, stimulus_record,'I-VT');
    
% end


clear eye_record;
clear stimulus_record;
return