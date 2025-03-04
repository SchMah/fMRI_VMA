% This script preprocesses the functional data in session 2.
% Previously:
% 1. The structural images were corrected for yaw,
% pitch,roll biases and reoriented to AC position.
% 2. Functional images were corrected for magnetic field inhomogenity using
% fieldmaps in fsl
% 3. denoising was applied on functional data using NORDIC method

% subject number 8083 : The long T1 was acquired on session2.
% subject 8082 only has short T1

% Smoothing is not performed at this stage.

% Specify data path
data_path = '....\BIDS';
subj_list = [];

% Loop through subjects
for subj = 1:size(subj_list,2)
    
    % Specify subject ID
    subj_id = sprintf('sub-%03d', subj_list(subj));
    % file names
    func_file_run1 = fullfile(data_path, subj_id,'ses-002', 'func', ...
        sprintf('sub-%03d_ses-002_task-VMA_run-01.nii', subj_list(subj)));
    func_file_run2 = fullfile(data_path, subj_id,'ses-002', 'func', ...
        sprintf('sub-%03d_ses-002_task-VMA_run-02.nii', subj_list(subj)));
    
    % determine separate file name for subj 8083 8082
    if strcmp(subj_id,'sub-8083')==1
        struct_file = fullfile(data_path, subj_id,'ses-002', 'anat', ...
            sprintf('sub-%03d_ses-002_long_run-01_T1w.nii', subj_list(subj))); % anatomical image from session one was coregistered to anatomical scan in session2..prefix "r" .. then this image plus func runs in session2 were reoriented
    elseif strcmp(subj_id,'sub-8082')==1          
         struct_file = fullfile(data_path, subj_id,'ses-002', 'anat', ...
            sprintf('sub-%03d_ses-002_run-01_T1w.nii', subj_list(subj)));
    else
        struct_file = fullfile(data_path, subj_id,'ses-001', 'anat', ...
            sprintf('rsub-%03d_ses-001_long_run-01_T1w.nii', subj_list(subj)));
    end
    
    %run 01
    if isfile(func_file_run1) == 0
        if isfile([func_file_run1 '.gz'])==1
            display('run1 has not been extracted; unzipping now.wait...')
            gunzip([func_file_run1 '.gz'])
        elseif isfile([func_file_run1 '.gz'])== 0
            display('session2- run 01 is missing')
            return;
        end
    else isfile(func_file_run1) == 1
        display('Run 1 is already extracted')
    end
    %run02
    
    if isfile(func_file_run2) == 0
        if isfile([func_file_run2 '.gz'])==1
            display('run2 has not been extracted; unzipping now.wait...')
            gunzip([func_file_run2 '.gz'])
        elseif isfile([func_file_run2 '.gz'])== 0
            display('session2- run 02 is missing')
            return;
        end
    else isfile(func_file_run2) == 1
        display('Run 2 is already extracted')
    end
    % anatomical data from session1
    if isfile(struct_file) == 0
        if isfile([struct_file '.gz'])==1
            display('structural image has not been extracted; unzipping now.wait...')
            gunzip([struct_file '.gz'])
        elseif isfile([struct_file '.gz'])== 0
            display('structural image is missing')
            return;
        end
    else isfile(struct_file) == 1
        display('structural image is already extracted')
    end
    
    % get the information about TR, TA and nSclices
    V_run1 = spm_vol(func_file_run1);
    nslice = V_run1(1).dim(3);
    
    import_TR = 1.5; %seconds
    import_TA = import_TR - (import_TR/nslice);
    %extract slice timig from json file
    json_FileName = [data_path '/' subj_id '/ses-002/func/' subj_id '_ses-002_task-VMA_run-01_bold.json'];
    str = fileread(json_FileName); % read the file
    data = jsondecode(str); % decode json file
    slice_timing = data.SliceTiming ;
    %define file names to be used in dependencies
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'run01run02Images';
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {
        {[data_path '/' subj_id '/ses-002/func/' subj_id '_ses-002_task-VMA_run-01.nii']}
        {[data_path '/' subj_id '/ses-002/func/' subj_id '_ses-002_task-VMA_run-02.nii']}
        }';
    % perfrom realignmnet
    matlabbatch{2}.spm.spatial.realign.estwrite.data{1}(1) = cfg_dep('Named File Selector: run01run02Images(1) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{1}));
    matlabbatch{2}.spm.spatial.realign.estwrite.data{2}(1) = cfg_dep('Named File Selector: run01run02Images(2) - Files', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files', '{}',{2}));
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{2}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    %SLice time Correction
    matlabbatch{3}.spm.temporal.st.scans{1}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 1)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{1}, '.','rfiles'));
    matlabbatch{3}.spm.temporal.st.scans{2}(1) = cfg_dep('Realign: Estimate & Reslice: Resliced Images (Sess 2)', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','sess', '()',{2}, '.','rfiles'));
    matlabbatch{3}.spm.temporal.st.nslices = nslice;
    matlabbatch{3}.spm.temporal.st.tr = import_TR;
    matlabbatch{3}.spm.temporal.st.ta = import_TA;
    matlabbatch{3}.spm.temporal.st.so = slice_timing;
    matlabbatch{3}.spm.temporal.st.refslice = 0;
    matlabbatch{3}.spm.temporal.st.prefix = 'a';
    %coregistration
    matlabbatch{4}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Realign: Estimate & Reslice: Mean Image', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rmean'));

    matlabbatch{4}.spm.spatial.coreg.estwrite.source = {[struct_file]};

    matlabbatch{4}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{4}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{4}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
   
    %segmentation
    if strcmp(subj_id,'sub-8083')==1
        matlabbatch{5}.spm.spatial.preproc.channel.vols = {[data_path '/' subj_id '/ses-002/anat/r' subj_id '_ses-002_long_run-01_T1w.nii']};
    elseif strcmp(subj_id,'sub-8082')==1
            matlabbatch{5}.spm.spatial.preproc.channel.vols = {[data_path '/' subj_id '/ses-002/anat/r' subj_id '_ses-002_acq_run-01_T1w.nii']};
    else
       matlabbatch{5}.spm.spatial.preproc.channel.vols = {[data_path '/' subj_id '/ses-001/anat/rr' subj_id '_ses-001_long_run-01_T1w.nii']};
    end
    matlabbatch{5}.spm.spatial.preproc.channel.biasreg = 0.001;
    matlabbatch{5}.spm.spatial.preproc.channel.biasfwhm = 60;
    matlabbatch{5}.spm.spatial.preproc.channel.write = [0 1];
    matlabbatch{5}.spm.spatial.preproc.tissue(1).tpm = {['...\TPM.nii,1']};
    matlabbatch{5}.spm.spatial.preproc.tissue(1).ngaus = 1;
    matlabbatch{5}.spm.spatial.preproc.tissue(1).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(1).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(2).tpm = {['...\TPM.nii,2']};
    matlabbatch{5}.spm.spatial.preproc.tissue(2).ngaus = 1;
    matlabbatch{5}.spm.spatial.preproc.tissue(2).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(2).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(3).tpm = {['...\TPM.nii,3']};
    matlabbatch{5}.spm.spatial.preproc.tissue(3).ngaus = 2;
    matlabbatch{5}.spm.spatial.preproc.tissue(3).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(3).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(4).tpm = {['...\TPM.nii,4']};
    matlabbatch{5}.spm.spatial.preproc.tissue(4).ngaus = 3;
    matlabbatch{5}.spm.spatial.preproc.tissue(4).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(4).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(5).tpm = {['...\TPM.nii,5']};
    matlabbatch{5}.spm.spatial.preproc.tissue(5).ngaus = 4;
    matlabbatch{5}.spm.spatial.preproc.tissue(5).native = [1 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(5).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(6).tpm = {['...\TPM.nii,6']};
    matlabbatch{5}.spm.spatial.preproc.tissue(6).ngaus = 2;
    matlabbatch{5}.spm.spatial.preproc.tissue(6).native = [0 0];
    matlabbatch{5}.spm.spatial.preproc.tissue(6).warped = [0 0];
    matlabbatch{5}.spm.spatial.preproc.warp.mrf = 1;
    matlabbatch{5}.spm.spatial.preproc.warp.cleanup = 1;
    matlabbatch{5}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
    matlabbatch{5}.spm.spatial.preproc.warp.affreg = 'mni';
    matlabbatch{5}.spm.spatial.preproc.warp.fwhm = 0;
    matlabbatch{5}.spm.spatial.preproc.warp.samp = 3;
    matlabbatch{5}.spm.spatial.preproc.warp.write = [1 1];
    % normalization
    matlabbatch{6}.spm.spatial.normalise.write.subj.def(1) = cfg_dep('Segment: Forward Deformations', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','fordef', '()',{':'}));
    matlabbatch{6}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
    matlabbatch{6}.spm.spatial.normalise.write.subj.resample(2) = cfg_dep('Slice Timing: Slice Timing Corr. Images (Sess 2)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{2}, '.','files'));
    
    if strcmp(subj_id,'sub-8083')==1
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
    elseif strcmp(subj_id,'sub-8082')==1
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
    else 
        matlabbatch{6}.spm.spatial.normalise.write.subj.resample(3) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
        
    end
    matlabbatch{6}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
        78 76 85];
    matlabbatch{6}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{6}.spm.spatial.normalise.write.woptions.interp = 4;
    matlabbatch{6}.spm.spatial.normalise.write.woptions.prefix = 'w';
    
    %smoothing
%     matlabbatch{7}.spm.spatial.smooth.data(1) = cfg_dep('Normalise: Write: Normalised Images (Subj 1)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('()',{1}, '.','files'));
%     matlabbatch{7}.spm.spatial.smooth.fwhm = [6 6 6];
%     matlabbatch{7}.spm.spatial.smooth.dtype = 0;
%     matlabbatch{7}.spm.spatial.smooth.im = 0;
%     matlabbatch{7}.spm.spatial.smooth.prefix = 's';
%     matlabbatch{8}.cfg_basicio.file_dir.file_ops.cfg_file_split.name = 'run01run02FileSplit';
%     matlabbatch{8}.cfg_basicio.file_dir.file_ops.cfg_file_split.files(1) = cfg_dep('Smooth: Smoothed Images', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
%     matlabbatch{8}.cfg_basicio.file_dir.file_ops.cfg_file_split.index = {
%         1
%         2
%         }';
    
    
    spm_jobman('run', matlabbatch);
    
end


