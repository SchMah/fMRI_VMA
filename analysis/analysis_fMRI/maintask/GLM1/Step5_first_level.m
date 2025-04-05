% Specify data path
data_path = '...\BIDS';
timePoint_dir = '...\BIDS';
wd = '...\GLM1'
firstlevel = 'Firstlevel'
glm_folder = '1st_level';

%subject V number
subj_list = [];

block_rot0_1 = 1;
block_rot0_2 = 2;
block_rot0_3 = 3;
block_rot0_4 = 4;
block_rot5a = 5;
block_rot5b = 6;
block_rot10a = 7;
block_rot10b = 8;
block_rot15a = 9;
%run2
block_rot15b = 10;
block_rot20a = 11;
block_rot20b = 12;
block_rot25a = 13;
block_rot25b = 14;
block_rot30a = 15;
block_rot30b = 16;
block_washout_1 = 17;
block_washout_2 = 18
block_washout_3 = 19;
% 
block_rot0 = [1:4];


block_adap_run1 = [5:9];
block_adap_run2 = [10:16];
block_washout = [17:19];

TR = 1.5

for subj = 1:size(subj_list,2)
    % Specify subject ID
    subj_id = sprintf('sub-%03d', subj_list(subj));
    if ~isfolder(fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder))
        mkdir(fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder))
    else
        display([wd firstlevel '/' subj_id '/ses-002/func/' glm_folder '...exists'])
    end
    Job.dir = {fullfile(wd,firstlevel,subj_id ,'ses-002/func',glm_folder)};
    Job.timing.units = 'secs';
    Job.timing.RT = 1.5;
    Job.timing.fmri_t = 16;
    Job.timing.fmri_t0 = 1;
    Job.sess(1).scans = {[data_path '/' subj_id '/ses-002/func/s6war_merge_' subj_id '_ses-002_task-VMA.nii']};
    
    %% conditions - Run1
    im_run1 = spm_vol([data_path '/' subj_id '/ses-002/func/s6war' subj_id '_ses-002_task-VMA_run-01.nii']);
    im_run2 = spm_vol([data_path '/' subj_id '/ses-002/func/s6war' subj_id '_ses-002_task-VMA_run-02.nii']);

    run1 = dir([timePoint_dir '/' subj_id '/ses-002/' subj_id '*' 'run-01.txt']);
    display(run1.name)
    data_run1 = readtable([run1.folder '/' run1.name],'Delimiter','\t','ReadVariableNames',true);
    
    run2 = dir([timePoint_dir '/' subj_id '/ses-002/' subj_id '*' 'run-02.txt']);
    display(run2.name)
    data_run2 = readtable([run2.folder '/' run2.name],'Delimiter','\t','ReadVariableNames',true);
    %
    
    Job.sess.cond(1).name = 'bsl1';
    Job.sess.cond(1).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot0_1));
    Job.sess.cond(1).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot0_1));
    Job.sess.cond(1).tmod = 0;
    Job.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(1).orth = 0;
    
    % bsl block2
    Job.sess.cond(2).name = 'bsl2';
    Job.sess.cond(2).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot0_2));
    Job.sess.cond(2).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot0_2));
    Job.sess.cond(2).tmod = 0;
    Job.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(2).orth = 0;
    % bsl block3
    Job.sess.cond(3).name = 'bsl3';
    Job.sess.cond(3).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot0_3));
    Job.sess.cond(3).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot0_3));
    Job.sess.cond(3).tmod = 0;
    Job.sess.cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(3).orth = 0;
    
    %bsl block4
    Job.sess.cond(4).name = 'bsl4';
    Job.sess.cond(4).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot0_4));
    Job.sess.cond(4).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot0_4));
    Job.sess.cond(4).tmod = 0;
    Job.sess.cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(4).orth = 0;
    
    % rotation 5a
    Job.sess.cond(5).name = 'rot5a';
    Job.sess.cond(5).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot5a));
    Job.sess.cond(5).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot5a));
    Job.sess.cond(5).tmod = 0;
    Job.sess.cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(5).orth = 0;
    %rotation 5b
    Job.sess.cond(6).name = 'rot5b';
    Job.sess.cond(6).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot5b));
    Job.sess.cond(6).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot5b));
    Job.sess.cond(6).tmod = 0;
    Job.sess.cond(6).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(6).orth = 0;
    
    % rot10a
    Job.sess.cond(7).name = 'rot10a';
    Job.sess.cond(7).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot10a));
    Job.sess.cond(7).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot10a));
    Job.sess.cond(7).tmod = 0;
    Job.sess.cond(7).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(7).orth = 0;
    % rot10b
    Job.sess.cond(8).name = 'rot10b';
    Job.sess.cond(8).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot10b));
    Job.sess.cond(8).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot10b));
    Job.sess.cond(8).tmod = 0;
    Job.sess.cond(8).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(8).orth = 0;
    %rot15run1
    Job.sess.cond(9).name = 'rot15';
    Job.sess.cond(9).onset = data_run1.BlockOnset(ismember(data_run1.Block,block_rot15a));
    Job.sess.cond(9).duration = data_run1.block_duration(ismember(data_run1.Block,block_rot15a));
    Job.sess.cond(9).tmod = 0;
    Job.sess.cond(9).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(9).orth = 0;
    
    %rot15run2
    Job.sess.cond(10).name = 'rot15run2';
    onsets_rot15run2 = data_run2.BlockOnset(ismember(data_run2.Block,block_rot15b)) + length(im_run1)*TR;
    Job.sess.cond(10).onset = onsets_rot15run2;
    Job.sess.cond(10).duration = data_run2.block_duration(ismember(data_run2.Block,block_rot15b));
    Job.sess.cond(10).tmod = 0;
    Job.sess.cond(10).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(10).orth = 0;
    
    %rot20a
    Job.sess.cond(11).name = 'rot20a';
    Job.sess.cond(11).onset =  data_run2.BlockOnset(ismember(data_run2.Block,block_rot20a)) + length(im_run1)*TR
    Job.sess.cond(11).duration = data_run2.block_duration(ismember(data_run2.Block, block_rot20a));
    Job.sess.cond(11).tmod = 0;
    Job.sess.cond(11).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(11).orth = 0;
    %rot20b
    Job.sess.cond(12).name = 'rot20b';
    Job.sess.cond(12).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_rot20b)) + length(im_run1)*TR;
    Job.sess.cond(12).duration = data_run2.block_duration(ismember(data_run2.Block, block_rot20b));
    Job.sess.cond(12).tmod = 0;
    Job.sess.cond(12).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(12).orth = 0;
    %rot25a
    Job.sess.cond(13).name = 'rot25a';
    Job.sess.cond(13).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_rot25a)) + length(im_run1)*TR;
    Job.sess.cond(13).duration = data_run2.block_duration(ismember(data_run2.Block, block_rot25a));
    Job.sess.cond(13).tmod = 0;
    Job.sess.cond(13).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(13).orth = 0;
    %rot25b
    Job.sess.cond(14).name = 'rot25b';
    Job.sess.cond(14).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_rot25b)) + length(im_run1)*TR;
    Job.sess.cond(14).duration = data_run2.block_duration(ismember(data_run2.Block, block_rot25b));
    Job.sess.cond(14).tmod = 0;
    Job.sess.cond(14).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(14).orth = 0;
    
    Job.sess.cond(15).name = 'rot30a';
    Job.sess.cond(15).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_rot30a)) + length(im_run1)*TR;
    Job.sess.cond(15).duration = data_run2.block_duration(ismember(data_run2.Block, block_rot30a));
    Job.sess.cond(15).tmod = 0;
    Job.sess.cond(15).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(15).orth = 0;
    
    Job.sess.cond(16).name = 'rot30b';
    Job.sess.cond(16).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_rot30b)) + length(im_run1)*TR;
    Job.sess.cond(16).duration = data_run2.block_duration(ismember(data_run2.Block, block_rot30b));
    Job.sess.cond(16).tmod = 0;
    Job.sess.cond(16).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(16).orth = 0;
    
    Job.sess.cond(17).name = 'Washout-1';
    Job.sess.cond(17).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_washout_1)) + length(im_run1)*TR;
    Job.sess.cond(17).duration = data_run2.block_duration(ismember(data_run2.Block,block_washout_1));
    Job.sess.cond(17).tmod = 0;
    Job.sess.cond(17).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(17).orth = 0;
    
    Job.sess.cond(18).name = 'Washout-2';
    Job.sess.cond(18).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_washout_2)) + length(im_run1)*TR;
    Job.sess.cond(18).duration = data_run2.block_duration(ismember(data_run2.Block,block_washout_2));
    Job.sess.cond(18).tmod = 0;
    Job.sess.cond(18).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(18).orth = 0;
    
    Job.sess.cond(19).name = 'Washout-3';
    Job.sess.cond(19).onset = data_run2.BlockOnset(ismember(data_run2.Block,block_washout_3)) + length(im_run1)*TR;
    Job.sess.cond(19).duration = data_run2.block_duration(ismember(data_run2.Block,block_washout_3));
    Job.sess.cond(19).tmod = 0;
    Job.sess.cond(19).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(19).orth = 0;
    
    Job.sess.cond(20).name = 'MovBsl';
    onset_mov_bsl = data_run1.mov_onset((ismember(data_run1.block,block_rot0)));
    Job.sess.cond(20).onset = onset_mov_bsl;
    Job.sess.cond(20).duration = 0;
    Job.sess.cond(20).tmod = 0;
    Job.sess.cond(20).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(20).orth = 0;
    
    % reponse baseline
    Job.sess.cond(21).name = 'respBsl';
    onset_resp_bsl = data_run1.resp_onset((ismember(data_run1.block,block_rot0)));
    Job.sess.cond(21).onset = onset_resp_bsl;
    Job.sess.cond(21).duration = 0;
    Job.sess.cond(21).tmod = 0;
    Job.sess.cond(21).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(21).orth = 0;
    
    
    Job.sess.cond(22).name = 'MovAadap';
    onset_movadap_run1 = data_run1.mov_onset((ismember(data_run1.block,block_adap_run1)));
    onset_movadap_run2 = data_run2.mov_onset((ismember(data_run2.block,block_adap_run2))) + length(im_run1)*TR;
    onset_movadap_cat = [onset_movadap_run1;onset_movadap_run2];
    Job.sess.cond(22).onset = onset_movadap_cat;
    Job.sess.cond(22).duration = 0;
    Job.sess.cond(22).tmod = 0;
    Job.sess.cond(22).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(22).orth = 0;
    
    % reponse baseline
    Job.sess.cond(23).name = 'respAdap';
    onset_respAdap_run1 = data_run1.resp_onset((ismember(data_run1.block,block_adap_run1)));
    onset_respAdap_run2 = data_run2.resp_onset((ismember(data_run2.block,block_adap_run2))) + length(im_run1)*TR;
    onset_resp_cat = [onset_respAdap_run1;onset_respAdap_run2];
    Job.sess.cond(23).onset = onset_resp_cat;
    Job.sess.cond(23).duration = 0;
    Job.sess.cond(23).tmod = 0;
    Job.sess.cond(23).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(23).orth = 0;
    
    
    
    % movement phase in washout
    Job.sess.cond(24).name = 'movwashout';
    onset_movwashout_run2 = data_run2.mov_onset(ismember(data_run2.block , block_washout)) + length(im_run1)*TR;
    Job.sess.cond(24).onset = onset_movwashout_run2;
    Job.sess.cond(24).duration = 0;
    Job.sess.cond(24).tmod = 0;
    Job.sess.cond(24).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(24).orth = 0;
    
    % response phase in washout
    Job.sess.cond(25).name = 'RespWashout';
    onset_respwashout_run2 = data_run2.resp_onset((ismember(data_run2.block,block_washout))) + length(im_run1)*TR;
    Job.sess.cond(25).onset = onset_respwashout_run2;
    Job.sess.cond(25).duration = 0;
    Job.sess.cond(25).tmod = 0;
    Job.sess.cond(25).pmod = struct('name', {}, 'param', {}, 'poly', {});
    Job.sess.cond(25).orth = 0;
    
    if any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames)) | any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))
        Job.sess.cond(26).name = 'MissedEvents';
        
        if any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames)) & any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))
            missed_onset_run1 = data_run1.mov_missed_onset(~isnan(data_run1.mov_missed_onset));
            missed_onset_run2 = data_run2.mov_missed_onset(~isnan(data_run2.mov_missed_onset)) + length(im_run1)* TR;
            missed_onset_cat = [missed_onset_run1;missed_onset_run2];
        elseif any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames))==1 & any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))==0
            missed_onset_cat = data_run1.mov_missed_onset(~isnan(data_run1.mov_missed_onset));
        elseif any(strcmp('mov_missed_onset',data_run1.Properties.VariableNames))==0 & any(strcmp('mov_missed_onset',data_run2.Properties.VariableNames))==1
            missed_onset_cat = data_run2.mov_missed_onset(~isnan(data_run2.mov_missed_onset)) + length(im_run1)* TR;
        end
        Job.sess.cond(26).onset = missed_onset_cat;
        Job.sess.cond(26).duration = 0;
        Job.sess.cond(26).tmod = 0;
        Job.sess.cond(26).pmod = struct('name', {}, 'param', {}, 'poly', {});
        Job.sess.cond(26).orth =0;
    end
    
    
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
    Job.sess.multi_reg ={[data_path '/' subj_id '/ses-002/func/reg_motion_compcor_' subj_id '.mat']};% 
    Job.sess.hpf = 128;
    
    Job.fact 			   = struct('name', {}, 'levels', {});
    Job.bases.hrf.derivs = [0 0];
    Job.bases.hrf.params = [6 16 1 1 6 0 32] ; % canonical hrf
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
