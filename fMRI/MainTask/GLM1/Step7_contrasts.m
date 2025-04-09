
%% This script specifies different contrasts
clear all;
%% Specify data path
wd = '...\GLM1\Firstlevel'
glm_folder = '1st_level'
data_path = '...\BIDS';

interests = {'bsl1','bsl2','bsl3','bsl4','rot5a','rot5b','rot10a','rot10b','rot15','rot15run2','rot20a','rot20b',...
    'rot25a','rot25b','rot30a','rot30b','Washout-1','Washout-2','Washout-3','MovBsl','respBsl','MovAadap','respAdap','movwashout',...
    'RespWashout','MsgDisp','MissedEvents'};

%subject V number
subj_list = [];


for subj = 1:size(subj_list,2)
    clear matlabbatch
    subj_id = sprintf('sub-%03d', subj_list(subj));
    if isfolder(fullfile(wd,subj_id,'ses-002','func', glm_folder))
        SPM_DM = fullfile(wd, subj_id,'ses-002', 'func',glm_folder,'SPM.mat')
        load(SPM_DM)
    else
        display([wd '/' subj_id '/' 'ses-002' '/' 'func' '/' glm_folder '/' 'SPM.mat' '... does not exists'])
        return
    end
    
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'run1run2Images';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{SPM_DM}};
    matlabbatch{2}.spm.stats.con.spmmat(1) = cfg_dep('Named File Selector: run1run2Images(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.name = 'rotation5-bsl';
    contrast_a = find(ismember(cellstr(SPM.xX.name), {'bsl1','bsl2','bsl3','bsl4'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot5a','rot5b'}));
    contrast1 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast1(contrast_a) = -1/2;
    contrast1(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.weights = contrast1;
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    
    
    matlabbatch{2}.spm.stats.con.consess{2}.tcon.name = 'rotation10-rotation5';
    contrast_a = find(ismember(cellstr(SPM.xX.name),{'rot5a','rot5b'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot10a','rot10b'}));
    contrast2 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast2(contrast_a) = -1;
    contrast2(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{2}.tcon.weights = contrast2;
    matlabbatch{2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{2}.spm.stats.con.consess{3}.tcon.name = 'rotation15-rotation10';
    contrast_a = find(ismember(cellstr(SPM.xX.name),{'rot10a','rot10b'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot15','rot15run2'}));
    contrast3 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast3(contrast_a) = -1;
    contrast3(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{3}.tcon.weights = contrast3;
    matlabbatch{2}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
    
    matlabbatch{2}.spm.stats.con.consess{4}.tcon.name = 'rotation20-rotation15';
    contrast_a = find(ismember(cellstr(SPM.xX.name),{'rot15','rot15run2'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot20a','rot20b'}));
    contrast4 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast4(contrast_a) = -1;
    contrast4(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{4}.tcon.weights = contrast4;
    matlabbatch{2}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
    
    
    matlabbatch{2}.spm.stats.con.consess{5}.tcon.name = 'rotation25-rotation20';
    contrast_a = find(ismember(cellstr(SPM.xX.name),{'rot20a','rot20b'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot25a','rot25b'}));
    contrast5 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast5(contrast_a) = -1;
    contrast5(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{5}.tcon.weights = contrast5;
    matlabbatch{2}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
    
    matlabbatch{2}.spm.stats.con.consess{6}.tcon.name = 'rotation30-rotation25';
    contrast_a = find(ismember(cellstr(SPM.xX.name),{'rot25a','rot25b'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot30a','rot30b'}));
    contrast6 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast6(contrast_a) = -1;
    contrast6(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{6}.tcon.weights = contrast6;
    matlabbatch{2}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
    
    
    matlabbatch{2}.spm.stats.con.consess{7}.tcon.name = 'rot30-rot5';
    contrast_a = find(ismember(cellstr(SPM.xX.name),{'rot5a','rot5b'}));
    contrast_b = find(ismember(cellstr(SPM.xX.name), {'rot30a','rot30b'}));
    contrast7 = zeros(1, size(cellstr(SPM.xX.name),2));
    contrast7(contrast_a) = -1;
    contrast7(contrast_b) = 1;
    matlabbatch{2}.spm.stats.con.consess{7}.tcon.weights = contrast7;
    matlabbatch{2}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
    
    
    matlabbatch{2}.spm.stats.con.delete = 1;
    %
    spm_jobman('run', matlabbatch);
    
end