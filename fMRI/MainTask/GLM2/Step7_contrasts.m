
%% This script specifies different contrasts

%% Specify data path
data_path = '...\BIDS';
wd = '...\GLM2\Firstlevel'
glm_folder = '1st_level'
% Define contrast names and their corresponding new names

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
    
    
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.name = 'HandTraining-pm';
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.weights = [0 1];
    matlabbatch{2}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    
    matlabbatch{2}.spm.stats.con.consess{2}.tcon.name = 'Perception-pm';
    matlabbatch{2}.spm.stats.con.consess{2}.tcon.weights = [0 0 0 0 1];
    matlabbatch{2}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
    
    matlabbatch{2}.spm.stats.con.delete = 1;
    spm_jobman('run', matlabbatch);
    
end