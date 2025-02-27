%% Behavioral Data
%run the behavioral analysis code to have avg of hand angle in blocks of
%experiment
addpath(genpath('C:\Users\mahdavi\Documents\MATLAB\fMRI_VMA_Experiment\fMRI_VMA_BehavioralData\fMRI_VMA_session2\Script'))
loc_group_analysis;
for s = 1: length(subj)
    perception_mean_bsl(s,1) = mean(perception_block(s,1:4)) %baseline blocks 1 2 3 4
    perception_mean_adap(s,1) = mean(perception_block(s,15:16)) %last adaptationblocks 15 16 rot30
    perception_mean_washout(s,1) = mean(perception_block(s,19))- mean(perception_block(s,17))
    perception_change(s,1) =  perception_mean_bsl(s) -  perception_mean_adap(s) %
end

subj
%% subjects included in fmri analysis
subj_list = [5595 7605 7629 8028 8063 8082 8083 8084 8091 8092 8095 8099 8100 8104 8105 8108 8109 8110 8113 8114 8116 8117 8120 8121 8124 8127 8129 8131 8135 8136];
% subj_list_beta = [5595 7605 7629 8028 8063 8082 8083 8084 8091 8092 8095 8099 8100 8104 8105 8108 8109 8110 8113 8114 8116 8117 8120 8121 8124 8127 8129 8131 8135 8136];

%% information table
% read table of subjects information/ conversion between Vnumber in MRI
% analysis and S* numbers in behavioral analysis
% location of excel file:
dir_info = 'C:\Users\mahdavi\Documents\MATLAB\fMRI_VMA_Experiment'
file_info = 'behavioral-to-Vnumber-conversion.xlsx'
T_info = readtable(fullfile(dir_info,file_info),'ReadVariableNames',true);
%% contrast of interest

% extract betas for the contrast of interest (adaptation-bsl)
contrast_dir = 'I:\fMRI_VMA_Analysis\fMRI_VMA_Analysis_topup\6_IndividualHRF_wholeBrain\6_3_13_PMPhase2_IndvHRF_ActualHand_hpf200_rwls_removeRest_smooth6_msgreg_rp\2ndLevel_compcor_war_HandRot_msgdispreg\Perception-pm'
% contrast_dir = 'I:\fMRI_VMA_Analysis\fMRI_VMA_Analysis_topup\6_IndividualHRF_wholeBrain\6_3_13_PMPhase2_IndvHRF_ActualHand_hpf200_rwls_removeRest_smooth6_msgreg_rp\fixedDur\2ndLevel_compcor_war_HandRot_msgdispreg_fixdur\Perception-pm'
% contrast_dir = 'I:\fMRI_VMA_Analysis\fMRI_VMA_Analysis_topup\6_IndividualHRF_wholeBrain\6_3_13_PMPhase2_IndvHRF_ActualHand_hpf200_rwls_removeRest_smooth6_msgreg_rp\HandPosOnly_fixDur\2ndLevel_HandP_fixdur\PerceptionPM'
load(fullfile(contrast_dir,'SPM.mat'))
%% read regions of interest
addpath(genpath('C:\Users\mahdavi\Documents\MATLAB\fMRI_VMA_Experiment\fMRI_NEuroimaginge_Analysis'))
regions_roi_localizer_thalamus;
R = region_calcregions(R);


% extract betas for selected regions
[beta] = region_getdata(SPM.xY.VY,R);
% mean of extracted betas over the roi 
for i = 1: size(R,2)
    avgbeta_roi(:,i) = mean(beta{1,i},2,'omitnan')
end
% % % plot the correlations
% % for r = 1: length(R)
% %     
% %     for sn = 1: length(subj_list)
% %         idx = find(subj_list(sn)== T_info.V_number) % find the current subject in the information table; for instance subj 5595 is row 31. having this helps to find the behvioral label for this subjest
% %         beh_ind = find(strcmp( T_info.subject_label(idx), strcat('S', cellstr(subj))));
% %         percpX(sn,1) = perception_change(beh_ind) %perception_block(beh_ind,17)% - perception_block(beh_ind,17)% (perception_change(beh_ind));
% %         idx_s = find(subj_list_beta == subj_list(sn))
% %         betaY(sn,1) = avgbeta_roi(idx_s,r);
% %     end
% %     
% %     [R1, p1] = corr([percpX,betaY], 'Type','Spearman');
% %     h = figure ('Color', [1 1 1]);hold on;
% %     set(gcf,'units','inches','pos',[4 4 4 4]);
% %     plot(percpX,betaY,'.','MarkerEdgeColor','k','MarkerSize',10)
% %     text(min(percpX), max(betaY),['p = ' num2str(p1(1,2),2) ' r = ' num2str(R1(1,2),2)],'FontWeight','bold','FontSize', 12,'color','k')
% %     l = lsline;
% %     xlabel(['Adapation Amount (',char(176),')'],'FontWeight','normal','FontSize',10);
% %     ylabel(['Predicted Beta'],'FontWeight','normal','FontSize',10);
% %     title(['ROI ' R{r}.name],'Interpreter', 'latex')
% %     set(l,'LineWidth', 2)
% % end

    
% organize data to save for analysis in R
Beta_per = table();

for s = 1: length(subj_list)
    subject_data = table(); % Initialize a structure to store the subject's data
    % Loop over R values
    for r = 1:length(R)
        % Get the data for the specific R value
        data_ind_value =  avgbeta_roi(s,r); % Replace this with the actual data retrieval code based on 'a' and 'R(r)'
        
        % Store the data in the condition_data structure
        condition_data(r,1) = data_ind_value;
        roi(r) = r;
        roi_name(r)= {R{r}.name};
    end
    
    % Add the condition_data to the subject_data
    subject_data.roi =  roi';
    subject_data.roi_name =  roi_name';
    subject_data.betaPerception = condition_data;
    % find behavioral subject label from the MR list 
    idx = find(subj_list(s)== T_info.V_number);
    subject_sn = table(repmat(T_info.subject_label(idx),length(R),1), 'VariableNames', {'subjectSN'});
    sub_name = cell2mat(T_info.subject_label(idx)) % same as above. to keep it persistent with T_GLoc_R
    subject_sn_2 = table(repmat(sub_name(2:end),length(R),1), 'VariableNames', {'sub_SN'});
    % Add the subject_data to the Beta_conditions table
    subject_name = table(repmat(subj_list(s),length(R),1), 'VariableNames', {'Subject'});
    % find subject name in behavioral perception matrix
    beh_ind = find(strcmp( T_info.subject_label(idx), strcat('S', cellstr(subj))));
    percp_subj = table(repmat(perception_change(beh_ind),length(R),1), 'VariableNames', {'perception'}) ;
    
    indv_subj_cat = [subject_name subject_sn subject_sn_2 subject_data percp_subj];
    Beta_per = [Beta_per; indv_subj_cat];
    
end

dir_save = 'C:\Users\mahdavi\Documents\MATLAB\fMRI_VMA_Experiment\fMRI_NEuroimaginge_Analysis\GLM2\'
writetable(Beta_per,[dir_save 'beta_perception.txt'],'Delimiter',' ')

 