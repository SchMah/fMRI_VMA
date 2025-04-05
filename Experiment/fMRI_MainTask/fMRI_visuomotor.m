function fMRI_visuomotor (subjectGroup, subjectNumber, fMRI, eye_Tracker,ScreenName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Screen parameters
% Using PsychImaging to flip the image horizontally for Optostim monitor
%%% =========================================================================
% %%%%%%%%%%%%%%        Shirin       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%  Written: Oct. 2021 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Earlier version : fmrireachingSep2021.m
%%% =========================================================================
% %%%%%%% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI_visuomotor (subjectGroup, subjectNumber, fMRI, eye_Tracker)
% subjectNumber: for example: '1'
% subjectGroup: for example 'Pilot' , 'C' , 'P'
% fMRI: 1 or 0...0 for behavioral only .. 1 for running in scanner with  imaging
% eyeTrack: 1: record Gaze data.... 0 : no eyetracker
%Screen : define which setup is gonna be used, options: Psychphysics set-up
%or scanner. Valid inputs, 'Psychophysics' 'Scanner'
%%% =========================================================================
%  ____            ____                ____            ____
% |    |          |    |              |    |          |    |
% | 0� |_||||||||_| 0� |_||||||||_..._| 0� |_||||||||_| 5� |_||||||||_ ..
% T-blc   Loc       T      Loc   ..... Adap    Loc     Adap    Loc
%%% =========================================================================
%% Functions called in this script
% ArringtonCalibration.m
% BlockDescription.m
% Targetside.m
% VisualFB_Matrix.M
% wait_scanner_trigger.m
% checkExit.m
% CheckIfMouseIsClosetoCenter.m
% deg2pix.m
% CheckIfMouseIsReleased.m
% gradedcircle.m
% recordReportedNumber.m
% getparameters.m
%%% =========================================================================
%% Initialize window , screen properties
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebugLevel', 1);
PsychImaging('PrepareConfiguration');
% flipHorizontally = true;
% if flipHorizontally
%     PsychImaging('PrepareConfiguration');
%     PsychImaging('AddTask', 'AllViews', 'FlipHorizontal');
% end
% fitSize = [1400,1050]; % same aspect ratio as touchscreen
% PsychImaging('AddTask', 'General', 'UsePanelFitter', fitSize, 'Centered');
%%%%%%% Screen Number %%%%%%%
% ScreenNumber=0;
%%% =========================================================================

%% load parameters
getparameters;
[L_1] = BlockDescription('English');
[~,params.targetposition,~,~] = Targetside('Right');
params.Rot_Deg = VisualFB_Matrix(params);
%%# =========================================================================
%% Create logfile / folder to save data
% open a logfile
LogFile = fopen(['fMRI_Visuomotor_' subjectGroup num2str(subjectNumber) '_' 'log' '.txt'],'a');
fprintf(LogFile,'+++++++++++++++++++++++++++++++++++++++++\n');
fprintf(LogFile, ['* Date/Time: ' datestr(now) '\n']);
fprintf(LogFile, ['* Subject Number: ' num2str(subjectNumber) '\n']);
fprintf(LogFile, ['* Subject Name: ' subjectGroup '\n']);
fprintf(LogFile,'+++++++++++++++++++++++++++++++++++++++++\n\n');
disp( ['* Date/Time: ' datestr(now)]);
disp( ['* Subject Number: ' num2str(subjectNumber)]);
disp( ['* Subject Name: ' subjectGroup ]);


% set-up folder for storing data
SubjectID = strcat(subjectGroup, num2str(subjectNumber));
filename = strcat(SubjectID, datestr(clock, '_YYYYmmdd_HHMMSS') );
SubjectFolder = SubjectID;

while exist(SubjectFolder, 'dir')
    
    fprintf('The folder %s already exists!\n', SubjectFolder);
    SubjectFolder = sprintf('%sn',SubjectFolder);
    fprintf('Trying: %s\n', SubjectFolder);
    
end

mkdir(SubjectFolder);
save_dir=[cd filesep sprintf('%s',SubjectFolder) filesep];

% table to store behavioral data
% with Target
T = table;
Names = {'SL';'SN';'Block';'Trial_num';'Status';'Points';'ShootEndPoint';'EndAngle';'FBEndPoint';'EndAngle_FB';'TargetPosition';'Elapsedtime';'starttimePoint';'EndTimePoint'};

% without Target
T_Loc = table;
Names_Loc = {'SL';'SN';'Block';'Trial_num';'Status';'Points';'ShootEndPoint';'EndAngle';'Elapsedtime';'starttimePoint';'EndTimePoint';'Numbers';'response_Number'};

% output structure to store summary of time events
%for training phase
TrainingTimeEvents.t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
    [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]);

% Localization trials
TimeEvents_Loc.t = struct('Trial_Loc', [], 'Block', [], 'trialStatus', [], 'fix_start',[],'Event_instruc_start',[],'Event_instruc_stop',[],'Event_instruc_Dur',[],...
    'fix_stop',[],'fst_fix_oneset',[],'fst_fix_dur_all',[],'fst_fix_dur',[],...
    'instrc_Tminus_Onset',[],'instrc_Duration',[],'mvnt_phase_start',[],'mvmnt_phase_Onset',[],'mvnt_startRecord',[],'Mvmnt_End',[],...
    'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[],'fix_start_middle',[],'fix_middle_Onset',[],'fix_stop_middle',[],'response_start',[],...
    'response_Onset',[],'response_stop',[]);

%%% =========================================================================
%% fMRI and Eyetracker
%  set the default
if ~exist('fMRI')
    fMRI = 0;
end

if ~exist('eye_Tracker')
    eye_Tracker = 0;
end
%%% =========================================================================
%% Initinalize PsychToolBox
%open window
params.ScreenNumber
Screen('Preference', 'SkipSyncTests', 1)
[window, screenrect] = PsychImaging('OpenWindow', params.ScreenNumber, params.black);
% center of Screen
% [xCenter, params.yCent] = RectCenter(screenrect)
% related to buttonpress section
params.centeredspotRect = CenterRect(params.spotRect, params.screen_size);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
% font size
Screen('TextSize',window,params.textsize);
% font color
Screen('TextColor',window,params.white);
% font style
Screen('TextStyle',window,1);
% ShowCursor(); % this line is for debugging. in actual eperiment comment it and uncomment the next line
HideCursor()
%%% =========================================================================
%%  Initialize EyeTracker

if eye_Tracker
    % initialize library
    if ~libisloaded('vpx')
        vpx_Initialize;
    end
    
    if vpx_GetStatus(1)==0
        error('ViewPoint software is not running!')
    end
    
    dspl_text = 'The Eye-Tracker has initialized ... The calibration will start soon ... ';
    DrawFormattedText(window,dspl_text , 'center', params.yCent, params.white,[],0);
    
else
    
    dspl_text = ' Please wait ... The Experiment is about to begin .. ';
    DrawFormattedText(window,dspl_text , 'center', params.yCent, params.white,[],0);
end
WaitSecs(0.5)
Screen('Flip', window);

%%%% Calibrate Eye tracker
if eye_Tracker
    ArringtonCalibration(params.ScreenNumber)
    vpx_SendCommandString( sprintf('dataFile_NewName %sn',filename));
end
%%% =========================================================================
%% Keyboard Setup
KbName('UnifyKeyNames');
keyslist=zeros(1,256);
keyslist(KbName({'SPACE','ESCAPE', 'RETURN', '6^', '7&','8*','4$','3#','2@','+','9('}))= 1; %'4$','3#','2@'
KbQueueCreate([], keyslist);
KbQueueStart;
%%% =========================================================================
% 
%% %% run the Experiment
% define initial values for each phase
%%% =========================================================================
% Target position 45�
params.tXpos = params.gradedcircle * cos(params.targetposition) + params.xCent;
params.tYpos = params.gradedcircle * sin(params.targetposition) + params.yCent;
%%% =========================================================================
%% Display discription for Training
exitDemo = false;
params.Block_runPause_status = false;
% In order to have all blocks in one program, differet steps are defined
params.INSTRUCTION1 = false;
disp( 'Description for Block');
Screen('TextSize',window,params.textsize_dscrptn)
DrawFormattedText(window, sprintf('%s\n\n',L_1{:}),'center',params.yCent * 0.25, params.white,[],0)
disp_vbl = Screen('Flip', window);

% Wait for button press
while ( ~params.INSTRUCTION1 && ~exitDemo)
    [pressed, firstpress] = KbQueueCheck();
    
    if firstpress (KbName('SPACE'))
        params.INSTRUCTION1 = true;
    end
    exitDemo = checkExit(pressed, firstpress);
end
%%  Initialize scanner
if fMRI
    Screen('TextSize',window,params.textsize)
    text_scanner ='Please wait for the scanner to trigger';
    DrawFormattedText(window,text_scanner ,...
        'center', params.yCent, params.white,[],0);
    Screen('Flip', window);
    params.trigger_T = wait_scanner_trigger(window, text_scanner);
    params.trigger_T_firstRun = params.trigger_T;
end
%%% =========================================================================
%% Beginnig of Trials
Block = 1;
while Block <= params.n_blcks  ~exitDemo   % total blocks 4:T 8:adap 3:dAdap
    Screen('TextSize', window, params.textsize)
    fprintf(LogFile,'block\tTrial\tstartPoint_Start(time)\tstartPoint_Stop\tTarget_displayTime(time)\tFeedback_Start\tFeedback_Stop\n');
 
    %     Trial_Target = max(1, Trial_Target);
    if fMRI
        params.Intro = params.trigger_T;
    else 
        params.Intro = GetSecs;
    end
    
    elapsedtime_T = nan (1,100);
    Endtime_point_Training =  zeros (1,100);
    
    TrainingTimeEvents(Block).t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
        [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]);   
   
    TimeEvents_Loc(Block).t = struct('Trial_Loc', [], 'Block', [], 'trialStatus', [], 'fix_start',[],'Event_instruc_start',[],'Event_instruc_stop',[],'Event_instruc_Dur',[],...
    'fix_stop',[],'fst_fix_oneset',[],'fst_fix_dur_all',[],'fst_fix_dur',[],...
    'instrc_Tminus_Onset',[],'instrc_Duration',[],'mvnt_phase_start',[],'mvmnt_phase_Onset',[],'mvnt_startRecord',[],'Mvmnt_End',[],...
    'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[],'fix_start_middle',[],'fix_middle_Onset',[],'fix_stop_middle',[],'response_start',[],...
    'response_Onset',[],'response_stop',[]);

    for Trial_Target = 1: params.n_Trials_blck
        
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start"', Block, Trial_Target));
        end
        
        Fam_StartTime_Trial = GetSecs();
        XYPoints_hand = [];
        starttime_Fam = [];
        starttime_point_Fam = [];
        EndPosition_Training = [];
        M_dis = [];
        M_dis1=[];
        r_rot = [];
        trialstatus = [];
        Trial_Target
        cursorShow = false ;
        CheckIfMouseIsReleased;
        
        % Draw a white cross in the middle of the screen as fixation
        Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
        TrainingTimeEvents(Block).t(Trial_Target).startPoint_Start = Screen('Flip',window);
 
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Central plus sign appears "', Block, Trial_Target));
        end
        
        SetMouse(params.xCent, params.yCent, window);
        
        %wait for 500ms in fixation phase until target appears
        while GetSecs - TrainingTimeEvents(Block).t(Trial_Target).startPoint_Start <= params.fix %500ms
        end
        
        TrainingTimeEvents(Block).t(Trial_Target).startPoint_Stop = GetSecs;
        
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of Central plus sign, start point appears "', Block, Trial_Target));
        end
        
        % target appears after 500ms and allows subject to initiate movement
        Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
        Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
        TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime = Screen('Flip',window);
        
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Target appears.. Movement Phase "', Block, Trial_Target));
        end
        
        % movement phase for 3 seconds
        while (GetSecs - TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur && ~exitDemo
            
            %%% =========================================================================
            %%%% Wait for the mouse %%%%
            while true && (GetSecs - TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur
                [x_mouse, y_mouse, buttons] = GetMouse(window); % get mouse data
                M_dis1 = sqrt((x_mouse-params.xCent)^2 + (y_mouse-params.yCent)^2);
                if buttons(1)
                    break;
                end
            end
            %%% =========================================================================
            [cursorShow] = CheckIfMouseIsClosetoCenter(M_dis1,params,window,x_mouse,y_mouse,cursorShow);
            %%% =========================================================================
            % While button is pressed and cursor is in searching mode
            while cursorShow == true && (GetSecs - TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur
%               [cursorShow] = CheckIfMouseIsClosetoCenter(M_dis1,params,window,x_mouse,y_mouse,cursorShow);
                
                [x_mouse, y_mouse, buttons] = GetMouse(window);
                %distance vector from center
                M_dis = sqrt((x_mouse-params.xCent)^2 + (y_mouse-params.yCent)^2);
                
                Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                Screen('DrawDots', window, [x_mouse y_mouse], params.cursorsize, params.white, [], 2);
                
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d cursor in searching phase "', Block, Trial_Target));
                end
                
                if M_dis < params.fixdotsize
                    starttime_Fam = GetSecs();
                    cursorShow = false;
                    XYPoints_hand = vertcat(XYPoints_hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) 0]);
                    break;
                end
                Screen('Flip',window);
            end
            
            
            %             XYPoints_hand = vertcat(XYPoints_hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) 0]);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d cursor in starting position "', Block, Trial_Target));
            end
            %%% =========================================================================
            % when cursor is in starting position
            while  cursorShow == false && (GetSecs - TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur %&& M_dis <= params.gradedcircle
                
                [x_mouse, y_mouse, buttons] = GetMouse(window);
                if ~isempty(starttime_Fam)
                    time_Fam = GetSecs()-starttime_Fam;
                else
                    time_Fam = GetSecs();
                end
                if  ~buttons(1) && time_Fam >= 0.5
                    %                     disp('disconnection is too long')
                    break
                end
                
                XYPoints_hand = vertcat(XYPoints_hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) time_Fam]);
                
                %M_dis= movement distance
                M_dis = sqrt((x_mouse-params.xCent)^2 + (y_mouse-params.yCent)^2);
                %position coordinate transformation to 0,0 coordinate.
                relPos = [x_mouse-params.xCent; -y_mouse+params.yCent];
                
                % rotation amount
                phi = params.Rot_Deg(Block,Trial_Target) * pi/180;
                % rotation matrix for counterclockwise rotation
                R = [cos(phi), -sin(phi); sin(phi), cos(phi)];
                r_rot = R*[(x_mouse-params.xCent); (-y_mouse+params.yCent)];
                        
                if M_dis < params.fixdotsize
                    Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.green, [], 2);
                    Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                    TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_Start = GetSecs; % Movement Starts
                    starttime_point_Fam = time_Fam;
                else
                    Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                end
                
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement Initiation "', Block, Trial_Target));
                end
                
                Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                
                % Draw the dot that represents the cursor
                if M_dis <= params.gradedcircle && Block <= params.Blcks_trajFB  
                    Screen('DrawDots', window, [r_rot(1)+params.xCent -r_rot(2)+params.yCent], params.cursorsize, params.white,[], 2);  % actual cursor as green dot
                end
                %%% =========================================================================
                % constraint movement to the boundary - End of Movement
                if M_dis >= params.gradedcircle;
                    TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_End = GetSecs();
                    Endtime_point_Training(1,Trial_Target) = time_Fam;
                    %Screen('DrawDots', window, [tXpos tYpos], params.Rtarget, params.white, [], 2);
                    if ~isempty(TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_Start)
                        elapsedtime_T(1,Trial_Target)= GetSecs()- TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_Start;
                    end
                    % % Compute angle
                      
                    %the reason for using relPos is that we need angle
                    %relative to center, however the actual mouse position
                    %is relative to 0,0 of screen which is upper left side.
                    
                    angle_hand = atan2(relPos(2),relPos(1));
                    x_endAngle_hand = params.gradedcircle * cos(angle_hand);
                    y_endAngle_hand = params.gradedcircle * sin(angle_hand);
                    EndPosition_Training = [x_endAngle_hand+params.xCent; -y_endAngle_hand+params.yCent];
                    
                    % for  FB
                    Endangle_FB = atan2(r_rot(2),r_rot(1));
                    x_endAngle_FB = params.gradedcircle * cos(Endangle_FB);
                    y_endAngle_FB = params.gradedcircle * sin(Endangle_FB);
                    EndPosition_FB = [x_endAngle_FB+params.xCent; -y_endAngle_FB+params.yCent];
                    
                    TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_Duration = TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_End - TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_Start;
                    dotCenter = [0 0];

                    if eye_Tracker
                        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement ends "', Block, Trial_Target));
                    end
                    
                    break;
                end
                
                Screen('Flip',window);
                
            end
            
            %             if (GetSecs - TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime) < params.trial_mvmntdur
            %
            % %                 Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
            % %                 Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
            %                 DrawFormattedText(window, 'Done...Wait',  params.xCent-150, params.yCent - 50, params.white,[],0)
            %                 Screen('Flip',window);
            %
            %             elseif (GetSecs - TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime) == params.trial_mvmntdur
            %
            break;
            %
            %             end
            [pressed, firstpress] = KbQueueCheck();
            exitDemo = checkExit(pressed, firstpress);
            %
        end
        %%% =========================================================================
        % ++++++++++++++++++++++++++++++ Feedback Phase ++++++++++++++++++++++
        %    completed - acceptatble   :  blue dot corresponding to end point of movement
        %    completed - unacceptable  :  urge to do faster
        %    uncompleted - unacceptable : failed movement
        
        if M_dis < params.gradedcircle
            TrainingTimeEvents(Block).t(Trial_Target).Mvmnt_End_UnderShoot = GetSecs;
            UndershootEndPoint = [x_mouse y_mouse];
            if ~isempty(r_rot)
                UndershootFB = [r_rot(1)+params.xCent -r_rot(2)+params.yCent]
                dotCenter = [0 0];
                Screen('DrawDots', window, UndershootFB, params.cursorsize, params.red, dotCenter, 2);
            end
            Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
            Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
            DrawFormattedText(window, 'failed',  params.xCent-150, params.yCent - 50, params.white,[],0);
            trialstatus = -1;
            %             XYPoints_hand
            %             UndershootEndPoint
            %             starttime_point_Fam
            
            if ~isempty(starttime_point_Fam)
                T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {UndershootEndPoint'},NaN,{NaN},NaN,{[params.tXpos; params.tYpos]},NaN,starttime_point_Fam,NaN)
                
            else
                T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {UndershootEndPoint'},NaN,{NaN},NaN,{[params.tXpos; params.tYpos]},NaN,NaN,NaN)
                
            end
            T_tmp.Properties.VariableNames = Names;
            T = [T ; T_tmp];
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Failed Movement"', Block, Trial_Target));
            end
        elseif ~isempty(EndPosition_Training) && elapsedtime_T(1,Trial_Target) < params.mvmnt_time %&& Block <= params.baselineBlocks% 0.5 s
            Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
            Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
            if Block <= params.baselineBlocks
                Screen('DrawDots', window, EndPosition_FB, params.cursorsize, params.aqua, dotCenter, 2);
            end
            trialstatus = 1;
            %             XYPoints_hand
            %             {[x_endAngle_hand y_endAngle_hand]'}
            %             angle_hand
            %             {[x_endAngle_FB y_endAngle_FB]'}
            %             Endangle_FB
            %             {[params.tXpos; params.tYpos]}
            %             elapsedtime_T(1,Trial_Target)
            %             starttime_point_Fam
            %             Endtime_point_Training(1,Trial_Target)
            if ~isempty(starttime_point_Fam)
                
                T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[x_endAngle_FB y_endAngle_FB]'},Endangle_FB ,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),starttime_point_Fam,Endtime_point_Training(1,Trial_Target));
            else
                T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[x_endAngle_FB y_endAngle_FB]'},Endangle_FB ,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),NaN,Endtime_point_Training(1,Trial_Target));
            end
            
            T_tmp.Properties.VariableNames = Names;
            T = [T ; T_tmp]
            
        elseif ~isempty(EndPosition_Training) && elapsedtime_T(1,Trial_Target) > params.mvmnt_time
            DrawFormattedText(window, 'Too Slow..faster please', params.xCent-50, params.yCent, params.white,[],0);
            trialstatus = 0
            if ~isempty(starttime_point_Fam)
                T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[x_endAngle_FB y_endAngle_FB]'},Endangle_FB,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),starttime_point_Fam,Endtime_point_Training(1,Trial_Target))
            else
                
                T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[x_endAngle_FB y_endAngle_FB]'},Endangle_FB,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),NaN,Endtime_point_Training(1,Trial_Target))
            end
            T_tmp.Properties.VariableNames = Names;
            T = [T ; T_tmp]
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Slow/Failed Movement"', Block, Trial_Target));
            end
        end

        TrainingTimeEvents(Block).t(Trial_Target).Feedback_Start = Screen('Flip',window);
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start of Feedback phase"', Block, Trial_Target));
        end
        while GetSecs()- TrainingTimeEvents(Block).t(Trial_Target).Feedback_Start <= params.feedbacktime
            %                 WaitSecs(params.feedbacktime)
        end
        
        TrainingTimeEvents(Block).t(Trial_Target).Feedback_Stop = GetSecs;
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of Feedback phase"', Block, Trial_Target));
        end
        % Write Logfile data
       fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',Block,Trial_Target,TrainingTimeEvents(Block).t(Trial_Target).startPoint_Start,TrainingTimeEvents(Block).t(Trial_Target).startPoint_Stop,...
                TrainingTimeEvents(Block).t(Trial_Target).Target_displayTime,TrainingTimeEvents(Block).t(Trial_Target).Feedback_Start,TrainingTimeEvents(Block).t(Trial_Target).Feedback_Stop);

        % assigned necessay variables to time structure
        TrainingTimeEvents(Block).t(Trial_Target).Trial =  Trial_Target;
        TrainingTimeEvents(Block).t(Trial_Target).Block = Block;
        TrainingTimeEvents(Block).t(Trial_Target).trialStatus = trialstatus;
        
        SetMouse(params.xCent, params.yCent, window);
        %         save(strcat(save_dir, SubjectID),'PreAdap')
       
        [pressed, firstpress] = KbQueueCheck();
        exitDemo = checkExit(pressed, firstpress);
        
        
    end
    TrainingTimeEvents(Block).Block = Block;
    TrainingTimeEvents(Block).BlockOnset = TrainingTimeEvents(Block).t(1).startPoint_Start - params.Intro;
   
    TrainingTimeEvents(Block).block_duration =  TrainingTimeEvents(Block).t(end).Feedback_Stop - TrainingTimeEvents(Block).t(1).startPoint_Start ;
    save(strcat(save_dir, filename,'.mat'), 'T','TrainingTimeEvents' );
    %%% ++++++++++++++++++++   End of the Block ++++++++++++++++++++++++++++++++++++++
    %%% =========================================================================
    %%% ++++++++++++++++++++ 20s Rest between Block and Loc trial +++++++++++++++
    %     Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
    %     DrawFormattedText(window, 'Rest..Try to concentrate on the circle', params.xCent-150, params.yCent-50, params.white,[],1);
    %     resttime=Screen('Flip',window);
    %     tic
    %     WaitSecs(params.resttime)
    %     toc
%     DrawFormattedText(window, 'This Block is finished.. Next block will start shortly', params.xCent - 500, params.yCent, params.white,[],0)
%     TrainingTimeEvents(Block).t(Trial_Target).time_BlockEnd_mssg = Screen('Flip',window);
%     while GetSecs()- TrainingTimeEvents(Block).t(Trial_Target).time_BlockEnd_mssg < 1  && ~exitDemo
%         [pressed, firstpress] = KbQueueCheck();
%         exitDemo = checkExit(pressed, firstpress);
%         
%     end
    %%
    
    %%%%% =========================================================================
    %%%%% ================== Localization Trials ==================================
    %%%%% =========================================================================
    
    fprintf(LogFile,'block\tTrial\tIntl_Fix_Strt(time)\tIntl_Fix_Stp(time)\tMovement_phase(time)\tMddl_Fix_Strt(time)\tMddl_Fix_Stp(time)\tResp_strt(time)\tResp_stp(time)\tMvmnt_feedback(time)\n');
    selected_number = [];
    %     Trial_Loc = 1;
    %     Trial_Loc = max(1, Trial_Loc);
    elapsedtime_Loc = nan(1,100);
    Endtime_point_Loc =  zeros (1,200);
    x_mouse = [];
    y_mouse = [];


    for Trial_Loc = 1: params.n_Trials_loc
        
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Localization Block %02d Trial %03d Starts"', Block ,Trial_Loc));
        end
        
        Loc_StartTime_Trial = GetSecs();
        XYPoints_Loc_Hand = [];
        %         TimeEvents_Loc(Block).t(Trial_Loc)
        
        %         tSum_Loc(Trial_Loc).mvnt_startRecord = [];
        starttime_point_Loc = [];
        Movement_dis_Loc = [];
        EndPosition_Loc = [];
        trialstatus = [];
        XYGaze_Loc = [];
        Trial_Loc;
        button = false
        %check if mouse is pressed and wait until it is released.
        CheckIfMouseIsReleased;
        %%%%% =========================================================================
        %        ++++++++++++++++++++ first 15s fixation +++++++++++++++++++++++++++++++++++++++
        %           Draw a white dot in the middle of the screen to concentrate on
        % display in command window
        fprintf([ sprintf( '* Localization/ Block %02d Trial %02d Initial fixation phase starts ...', Block, Trial_Loc) '\n'])
        
        Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
        %         Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.grey, [], 2);
        
        TimeEvents_Loc(Block).t(Trial_Loc).fix_start = Screen('Flip',window);
        Screen('TextSize', window, params.textsize);
       
        while  GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).fix_start <= params.fixdur_loc && ~exitDemo % 15s fixartion
            [x_mouse, y_mouse, buttons] = GetMouse(window);
            if GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).fix_start >= params.Tcountdown_Instruction_Loc
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Display Message"', Block));
            end
            
            DrawFormattedText(window,'Move to an arbitrary direction', 'centerblock', 'center', params.white,[],0);
            TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_start = Screen('Flip',window);
            WaitSecs(params.MSG);
            TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_stop = GetSecs;
            TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_Dur = TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_stop - TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_start;
            
            end
            
            

            if GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).fix_start >= params.Tcountdown
                
                DrawFormattedText(window,'3','centerblock', 'center', params.white,[],0);
                Screen('Flip', window);
                WaitSecs(params.countdown_dur);
                % 2
                DrawFormattedText(window,'2', 'centerblock', 'center', params.white,[],0);
                Screen('Flip', window);
                WaitSecs(params.countdown_dur);
                % 1
                DrawFormattedText(window,'1', 'centerblock', 'center', params.white,[],0);
                Screen('Flip', window);
                WaitSecs(params.countdown_dur);
            end
            [pressed, firstpress] = KbQueueCheck();
            exitDemo = checkExit(pressed, firstpress);
        end
       
        SetMouse(params.xCent, params.yCent, window);
        
        TimeEvents_Loc(Block).t(Trial_Loc).fix_stop = GetSecs;
        
        TimeEvents_Loc(Block).t(Trial_Loc).fst_fix_oneset = TimeEvents_Loc(Block).t(Trial_Loc).fix_start - params.Intro;
        TimeEvents_Loc(Block).t(Trial_Loc).fst_fix_dur_all = TimeEvents_Loc(Block).t(Trial_Loc).fix_stop - TimeEvents_Loc(Block).t(Trial_Loc).fix_start
        TimeEvents_Loc(Block).t(Trial_Loc).fst_fix_dur = TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_start - TimeEvents_Loc(Block).t(Trial_Loc).fix_start
        % save Oneset and duration of MSG+3+2+1
        TimeEvents_Loc(Block).t(Trial_Loc).instrc_Tminus_Onset = TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_start - params.Intro
        TimeEvents_Loc(Block).t(Trial_Loc).instrc_Duration = TimeEvents_Loc(Block).t(Trial_Loc).fix_stop - TimeEvents_Loc(Block).t(Trial_Loc).Event_instruc_start
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Loc Trial %02d Stop Countdown/Stop Rest"', Block,Trial_Loc));
        end
        
        % display in command window
        fprintf([ sprintf( '* Localization/ Block %02d Trial %02d Initial fixation phase stops ...', Block, Trial_Loc) '\n'])
        
        Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
        TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start = Screen('Flip',window);
        TimeEvents_Loc(Block).t(Trial_Loc).mvmnt_phase_Onset = TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start - params.Intro
   
        if eye_Tracker
            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Loc Trial %02d start position appears.. Movement Phase "', Block, Trial_Loc));
        end
        while  (GetSecs- TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start) <= params.trial_mvmntdur_loc
            
            while button == false && (GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start) <= params.trial_mvmntdur_loc
                  
                [x_mouse, y_mouse, buttons] = GetMouse(window); % get mouse data
                M_dis1_loc = sqrt((x_mouse-params.xCent)^2 + (y_mouse-params.yCent)^2);
                
                if buttons(1)
%                     starttime_Loc = GetSecs();
%                     XYPoints_Loc_Hand = vertcat(XYPoints_Loc_Hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) 0]);
                    button = true
                    break;
                end
            end
%             %            %%% =========================================================================
            [cursorShow] = CheckIfMouseIsClosetoCenter(M_dis1_loc,params,window,x_mouse,y_mouse,cursorShow);
%             %            %%% =========================================================================
%             % While button is pressed and cursor is in searching mode
            while cursorShow == true && (GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start) <= params.trial_mvmntdur_loc
                [x_mouse, y_mouse, buttons] = GetMouse(window);
                %distance vector from center
                M_dis_Loc = sqrt((x_mouse-params.xCent)^2 + (y_mouse-params.yCent)^2);
                Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                Screen('DrawDots', window, [x_mouse y_mouse], params.cursorsize, params.white, [], 2);
%                 
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial_loc %02d cursor in searching phase "', Block, Trial_Loc));
                end
%                 
                if M_dis_Loc < params.fixdotsize
                    starttime_Loc = GetSecs();
                    cursorShow = false;
                    XYPoints_Loc_Hand = vertcat(XYPoints_Loc_Hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) 0]);
                    break;
                end
                Screen('Flip',window);
            end
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial_loc %02d cursor in starting position "', Block, Trial_Loc));
            end
            
            
            while  cursorShow == false && (GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start) <= params.trial_mvmntdur_loc
                
                [x_mouse, y_mouse, buttons] = GetMouse(window);
                if ~isempty(starttime_Loc)
                    time_Loc = GetSecs()-starttime_Loc;
                else
                    time_Loc = GetSecs();
                end
                if  ~buttons(1) && time_Loc >= 0.5
                    %                     disp('disconnection is too long')
                    break
                end
%                 %
                
%             while button==true && GetSecs()- TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start <= params.trial_mvmntdur_loc
%                 [x_mouse, y_mouse, buttons] = GetMouse(window);
%                 time_Loc = GetSecs()-starttime_Loc;
%                 
%                 if ~buttons(1) && time_Loc >= 0.5;
%                     disp('disconnection is too long');
%                     break
%                 end
%                 
%                 
                % calculate distance from center
                XYPoints_Loc_Hand = vertcat(XYPoints_Loc_Hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) time_Loc]);
                
                Movement_dis_Loc = sqrt((x_mouse-params.xCent)^2 + (y_mouse-params.yCent)^2); %XYPoints_PreAdap_Loc= movement distance
                
                relPos = [(x_mouse-params.xCent); (-y_mouse+params.yCent)];
                % Turn the fixation point green if the mouse is within
                % accepted area
                if Movement_dis_Loc < params.fixdotsize
                    Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.green, [], 2);
                    starttime_point_Loc = time_Loc;
                    TimeEvents_Loc(Block).t(Trial_Loc).mvnt_startRecord = GetSecs;
                else
                    Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                end
                
                Screen('Flip',window);
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Loc Trial %02d Movement Initiation "', Block, Trial_Target));
                end
                %calculate end point movement to store for analysis
                if Movement_dis_Loc > params.gradedcircle
                    
                    TimeEvents_Loc(Block).t(Trial_Loc).Mvmnt_End = GetSecs;
                    Endtime_point_Loc(1,Trial_Loc) = time_Loc;
                    
                    if ~isempty(TimeEvents_Loc(Block).t(Trial_Loc).mvnt_startRecord)
                        elapsedtime_Loc(1,Trial_Loc) = GetSecs()- TimeEvents_Loc(Block).t(Trial_Loc).mvnt_startRecord;
                    end
                                       
                    % Compute ending angle
                    EndAngle_Loc = atan2(relPos(2),relPos(1));
                    x_endAngle_Loc = params.gradedcircle * cos(EndAngle_Loc);
                    y_endAngle_Loc = params.gradedcircle * sin(EndAngle_Loc);
                    
                    EndPosition_Loc = [x_endAngle_Loc+params.xCent; -y_endAngle_Loc+params.yCent];
                    dotCenter = [0 0];
                    TimeEvents_Loc(Block).t(Trial_Loc).Mvmnt_Duration = TimeEvents_Loc(Block).t(Trial_Loc).Mvmnt_End - TimeEvents_Loc(Block).t(Trial_Loc).mvnt_startRecord;
                    
                    if eye_Tracker
                        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement ends "', Block, Trial_Loc));
                    end
                    
                    break;
                end
                %                     if ~isempty(time_Loc(Trial_Loc).mvnt_startRecord)
                %                         elapsedtime_Loc(1,Trial_Loc) = GetSecs()- time_Loc(Trial_Loc).mvnt_startRecord
                %                     end
                
            end
            %
            %
            %             if  (GetSecs - TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start) <= params.trial_mvmntdur_loc
            %                 Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
            %                 Screen('Flip',window);
            %             elseif (GetSecs()- TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start) == params.trial_mvmntdur_loc
            %                 break;
            %             end
            break;
        end
        
        Screen('TextSize', window, params.textsize)
        
        %%% =========================================================================
        % ++++++++++++++++++++++++++++++ Feedback Phase ++++++++++++++++++++++
        if Movement_dis_Loc < params.gradedcircle

            TimeEvents_Loc(Block).t(Trial_Loc).Mvmnt_End_UnderShoot = GetSecs;
            UndershootEndPoint_Loc = [x_mouse y_mouse];
            dotCenter = [0 0];
            Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
            DrawFormattedText(window, 'failed',  params.xCent-150, params.yCent - 50, params.white,[],0);
            trialstatus = -1
            %save data
            %save data in each trial separately
            % Names_Loc = {'SL';'SN';'Block';'Trial_num';'Status';'Points';'ShootEndPoint';'EndAngle';'Elapsedtime';'starttimePoint';'EndTimePoint';'Numbers'};
            if ~isempty(starttime_point_Loc)
                T_tmp_Loc = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Loc, trialstatus, {XYPoints_Loc_Hand}, {UndershootEndPoint_Loc'},NaN,NaN,starttime_point_Loc,NaN,{NaN},NaN)
            else
                T_tmp_Loc = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Loc, trialstatus, {XYPoints_Loc_Hand}, {UndershootEndPoint_Loc'},NaN,NaN,NaN,NaN,{NaN},NaN)
            end
            
            T_tmp_Loc.Properties.VariableNames = Names_Loc;
            T_Loc = [T_Loc ; T_tmp_Loc]
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Loc Trial %02d Failed Movement"', Block, Trial_Loc));
            end
        elseif ~isempty(EndPosition_Loc) && elapsedtime_Loc(1,Trial_Loc) < params.mvmnt_time
            %             Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
            trialstatus = 1;
            
            CheckIfMouseIsReleased;
            Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
            %  Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.grey, [], 2);
            TimeEvents_Loc(Block).t(Trial_Loc).fix_start_middle = Screen('Flip',window);
            TimeEvents_Loc(Block).t(Trial_Loc).fix_middle_Onset =  TimeEvents_Loc(Block).t(Trial_Loc).fix_start_middle - params.Intro    
    
    
            fprintf([ sprintf( '* Localization/ Block %02d Trial %02d Second fixation phase starts...', Block, Trial_Loc) '\n'])
                                         
            while GetSecs()-TimeEvents_Loc(Block).t(Trial_Loc).fix_start_middle <= params.fixdur_loc %15s
             [x_mouse, y_mouse, buttons] = GetMouse(window);   
            end
            
            TimeEvents_Loc(Block).t(Trial_Loc).fix_stop_middle = GetSecs;
            fprintf([ sprintf( ['* Localization/ Block %02d Trial %02d Second fixation time has just finished..duration..=' num2str(GetSecs()-TimeEvents_Loc(Block).t(Trial_Loc).fix_start_middle)], Block, Trial_Loc) '\n'])

            % disp (['second fixation time has just finished...duration = ' num2str(GetSecs()-TimeEvents_Loc(Block).t(Trial_Loc).fix_start_middle)])
            % call gradedcircle function to make gradedcircle with random
            % numbers % response time = 3s
            disp ('response phase...')
            Screen('TextSize', window, params.textsize)
            
            %             [random_numbers,XX,YY,value]= gradedcircle (params, window,params.yCent, params.xCent);
            
            % Recording audio from subjects
            [random_numbers,XX,YY,value,selected_number,TimeEvents_Loc(Block).t(Trial_Loc).response_start,TimeEvents_Loc(Block).t(Trial_Loc).response_stop]= gradedcircle(params, window,params.yCent, params.xCent);
            %             [TimeEvents_Loc(Block).t(Trial_Loc).response_start,TimeEvents_Loc(Block).t(Trial_Loc).response_stop,Trial_Loc] = recordReportedNumber (Block,params,window,Trial_Loc,params.xCent,params.yCent,save_dir,filename);
            TimeEvents_Loc(Block).t(Trial_Loc).response_Onset = TimeEvents_Loc(Block).t(Trial_Loc).response_start - params.Intro
            if ~isempty(starttime_point_Loc)
                T_tmp_Loc = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Loc, trialstatus, {XYPoints_Loc_Hand}, {[x_endAngle_Loc y_endAngle_Loc]'},EndAngle_Loc,elapsedtime_Loc(1,Trial_Loc),starttime_point_Loc,Endtime_point_Loc(1,Trial_Loc),{value},selected_number);
            else
                T_tmp_Loc = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Loc, trialstatus, {XYPoints_Loc_Hand}, {[x_endAngle_Loc y_endAngle_Loc]'},EndAngle_Loc,elapsedtime_Loc(1,Trial_Loc),NaN,Endtime_point_Loc(1,Trial_Loc),{value},NaN);
            end
            
            T_tmp_Loc.Properties.VariableNames = Names_Loc;
            T_Loc = [T_Loc ; T_tmp_Loc]
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Loc Trial %02d Accepted Movement"', Block, Trial_Loc));
            end
        elseif ~isempty(EndPosition_Loc) && elapsedtime_Loc(1,Trial_Loc) > params.mvmnt_time
            DrawFormattedText(window, 'Too slow.. faster please', params.xCent-100, params.yCent, params.white,[],0);
            trialstatus = 0;
            %             Names_Loc = {'SL';'SN';'Block';'Trial_num';'Status';'Points';'ShootEndPoint';'EndAngle';'Elapsedtime';'starttimePoint';'EndTimePoint'};
            if ~isempty(starttime_point_Loc)
                T_tmp_Loc = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Loc, trialstatus, {XYPoints_Loc_Hand}, {[x_endAngle_Loc y_endAngle_Loc]'},EndAngle_Loc,elapsedtime_Loc(1,Trial_Loc),starttime_point_Loc,Endtime_point_Loc(1,Trial_Loc),{NaN},NaN)
            else
                T_tmp_Loc = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Loc, trialstatus, {XYPoints_Loc_Hand}, {[x_endAngle_Loc y_endAngle_Loc]'},EndAngle_Loc,elapsedtime_Loc(1,Trial_Loc),NaN,Endtime_point_Loc(1,Trial_Loc),{NaN},NaN)
            end
            T_tmp_Loc.Properties.VariableNames = Names_Loc;
            T_Loc = [T_Loc ; T_tmp_Loc]
        end
                                    
        TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Start = Screen('Flip',window);
        
        while GetSecs()- TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Start <= params.feedbacktime
            
        end
        
        TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Stop = GetSecs;
        if trialstatus == -1
            fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%d\t%d\t%d\t%d\t%.4f\n',Block,Trial_Loc,TimeEvents_Loc(Block).t(Trial_Loc).fix_start,TimeEvents_Loc(Block).t(Trial_Loc).fix_stop,TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start,-1,-1,-1,-1,TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Start);
        elseif trialstatus == 1
            fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',Block,Trial_Loc,TimeEvents_Loc(Block).t(Trial_Loc).fix_start,TimeEvents_Loc(Block).t(Trial_Loc).fix_stop,TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start,TimeEvents_Loc(Block).t(Trial_Loc).fix_start_middle,TimeEvents_Loc(Block).t(Trial_Loc).fix_stop_middle,TimeEvents_Loc(Block).t(Trial_Loc).response_start,TimeEvents_Loc(Block).t(Trial_Loc).response_stop,TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Start);
            
        elseif trialstatus == 0
            fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%d\t%d\t%d\t%d\t%.4f\n',Block,Trial_Loc,TimeEvents_Loc(Block).t(Trial_Loc).fix_start,TimeEvents_Loc(Block).t(Trial_Loc).fix_stop,TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start,0,0,0,0,TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Start);
            
        elseif isempty(trialstatus) % when movement is missed
            fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%d\t%d\t%d\t%d\t%.4f\n',Block,Trial_Loc,TimeEvents_Loc(Block).t(Trial_Loc).fix_start,TimeEvents_Loc(Block).t(Trial_Loc).fix_stop,TimeEvents_Loc(Block).t(Trial_Loc).mvnt_phase_start,2,2,2,2,TimeEvents_Loc(Block).t(Trial_Loc).Feedback_Start);
        end
        
        TimeEvents_Loc(Block).t(Trial_Loc).Trial_Loc =Trial_Loc;
        TimeEvents_Loc(Block).t(Trial_Loc).Block = Block;
        TimeEvents_Loc(Block).t(Trial_Loc).trialStatus = trialstatus;
        
        
        %
        SetMouse(params.xCent, params.yCent, window);
        
        save(strcat(save_dir, filename,'_Loc.mat'), 'T_Loc','TimeEvents_Loc')
        
    end
    %%
    
    %%
    Block = Block+1;
    
    if Block == params.Block_runPause  % 2mins pause between two runs
        Screen('TextSize', window, params.textsize_counter)
        tic
        Seconds_order = [params.RestTime:-1:1];
        for i = 1: length(Seconds_order)
            String_number = num2str(Seconds_order(i));
            DrawFormattedText(window, String_number, params.xCent, params.yCent, params.white,[],0);
            Screen('Flip', window);
            WaitSecs(1);
        end
        toc
        if fMRI
            Screen('TextSize', window, params.textsize)
            text_scanner ='Break time is over.We will start soon.\n Please wait for the scanner to trigger';
            DrawFormattedText(window,text_scanner ,...
                'center', params.yCent, params.white,[],0);
            Screen('Flip', window);
            
            while ( ~params.Block_runPause_status && ~exitDemo)
                [pressed, firstpress] = KbQueueCheck();
                
                if firstpress (KbName('SPACE'))
                    params.Block_runPause_status = true;
                end
                exitDemo = checkExit(pressed, firstpress);
            end
            
            params.trigger_T = wait_scanner_trigger(window, text_scanner);
            params.trigger_T_SecondRun = params.trigger_T;
        end
    end
    [pressed, firstpress] = KbQueueCheck();
    exitDemo = checkExit(pressed, firstpress);
end

save(strcat(save_dir, filename,'_params.mat'), 'params')
if eye_Tracker
    vpx_SendCommandString( 'dataFile_Close');
    % end VPX properly
    vpx_Unload;
end
Screen('CloseAll')
