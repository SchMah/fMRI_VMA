% Specify data path
data_path = '...\BIDS';
timePoint_dir = '...\BIDS' ;
wd = '...\GLM2';
firstlevel = 'Firstlevel'
glm_folder = '1st_level'

%subject V number
subj_list = [];

block_adap_run1 = [1 2 3 4 5 6 7 8 9];
rot_run1 = [0 0 0 0 5 5 10 10 15];
block_adap_run2 = [10 11 12 13 14 15 16];
rot_run2 = [15 20 20 25 25 30 30];
block_washout = [17 18 19];
rot_washout = [0 0 0];

TR = 1.5

for subj = 1:size(subj_list,2)
    % Specify subject ID
    subj_id = sprintf('sub-%03d', subj_list(subj));
    if ~isfolder(fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder))
        mkdir(fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder))
    else
        display([wd firstlevel '/' subj_id '/ses-002/func/' glm_folder '...exists'])
    end
    %
    Job.dir = {fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder)};
    Job.timing.units = 'secs';
    Job.timing.RT = 1.5;
    Job.timing.fmri_t = 16;
    Job.timing.fmri_t0 = 1;
    
    Job.sess(1).scans = {[data_path '/' subj_id '/ses-002/func/s6war_merge_' subj_id '_ses-002_task-VMA_acq-GE_rec-ND_topup_NORDIC.nii']};
    
    %% conditions -Run1
    im_run1 = spm_vol([data_path '/' subj_id '/ses-002/func/s6war' subj_id '_ses-002_task-VMA_run-01.nii']);
    im_run2 = spm_vol([data_path '/' subj_id '/ses-002/func/s6war' subj_id '_ses-002_task-VMA_run-02.nii']);

    run1 = dir([timePoint_dir '/' subj_id '/ses-002/' subj_id '*' 'run-01.txt']);
    display(run1.name)
    data_run1 = readtable([run1.folder '/' run1.name],'Delimiter','\t','ReadVariableNames',true);
    
    run2 = dir([timePoint_dir '/' subj_id '/ses-002/' subj_id '*' 'run-02.txt']);
    display(run2.name)
    data_run2 = readtable([run2.folder '/' run2.name],'Delimiter','\t','ReadVariableNames',true);
    %
    % Conditions
    Job.sess.cond(1).name = 'Training';
    onsets_adap_run1 = data_run1.BlockOnset(ismember(data_run1.Block,block_adap_run1));
    onsets_adap_run2 = data_run2.BlockOnset(ismember(data_run2.Block,block_adap_run2)) + length(im_run1)*TR;
    onset_cat = [onsets_adap_run1;onsets_adap_run2];
    Hand_ang = [data_run1.HandBlock(ismember(data_run1.Block,block_adap_run1));data_run2.HandBlock(ismember(data_run2.Block,block_adap_run2))];
    Job.sess.cond(1).onset = onset_cat;
    Job.sess.cond(1).duration = [data_run1.block_duration(ismember(data_run1.Block,block_adap_run1)); data_run2.block_duration(ismember(data_run2.Block,block_adap_run2))];
    Job.sess.cond(1).tmod = 0;

    Job.sess.cond(1).pmod(1).name = 'HandTraining';
    Job.sess.cond(1).pmod(1).param = ((45-Hand_ang))%
    Job.sess.cond(1).pmod(1).poly = 1;
    Job.sess.cond(1).pmod(2).name = 'RotTraining';
    Job.sess.cond(1).pmod(2).param = [rot_run1 rot_run2];
    Job.sess.cond(1).pmod(2).poly = 1;
    Job.sess.cond(1).orth = 1;
    
    
    Job.sess.cond(2).name = 'MovTraining';
    onset_movadap_run1 = data_run1.mov_onset((ismember(data_run1.block,block_adap_run1)));
    onset_movadap_run2 = data_run2.mov_onset((ismember(data_run2.block,block_adap_run2))) + length(im_run1)*TR;
    onset_movadap_cat = [onset_movadap_run1;onset_movadap_run2];
    
    dur_movadap_run1 = data_run1.mov_dur((ismember(data_run1.block,block_adap_run1)));
    dur_movadap_run2 = data_run2.mov_dur((ismember(data_run2.block,block_adap_run2)));
    dur_movadap_cat = [dur_movadap_run1;dur_movadap_run2];
    
    perc_ang_adap = [data_run1.Perc(ismember(data_run1.block,block_adap_run1));data_run2.Perc(ismember(data_run2.block,block_adap_run2))];
    
    % for rotation parametric modulation;
    idx = find((ismember(data_run1.block,block_adap_run1)));
    counter = 1
    for x = 1: length(idx)
        if ismember(data_run1.block(idx(x)),[5 6]);
            rot_p_run1(counter)=5;
        elseif ismember(data_run1.block(idx(x)),[7 8]);
            rot_p_run1(counter)= 10;
        elseif ismember(data_run1.block(idx(x)),[9]);
            rot_p_run1(counter)= 15;
        end
        counter = counter+1;
    end
    
    idx_run2 = find((ismember(data_run2.block,block_adap_run2)));
    counter = 1
    for x = 1: length(idx_run2)
        if ismember(data_run2.block(idx_run2(x)),[10]);
            rot_p_run2(counter)= 15;
        elseif ismember(data_run2.block(idx_run2(x)),[11 12]);
            rot_p_run2(counter)= 20;
        elseif ismember(data_run2.block(idx_run2(x)),[13 14]);
            rot_p_run2(counter)= 25;
        elseif ismember(data_run2.block(idx_run2(x)),[15 16]);
            rot_p_run2(counter)= 30;
        end
        counter = counter+1;
    end
    rot_run_p = [rot_p_run1 rot_p_run2];
    
    
    Job.sess.cond(2).onset = onset_movadap_cat;
    Job.sess.cond(2).duration = dur_movadap_cat;
    Job.sess.cond(2).tmod = 0;
    
    Job.sess.cond(2).pmod(1).name = 'AdapPerception';
    Job.sess.cond(2).pmod(1).param = -(perc_ang_adap)%
    Job.sess.cond(2).pmod(1).poly = 1;
    
    Job.sess.cond(2).pmod(2).name = 'RotPAdap';
    Job.sess.cond(2).pmod(2).param = [rot_run_p];
    Job.sess.cond(2).pmod(2).poly = 1;
    
    Job.sess.cond(2).orth = 1;
    
    % reponse baseline
    Job.sess.cond(3).name = 'respAdap';
    onset_respAdap_run1 = data_run1.resp_onset((ismember(data_run1.block,block_adap_run1)));
    onset_respAdap_run2 = data_run2.resp_onset((ismember(data_run2.block,block_adap_run2))) + length(im_run1)*TR;
    dur_respAdap_run1 = data_run1.resp_dur((ismember(data_run1.block,block_adap_run1)));
    dur_respAdap_run2 = data_run2.resp_dur((ismember(data_run2.block,block_adap_run2)));
    onset_resp_cat = [onset_respAdap_run1;onset_respAdap_run2];
    dur_resp_cat = [dur_respAdap_run1;dur_respAdap_run2];
    Job.sess.cond(3).onset = onset_resp_cat;
    Job.sess.cond(3).duration = dur_resp_cat;
    Job.sess.cond(3).tmod = 0;
    Job.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(3).orth = 0;
    
    
    Job.sess.cond(4).name = 'Washout';
    onsets_washout_run2 = data_run2.BlockOnset(ismember(data_run2.Block,block_washout)) + length(im_run1)*TR;
    Hand_ang_washout = [data_run2.HandBlock(ismember(data_run2.Block,block_washout))];
    Job.sess.cond(4).onset = onsets_washout_run2;
    Job.sess.cond(4).duration = data_run2.block_duration(ismember(data_run2.Block,block_washout));
    Job.sess.cond(4).tmod = 0;
    Job.sess.cond(4).pmod.name = 'HandWashout';
    Job.sess.cond(4).pmod.param = (45-Hand_ang_washout);% 
    Job.sess.cond(4).pmod.poly = 1;
    Job.sess.cond(4).orth = 1;
    % movement phase in washout
    Job.sess.cond(5).name = 'movwashout';
    onset_movwashout_run2 = data_run2.mov_onset(ismember(data_run2.block , block_washout)) + length(im_run1)*TR;
    dur_movwashout_run2 = data_run2.mov_dur(ismember(data_run2.block , block_washout));
    perc_ang_washout = data_run2.Perc(ismember(data_run2.block,block_washout));
    Job.sess.cond(5).onset = onset_movwashout_run2;
    Job.sess.cond(5).duration = dur_movwashout_run2;
    Job.sess.cond(5).tmod = 0;
    Job.sess.cond(5).pmod.name = 'perceptionwashout';
    Job.sess.cond(5).pmod.param = -(perc_ang_washout) 
    Job.sess.cond(5).pmod.poly = 1;
    Job.sess.cond(5).orth = 1;
    
    % response phase in washout
    Job.sess.cond(6).name = 'RespWashout';
    onset_respwashout_run2 = data_run2.resp_onset((ismember(data_run2.block,block_washout))) + length(im_run1)*TR;
    dur_respwashout_run2 = data_run2.resp_dur((ismember(data_run2.block,block_washout)));
    Job.sess.cond(6).onset = onset_respwashout_run2;
    Job.sess.cond(6).duration = dur_respwashout_run2;
    Job.sess.cond(6).tmod = 0;
    Job.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(6).orth = 0;
    
    if any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames)) | any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))
        Job.sess.cond(7).name = 'MissedEvents';
        
        if any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames)) & any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))
            missed_onset_run1 = data_run1.mov_missed_onset(~isnan(data_run1.mov_missed_onset));
            missed_onset_run2 = data_run2.mov_missed_onset(~isnan(data_run2.mov_missed_onset)) + length(im_run1)* TR;
            missed_onset_cat = [missed_onset_run1;missed_onset_run2];
        elseif any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames))==1 & any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))==0
            missed_onset_cat = data_run1.mov_missed_onset(~isnan(data_run1.mov_missed_onset));
        elseif any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames))==0 & any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))==1
            missed_onset_cat = data_run2.mov_missed_onset(~isnan(data_run2.mov_missed_onset)) + length(im_run1)* TR;
        end
        Job.sess.cond(7).onset = missed_onset_cat;
        Job.sess.cond(7).duration = 0;
        Job.sess.cond(7).tmod = 0;
        Job.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
        Job.sess.cond(7).orth =0;
    end
    
    %
    
    Job.sess.multi = {''};

    msg_onset_run1 = data_run1.Message_Onset(~isnan(data_run1.Message_Onset));
    msg_onset_run2 = data_run2.Message_Onset(~isnan(data_run2.Message_Onset)) + length(im_run1)* TR;
    msg_onset_cat = [msg_onset_run1;msg_onset_run2];
    msg_volume = ceil(msg_onset_cat/TR);
    msg_regressor = zeros(length(im_run1) + length(im_run2), 1);    % create new multiple regressors
    indx = find(msg_volume<length(msg_regressor));
    msg_regressor(msg_volume(indx),1) = 1;
    Job.sess.regress.name = 'msgdisp';
    Job.sess.regress.val = msg_regressor; 
    Job.sess.multi_reg = {[data_path '/' subj_id '/ses-002/func/reg_motion_compcor_' subj_id '.mat']};
    Job.sess.hpf = 128;
    Job.fact 			   = struct('name', {}, 'levels', {});
    Job.bases.hrf.derivs = [0 0];
    Job.bases.hrf.params = [6 16 1 1 6 0 32];
    Job.volt = 1;
    Job.global = 'None';
    Job.mthresh = 0.01;
    Job.mask = {'...\mask_ICV.nii,1'};
    
    Job.cvi = '' %'AR(1)' or 'FAST' or 'None';
    spm_run_fmri_spec(Job)
    
    scans = [length(im_run1) length(im_run2)];
    spm_fmri_concatenate([wd '/' firstlevel '/' subj_id '/ses-002/func/' glm_folder '/SPM.mat'], scans)
end

% estimate the model - This chunk can be added after spm_fmri_concatenation
% to shorten the script. I kept it here for debugging
clear matlabbatch
est = 'spm.stats.fmri_est'; % estimation method

for subj = 1:size(subj_list,2)
    % Specify subject ID
    subj_id = sprintf('sub-%03d', subj_list(subj));
    subj_dir = fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder)
    eval(['matlabbatch{1}.' est '.spmmat = {fullfile(subj_dir,''SPM.mat'')};'])
    eval(['matlabbatch{1}.' est '.method.Classical =1 ;'])
    spm_jobman('run', matlabbatch);
end
