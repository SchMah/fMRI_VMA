
%% Normalize gm,wm,csf mask to mni space using deformation field obtained from preproc.m
data_path = '...\BIDS';
subj_list = [];

for subj = 1:size(subj_list,2)
    clear matlabbatch
    % Specify subject ID
    subj_id = sprintf('sub-%03d', subj_list(subj));
    
    if strcmp(subj_id,'sub-8083')==1
        struct_dir = fullfile(data_path, subj_id,'ses-002', 'anat');
    elseif strcmp(subj_id,'sub-8082')==1
        struct_dir = fullfile(data_path, subj_id,'ses-002', 'anat');
    else
        struct_dir = fullfile(data_path, subj_id,'ses-001', 'anat');
    end
    
    struct_def = dir([struct_dir '/' 'y_*']);
    struct_c1 = dir([struct_dir '/' 'c1*']);
    struct_c2 = dir([struct_dir '/' 'c2*']);
    struct_c3 = dir([struct_dir '/' 'c3*']);
    disp(struct_def.name)
    disp(struct_c1.name)
    disp(struct_c2.name)
    disp(struct_c3.name)
    
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = {fullfile(struct_def.folder, struct_def.name)};
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {
        fullfile(struct_c1.folder,struct_c1.name)
        fullfile(struct_c2.folder,struct_c2.name)
        fullfile(struct_c3.folder,struct_c3.name)
        };
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
        78 76 85];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
    spm_jobman('run', matlabbatch);
    
end
