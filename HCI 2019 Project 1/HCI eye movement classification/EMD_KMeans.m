% Author: Gentry Atkinson
% K-Means based eye movement classification based on:
% I-VT, eye movement detection by Velocity Threshold Model
% Provided for CS7321 at Texas State University
function [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD]= EMD_KMeans(eye_record)

    display('>>> EMD_KMeans starts..................................................................');
    
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
    
    


    FIX_PER     = 100 * fixation_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    SAC_PER     = 100 * saccade_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    PUR_PER     = 100 * pursuit_counter / (saccade_counter + fixation_counter + pursuit_counter + noise_counter);
    NOISE_PER   = 100 * noise_counter /(saccade_counter + fixation_counter + pursuit_counter + noise_counter);


    %% Call the EMD_Merge for grouping and Merging Saccades, Fixations and Pursuits 
    [eye_record,fixation_filtered_EMD,saccade_filtered_EMD,pursuit_detected_EMD] = EMD_Merge(eye_record);


return 