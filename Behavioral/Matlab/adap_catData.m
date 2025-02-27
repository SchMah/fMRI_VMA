% load/create group data
clear all;
group_dir = '' 
if exist(fullfile(group_dir,'T_Group.mat'));
    load(fullfile(group_dir,'T_Group.mat'));
else
    T_Group = [];
end
%%  step 1- import data/individual subjects
subj_dir = ''
subj_data = dir(fullfile(subj_dir,'*.mat'));
load(fullfile(subj_data(1).folder,subj_data(1).name)); % make sure it is the correct
%% call some parameters from experiment
params.xCent = 960;
params.yCent = 540;
scr.scr_sizeX = 1920; % touchtablet 4096
scr.scr_sizeY = 1080; % touchtablet 4096
scr.disp_sizeX = 43 % touchtablet 212;
scr.disp_sizeY = 24 % touchtablet 159;
pix_by_mmX = scr.scr_sizeX/scr.disp_sizeX;
pix_by_mmY = scr.scr_sizeY/scr.disp_sizeY;
pixel_to_mmX = 1/pix_by_mmX;
pixel_to_mmY = 1/pix_by_mmY;

%% Step 2 extrace only successfull movements.
succ_mov_indx = find(T.Status==1); %
T_tmp = T(succ_mov_indx,:); % create a temporary table for subsequent analysis
tbl_size = size(T_tmp.SL,1); % get the size of table (including only successfull mov
T_tmp.EndAngle_deg = T_tmp.EndAngle * 180/pi;
T_tmp.SN = repmat(categorical({T_tmp.SN{1}(1:2)}),tbl_size,1);

%additionally calculate the number of attempted trials 
unsucc_mov_indx = find(T.Status==-1);
blck = unique(T.Block)
for i = 1 : length(blck)
    indx = find(T.Block == blck(i));
    if numel(indx)<15
        missed_trial(i,1) = 15 - numel(indx)
    else
        missed_trial(i,1) = 0
    end
end
%% step 2-a Visualize hand reaches based on endpoint angle
figure; hold on;
set(gcf,'units','inches','pos',[1 2 7 3]);
plot(T_tmp.EndAngle_deg,'.-b','markersize',15,'LineWidth',1.5')
xlabel(['Trial Number'],'FontWeight','bold','FontSize',12);
ylabel(['Hand Angle (',char(176),')'],'FontWeight','bold','FontSize',12);
box off;
title('Endangle - raw data')
%% Step 2-b : Visualize trajectories in raw format
block = unique(T_tmp.Block)
colors = parula(size(block,1))
figure;set(gcf,'units','inches','pos',[2 0 10 10]);
tcl = tiledlayout(4,5);
for i = 1: length(block)
    
    indx_blck = find(T_tmp.Block == block(i));
    nexttile;hold on
        for j = 1 : length(indx_blck) 
            plot(T_tmp.Points{indx_blck(j),1}(:,1),T_tmp.Points{indx_blck(j),1}(:,2),'.-','color',colors(i,:))
        end
        xlim([-100 400])
        ylim([-100 400])
        plot(T_tmp.TargetPosition{1}(1)-params.xCent,-T_tmp.TargetPosition{1}(2)+params.yCent,'.k','MarkerSize',15)
        title(['Block' num2str(block(i))])
        xlabel('x')
        ylabel('y')
end
title(tcl,'Original Data')

%% Step 3 : smooth data to calculate velocity profile and hand angle at max veloci
order_n = 2;
F_sampling = 125;
F_cutoff = 10;
[B,A] = butter(order_n,F_cutoff/(F_sampling/2))
for i = 1:size(T_tmp,1); % or number of trials which is 60
    if ~isnan(T_tmp.Points{i,1})
        
        XY.X{i} = T_tmp.Points{i,1}(1:end,1);
        XY.Y{i} = T_tmp.Points{i,1}(1:end,2);
        
        
        T_tmp.Points_smoothed_vel{i,1} = [filtfilt(B,A,XY.X{i}) filtfilt(B,A,XY.Y{i}) T_tmp.Points{i,1}(1:end,3)];
        
    else
        [XY.X{i},XY.Y{i},XY.T{i},T_tmp.Points_smoothed_vel{i,1}(:,1),T_tmp.Points_smoothed{i,1}(:,2)]= deal(nan);
    end
end
% 
%% calculate head angle a maximum velocity
dt = 0.008 %check it
for i = 1:size(T_tmp,1); %
    if ~isnan(T_tmp.Points_smoothed_vel{i,1})
        vel_x = [];
        vel_y = [];
       % find the first point of main trajectory     
        %either from the startpoint position or based on marginal point of last distance
        %point fixdot size(37) both gives the same result
        a = find(T_tmp.starttimePoint(i) == T_tmp.Points{i,1}(:,3));
        
%         x = T_tmp.Points{i,1}(a:end,1).* pixel_to_mmX;
%         y= T_tmp.Points{i,1}(a:end,2) .* pixel_to_mmY;
        x = T_tmp.Points_smoothed_vel{i,1}(a:end,1).* pixel_to_mmX;
        y= T_tmp.Points_smoothed_vel{i,1}(a:end,2).* pixel_to_mmY ;
        vel_x = diff(x)./dt; % compute velocity based on a simple difference (thi
        vel_y = diff(y)./dt;
        T_tmp.hand_absvel{i} = sqrt(vel_x.^2 + vel_y.^2);
        hand_dist = sqrt(x.^2 + y.^2);
        T_tmp.rad_vel{i} = diff(hand_dist)/dt;
        [T_tmp.maxradVel(i), T_tmp.indx_maxradVel(i)] = max(T_tmp.rad_vel{i});
       
%         figure; plot(x,y);hold on; plot(x(T_tmp.indx_maxradVel(i)),y(T_tmp.indx_maxradVel(i)),'o')
        if  x(T_tmp.indx_maxradVel(i)) > 0 & y(T_tmp.indx_maxradVel(i))>0
        T_tmp.hand_maxradVel(i) = atan2(y(T_tmp.indx_maxradVel(i)) , x(T_tmp.indx_maxradVel(i)))* 180/pi;
        elseif x(T_tmp.indx_maxradVel(i)) < 0 & y(T_tmp.indx_maxradVel(i))>0
            T_tmp.hand_maxradVel(i) = 180 - atan2(y(T_tmp.indx_maxradVel(i)) , x(T_tmp.indx_maxradVel(i)))* 180/pi;
        elseif x(T_tmp.indx_maxradVel(i)) > 0 & y(T_tmp.indx_maxradVel(i)) < 0
            T_tmp.hand_maxradVel(i) =  - atan2(y(T_tmp.indx_maxradVel(i)) , x(T_tmp.indx_maxradVel(i)))* 180/pi;
        elseif x(T_tmp.indx_maxradVel(i)) < 0 & y(T_tmp.indx_maxradVel(i))< 0
            T_tmp.hand_maxradVel(i) =  180 + atan2(y(T_tmp.indx_maxradVel(i)) , x(T_tmp.indx_maxradVel(i)))* 180/pi;
        end
    else
        [T_tmp.maxradVel(i), T_tmp.indx_maxradVel(i)] =deal(nan);
        T_tmp.hand_maxradVel(i) = deal(nan);
        T_tmp.hand_Endangle(i) = deal(nan);
        T_tmp.hand_absvel{i}(:) = deal(nan);
    end
end

%% Step 3-a Visualize hand reaches based on hand angle at the maximum velocity
figure; hold on;
set(gcf,'units','inches','pos',[5 5 7 3]);
plot( T_tmp.hand_maxradVel,'.-b','markersize',15,'LineWidth',1.5')
plot( T_tmp.EndAngle*180/pi,'.-r','markersize',15,'LineWidth',1.5')
xlabel(['Trial Number'],'FontWeight','bold','FontSize',12);
ylabel(['Hand Angle (',char(176),')'],'FontWeight','bold','FontSize',12);
box off;
title('Hand angle (Max Velocity) ')
%% step 4 Outlier Detection: step 1 Remove trials in which the hand angle lies more
% than 3SD from the moving average of 5trials
% Create a matrix for all the blocks and trials. 19 blocks and 15 trials in each block. The following lines assign each movement to
%its corresponding element in the matrix. 
 
for b = 1:size(block,1)
    ind_b= find(T_tmp.Block == block(b));
    
    for t = 1:15 % trial number in each block
        a = find(T_tmp.Trial_num(ind_b)==t);
        if ~isempty(a)
            hand(b,t) = T_tmp.hand_maxradVel(ind_b(a));
        else
            hand(b,t) = deal(nan);
        end
    end
end

%% 
% smooth function calculates a moving average ( here using a five-trial window) of
% the hand angle data. Those that lie more than 3SD will be removed.  
% *****************

%outlier detection
movmean_hand_maxvelangle = smoothdata(hand,2,'movmean',5,'omitnan');
detrended = hand- movmean_hand_maxvelangle; 
Hand_SDs = std(detrended,0,2,'omitnan');

% outlier removal
outlrs = abs(detrended) > 3 * Hand_SDs(:,1);
outlrs_maxradhand = sum(outlrs,'all');
[row,col] = find(outlrs);

for i = 1: length(row)
    
    row_in_table = find(T_tmp.Block==row(i) & T_tmp.Trial_num ==col(i))
    [T_tmp.Points{row_in_table} T_tmp.Points_smoothed_vel{row_in_table} T_tmp.hand_maxradVel(row_in_table)...
        T_tmp.Elapsedtime(row_in_table) T_tmp.Elapsedtime(row_in_table)]= deal(nan);

end 

%% %% step 5 remove outliers based on huge drop in velocity 
outlrs_vel = 0; 
for i = 1:size(T_tmp,1); %
   if ~isnan(T_tmp.Points{i,1});
       a = T_tmp.indx_maxradVel(i);
      if sum((T_tmp.rad_vel{i}(a:end) < 0)) >=1
          
         [T_tmp.Points{i} T_tmp.Points_smoothed_vel{i} T_tmp.hand_maxradVel(i) T_tmp.Elapsedtime(i)]= deal(nan); 
         outlrs_vel= outlrs_vel +1;
      end
   end
end
%% step 5a Visualize hand reaches based on hand angle at maximum velocity after outliers removal step
figure; hold on;
set(gcf,'units','inches','pos',[5 5 7 3]);
plot( T_tmp.hand_maxradVel,'.-b','markersize',15,'LineWidth',1.5')

xlabel(['Trial Number'],'FontWeight','bold','FontSize',12);
ylabel(['Hand Angle (',char(176),')'],'FontWeight','bold','FontSize',12);
box off;
title('Hand angle (Max Velocity - OutliersRemoved ')
%% step 5b Visualize trajectories after outliers removal 
block = unique(T_tmp.Block)
colors = parula(size(block,1))
figure;set(gcf,'units','inches','pos',[2 0 10 10]);
tcl = tiledlayout(4,5);
for i = 1: length(block)
    
    indx_blck = find(T_tmp.Block == block(i));
    nexttile;hold on
        for j = 1 : length(indx_blck) 
            if ~isnan(T_tmp.Points{indx_blck(j),1})
            plot(T_tmp.Points{indx_blck(j),1}(:,1),T_tmp.Points{indx_blck(j),1}(:,2),'.-','color',colors(i,:))
            end
        end
        xlim([-100 400])
        ylim([-100 400])
        plot(T_tmp.TargetPosition{1}(1)-params.xCent,-T_tmp.TargetPosition{1}(2)+params.yCent,'.k','MarkerSize',15)
        title(['Block' num2str(block(i))])
        xlabel('x')
        ylabel('y')
end
title(tcl,'Outliers Removed')
%% save table of outliers statistics

% stat file name
if exist(fullfile(group_dir,'Outliers_stats.txt'))
    statFile= fopen(fullfile(group_dir,'Outliers_stats.txt'),'a');
else
    statFile = fopen(fullfile(group_dir,'Outliers_stats.txt'),'a');
    fprintf(statFile,'Subject\tSN_number\tOutliers_HandAngle\toutlrs_vel_neg\tSum_outliers\tPercentage_sum\tnumof_unsucc_mov\tmissedtrials\n');
    
end
fprintf(statFile,'%s\t%02d\t%2d\t%2d\t%2d\t%f\t%2d\t%2d\n',cell2mat(T_tmp.SL(1)),T_tmp.SN(1),outlrs_maxradhand,outlrs_vel,...
    outlrs_maxradhand+outlrs_vel,((outlrs_maxradhand+outlrs_vel)/285)*100,numel(unsucc_mov_indx),sum(missed_trial) );
fclose('all');
%% additional plots to see example of trajectories with velocity and time
% for i = 57 %size(T_tmp,1)
% figure(i);
% subplot(1,2,1)% plot trajectory
% z = T_tmp.rad_vel{i};
% x = T_tmp.Points_smoothed_vel{i,1}.* pixel_to_mmX;
% y = T_tmp.Points_smoothed_vel{i,1}.* pixel_to_mmY;
% surf([x(1:size(z,1),1) x(1:size(z,1),1)],...
%     [y(1:size(z,1),2) y(1:size(z,1),2)], [z(:) z(:)], ...  % Reshape and replicate data
%      'FaceColor', 'none', ...    % Don't bother filling faces with color
%      'EdgeColor', 'interp', ...  % Use interpolated color for edges
%      'LineWidth', 2);            % Make a thicker line
% view(2);   % Default 2-D view
% colorbar;  % Add a colorbar
% subplot(1,2,2)
% plot(T_tmp.Points_smoothed_vel{i,1}(1:size(z,1),3),z);colorbar;
% xlabel('time (s)')
% ylabel('Velocity cm/s')
% end
%% step 3 add this subject to the current group data and save it. 
T_Group = [T_Group; T_tmp];
save(fullfile(group_dir,'T_Group.mat'),'T_Group')
