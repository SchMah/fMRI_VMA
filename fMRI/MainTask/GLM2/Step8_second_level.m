
wd = '...\GLM2\Firstlevel'
glm_folder = '1st_level'
data_path = '...\BIDS';
analysis_path = '...\GLM2';

%subject V number
subj_list = [];

if ~exist(fullfile(analysis_path,'2ndLevel'),'dir')
    mkdir(fullfile(analysis_path,'2ndLevel'))
else
    disp('the second level analysis folder exists')
end
secondLevel_path = fullfile(analysis_path,'2ndLevel')

%% load example subject GLM to get required information for contrasts
subj_id = sprintf('sub-%03d', subj_list(1));
SPM_DM = fullfile(wd, subj_id,'ses-002', 'func',glm_folder,'SPM.mat');
load(SPM_DM);
num_con = length(SPM.xCon); % number of contrasts

for i = 1:num_con
    contrast{i} = SPM.xCon(i).name;
    %             contrast{i}(contrast{nn}==' ') = '_';
    %             contrast{i}(contrast{nn}=='-') = '';
end;

for j = 1: num_con
    if ~exist(fullfile(secondLevel_path,contrast{j}),'dir')
        mkdir(fullfile(secondLevel_path,contrast{j}))
    else
        disp(['contrast' contrast{j} 'folder exists'])
    end
    contrast_dir = fullfile(secondLevel_path,contrast{j})
    matlabbatch{1}.spm.stats.factorial_design.dir = {contrast_dir};
    
    % load subjects
    for subj =1:length(subj_list)
        % which contrast
        insert_contrast = sprintf('con_%04d.nii', j);
        % subject?
        subj_id = sprintf('sub-%03d', subj_list(subj));
        subj_dir = fullfile(wd,subj_id,'ses-002','func',glm_folder);
        P = cellstr(spm_select('FPList', subj_dir, insert_contrast));
    
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans{subj,1} = P{1};

        clear P;
    end;
    
    matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
    matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
    matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
    matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
    spm_jobman('run',matlabbatch);
    
    clear matlabbatch;
    
    % estimate the model 
    
    model = fullfile(contrast_dir,'SPM.mat');

    matlabbatch{1}.spm.stats.fmri_est.spmmat={model};
    
    spm_jobman('run',matlabbatch);
    
    clear matlabbatch;
    
    estimatedmodel=fullfile(contrast_dir,'SPM.mat');
    matlabbatch{1}.spm.stats.con.spmmat={estimatedmodel};
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = contrast{j};         % t Contrast (f contrast = fcon)
    matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1];
    
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = [contrast{j} '_Minus'];         % t Contrast (f contrast = fcon)
    matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [-1];
    
    spm_jobman('run',matlabbatch);
    
    clear matlabbatch;

end

