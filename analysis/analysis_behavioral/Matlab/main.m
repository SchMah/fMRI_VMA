clear all;
addpath(genpath(''))
%% settings
set(0,'defaultAxesFontSize',12)
set(0, 'DefaultAxesFontWeight','normal')
set(0,'defaultAxesFontName','Calibri')
%% ------------------------------ Load adaptation data ----------------------------
group_dir = ''
% load table where all datapoints are stored
load(fullfile(group_dir,'T_Group.mat'));
% shift hand angles to a common axis
T_Group.hand_maxradVel = (T_Group.hand_maxradVel - 45);
%% ------------------------------ Load Localization data ------------------------
load(fullfile(group_dir,'T_GLoc.mat'));

%% ------------------------------- Adaptation Analyses ------------------------
subj = unique(T_Group.SN); % how many subjects?
blocks_numb = unique(T_Group.Block); % how many blocks in total

for i = 1: size(subj,1)
    idx_subj =  find(T_Group.SN == subj(i)); %find subjects
    blocks = unique(T_Group.Block(idx_subj)); %find unique number of blocks each subject performed (in case of experiment interruption, each subject doesn't have 19 blocks as planned.
    for b = 1: length(blocks) 
        indx_blck_num = find(T_Group.SN == subj(i) &  T_Group.Block== blocks(b)) ;
        hand_maxRadVel(i, b)= mean(T_Group.hand_maxradVel(indx_blck_num),'omitnan');
        hand_maxRadVel_Std(i, b)= std(T_Group.hand_maxradVel(indx_blck_num),'omitnan');
    end
end

mean_handmaxVel_block = mean(hand_maxRadVel,1,'omitnan');
sem_handmaxVel_block = nanstderr(hand_maxRadVel,1,'omitnan');

%% plot group performance plot
h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 6 3]);
shadedErrorBar(blocks_numb,mean_handmaxVel_block,...
    sem_handmaxVel_block,{'-o','LineWidth',2,'color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',5});  

set(gca,'XTick',[blocks_numb],'FontWeight','normal','FontSize',10,'XMinorTick','off');
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
set(gca, 'YTick', [-30: 5: 10])
ylim([-30 10]);
xlabel(['Block Number'],'FontWeight','normal','FontSize',10);
ylabel(['Hand Angle (',char(176),')'],'FontWeight','normal','FontSize',10);
plot([1 1],ylim,'--k',[4.5 4.5], ylim,'--k',[16.5 16.5], ylim, '--k');
plot([6.5 6.5],ylim,'--k',[8.5 8.5], ylim, '--k');
plot([10.5 10.5],ylim,'--k',[12.5 12.5], ylim, '--k');
plot([14.5 14.5],ylim,'--k');
text(1,10,'rot0','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(4.5,10,'rot5','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(6.5,10,'rot10','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(8.5,10,'rot15','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(10.5,10,'rot20','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(12.5,10,'rot25','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(14.5,10,'rot30','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
text(16.5,10,'rot0','VerticalAlignment','bottom','Rotation',-90,'FontWeight','bold','FontSize',10)
plot([9.5 9.5], ylim, '--','color',[0.5 0.5 0.5]);
box off;
set(gca, 'YMinorTick','off','XMinorTick','off');
xlim([0 19])

%% plot trial course of adaptation
for s = 1: length(subj)
counter = 1;
for b = 1:size(blocks_numb,1)
    ind_b = find(T_Group.Block == blocks_numb(b) & T_Group.SN == subj(s));
    for t = 1:15 % trial number in each block
        a = find(T_Group.Trial_num(ind_b)==t);
        if ~isempty(a)
            hand(s,counter) = T_Group.hand_maxradVel(ind_b(a));
        else
            hand(s,counter) = deal(nan);
        end
           counter = counter+1;
    end
end
end

mean_hand_angle = mean(hand,1,'omitnan');
sem_hand_angle = nanstderr(hand,1,'omitnan');

%% Figure 2A
h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 6 3]);

counter_pos = [1, 61, 76:15:285 285];
for i = 1:length(counter_pos)-1
    start_idx = counter_pos(i);
    end_idx = counter_pos(i+1)-1;
    x_values = start_idx:end_idx;

    shadedErrorBar(x_values,mean_hand_angle(start_idx:end_idx),...
        sem_hand_angle(start_idx:end_idx),{'o','color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',3});
     
    rectangle('Position',[x_values(1) -30 x_values(end)-x_values(1) 50],'EdgeColor','none','FaceColor',[0.5 0.5 0.5 0.3])

    hold on
end
xlabel(['Trial #'],'FontWeight','normal','FontSize',12);
ylabel(['Hand Angle (',char(176),')'],'FontWeight','normal','FontSize',12);
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
set(gca, 'YTick', [-30: 5: 20])
set(gca,'XTick',[1 61 91 121 151 181 211 241 285],'FontWeight','normal','FontSize',12,'XMinorTick','off');
xlim([0 285])
ylim([-30 20]);
set(findall(gcf,'-property','FontSize'),'FontSize',12)
box off;

%% save data for analysis in R (This has to be run only one time)
% % % to obtain imposed rotation structure, load one of params file from a
% % % subject's folder
% % load('')
% % params.Rot_Deg
% % rotation_trials = reshape(params.Rot_Deg', 1, [])';
% % trial_number = repmat([1:15],1, 19)';
% % block = reshape(repmat([1:19],15,1), 1,[])';
% % hand_adap_step = table;
% % 
% % for i = 1: size(subj,1)
% %     hand_adap_step_tmp = table;
% %     hand_adap_step_tmp.subject = categorical (repmat(subj(i),size(rotation_trials,1),1));
% %     hand_adap_step_tmp.rotation = rotation_trials;
% %     hand_adap_step_tmp.block  = block;
% %     hand_adap_step_tmp.trialnum = trial_number;
% %     hand_adap_step_tmp.handangle = hand(i, :)';
% %     hand_adap_step =[hand_adap_step;hand_adap_step_tmp];
% %     clear hand_adap_step_tmp
% % end
% % writetable(hand_adap_step,[group_dir 'data_fMRI_adap_Group.txt'],'Delimiter',' ')











%% ------------------------------- Localization Analyses ------------------------
mov_block = nan (size(subj,1) , length(blocks_numb));
for i = 1: size(subj,1)
    idx_subj =  find(T_GLoc.SN == subj(i)); %find subjects
    blocks = unique(T_GLoc.Block(idx_subj)); %find unique number of blocks each subject performed (in case of experiment interruption, each subject doesn't have 19 blocks as planned.
    for b = 1: length(blocks)
        indx_blck_num = find(T_GLoc.SN == subj(i) &  T_GLoc.Block== blocks(b)) ;
        perception_block(i, blocks(b))= mean(T_GLoc.Perc(indx_blck_num),'omitnan');
        mov_block(i, blocks(b))= std(abs(T_GLoc.Endpoint_deg(indx_blck_num)-45),'omitnan');
        if (mov_block(i, blocks(b)))==0
            mov_block(i, blocks(b)) = deal(nan);
        end
        mov_med_block(i, blocks(b))= mean(abs(T_GLoc.Endpoint_deg(indx_blck_num)-45),'omitnan');
    end
end
% mean per group
mean_perc_block = mean(perception_block,1,'omitnan');
sem_perc_block = nanstderr(perception_block,1,'omitnan');
%% plot group performance plot (Figure 2B)
h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 6 3]);
shadedErrorBar(blocks_numb,mean_perc_block,...
    sem_perc_block,{'-o','LineWidth',2,'color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',5});

set(gca,'XTick',[blocks_numb],'FontWeight','normal','FontSize',10);
set(gca,'YTick',[-14: 2:4],'FontWeight','normal','FontSize',10);
ylim([-14 4]);
xlabel(['Block Number'],'FontWeight','normal','FontSize',12);
ylabel(['Hand Perception (',char(176),')'],'FontWeight','normal','FontSize',12);
plot([1 1],ylim,'--k',[4.5 4.5], ylim,'--k',[16.5 16.5], ylim, '--k');
plot([6.5 6.5],ylim,'--k',[8.5 8.5], ylim, '--k');
plot([10.5 10.5],ylim,'--k',[12.5 12.5], ylim, '--k');
plot([14.5 14.5],ylim,'--k');
text(1,4,'Bsl','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(4.5,4,'Rot5','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(6.5,4,'Rot10','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(8.5,4,'Rot15','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(10.5,4,'Rot20','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(12.5,4,'Rot25','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(14.5,4,'Rot30','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(16.5,4,'Washout','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)

plot([9.5 9.5], ylim, '--','color',[0.5 0.5 0.5]);

box off;
xlim([0 19])
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
set(findall(gcf,'-property','FontSize'),'FontSize',12)

%% plot single trial data (Figure S4.B)
for s = 1: length(subj)
counter = 1;
for b = 1:size(blocks_numb,1)
    ind_b= find(T_GLoc.Block == blocks_numb(b) & T_GLoc.SN == subj(s));
    for t = 1:4 % trial number in each block
        a = find(T_GLoc.Trial_num(ind_b)==t);
        if ~isempty(a)
            perception_trial(s,counter) = T_GLoc.Perc(ind_b(a));
        else
            perception_trial(s,counter) = deal(nan);
        end
           counter = counter+1;
    end
end
end

mean_perceptiontrial_angle = mean(perception_trial,1,'omitnan');
sem_perceptiontrial_angle = nanstderr(perception_trial,1,'omitnan');

h = figure ('Color', [1 1 1]);hold on
set(gcf,'units','inches','pos',[5 5 6 3]);
counter_pos = [1, 17, 21:4:76 77];
for i = 1:length(counter_pos)-1
    start_idx = counter_pos(i);
    end_idx = counter_pos(i+1)-1;
    x_values = start_idx:end_idx;
    shadedErrorBar(x_values,mean_perceptiontrial_angle(start_idx:end_idx),...
        sem_perceptiontrial_angle(start_idx:end_idx),{'o','color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',3});

    hold on
end
plot([1 1],ylim,'--k',[17 17], ylim,'--k',[25 25], ylim, '--k');
plot([33 33],ylim,'--k',[41 41], ylim, '--k');
plot([49 49],ylim,'--k',[57 57], ylim, '--k');
plot([65 65],ylim,'--k');
text(1,10,'Bsl','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(17,10,'Rot5','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(25,10,'Rot10','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(33,10,'Rot15','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(41,10,'Rot20','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(49,10,'Rot25','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(57,10,'Rot30','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)
text(65,10,'Washout','VerticalAlignment','bottom','Rotation',-90,'FontWeight','normal','FontSize',10)

plot([36.5 36.5], ylim, '--','color',[0.5 0.5 0.5]);
xlabel(['Trial #'],'FontWeight','normal','FontSize',10);
ylabel(['Hand Perception (',char(176),')'],'FontWeight','normal','FontSize',10);
set(gca,'XTick',[1 17 25 33 41 49 57 65 76],'FontWeight','normal','FontSize',10);
set(gca, 'YTick', [-20: 5: 10])
xlim([0 76])
ylim([-20 10]);
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'in');
set(findall(gcf,'-property','FontSize'),'FontSize',12)
box off;

%% save data to analyze in R
% rotation_step = [0 0 0 0 5 5 10 10 15 15 20 20 25 25 30 30 0 0 0]';
% block = [1:19]';
% phase = [repmat(categorical({'bsl'}),4,1); repmat(categorical({'adap'}),12,1); repmat(categorical({'washout'}),3,1)];
% 
% hand_loc_step = table;
% 
% for i = 1: size(subj,1)
%     hand_loc_step_tmp = table;
%     hand_loc_step_tmp.subject = categorical (repmat(subj(i),size(rotation_step,1),1));
%     hand_loc_step_tmp.rotation = rotation_step;
%     hand_loc_step_tmp.block  = block;
%     hand_loc_step_tmp.phase  = phase;
%     hand_loc_step_tmp.Perception = perception_block(i, :)';
%     hand_loc_step =[hand_loc_step;hand_loc_step_tmp];
%     clear hand_loc_step_tmp
% end
% 
% writetable(hand_loc_step,[group_dir 'data_fMRI_Loc_Group.txt'],'Delimiter',' ')























%%
%---------------------------------------------------------------------------------
%----------------- Additional Analyses for Neuroimage Revision -------------------
%---------------------------------------------------------------------------------
%% Figure S2 - plot individual adaptation plots and mark the ones who noticed adaptation
subgroup = categorical([10 13 17 21 22 27 29 34 36]); % participant who noticed a change in the task condition
figure;set(gcf,'units','inches','pos',[2 0 12 10]);
tcl = tiledlayout(5,6);
for i = 1: size(subj,1)
    nexttile;
    plot([61 61], [-45 30],'--','color',[0.5 0.5 0.5]);
    hold on
    plot([241 241], [-45 30], '--', 'color', [0.5 0.5 0.5]); % Second line
    plot(hand(i,:),'-o','LineWidth',1,'color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',2)
    title(['S' subj(i)])
    if ismember(subj(i),subgroup)
        title(['S' char(subj(i))],'color','r')
    else
        title(['S' char(subj(i))],'color','k')
    end

    xlim([0 285])
    ylim([-45 30])
    set(gca, 'YTick', -45:15:30)
    set(gca, 'YTick', -45:15:30)
    set(gca,'XTick',[1 61 241]);
    set(gca, 'YMinorTick','off','XMinorTick','off');
    
end
xlabel(tcl, ['Trial #'],'FontWeight','normal','FontSize',12);
ylabel(tcl, ['Hand Angle (',char(176),')'],'FontWeight','normal','FontSize',12);
set(findall(gcf,'-property','FontSize'),'FontSize',12)

%% Figure S3 - individual hand perception plot and mark the ones who noticed adaptation
subgroup = categorical([10 13 17 21 22 27 29 34 36]);
figure;set(gcf,'units','inches','pos',[2 0 12 10])
tcl = tiledlayout(5,6);
for i = 1: size(subj,1)
    nexttile;
    plot([4.5 4.5], [-30 25],'--','color',[0.5 0.5 0.5]);
    hold on;
    plot([16.5 16.5], [-30 25], '--', 'color', [0.5 0.5 0.5]); % Second line
    plot(perception_block(i,:),'-o','LineWidth',1,'color','k','MarkerFaceColor','k', 'MarkerEdgeColor','none','MarkerSize',2)
    hold on
    title(['S' subj(i)])
    if ismember(subj(i),subgroup)
        title(['S' char(subj(i))],'color','r')
    else
        title(['S' char(subj(i))],'color','k')
    end
    xlim([0 19])
    ylim([-30 25]);
    set(gca,'XTick',[1 5,7,9,11,13,15,17],'XTickLabelRotation',45);
    set(gca,'YTick',[-30:10:25]);
    set(gca, 'YMinorTick','off','XMinorTick','off');
end
xlabel(tcl,['Block Number'],'FontWeight','normal','FontSize',12);
ylabel(tcl,['Hand Perception (',char(176),')'],'FontWeight','normal','FontSize',12);

%% Figure S4-A
% plot distribution of hand trajectories and variability 
color_code = [40 81 242]./255;
h = figure ('Color', [1 1 1]);hold on;
set(gcf,'units','inches','pos',[5 5 6 5]);

subplot(3,1,1)
bar(mean((mov_block),1,'omitnan'),'FaceColor',color_code,'EdgeColor','none','barwidth',0.95); % Remove outliers for cleaner plot
hold on
errorbar(1:1:19, mean(mov_block,1,'omitnan'),nanstderr(mov_block,1,'omitnan'),'color',color_code,'linestyle', 'none','LineWidth',1.5)
xlabel('Block Number ');
ylabel('Variability(�)');
set(gca,'XTick',[blocks_numb],'FontWeight','normal','FontSize',12,'XTickLabelRotation',45);
title('Within-Subject Variability in Chosen Directions');
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
set(findall(gcf,'-property','FontSize'),'FontSize',12)
ylim([0 15])
box off

subplot(3,1,2)
bar(std(mov_med_block,1,'omitnan'),'FaceColor',color_code,'EdgeColor','none','barwidth',0.95); % Remove outliers for cleaner plot
hold on
errorbar(1:1:19, std(mov_med_block,1,'omitnan'),nanstderr(mov_med_block,1,'omitnan'),'color',color_code,'linestyle', 'none','LineWidth',1.5)
xlabel('Block Number ');
ylabel('Variability(�)');
title('Between-Subject Variability in Chosen Directions');
set(gca,'XTick',[blocks_numb],'FontWeight','normal','FontSize',12,'XTickLabelRotation',45);
set(gca, 'YMinorTick','off','XMinorTick','off','TickDir', 'out');
set(findall(gcf,'-property','FontSize'),'FontSize',12)
ylim([0 15])
box off


num_subjects = size(subj,1); % 
for i = 1: size(subj,1)
    
    idx_subj =  find(T_GLoc.SN == subj(i)); %find subjects
    blocks = unique(T_GLoc.Block(idx_subj));
    for b = 1: length(blocks) 
        indx_blck_num = find(T_GLoc.SN == subj(i) &  T_GLoc.Block== blocks(b)) ;
        hand_Loc_ineachBlock{i,b}= T_GLoc.Endpoint_deg(indx_blck_num);
        response_Loc_ineachBlock{i,b}= T_GLoc.response_angle(indx_blck_num);

    end
end
% define bin edges 
bin_edges = 0:15:90;
bin_centers = [bin_edges(1:end-1) + 15]; % midpoints for bar plot
% Initialize a matrix to store histogram counts for each subject
hist_counts = zeros(num_subjects, length(bin_edges)-1);
for i = 1:num_subjects
    % 
    angles =  cat(1,hand_Loc_ineachBlock{i,:});
    angles = angles(~isnan(angles));
    % histogram counts for the current subject
    hist_counts(i, :) = histcounts(angles, bin_edges);
end

% aggregate across all subjects
total_counts = sum(hist_counts, 1);

subplot(3,1,3)
bar(bin_centers, total_counts,'FaceColor',color_code,'EdgeColor','none','barwidth',0.95);
xlabel('Hand Angle (�)');
ylabel('Number of Trials');
title('Distribution of Chosen Hand Angles Across All Subjects');
xticks(bin_centers)
xticklabels([bin_edges(1:end-1) + 15]-45);
xlim([7 98]);
grid off;
box off



%% compare total adaptation between aware/unaware subgroup
hand_mean_bsl = mean(hand_maxRadVel(:,4),2,'omitnan');
hand_mean_30 =  mean(hand_maxRadVel(:,16),2,'omitnan'); 
adap_amount = hand_mean_bsl-hand_mean_30;

adap_amount_aware = adap_amount(find(ismember(subj,subgroup)));
adap_amount_unaware = adap_amount(find(~ismember(subj,subgroup)));

color_unaware = [36 203 45]./255;
color_aware = [230 7 7]./255;
h1 = figure ('Color', [1 1 1]);hold on;
set(h1,'units','centimeter','Position',[5 5 5 5]); 
group = [1 *  ones(size(adap_amount_unaware));
         2 *  ones(size(adap_amount_aware))];
colors =[ color_unaware; color_aware ];
h = violinplot([adap_amount_unaware; adap_amount_aware],group, 'ShowMean', true,...
    'ShowMedian', true,...
    'ViolinColor', colors, 'ViolinAlpha',0.5,'BoxColor',[0 0 0],'Width',0.4,'MarkerSize',18);
ylabel(['Adaptation level (',char(176),')'] )
set(gca,'XTicklabel',{'unawrare', 'aware'},'FontWeight','normal','FontSize',12,'XTickLabelRotation',45);
ylim([10 35]);
box off
[p,h,stats] = ranksum(adap_amount_aware,adap_amount_unaware);


%% compare total change in perception between aware/unaware subgroup
perception_bsl = mean(perception_block(:,3:4),2,'omitnan');
perception_rot30 = mean(perception_block(:,16),2,'omitnan');
perception_change = perception_bsl - perception_rot30;

perc_amount_aware = perception_change(find(ismember(subj,subgroup)));
perc_amount_unaware = perception_change(find(~ismember(subj,subgroup)));

color_unaware = [36 203 45]./255;
color_aware = [230 7 7]./255;
h1 = figure ('Color', [1 1 1]);hold on;
set(h1,'units','centimeter','Position',[5 5 5 5]); 
group = [1 *  ones(size(perc_amount_unaware));
         2 *  ones(size(perc_amount_aware))];
colors =[ color_unaware; color_aware ];
h = violinplot([perc_amount_unaware; perc_amount_aware],group, 'ShowMean', true,...
    'ShowMedian', true,...
    'ViolinColor', colors, 'ViolinAlpha',0.5,'BoxColor',[0 0 0],'Width',0.4,'MarkerSize',18);
ylabel(['Perception Change (',char(176),')'] )
set(gca,'XTicklabel',{'unawrare', 'aware'},'FontWeight','normal','FontSize',12,'XTickLabelRotation',45);

% ylim([10 35])
box off
[p,h,stats] = ranksum(perc_amount_unaware,perc_amount_aware);

