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
    
    
    im_wm = dir([struct_dir '/' 'wc2*']);
    
    matlabbatch{1}.spm.util.imcalc.input = {
        fullfile(im_wm.folder, im_wm.name)
        '...\rwMNI_L_R_thalamus.nii,1'
        };
    matlabbatch{1}.spm.util.imcalc.output = '';
    matlabbatch{1}.spm.util.imcalc.outdir = {struct_dir};
    matlabbatch{1}.spm.util.imcalc.expression = 'i1-i2';
    matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
    matlabbatch{1}.spm.util.imcalc.options.mask = 0;
    matlabbatch{1}.spm.util.imcalc.options.interp = 1;
    matlabbatch{1}.spm.util.imcalc.options.dtype = 2;
    spm_jobman('run', matlabbatch);
end