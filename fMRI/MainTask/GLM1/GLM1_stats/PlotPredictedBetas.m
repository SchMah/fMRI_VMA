%% Specify data path
addpath = '\MainTask\'
data_path =  '\PATH\GLM1\Firstlevel' % PATH TO THE FIRST LEVEL ANALYSIS FOLDER
glm_folder = '1st_level'
dir_info = '\FILE_INFO\PATH\' % PATH TO FILE_INFO EXCEL FILE 
file_info = 'behavioral-to-Vnumber-conversion.xlsx'
T_info = readtable(fullfile(dir_info,file_info),'ReadVariableNames',true);
dir_save = 'SAVE/DIR/'

%subject V number
subj_list = '[...];'
regions_roi_localizer_thalamus;
R = region_calcregions(R);

for subj = 1:size(subj_list,2)
    clear matlabbatch
    subj_id = sprintf('sub-%03d', subj_list(subj))
    if isfolder([data_path '/' subj_id '/ses-002/func/' glm_folder])
        SPM_DM = fullfile(data_path, subj_id,'ses-002', 'func',glm_folder,'SPM.mat');
        load(SPM_DM);
    else
        display([data_path '/' subj_id '/' 'ses-002' '/' 'func' '/' glm_folder '/' 'SPM.mat' '... does not exists']);
        return
    end
    [~,y_adj{subj},y_hat{subj},y_res{subj}, B{subj},y_filt{subj}] = region_getts(SPM, R);
    betaname{subj} = SPM.xX.name;
end

conditions_name = {'bsl1','bsl2','bsl3','bsl4','rot5a','rot5b','rot10a','rot10b','rot15','rot15run2','rot20a','rot20b','rot25a',...
       'rot25b', 'rot30a','rot30b', 'Washout-1','Washout-2','Washout-3'}

% Initialize the table to store the results
Beta_conditions = table();
% Loop over subjects
for sn = 1:size(subj_list, 2)
    subject_data = table(); % Initialize a structure to store the subject's data
    
    % Loop over conditions
    for i = 1:size(conditions_name, 2)
        a = find(ismember(betaname{1, sn}, conditions_name{i}));
        
        % Check if the condition exists for the subject
        if ~isempty(a)
            
            % Loop over R values
            for r = 1:length(R)
                % Get the data for the specific R value
                data_value = B{1,sn}(a,r) % Replace this with the actual data retrieval code based on 'a' and 'R(r)'
                
                % Store the data in the condition_data structure
                condition_data(r,1) = data_value;
                roi(r) = r
                roi_name(r)= {R{r}.name};
            end
            
            % Add the condition_data to the subject_data
            subject_data.roi =  roi'
            subject_data.roi_name =  roi_name';
            subject_data.(conditions_name{i}) = condition_data;
            
        end
    end
    
    % Add the subject_data to the Beta_conditions table
    subject_name = table(repmat(subj_list(sn),length(R),1), 'VariableNames', {'Subject'});
    indv_subj_cat = [subject_name subject_data];
    Beta_conditions = [Beta_conditions; indv_subj_cat];
end



%% save table of predicted betas
% run main.m KinematicParameters.m separately. Warning: the code contains "clear all". Don't run it by command. Run sections of the code to get hand angle and RT 
adap_blocks = {'Hbsl1','Hbsl2','Hbsl3','Hbsl4','Hrot5a','Hrot5b','Hrot10a','Hrot10b','Hrot15','Hrot15run2',...
    'Hrot20a','Hrot20b','Hrot25a','Hrot25b','Hrot30a','Hrot30b','HWashout-1','HWashout-2','HWashout-3'};

subj = unique(T_Group.SN)
table_beh = table; 
for sn = 1: length(subj_list)
    table_beh_tmp = table;
        for con = 1: 19; 
        idx = find(subj_list(sn)== T_info.V_number); % find the current subject in the information table; for instance subj 5595 is row 31. having this helps to find the behvioral label for this subjest
        beh_ind = find(strcmp( T_info.subject_label(idx), strcat('S', cellstr(subj))));
        table_beh_tmp.sub = repmat(T_info.subject_label(idx),length(R),1);
        table_beh_tmp.Vnum = repmat(subj_list(sn),length(R),1);
        ColumnName = cell2mat(adap_blocks(con));
        table_beh_tmp.(ColumnName) = repmat(hand_maxRadVel(beh_ind,con),length(R),1);%adap_amount(beh_ind);
        
        end
  table_beh = [table_beh;table_beh_tmp];     
end

% add reaction time 
adap_blocks = {'RTbsl1','RTbsl2','RTbsl3','RTbsl4','RTrot5a','RTrot5b','RTrot10a','RTrot10b','RTrot15','RTrot15run2',...
    'RTrot20a','RTrot20b','RTrot25a','RTrot25b','RTrot30a','RTrot30b','RTWashout-1','RTWashout-2','RTWashout-3'};
subj = unique(T_Group.SN)
table_beh_RT = table; 
for sn = 1: length(subj_list)
    table_beh_RT_tmp = table;
        for con = 1: 19; 
        idx = find(subj_list(sn)== T_info.V_number); % find the current subject in the information table; for instance subj 5595 is row 31. having this helps to find the behvioral label for this subjest
        beh_ind = find(strcmp( T_info.subject_label(idx), strcat('S', cellstr(subj))));
        ColumnName = cell2mat(adap_blocks(con));
        table_beh_RT_tmp.(ColumnName) = repmat(RT(beh_ind,con),length(R),1);%adap_amount(beh_ind); 
        end
  table_beh_RT = [table_beh_RT; table_beh_RT_tmp];     
end

Beta_conditions = [Beta_conditions table_beh table_beh_RT]
writetable(Beta_conditions,[dir_save 'beta_adaptation_beh.txt'],'Delimiter',' ')




