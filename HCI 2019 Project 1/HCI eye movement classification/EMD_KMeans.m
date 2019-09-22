% Author: Gentry Atkinson
% K-Means based eye movement classification based on:
% I-VT, eye movement detection by Velocity Threshold Model
% Provided for CS7321 at Texas State University
function [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD]= EMD_KMeans(eye_record)

    display('>>> EMD_KMeans starts...............................................................');
    
    global FIX_PER;
    global SAC_PER;
    global PUR_PER;
    global NOISE_PER;
    global K;

 %% YOU MUST INITIALIZE THE VARIABLES THAT ARE RELATED TO YOUR CLASSIFICATION METHOD HERE 
    K=2;

 
    
    %% K-Means algorithm
    fixation_counter = 0;
    saccade_counter = 0;
    pursuit_counter = 0;
    noise_counter = 0;
    
    display(length(eye_record));
    data = zeros(3, length(eye_record));
    
    for t=1:length(eye_record)
        data(t,1) = abs(eye_record(t).xy_velocity_measured_deg);
        data(t,2) = abs(eye_record(t).x_velocity_measured_deg);
        data(t,3) = abs(eye_record(t).y_velocity_measured_deg);
    end

%     data(:,1) = eye_record(:).xy_velocity_measured_deg;
    
    clusters = kmeans(data, 2);
    
    for t=1:length(clusters)
        eye_record(t).xy_movement_EMD = clusters(t);
        if (clusters(t) == 1)
           fixation_counter = saccade_counter + 1; 
        elseif (clusters(t) == 2)
           saccade_counter = saccade_counter + 1;
        else
            eye_record(t).xy_movement_EMD = 4;
        end
            
    end


    FIX_PER     = 100 * fixation_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    SAC_PER     = 100 * saccade_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    PUR_PER     = 100 * pursuit_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    NOISE_PER   = 100 * noise_counter /(saccade_counter + fixation_counter + pursuit_counter + noise_counter);


    %% Call the EMD_Merge for grouping and Merging Saccades, Fixations and Pursuits 
    [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_Merge(eye_record);


return 