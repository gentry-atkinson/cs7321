function EMD_Score_parameter_initialization()

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
    
        %score related parameters
    fix_q_total_score = 0; % total fixation quantitative score to get the average
    sac_q_total_score = 0; % total saccade quantitative score to get the average
    fix_qual_diff_total_hr = 0;
    fix_qual_diff_total_vr = 0;
    fix_qual_diff_total_2D = 0;
    pur_q_total_score = 0;
    pur_qual_diff_total_hr = 0;
    pur_qual_vel_total_hr = 0;
    pur_qual_vel_total_vr = 0;
    pur_qual_diff_total_vr = 0;
    pur_qual_vel_total_2D = 0;
    pur_qual_diff_total_2D = 0;
    score_count = 0; % number of iterations of the score  
    total_saccade_amplitude_avg = 0 ; % total avg value from all the subjects
    total_fixation_duration_avg = 0;
    total_saccade_counter = 0;
    total_fixation_counter = 0;
    fix_q_count_total_score = 0;
    
    FIXATION_QUANTITATIVE_COUNT_SCORE_AVG = NaN;
    FIXATION_QUANTITATIVE_SCORE_AVG = NaN;
    SACCADE_QUANTITATIVE_SCORE_AVG = NaN;
    FIXATION_DIFFERENCE_QUALITATIVE_1D_HR_AVG = NaN;
    FIXATION_DIFFERENCE_QUALITATIVE_1D_VR_AVG = NaN;
    FIXATION_DIFFERENCE_QUALITATIVE_2D_AVG = NaN;
    PURSUIT_QUANTITATIVE_SCORE_AVG = NaN;
    PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_HR_AVG = NaN;
    PURSUIT_VELOCITY_QUALITATIVE_SCORE_1D_VR_AVG = NaN;
    PURSUIT_VELOCITY_QUALITATIVE_SCORE_2D_AVG = NaN;
    PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_HR_AVG = NaN;
    PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_1D_VR_AVG = NaN;
    PURSUIT_DIFFERENCE_QUALITATIVE_SCORE_2D_AVG = NaN;
    
return