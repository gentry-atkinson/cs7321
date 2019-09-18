close all;
clear all;
clc; % clear command window
display(strcat('START processing data : ',datestr(now)));


global SUM_SACCADE_AMPLITUDE;
global SACCADE_COUNTER;% this counter will not contain either corrupted saccades or micro saccades
global SACCADE_AMPLITUDE_AVR;
global SACCADE_CORRUPTED_PER;% this metric shows the percentage of corrupted saccades out of total saccades
global SACCADE_MICRO_PER;% this metric shows the percentage of micro saccades without considering corrupted saccades
global SUM_FIXATION_DURATION_SEC;
global FIXATION_COUNTER;
global FIXATION_DURATION_AVR_SEC;
global TOTAL_EYE_PATH_DEG;% how much eye movement between qualified fixations in degrees
global FIX_PER;
global SAC_PER;
global PUR_PER;
global NOISE_PER;
global LE_VALIDITY_PER;% validity of the left eye
global RE_VALIDITY_PER;% validity of the right eye
global BLINK_DURATION_SEC% this variable hold the value for the average blink duration. This value is going to be used in fixation filtering/merging algorithm
global FIXATION_MERGE_DISTANCE_THRESHOLD_DEG
global SUBJECT_FILES_INPUT_DIR;% directory from where subject files are going to be read
global SUBJECT_FILES_OUTPUT_DIR;% directory to where subject files are going to be stored
global SUBJECT_FILE_NAME; % name of the subject files  
global SUBJECT_NAME; 
global SUBJECT_NAME_NUMBER;
global VALIDITY_PERCENTAGE_THRESHOLD;
global SUBJECT_NUMBER;
global SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD;
global score_IVT;
global DELTA_T_SEC 
global FIXATION_MINIMUM_DURATION_SEC;
global stopper; % this will stop doing any other process on the subject if the detection is not successful (at EMD_Merge)
 
% variables related to experiment setup
global IMAGE_WIDTH_ETU  
global IMAGE_HEIGHT_ETU
global IMAGE_WIDTH_MM
global IMAGE_HEIGHT_MM
global SUBJECT_DISTANCE_FROM_EYE_TRACKER_MM
global EYE_TRACKER_SAMPLING_RATE_HZ
global MINIMUM_SACCADE_RANGE_DEG;

    %variables related to IVT
global SACCADE_DETECTION_THRESHOLD_DEG_SEC;
global FIXATION_DETECTION_THRESHOLD_DEG_SEC;
global PURSUIT_DETECTION_THRESHOLD_DEG_SEC;

% YOU MUST CREATE GLOBAL VARIABLES THAT ARE RELATED TO YOUR CLASSIFICATION
% METHOD

%variables related to plot graph & EMD score
global Movement_Selection; % this will give the type of the eye movement sample, 1D HR, 1D VR etc...
global Score_Selection; % This will give the eye movement detection algorithm for score calculations



 %% initializing variables related to experiment setup
 IMAGE_WIDTH_ETU = 1280; 
 IMAGE_HEIGHT_ETU = 1024;  
 IMAGE_WIDTH_MM = 377;
 IMAGE_HEIGHT_MM = 303;
 SUBJECT_DISTANCE_FROM_EYE_TRACKER_MM = 710; 
 EYE_TRACKER_SAMPLING_RATE_HZ = 120;
 
 VALIDITY_PERCENTAGE_THRESHOLD = 80;% Right eye validity threshold.
 DELTA_T_SEC = 1/EYE_TRACKER_SAMPLING_RATE_HZ; % eye-position sampling interval measured in sec
 
 
 %% file parameters initialization
    %input and output file folders
SUBJECT_FILES_OUTPUT_DIR = 'EMD_Output/'; 
Movement_Selection = input ('1D HR Saccades = 1 \n1D HR Pursuits = 3 \n Enter Movement Type:', 's');
if Movement_Selection =='1'
    SUBJECT_FILES_INPUT_DIR = 'EMD_Input/1D_HR_Saccades/';
    SUBJECT_NAME = '1D_HR_Saccade_participant-';
elseif Movement_Selection =='3'
    SUBJECT_FILES_INPUT_DIR = 'EMD_Input/1D_HR_Pursuits/';  
    SUBJECT_NAME = '1D_HR_Pursuit_20_participant-';
end

%% EMD_MERGE grouping and merging related parameters
FIXATION_MINIMUM_DURATION_SEC = 0.1;
BLINK_DURATION_SEC = 0.075;
MINIMUM_SACCADE_RANGE_DEG = 0.5; % assigning value for the saccade range to eliminate corrupted/micro saccades
FIXATION_MERGE_DISTANCE_THRESHOLD_DEG = 1;


%% EMD SCORE RELATED PARAMETERS
score_IVT = 0;
SCORE_IMPROVEMENT_FIXATION_DIFFERENCE_THRESHOLD = 3;

%% parameter declaration and initialization
SUM_SACCADE_AMPLITUDE=0;
SACCADE_COUNTER=0;
SUM_FIXATION_DURATION=0;
FIXATION_COUNTER=0;
SUM_SACCADE_AMPLITUDE = 0;
SACCADE_COUNTER = 0;     
SUM_FIXATION_DURATION = 0;
FIXATION_COUNTER = 0;
LE_VALIDITY_PER = 0;
RE_VALIDITY_PER = 0;
SACCADE_AMPLITUDE_AVR = 0;
SACCADE_CORRUPTED_PER = 0;
SACCADE_MICRO_PER = 0;
SUM_FIXATION_DURATION_SEC = 0;
FIXATION_DURATION_AVR_SEC = 0;
FIX_PER = 0;
SAC_PER = 0;
    
    %score  files
FID_IVT_Score = fopen(strcat(SUBJECT_FILES_OUTPUT_DIR, SUBJECT_NAME_NUMBER, 'IVT_Score_All_Subjects.txt'), 'wt');
fprintf(FID_IVT_Score,'Fixation_Threshold  ,Saccade_Threshold  ,Avg_Sac_Quantitative,  Avg_Fix_Quantitative_Count,  Avg_Fix_Quantitative  ,Avg_Fix_Qualitative_1D_HR  ,Avg_Fix_Qualitative_1D_VR  ,Avg_Fix_Qualitative_2D,  Avg_Pur_Quantitative, Avg_Pur_Vel_Qualtitative_1D_HR, Avg_Pur_Diff_Qualitative_1D_HR,  Avg_Pur_Vel_Qualtitative_1D_VR, Avg_Pur_Diff_Qualitative_1D_VR,  Avg_Pur_Vel_Qualtitative_2D,  Avg_Pur_Diff_Qualitative_2D,  Average_saccade_counter,  Average_fixation_counter,  Saccade_to_fixation_ratio,  Saccade_amplitude_avg,  Fixation_duration_avg \n');

    %log file to keep track of subjects failing after detection
FID_subject_log_IVT = fopen(strcat(SUBJECT_FILES_OUTPUT_DIR, SUBJECT_NAME_NUMBER, 'IVT_Subject_log.txt'), 'wt');
fprintf(FID_subject_log_IVT,'Subject_Number  ,Saccade_Threshold  ,Fixation_Threshold  ,Pursuit_Threshold \n');


    %program input selection for score improvements
Score_Selection = '1';
    %assign values to the global score selection
% if(Score_Selection =='1')
%    score_IVT = 1; 
% 
% end



%% IVT 

% if(score_IVT)
    
        EMD_Score_parameter_initialization();  
        
        SUBJECT_NUMBER = 2; % Subject Number from the input folder
            % this will create correct subject file id to retrive data from
            % the subject file
        str_sbj_num = num2str(SUBJECT_NUMBER,'%02d\n');
        SUBJECT_FILE_NAME = strcat(SUBJECT_NAME,str_sbj_num,'.txt');
        SUBJECT_NAME_NUMBER = strcat(SUBJECT_NAME,str_sbj_num);
        test_subject_fid = fopen(strcat(SUBJECT_FILES_INPUT_DIR,SUBJECT_FILE_NAME), 'r');
        
        if(test_subject_fid ==-1)
           display('Invalid Subject ID!'); 
        else

            C = textscan(test_subject_fid, '%s', 11, 'delimiter','\n');
            C = textscan(test_subject_fid, '%d %d %f %f %f %d %f %f %f %f %d %f %f %f');
            
                %create structure "eye_data" to hold eye movement data
            eye_data.gaze_validity                  = C{6}; % validity of the right eye
            eye_data.gaze_validity_left             = C{11}; %validity of the left eye
            eye_data.x_pos_measured_deg             = C{3}; % x position mesasured degree at right eye
            eye_data.y_pos_measured_deg             = C{4}; % y position mesasured degree at right eye
            eye_data.x_stimulus_pos_measured_deg    = C{13}; % stimulus x coordinate
            eye_data.y_stimulus_pos_measured_deg    = C{14}; % stimulus y coordinate

            % process subjects based on validity of right eye. If validy of the
            % right eye is greater than validity threshold, then only process the subject data,
            valid_counter = 0;    
            for t=1:length(eye_data.gaze_validity);
                if(eye_data.gaze_validity(t) == 0)
                    valid_counter = valid_counter + 1;
                end
            end 

            RE_VALIDITY_PER = 100*(valid_counter)/length(eye_data.gaze_validity);
            if(RE_VALIDITY_PER > VALIDITY_PERCENTAGE_THRESHOLD)
                % call the main function for data processing
                main(eye_data); 
                % responsible for collecting the data from EMD_Score
                % program to get the total score values from all the
                % subjects. This is used when there are several subjects to get the running totals. 
                EMD_Score_data_collection(); 
                
            end

            if(stopper) % if subject detection failed at EMD_Merge, stopper = 1 otherwise stopper = 0
                fprintf(FID_subject_log_IVT,'%d        ,%0.2f      ,%0.2f \n',SUBJECT_NUMBER,SACCADE_DETECTION_THRESHOLD_DEG_SEC,FIXATION_DETECTION_THRESHOLD_DEG_SEC);
            end
        end %end if
        
        fclose(test_subject_fid);
        EMD_Score_calculation(FID_IVT_Score); % call the function to write score data into external files
     
% end
    


 display(strcat('STOP processing data : ',datestr(now)));
 fclose('all');