clear all;
group_dir = ''
% load table where all datapoints are stored
load(fullfile(group_dir,'T_Group.mat'));
%% aesthetics
set(0,'defaultAxesFontSize',12)
set(0, 'DefaultAxesFontWeight','normal')
set(0,'defaultAxesFontName','Calibri')
%% Movement time
subj = unique(T_Group.SN); % how many subjects?
blocks_numb = unique(T_Group.Block); %how many blocks in total
for i = 1: size(subj,1)
    idx_subj =  find(T_Group.SN == subj(i)); %find subjects
    blocks = unique(T_Group.Block(idx_subj)); %find unique number of blocks each subject performed (in case of experiment interruption, each subject doesn't have 19 blocks as planned.
    for b = 1: length(blocks) 
        indx_blck_num = find(T_Group.SN == subj(i) &  T_Group.Block== blocks(b)) ;
        ElapsedTime(i, b)= mean(T_Group.Elapsedtime(indx_blck_num),'omitnan');
    end
end

mean_MovementTime_block = mean(ElapsedTime,1,'omitnan');
sem_MovementTime_block = nanstderr(ElapsedTime,1,'omitnan');
%% plot group performance - Movement Time -Figure 2C
h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 4 3]);
shadedErrorBar(blocks_numb,mean_MovementTime_block,...
    sem_MovementTime_block,{'-o','LineWidth',2,'color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',5});  
set(gca,'XTick',[blocks_numb],'FontWeight','normal','FontSize',10,'XMinorTick','off','XTickLabelRotation',45);
set(gca,'YTick',[0.14: 0.02:0.26],'FontWeight','normal','FontSize',10,'YMinorTick','off');

xlabel(['Block Number'],'FontWeight','normal','FontSize',12);
ylabel(['Average Movement Time (s)'],'FontWeight','normal','FontSize',12);
ylim([0.14 0.26])
ylim_min = 0.14;
ylim_max = 0.26;
ylim([ylim_min ylim_max])

plot([1 1],ylim,'--k',[4.5 4.5], ylim,'--k',[16.5 16.5], ylim, '--k');
plot([6.5 6.5],ylim,'--k',[8.5 8.5], ylim, '--k');
plot([10.5 10.5],ylim,'--k',[12.5 12.5], ylim, '--k');
plot([14.5 14.5],ylim,'--k');
text(1,ylim_max,'Bsl','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(4.5,ylim_max,'Rot5','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(6.5,ylim_max,'Rot10','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(8.5,ylim_max,'Rot15','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(10.5,ylim_max,'Rot20','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(12.5,ylim_max,'Rot25','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(14.5,ylim_max,'Rot30','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(16.5,ylim_max,'Washout','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
plot([9.5 9.5], ylim, '--','color',[0.5 0.5 0.5]);
box off;
% set(findall(gcf,'-property','FontSize'),'FontSize',12)
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
xlim([0 19]);

%% plot trial course of adaptation-MT
for s = 1: length(subj)
counter = 1;
for b = 1:size(blocks_numb,1)
    ind_b = find(T_Group.Block == blocks_numb(b) & T_Group.SN == subj(s));
    for t = 1:15 % trial number in each block
        a = find(T_Group.Trial_num(ind_b)==t);
        if ~isempty(a)
            MT_trial(s,counter) = T_Group.Elapsedtime(ind_b(a));
        else
            MT_trial(s,counter) = deal(nan);
        end
           counter = counter+1;
    end
end
end
mean_MTTrial = mean(MT_trial,1,'omitnan');
sem_hMTTrial = nanstderr(MT_trial,1,'omitnan');

h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 6 3]);
counter_pos = [1, 61, 76:15:285 285];
for i = 1:length(counter_pos)-1
    start_idx = counter_pos(i);
    end_idx = counter_pos(i+1)-1;
    x_values = start_idx:end_idx;
    shadedErrorBar(x_values,mean_MTTrial(start_idx:end_idx),...
        sem_hMTTrial(start_idx:end_idx),{'o','color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',3});
    hold on
end
xlabel(['Trial #'],'FontWeight','normal','FontSize',10);
ylabel(['Movement Time (s)'],'FontWeight','normal','FontSize',10);
set(gca, 'YMinorTick','off','XMinorTick','off');
xlim([0 285])
ylim([0.1 0.4]);
box off;


%% calculate reaction time
for i = 1: size(T_Group,1)
    if ~isnan(T_Group.Points{i,1})
        dist = sqrt(T_Group.Points{i,1}(:,1).^2 + T_Group.Points{i,1}(:,2).^2);
        idx = dist <= 37; % params.fixdotsize
        
        idx1=find(idx==1);
        a = find(T_Group.starttimePoint(i) == T_Group.Points{i,1}(:,3)); %points(:,3) timepoints
        RT = T_Group.Points{i,1}(a,3)-T_Group.Points{i,1}(idx1(1),3);
        T_Group.RT(i) = RT;
    else
        T_Group.RT(i) = deal(nan);
    end
end
%% categorize reaction time for each subject and block
for i = 1: size(subj,1)
    idx_subj =  find(T_Group.SN == subj(i)); %find subjects
    blocks = unique(T_Group.Block(idx_subj)); %find unique number of blocks each subject performed (in case of experiment interruption, each subject doesn't have 19 blocks as planned.
    for b = 1: length(blocks) 
        indx_blck_num = find(T_Group.SN == subj(i) &  T_Group.Block== blocks(b)) ;
        RT(i, b)= mean(T_Group.RT(indx_blck_num),'omitnan');
    end
end

mean_RT_block = mean(RT,1,'omitnan');
sem_RT_block = nanstderr(RT,1,'omitnan');
%% plot group performance plot. Reaction Time - Figure 2D
h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 4 3]);
shadedErrorBar(blocks_numb,mean_RT_block,...
    sem_RT_block,{'-o','LineWidth',2,'color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',5});  
set(gca,'XTick',[blocks_numb],'FontWeight','normal','FontSize',10,'XMinorTick','off','XTickLabelRotation',45);
set(gca,'YTick',[0.14: 0.02:0.26],'FontWeight','normal','FontSize',10,'YMinorTick','off');

xlabel(['Block Number'],'FontWeight','normal','FontSize',12);
ylabel(['Average Reaction Time (s)'],'FontWeight','normal','FontSize',12);
ylim([0.14 0.26])
ylim_min = 0.14;
ylim_max = 0.26;
ylim([ylim_min ylim_max])
plot([1 1],ylim,'--k',[4.5 4.5], ylim,'--k',[16.5 16.5], ylim, '--k');
plot([6.5 6.5],ylim,'--k',[8.5 8.5], ylim, '--k');
plot([10.5 10.5],ylim,'--k',[12.5 12.5], ylim, '--k');
plot([14.5 14.5],ylim,'--k');
text(1,ylim_min,'Bsl','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(4.5,ylim_min,'Rot5','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(6.5,ylim_min,'Rot10','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(8.5,ylim_min,'Rot15','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(10.5,ylim_min,'Rot20','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(12.5,ylim_min,'Rot25','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(14.5,ylim_min,'Rot30','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
text(16.5,ylim_min,'Rot0','HorizontalAlignment','Right','VerticalAlignment', 'bottom','Rotation',-90,'FontWeight','bold','FontSize',10);
plot([9.5 9.5], ylim, '--','color',[0.5 0.5 0.5]);
box off;
% set(findall(gcf,'-property','FontSize'),'FontSize',10)
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
xlim([0 19])
%% plot reaction time trial wise
for s = 1: length(subj)
counter = 1;
for b = 1:size(blocks_numb,1)
    ind_b= find(T_Group.Block == blocks_numb(b) & T_Group.SN == subj(s));
    for t = 1:15 % trial number in each block
        a = find(T_Group.Trial_num(ind_b)==t);
        if ~isempty(a)
            RT_trial(s,counter) = T_Group.RT(ind_b(a));
        else
            RT_trial(s,counter) = deal(nan);
        end
           counter = counter+1;
    end
end
end
mean_RTTrial = mean(RT_trial,1,'omitnan');
sem_RTTrial = nanstderr(RT_trial,1,'omitnan');

h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 6 3]);
counter_pos = [1, 61, 76:15:285 285];
for i = 1:length(counter_pos)-1
    start_idx = counter_pos(i);
    end_idx = counter_pos(i+1)-1;
    x_values = start_idx:end_idx;
 shadedErrorBar(x_values,mean_RTTrial(start_idx:end_idx),...
        sem_RTTrial(start_idx:end_idx),{'o-','color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',3});
    hold on
end
xlabel(['Trial #'],'FontWeight','normal','FontSize',10);
ylabel(['Reaction Time (s)'],'FontWeight','normal','FontSize',10);
set(gca, 'YMinorTick','off','XMinorTick','off');
xlim([0 285])
ylim([0.1 0.35]);
box off;



%% save tables of RT and Movement time for statistical analyses in R
% % rotation_blocks = [0 0 0 0 5 5 10 10 15 15 20 20 25 25 30 30 0 0 0]';
% % block = [1:19]';
% % phase = [repmat(categorical({'bsl'}),4,1); repmat(categorical({'adap'}),12,1); repmat(categorical({'washout'}),3,1)];
% % kinematic_table = table;
% % % 
% % for i = 1: size(subj,1)
% %     Kinematic_step_tmp = table;
% %     Kinematic_step_tmp.subject = categorical(repmat(subj(i),size(rotation_blocks,1),1));
% %     Kinematic_step_tmp.rotation = rotation_blocks;
% %     Kinematic_step_tmp.block  = block;
% %     Kinematic_step_tmp.phase  = phase;
% %     Kinematic_step_tmp.MT = ElapsedTime(i,:)';
% %     Kinematic_step_tmp.RT = RT(i,:)';    
% %     kinematic_table =[kinematic_table;Kinematic_step_tmp];
% %     clear Kinematic_step_tmp
% % end
% % writetable(kinematic_table,[group_dir 'data_kinematic.txt'],'Delimiter',' ')
