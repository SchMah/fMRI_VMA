clear all;
close all;
group_dir = ''
if exist(fullfile(group_dir,'T_GLoc.mat'));
    load(fullfile(group_dir,'T_GLoc.mat'));
else
    T_GLoc = [];
end
%% individual subjects 
subj_dir = ''
subj_data = dir(fullfile(subj_dir,'*_Loc.mat'));
load(fullfile(subj_data.folder,subj_data.name));

%calculate the number of attempted trials 
unsucc_mov_indx = find(T_Loc.Status==-1);
blck = unique(T_Loc.Block)
for i = 1 : length(blck)
    indx = find(T_Loc.Block == blck(i));
    if numel(indx)< 4
        missed_trial(i,1) = 4 - numel(indx) % the number of trials in each associated block is 4
    else
        missed_trial(i,1) = 0
    end
end

succ_mov_indx = find(T_Loc.Status==1); % extrace only successfull movement. 
T_Loc_tmp = T_Loc(succ_mov_indx,:); % create a temporary table for subsequent analysis
tbl_size = size(T_Loc_tmp.SL,1); % get the size of table (inclusing only successfull movement)


params.xCent = 960;
params.yCent = 540;

for i = 1: tbl_size
        T_Loc_tmp.Endpoint_deg(i) =  T_Loc_tmp.EndAngle(i) * 180/pi; % caclulate hand angles
        if ~isnan(T_Loc_tmp.response_Number(i)) % sometime the movement is accepted but subject failed to give a response
        a = find(T_Loc_tmp.Numbers{i}(:,3) == T_Loc_tmp.response_Number(i)); % refer to step2, bulletpoint2 
        T_Loc_tmp.response_angle(i) = atan2(-T_Loc_tmp.Numbers{i,1}(a,2)+params.yCent, T_Loc_tmp.Numbers{i,1}(a,1)-params.xCent)*180/pi;
        else
           T_Loc_tmp.response_angle(i) = deal(nan);
        end
end
T_Loc_tmp.Perc=T_Loc_tmp.Endpoint_deg - T_Loc_tmp.response_angle ; % caclulate the perception 
T_Loc_tmp.SN = repmat(categorical({T_Loc_tmp.SN{1}(1:2)}),tbl_size,1); % give a unique SN number to each subject. Check it always to be correct with subject number
T_Loc_tmp.SN(1)

%%plot individual subject
figure; set(gcf,'units','inches','pos',[5 5 7 3]);
plot(T_Loc_tmp.Perc,'.-','markersize',15,'LineWidth',1.5)
set(gca,'xtick',[1:4:tbl_size],'xticklabel',unique(T_Loc_tmp.Block),'XTickLabelRotation' , 45)
%% save table of outliers statistics

% stat file name
if exist(fullfile(group_dir,'Outliers_stats_loc.txt'))
   statFile= fopen(fullfile(group_dir,'Outliers_stats_loc.txt'),'a');
else
    statFile = fopen(fullfile(group_dir,'Outliers_stats_loc.txt'),'a');
   
end
fprintf(statFile,'Subject\tSN_number\tnumof_unsucc_mov\tmissedtrials\n');
fprintf(statFile,'%s\t%02d\t%2d\t%2d\n',cell2mat(T_Loc_tmp.SL(1)),T_Loc_tmp.SN(1),...
    numel(unsucc_mov_indx),sum(missed_trial) );
fclose('all');

%%add this subject to the current group data and save it. 
T_GLoc = [T_GLoc; T_Loc_tmp];
save(fullfile(group_dir,'T_GLoc.mat'),'T_GLoc')