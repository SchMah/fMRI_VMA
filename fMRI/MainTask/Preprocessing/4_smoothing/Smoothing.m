%% smoothing after preproc.
% two smoothing size : 6 for whole brain analysis

% Specify data path
data_path = '...\BIDS';
subj_list = [];

% Loop through subjects
for subj = 1:size(subj_list,2)
    clear matlabbatch
    % Specify subject ID
    subj_id = sprintf('sub-%03d', subj_list(subj));
    % file names
    func_file_run1 = fullfile(data_path, subj_id,'ses-002', 'func', ...
        sprintf('warsub-%03d_ses-002_task-VMA_run-01.nii', subj_list(subj)));
    func_file_run2 = fullfile(data_path, subj_id,'ses-002', 'func', ...
        sprintf('warsub-%03d_ses-002_task-VMA_run-02.nii', subj_list(subj)));
    
    %define file names to be used in dependencies
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'run01run02Images';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
        {[func_file_run1]}
        {[func_file_run2]}
        }';

%     smoothing 
        matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
        matlabbatch{7}.spm.spatial.smooth.fwhm = [6 6 6];
        matlabbatch{7}.spm.spatial.smooth.dtype = 0;
        matlabbatch{7}.spm.spatial.smooth.im = 0;
        matlabbatch{7}.spm.spatial.smooth.prefix = 's6';
        matlabbatch{8}.cfg_basicio.file_dir.file_ops.cfg_file_split.name = 'run01run02FileSplit';
        matlabbatch{8}.cfg_basicio.file_dir.file_ops.cfg_file_split.files(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
        matlabbatch{8}.cfg_basicio.file_dir.file_ops.cfg_file_split.index = {
            1
            2
            }';
    
    
    spm_jobman('run', matlabbatch);
    
end


