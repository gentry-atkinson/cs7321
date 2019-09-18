% Collect total score values to get average score for all the subjects, 
% called after the EMD_score from runtime at each detection algorithm
function EMD_Score_data_collection()

global FIXATION_POINT_QUANTITATIVE_COUNT_SCORE;
global FIXATION_POINT_QUANTITATIVE_SCORE;
global FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR;
global FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR;
global FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D;
global SACCADE_AMPLITUDE_QUANTITATIVE_SCORE;

global PURSUIT_QUANTITATIVE_SCORE;
global PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR;
global PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR;
global PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D;
global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR;
global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR;
global PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D;

global Movement_Selection; % this will give the type of the eye movement sample
global fix_q_total_score; %total fixation quantitative score
global sac_q_total_score; % total saccade quantitative score
global fix_qual_diff_total_hr; % total fixa qualitative score hr
global fix_qual_diff_total_vr; %total fixation qualitative score ver
global fix_qual_diff_total_2D; 
global score_count;% number of scores on recursion
global fix_q_count_total_score; % total fixation quantitative count score

global pur_q_total_score;
global pur_qual_vel_total_hr;
global pur_qual_vel_total_vr;
global pur_qual_diff_total_hr;
global pur_qual_diff_total_vr;
global pur_qual_vel_total_2D;
global pur_qual_diff_total_2D;
 
global total_saccade_amplitude_avg;
global SACCADE_AMPLITUDE_AVR; 
global FIXATION_DURATION_AVR_SEC;
global total_fixation_duration_avg;
global SACCADE_COUNTER;
global total_saccade_counter;
global FIXATION_COUNTER;
global total_fixation_counter;


global stopper; % this will stop doing any other stuff on the subject if the detection is not successful

if(stopper)
%     display('Subject detection failed......no score calculations performed!');
else
    % display(SACCADE_AMPLITUDE_QUANTITATIVE_SCORE);
    fix_q_total_score = fix_q_total_score + FIXATION_POINT_QUANTITATIVE_SCORE;
    sac_q_total_score = sac_q_total_score + SACCADE_AMPLITUDE_QUANTITATIVE_SCORE;
    fix_q_count_total_score =  fix_q_count_total_score + FIXATION_POINT_QUANTITATIVE_COUNT_SCORE;
    
    if(Movement_Selection =='1' || Movement_Selection=='3')% 1D horizontal
       fix_qual_diff_total_hr = fix_qual_diff_total_hr + FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR;
    elseif (Movement_Selection=='2' || Movement_Selection=='4')%1D vertical
       fix_qual_diff_total_vr = fix_qual_diff_total_vr +  FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR;
    elseif(Movement_Selection=='5')%2D
        fix_qual_diff_total_2D = fix_qual_diff_total_2D + FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D;

    end

    if(Movement_Selection == '3')%1D HR pursuit
        pur_q_total_score = pur_q_total_score + PURSUIT_QUANTITATIVE_SCORE;
        pur_qual_diff_total_hr = pur_qual_diff_total_hr + PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR;
        pur_qual_vel_total_hr = pur_qual_vel_total_hr + PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR;

    elseif(Movement_Selection == '4') %1D VR Pursuit
        pur_q_total_score = pur_q_total_score + PURSUIT_QUANTITATIVE_SCORE;
        pur_qual_vel_total_vr = pur_qual_vel_total_vr +  PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR;
        pur_qual_diff_total_vr = pur_qual_diff_total_vr + PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR;

    elseif(Movement_Selection == '5') %2D Pursuit
        pur_q_total_score = pur_q_total_score + PURSUIT_QUANTITATIVE_SCORE;
        pur_qual_vel_total_2D = pur_qual_vel_total_2D + PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D;
        pur_qual_diff_total_2D = pur_qual_diff_total_2D + PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D;
    end


    score_count = score_count + 1;
    total_saccade_amplitude_avg = total_saccade_amplitude_avg + SACCADE_AMPLITUDE_AVR;
    total_fixation_duration_avg = total_fixation_duration_avg + FIXATION_DURATION_AVR_SEC;
    total_saccade_counter = total_saccade_counter + SACCADE_COUNTER;
    total_fixation_counter = total_fixation_counter + FIXATION_COUNTER;

    % fprintf(FID_IVT_Score_val,'%d                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f                ,%0.2f \n',i,SACCADE_AMPLITUDE_QUANTITATIVE_SCORE,FIXATION_POINT_QUANTITATIVE_SCORE,FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_HR,FIXATION_DIFFERENCE_QUALITATIVE_SCORE_1D_VR,FIXATION_DIFFERENCE_QUALITATIVE_SCORE_2D,PURSUIT_QUANTITATIVE_SCORE,PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR,PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR,PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D,PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR,PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR,PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D);

end

return