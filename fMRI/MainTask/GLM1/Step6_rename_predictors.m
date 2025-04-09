%% This script changes the name of predictors in each spm mat file to the ones were specified initially. 
clear all;
%% Specify data path
wd = '...\GLM1\Firstlevel'
glm_folder = '1st_level'
data_path = '...\BIDS';
%subject V number
subj_list = [];

for subj = 1:size(subj_list,2)
    subj_id = sprintf('sub-%03d', subj_list(subj));
    subj_dir = [wd '/' subj_id '/ses-002/func/' glm_folder]
    
    if isfolder(subj_dir)
        SPM_DM = fullfile(subj_dir,'SPM.mat')
    else
        display([wd '/' subj_id '/' 'ses-002' '/' 'func' '/' glm_folder '/' 'SPM.mat' '... does not exists'])
        return
    end
    load(SPM_DM)
    current_names = cellstr(SPM.xX.name);
    current_names_new = current_names;
    % Define new names
    interests = {'bsl1','bsl2','bsl3','bsl4','rot5a','rot5b','rot10a','rot10b','rot15','rot15run2','rot20a','rot20b',...
        'rot25a','rot25b','rot30a','rot30b','Washout-1','Washout-2','Washout-3','MovBsl','respBsl','MovAadap','respAdap','movwashout',...
        'RespWashout','MissedEvents'};
    
    for i = 1:numel(interests)
        interest = interests{i};
        indices = cellfun(@(x) ~isempty(regexp(x, [ interest ])), current_names);
        nonEmptyIndices = find(indices);
        
        for j = 1:numel(nonEmptyIndices)
            index = nonEmptyIndices(j);
            current_names_new{index} = interest;
        end
 
    end
    disp(current_names_new)
    SPM.xX.name = current_names_new;
    save([subj_dir '/SPM.mat'], 'SPM')
    
end

