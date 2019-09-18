function EMD_Score_calculation(FID_IVT_Score)

    global Movement_Selection; 
    global SACCADE_DETECTION_THRESHOLD_DEG_SEC;
    global FIXATION_DETECTION_THRESHOLD_DEG_SEC;
    global PURSUIT_DETECTION_THRESHOLD_DEG_SEC;

    global fix_q_total_score; %total fixation quantitative score
    global sac_q_total_score; % total saccade quantitative score
    global fix_qual_diff_total_hr; % total fixa qualitative score hr
    global fix_qual_diff_total_vr; %total fixation qualitative score ver
    global fix_qual_diff_total_2D; 
    global score_count;% number of scores on recursion
    global pur_q_total_score;
    global pur_qual_vel_total_hr;
    global pur_qual_vel_total_vr;
    global pur_qual_diff_total_hr;
    global pur_qual_diff_total_vr;
    global pur_qual_vel_total_2D;
    global pur_qual_diff_total_2D;
    global total_saccade_amplitude_avg;
    global total_fixation_duration_avg;
    global total_saccade_counter;
    global total_fixation_counter;
    global fix_q_count_total_score; % total fixation quantitative count score


    global FIXATION_QUANTITATIVE_COUNT_SCORE_AVG;
    global FIXATION_QUANTITATIVE_SCORE_AVG;
    global SACCADE_QUANTITATIVE_SCORE_AVG;
    global FIXATION_DIFFERENCE_QUALITATIVE_1D_HR_AVG;
    global FIXATION_DIFFERENCE_QUALITATIVE_1D_VR_AVG;
    global FIXATION_DIFFERENCE_QUALITATIVE_2D_AVG;
    global PURSUIT_QUANTITATIVE_SCORE_AVG;
    global PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR_AVG;
    global PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR_AVG;
    global PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D_AVG;
    global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR_AVG;
    global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR_AVG;
    global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D_AVG;


    FIXATION_QUANTITATIVE_COUNT_SCORE_AVG = fix_q_count_total_score/score_count  ;  
    FIXATION_QUANTITATIVE_SCORE_AVG = fix_q_total_score/score_count;
    SACCADE_QUANTITATIVE_SCORE_AVG  = sac_q_total_score/score_count;
    ALL_SUBJECT_SACCADE_AMPLITUDE_AVG = total_saccade_amplitude_avg/score_count ;
    ALL_SUBJECT_FIXATION_DURATION_AVG = total_fixation_duration_avg/score_count;
    ALL_SUBJECT_SACCADE_COUNTER_AVG = total_saccade_counter/score_count;
    ALL_SUBJECT_FIXATION_COUNTER_AVG = total_fixation_counter/score_count;
    SACCADE_TO_FIXATION_RATIO = ALL_SUBJECT_SACCADE_COUNTER_AVG/ALL_SUBJECT_FIXATION_COUNTER_AVG;

    if(Movement_Selection =='1' || Movement_Selection=='3')% 1D horizontal
          FIXATION_DIFFERENCE_QUALITATIVE_1D_HR_AVG = fix_qual_diff_total_hr/score_count;
    elseif (Movement_Selection=='2' || Movement_Selection=='4')%1D vertical
          FIXATION_DIFFERENCE_QUALITATIVE_1D_VR_AVG = fix_qual_diff_total_vr/score_count;
    elseif(Movement_Selection=='5')%2D
          FIXATION_DIFFERENCE_QUALITATIVE_2D_AVG = fix_qual_diff_total_2D/score_count;

    end

    if(Movement_Selection == '3')%1D HR pursuit
        PURSUIT_QUANTITATIVE_SCORE_AVG=pur_q_total_score/score_count;
        PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR_AVG = pur_qual_diff_total_hr/score_count;
        PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR_AVG = pur_qual_vel_total_hr/score_count;

    elseif(Movement_Selection == '4') %1D VR Pursuit
        PURSUIT_QUANTITATIVE_SCORE_AVG = pur_q_total_score/score_count;
        PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR_AVG = pur_qual_vel_total_vr/score_count;
        PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR_AVG = pur_qual_diff_total_vr/score_count;

    elseif(Movement_Selection == '5') %2D Pursuit
        PURSUIT_QUANTITATIVE_SCORE_AVG = pur_q_total_score/score_count;
        PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D_AVG = pur_qual_vel_total_2D/score_count;
        PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D_AVG = pur_qual_diff_total_2D/score_count;
    end


    fprintf(FID_IVT_Score,'%d                ,%d                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f \n',FIXATION_DETECTION_THRESHOLD_DEG_SEC,SACCADE_DETECTION_THRESHOLD_DEG_SEC,SACCADE_QUANTITATIVE_SCORE_AVG,FIXATION_QUANTITATIVE_COUNT_SCORE_AVG,FIXATION_QUANTITATIVE_SCORE_AVG,FIXATION_DIFFERENCE_QUALITATIVE_1D_HR_AVG,FIXATION_DIFFERENCE_QUALITATIVE_1D_VR_AVG,FIXATION_DIFFERENCE_QUALITATIVE_2D_AVG,PURSUIT_QUANTITATIVE_SCORE_AVG,PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR_AVG,PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR_AVG,PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR_AVG,PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR_AVG,PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D_AVG,PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D_AVG,ALL_SUBJECT_SACCADE_COUNTER_AVG,ALL_SUBJECT_FIXATION_COUNTER_AVG,SACCADE_TO_FIXATION_RATIO,ALL_SUBJECT_SACCADE_AMPLITUDE_AVG,ALL_SUBJECT_FIXATION_DURATION_AVG);
	
	fprintf('Saccade Quantitative Score (SQnS): %0.2f\n', SACCADE_QUANTITATIVE_SCORE_AVG);
%	fprintf('Avg_Fix_Quantitative_Count: %0.2f\n', FIXATION_QUANTITATIVE_COUNT_SCORE_AVG);
	fprintf('Fixation Quantitative Score (FQnS): %0.2f\n', FIXATION_QUANTITATIVE_SCORE_AVG);
	fprintf('Fixation Qualitative Score (FQlS): %0.2f\n', FIXATION_DIFFERENCE_QUALITATIVE_1D_HR_AVG);
% 	fprintf('Avg_Fix_Qualitative_1D_VR: %0.2f\n', FIXATION_DIFFERENCE_QUALITATIVE_1D_VR_AVG);
% 	fprintf('Avg_Fix_Qualitative_2D: %0.2f\n', FIXATION_DIFFERENCE_QUALITATIVE_2D_AVG);
% 	fprintf('Avg_Pur_Quantitative: %0.2f\n', PURSUIT_QUANTITATIVE_SCORE_AVG);
% 	fprintf('Avg_Pur_Vel_Qualtitative_1D_HR: %0.2f\n', PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR_AVG);
% 	fprintf('Avg_Pur_Diff_Qualitative_1D_HR: %0.2f\n', PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR_AVG);
% 	fprintf('Avg_Pur_Vel_Qualtitative_1D_VR: %0.2f\n', PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR_AVG);
% 	fprintf('Avg_Pur_Diff_Qualitative_1D_VR: %0.2f\n', PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR_AVG);
% 	fprintf('Avg_Pur_Vel_Qualtitative_2D: %0.2f\n', PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D_AVG);
% 	fprintf('Avg_Pur_Diff_Qualitative_2D: %0.2f\n', PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D_AVG);


return