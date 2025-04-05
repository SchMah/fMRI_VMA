function fMRI_reach_localizer (subjectGroup, subjectNumber, fMRI, eye_Tracker,ScreenName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Screen parameters
% Using PsychImaging to flip the image horizontally for Optostim monitor
%%% =========================================================================
% %%%%%%%%%%%%%%        Shirin       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%  Written : Dec. 2022 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%  _______        _______         _____
% |       |      |        |      |     |
% | R(VF) |_rest_| R(nVF) |_rest_| Eye |_....
% Reach with VF ; Reach wiithout VF ; Reach observation
%%% =========================================================================
%% Functions called in 999this script
% ArringtonCalibration.m
% BlockDescription.m
% Targetside.m
% VisualFB_Matrix.M
% wait_scanner_trigger.m
% KbQueueCheck.m
% checkExit.m
% CheckIfMouseIsClosetoCenter.m
% deg2pix.m
% CheckIfMouseIsReleased.m
% gradedcircle.m

%%% =========================================================================
%% Initialize window , screen properties
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'VisualDebugLevel', 1);
PsychImaging('PrepareConfiguration');
%%% =========================================================================
% %% Keyboard Setup
% KbName('UnifyKeyNames');
% keyslist=zeros(1,256);
% keyslist(KbName({'SPACE','ESCAPE', 'RETURN','9('}))= 1; %'4$','3#','2@'
% KbQueueCreate([], keyslist);
% KbQueueStart;
%%% =========================================================================
%% load parameters
getparameters;
[L_1] = BlockDescription('English');
[~,params.targetposition,~,~] = Targetside('Right');
%%# =========================================================================
%% Create logfile / folder to save data
% open a logfile
LogFile = fopen(['fMRI_Reach_' subjectGroup num2str(subjectNumber) '_' 'log' '.txt'],'a');
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
% Reach with Visual Feedback
T_Reach_VF = table;
Names = {'SL';'SN';'Block';'Trial_num';'Status';'Points';'ShootEndPoint';'EndAngle';'TargetPosition';'Elapsedtime';'starttimePoint';'EndTimePoint';'Block_seq'};
% % Reach without Visual Feedback
% T_Reach_nVF = table;
% Names_nVF = {'SL';'SN';'Block';'Trial_num';'Status';'Points';'ShootEndPoint';'EndAngle';'Elapsedtime';'starttimePoint';'EndTimePoint';'Numbers';'response_Number'};

%Reach Observation
T_Reach_Obs = table;
Names_Obs = {'SL';'SN';'Block';'Trial_num';'Points';'TargetPosition';'Traj_ElapsedTime';'Block_seq'};

% output structure to store summary of time events
%for training phase
Reach_Localizer_TimeEvents.t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
    [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]);

% % Localization trials
% Reach_nVF_TimeEvents.t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
%     [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]);
%
% Reach_Obs_TimeEvents.t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
%     [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]); %observation

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

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
params.ifi= Screen('GetFlipInterval', window);
% font size
% Screen('TextSize',window,params.textsize);
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
    DrawFormattedText(window,dspl_text , 'centerblock', 'center', params.white,[],0);
    
else
    
    dspl_text = ' Please wait ... The Experiment is about to begin .. ';
    DrawFormattedText(window,dspl_text , 'centerblock', 'center', params.white,[],0);
end
WaitSecs(0.5)
Screen('Flip', window);

%%%% Calibrate Eye tracker
if eye_Tracker
    ArringtonCalibration(params.ScreenNumber)
    vpx_SendCommandString( sprintf('dataFile_NewName %sn',filename));
end
%% Keyboard Setup
KbName('UnifyKeyNames');
keyslist=zeros(1,256);
keyslist(KbName({'SPACE','ESCAPE', 'RETURN','9('}))= 1; %'4$','3#','2@'
KbQueueCreate([], keyslist);
KbQueueStart;
%%% =========================================================================
%%%%% =========================================================================
%%
% Target position 45°
params.tXpos = params.gradedcircle * cos(params.targetposition) + params.xCent;
params.tYpos = params.gradedcircle * sin(params.targetposition) + params.yCent;
%%% =========================================================================
% determine the number of time points to draw a moving trajectory in allocated movement time
% period
params.numberofPoints = params.mvmnt_time/(params.ifi)
params.Xseg = linspace(params.xCent,params.tXpos,floor(params.numberofPoints));
params.Yseg = linspace(params.yCent,params.tYpos,floor(params.numberofPoints));

%% Define the sequence of blocks randomly
params.conditions = 1:3 % 1 Mov with VF; 2 Mov without VF ; 3 EyeMov
params.repetition = [5 6 6]; % 5 6 6
params.Block_seq = [repelem(params.conditions, params. repetition)]
params.Block_seq_tmp = [1 params.Block_seq(randperm(numel(params.Block_seq)))] % shuffle the order of blocks
while ~isempty(strfind(diff(params.Block_seq_tmp(2:end)), [0]))  %diff(out) will have at least two consecutive 0 if there are 3 or more identical consecutive numbers
    params.Block_seq_tmp = [1 params.Block_seq(randperm(numel(params.Block_seq)))]  %try again
end
params.Block_seq = params.Block_seq_tmp;
%% Display discription for Training
exitDemo = false;
% In order to have all blocks in one program, differet steps are defined
params.INSTRUCTION1 = false;
disp( 'Description for Block');
Screen('TextSize',window,params.textsize_dscrptn)
DrawFormattedText(window, sprintf('%s\n\n',L_1{:}),  'center',params.yCent * 0.5, params.white,[],0)
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
    text_scanner ='Please wait for the scanner to trigger';
    DrawFormattedText(window,text_scanner ,...
        'center', params.yCent, params.white,[],0);
    Screen('Flip', window);
    params.trigger_T = wait_scanner_trigger(window, text_scanner);
end
%%% =========================================================================
Block = 1
while Block <= params.n_blcks_reach_localizer && ~exitDemo
    Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
    Reach_Localizer_TimeEvents(Block).rest_start = Screen('Flip',window); % beginning of rest
    if fMRI
        params.Intro = params.trigger_T
    else
        params.Intro = Reach_Localizer_TimeEvents(1).rest_start
    end
    
    if eye_Tracker
        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Rest Block starts"', Block));
    end
    
    Screen('TextSize', window, params.textsize)
    
    while  GetSecs - Reach_Localizer_TimeEvents(Block).rest_start <= params.rest && ~exitDemo % 15s fixartion
       [x_mouse, y_mouse, buttons] = GetMouse(window);
        if GetSecs - Reach_Localizer_TimeEvents(Block).rest_start >= params.Tcountdown_Instruction
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Display Message"', Block));
            end
            switch params.Block_seq(Block)
                case 1
                    DrawFormattedText(window,'Move the Cursor to the target', 'centerblock', 'center', params.white,[],0);
                    Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start = Screen('Flip',window);
                    WaitSecs(params.MSG)
                    Reach_Localizer_TimeEvents(Block).IntialMSG_stop = GetSecs;
                    Reach_Localizer_TimeEvents(Block).IntialMSG_Duration = Reach_Localizer_TimeEvents(Block).IntialMSG_stop - Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start;
                    
                case 2
                    DrawFormattedText(window,'Movement without visual Feedback', 'centerblock', 'center', params.white,[],0);
                    Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start = Screen('Flip',window);
                    WaitSecs(params.MSG)
                    Reach_Localizer_TimeEvents(Block).IntialMSG_stop = GetSecs;
                    Reach_Localizer_TimeEvents(Block).IntialMSG_Duration = Reach_Localizer_TimeEvents(Block).IntialMSG_stop - Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start;
                    
                case 3
                    DrawFormattedText(window,'Follow the dots with eyes', 'centerblock', 'center', params.white,[],0);
                    Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start = Screen('Flip',window);
                    WaitSecs(params.MSG)
                    Reach_Localizer_TimeEvents(Block).IntialMSG_stop = GetSecs;
                    Reach_Localizer_TimeEvents(Block).IntialMSG_Duration = Reach_Localizer_TimeEvents(Block).IntialMSG_stop - Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start;
            end
        end
        
        if GetSecs - Reach_Localizer_TimeEvents(Block).rest_start >= params.Tcountdown_rest
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Start countdown"', Block));
            end
            Screen('TextSize', window, params.textsize_counter)
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
    Reach_Localizer_TimeEvents(Block).rest_stop = GetSecs;  % end of rest block
    Reach_Localizer_TimeEvents(Block).rest_oneset = Reach_Localizer_TimeEvents(Block).rest_start - params.Intro;
    Reach_Localizer_TimeEvents(Block).rest_duration_all = Reach_Localizer_TimeEvents(Block).rest_stop - Reach_Localizer_TimeEvents(Block).rest_start
    Reach_Localizer_TimeEvents(Block).rest_duration = Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start - Reach_Localizer_TimeEvents(Block).rest_start
    % save Oneset and duration of MSG+3+2+1
    Reach_Localizer_TimeEvents(Block).MSG_TMinus_Onset = Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start - params.Intro
    Reach_Localizer_TimeEvents(Block).MSG_TMinus_Duration = Reach_Localizer_TimeEvents(Block).rest_stop - Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start
    Reach_Localizer_TimeEvents(Block).Block_seq = params.Block_seq(Block);
    if eye_Tracker
        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Stop Countdown/Stop Rest"', Block));
    end
    if params.Block_seq(Block) == 1
        %         Movement with VF
        
        Screen('TextSize', window, params.textsize)
        fprintf(LogFile,'block\tTrial\tInitial_Fixation(time)\tDspl_target(time)\tfeedback_startTime\tfeedback_stopTime)\n');
        elapsedtime_T = nan (1,100);
        Endtime_point_Training =  zeros (1,100);
        
        Reach_Localizer_TimeEvents(Block).t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
            [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]);
        for Trial_Target = 1: params.n_Trials_blck
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start"', Block, Trial_Target));
            end
            
            Fam_StartTime_Trial = GetSecs();
            XYPoints_hand = [];
            starttime_withVF = [];
            starttime_point_withVF = [];
            EndPosition_withVF = [];
            M_dis = [];
            M_dis1=[];
            r_rot = [];
            trialstatus = [];
            Trial_Target
            cursorShow = false ;
            CheckIfMouseIsReleased;
            
            % Draw a white cross in the middle of the screen as fixation
            Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Central plus sign appears "', Block, Trial_Target));
            end
            
            SetMouse(params.xCent, params.yCent, window);
            
            %wait for 500ms in fixation phase until target appears
            while GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start <= params.fix %500ms
            end
            
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Stop = GetSecs;
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of Central plus sign, start point appears"', Block, Trial_Target));
            end
            
            % target appears after 500ms and allows subject to initiate movement
            Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
            Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Target appears.. Movement Phase "', Block, Trial_Target));
            end
            
            % movement phase for 3 seconds
            while (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur && ~exitDemo
                
                %%% =========================================================================
                %%%% Wait for the mouse %%%%
                while true && (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur
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
                while cursorShow == true && (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur
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
                        starttime_withVF = GetSecs();
                        cursorShow = false;
                        XYPoints_hand = vertcat(XYPoints_hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) 0]);
                        break;
                    end
                    Screen('Flip',window);
                end
                
                % XYPoints_hand = vertcat(XYPoints_hand, [(x_mouse-params.xCent) (-y_mouse+params.yCent) 0]);
                
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d cursor in starting position "', Block, Trial_Target));
                end
                %%% =========================================================================
                % when cursor is in starting position
                while  cursorShow == false && (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur %&& M_dis <= params.gradedcircle
                    
                    [x_mouse, y_mouse, buttons] = GetMouse(window);
                    if ~isempty(starttime_withVF)
                        time_Fam = GetSecs()-starttime_withVF;
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
                    
                    % rotation amount 0
                    r_rot = [(x_mouse-params.xCent); (-y_mouse+params.yCent)];
                    
                    if M_dis < params.fixdotsize
                        Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.green, [], 2);
                        Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start = GetSecs; % Movement Starts
                        starttime_point_withVF = time_Fam;
                    else
                        Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                    end
                    
                    if eye_Tracker
                        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement Initiation "', Block, Trial_Target));
                    end
                    
                    Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                    
                    % Draw the dot that represents the cursor
                    if M_dis <= params.gradedcircle
                        Screen('DrawDots', window, [r_rot(1)+params.xCent -r_rot(2)+params.yCent], params.cursorsize, params.white,[], 2);  % actual cursor as green dot
                    end
                    %%% =========================================================================
                    % constraint movement to the boundary - End of Movement
                    if M_dis >= params.gradedcircle;
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_End = GetSecs();
                        Endtime_point_Training(1,Trial_Target) = time_Fam;
                        %Screen('DrawDots', window, [tXpos tYpos], params.Rtarget, params.white, [], 2);
                        if ~isempty(Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start)
                            elapsedtime_T(1,Trial_Target)= GetSecs()- Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start;
                        end
                        % % Compute angle
                        
                        %the reason for using relPos is that we need angle
                        %relative to center, however the actual mouse position
                        %is relative to 0,0 of screen which is upper left side.
                        
                        angle_hand = atan2(relPos(2),relPos(1));
                        x_endAngle_hand = params.gradedcircle * cos(angle_hand);
                        y_endAngle_hand = params.gradedcircle * sin(angle_hand);
                        EndPosition_withVF = [x_endAngle_hand+params.xCent; -y_endAngle_hand+params.yCent];
                        
                        % for  FB
                        Endangle_FB = atan2(r_rot(2),r_rot(1));
                        x_endAngle_FB = params.gradedcircle * cos(Endangle_FB);
                        y_endAngle_FB = params.gradedcircle * sin(Endangle_FB);
                        EndPosition_FB = [x_endAngle_FB+params.xCent; -y_endAngle_FB+params.yCent];
                        
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Duration = Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_End - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start;
                        dotCenter = [0 0];
                        
                        if eye_Tracker
                            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement ends "', Block, Trial_Target));
                        end
                        
                        break;
                    end
                    
                    Screen('Flip',window);
                    
                end
                break;
                
                [pressed, firstpress] = KbQueueCheck();
                exitDemo = checkExit(pressed, firstpress);
                
            end
            %%% =========================================================================
            % ++++++++++++++++++++++++++++++ Feedback Phase ++++++++++++++++++++++
            %    completed - acceptatble   :  blue dot corresponding to end point of movement
            %    completed - unacceptable  :  urge to do faster
            %    uncompleted - unacceptable : failed movement
            
            if M_dis < params.gradedcircle
                Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_End_UnderShoot = GetSecs;
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
                %             starttime_point_withVF
                
                if ~isempty(starttime_point_withVF)
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {UndershootEndPoint'},NaN,{[params.tXpos; params.tYpos]},NaN,starttime_point_withVF,NaN,params.Block_seq(Block))
                else
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {UndershootEndPoint'},NaN,{[params.tXpos; params.tYpos]},NaN,NaN,NaN,params.Block_seq(Block))
                    
                end
                T_tmp.Properties.VariableNames = Names;
                T_Reach_VF = [T_Reach_VF ; T_tmp];
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Failed Movement"', Block, Trial_Target));
                end
            elseif ~isempty(EndPosition_withVF) && elapsedtime_T(1,Trial_Target) < params.mvmnt_time %&& Block <= params.baselineBlocks% 0.5 s
                Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                Screen('DrawDots', window, EndPosition_FB, params.cursorsize, params.aqua, dotCenter, 2);
                
                trialstatus = 1;
                if ~isempty(starttime_point_withVF)
                    
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),starttime_point_withVF,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block));
                else
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),NaN,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block));
                end
                
                T_tmp.Properties.VariableNames = Names;
                T_Reach_VF = [T_Reach_VF ; T_tmp]
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Accepted Movement"', Block, Trial_Target));
                end
            elseif ~isempty(EndPosition_withVF) && elapsedtime_T(1,Trial_Target) > params.mvmnt_time
                DrawFormattedText(window, 'Too Slow..faster please', params.xCent-50, params.yCent, params.white,[],0);
                trialstatus = 0
                if ~isempty(starttime_point_withVF)
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),starttime_point_withVF,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block))
                else
                    
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),NaN,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block))
                end
                T_tmp.Properties.VariableNames = Names;
                T_Reach_VF = [T_Reach_VF ; T_tmp]
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Slow/Failed Movement"', Block, Trial_Target));
                end
            end
            
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start = Screen('Flip',window);
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start of Feedback phase"', Block, Trial_Target));
            end
            while GetSecs()- Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start <= params.feedbacktime
                %                 WaitSecs(params.feedbacktime)
            end
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Stop = GetSecs;
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of Feedback phase"', Block, Trial_Target));
            end
            % Write Logfile data
            
            fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%.4f\n',Block,Trial_Target,Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start ,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Stop);
            % assigned necessay variables to time structure
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Trial =  Trial_Target;
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Block = Block;
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).trialStatus = trialstatus;
            
            SetMouse(params.xCent, params.yCent, window);
            %         save(strcat(save_dir, SubjectID),'PreAdap')
            
            [pressed, firstpress] = KbQueueCheck();
            exitDemo = checkExit(pressed, firstpress);
            
            
        end
        Reach_Localizer_TimeEvents(Block).BlockOnset = Reach_Localizer_TimeEvents(Block).t(1).startPoint_Start - params.Intro
        
        Reach_Localizer_TimeEvents(Block).block_duration =  Reach_Localizer_TimeEvents(Block).t(end).Feedback_Stop - Reach_Localizer_TimeEvents(Block).t(1).startPoint_Start
        save(strcat(save_dir, filename,'.mat'), 'T_Reach_VF','T_Reach_Obs','Reach_Localizer_TimeEvents' )
        
    elseif params.Block_seq(Block) == 2
        %         Movement without VF
        Screen('TextSize', window, params.textsize)
        fprintf(LogFile,'block\tTrial\tInitial_Fixation(time)\tDspl_target(time)\tfeedback_startTime\tfeedback_stopTime)\n');
        elapsedtime_T = nan (1,100);
        Endtime_point_Training =  zeros (1,100);
        
        Reach_Localizer_TimeEvents(Block).t = struct('Trial', [], 'Block', [], 'trialStatus', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
            [], 'Mvmnt_Start', [], 'Mvmnt_End',[],'Mvmnt_Duration',[],'Feedback_Start',[],'Feedback_Stop',[]);
        
        for Trial_Target = 1: params.n_Trials_blck
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start"', Block, Trial_Target));
            end
            
            Fam_StartTime_Trial = GetSecs();
            XYPoints_hand = [];
            starttime_withVF = [];
            starttime_point_withVF = [];
            EndPosition_withVF = [];
            M_dis = [];
            M_dis1=[];
            r_rot = [];
            trialstatus = [];
            Trial_Target
            cursorShow = false ;
            CheckIfMouseIsReleased;
            
            % Draw a white cross in the middle of the screen as fixation
            Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Display of central plus sign "', Block, Trial_Target));
            end
            
            SetMouse(params.xCent, params.yCent, window);
            
            %wait for 500ms in fixation phase until target appears
            while GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start <= params.fix %500ms
            end
            
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Stop = GetSecs;
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d  End of Central plus sign, appear start point dot  "', Block, Trial_Target));
            end
            
            % target appears after 500ms and allows subject to initiate movement
            Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
            Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Target appears.. Movement Phase "', Block, Trial_Target));
            end
            
            % movement phase for 3 seconds
            while (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur && ~exitDemo
                
                %%% =========================================================================
                %%%% Wait for the mouse %%%%
                while true && (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur
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
                while cursorShow == true && (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur
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
                        starttime_withVF = GetSecs();
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
                while  cursorShow == false && (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur %&& M_dis <= params.gradedcircle
                    
                    [x_mouse, y_mouse, buttons] = GetMouse(window);
                    if ~isempty(starttime_withVF)
                        time_Fam = GetSecs()-starttime_withVF;
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
                    
                    % rotation amount 0
                    r_rot = [(x_mouse-params.xCent); (-y_mouse+params.yCent)];
                    
                    if M_dis < params.fixdotsize
                        Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.green, [], 2);
                        Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start = GetSecs; % Movement Starts
                        starttime_point_withVF = time_Fam;
                    else
                        Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                    end
                    
                    if eye_Tracker
                        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement Initiation "', Block, Trial_Target));
                    end
                    
                    Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                    
                    % Draw the dot that represents the cursor
                    
                    %%% =========================================================================
                    % constraint movement to the boundary - End of Movement
                    if M_dis >= params.gradedcircle;
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_End = GetSecs();
                        Endtime_point_Training(1,Trial_Target) = time_Fam;
                        %Screen('DrawDots', window, [tXpos tYpos], params.Rtarget, params.white, [], 2);
                        if ~isempty(Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start)
                            elapsedtime_T(1,Trial_Target)= GetSecs()- Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start;
                        end
                        % % Compute angle
                        
                        %the reason for using relPos is that we need angle
                        %relative to center, however the actual mouse position
                        %is relative to 0,0 of screen which is upper left side.
                        
                        angle_hand = atan2(relPos(2),relPos(1));
                        x_endAngle_hand = params.gradedcircle * cos(angle_hand);
                        y_endAngle_hand = params.gradedcircle * sin(angle_hand);
                        EndPosition_withVF = [x_endAngle_hand+params.xCent; -y_endAngle_hand+params.yCent];
                        
                        % for  FB
                        Endangle_FB = atan2(r_rot(2),r_rot(1));
                        x_endAngle_FB = params.gradedcircle * cos(Endangle_FB);
                        y_endAngle_FB = params.gradedcircle * sin(Endangle_FB);
                        EndPosition_FB = [x_endAngle_FB+params.xCent; -y_endAngle_FB+params.yCent];
                        
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Duration = Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_End - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start;
                        dotCenter = [0 0];
                        
                        if eye_Tracker
                            vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Movement ends "', Block, Trial_Target));
                        end
                        
                        break;
                    end
                    
                    Screen('Flip',window);
                    
                end
                break;
                
                [pressed, firstpress] = KbQueueCheck();
                exitDemo = checkExit(pressed, firstpress);
                
            end
            %%% =========================================================================
            % ++++++++++++++++++++++++++++++ Feedback Phase ++++++++++++++++++++++
            %    completed - acceptatble   :  blue dot corresponding to end point of movement
            %    completed - unacceptable  :  urge to do faster
            %    uncompleted - unacceptable : failed movement
            
            if M_dis < params.gradedcircle
                Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_End_UnderShoot = GetSecs;
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
                %             starttime_point_withVF
                
                if ~isempty(starttime_point_withVF)
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {UndershootEndPoint'},NaN,{[params.tXpos; params.tYpos]},NaN,starttime_point_withVF,NaN,params.Block_seq(Block))
                else
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {UndershootEndPoint'},NaN,{[params.tXpos; params.tYpos]},NaN,NaN,NaN,params.Block_seq(Block))
                    
                end
                T_tmp.Properties.VariableNames = Names;
                T_Reach_VF = [T_Reach_VF ; T_tmp];
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Failed Movement"', Block, Trial_Target));
                end
            elseif ~isempty(EndPosition_withVF) && elapsedtime_T(1,Trial_Target) < params.mvmnt_time %&& Block <= params.baselineBlocks% 0.5 s
                Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                Screen('DrawDots', window, EndPosition_FB, params.cursorsize, params.aqua, dotCenter, 2);
                trialstatus = 1;
                if ~isempty(starttime_point_withVF)
                    
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),starttime_point_withVF,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block));
                else
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),NaN,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block));
                end
                
                T_tmp.Properties.VariableNames = Names;
                T_Reach_VF = [T_Reach_VF ; T_tmp]
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Accepted Movement"', Block, Trial_Target));
                end
            elseif ~isempty(EndPosition_withVF) && elapsedtime_T(1,Trial_Target) > params.mvmnt_time
                DrawFormattedText(window, 'Too Slow..faster please', params.xCent-50, params.yCent, params.white,[],0);
                trialstatus = 0
                if ~isempty(starttime_point_withVF)
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),starttime_point_withVF,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block))
                else
                    
                    T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, trialstatus, {XYPoints_hand}, {[x_endAngle_hand y_endAngle_hand]'},angle_hand,{[params.tXpos; params.tYpos]},elapsedtime_T(1,Trial_Target),NaN,Endtime_point_Training(1,Trial_Target),params.Block_seq(Block))
                end
                T_tmp.Properties.VariableNames = Names;
                T_Reach_VF = [T_Reach_VF ; T_tmp]
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Slow/Failed Movement"', Block, Trial_Target));
                end
            end
            
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start of Feedback phase"', Block, Trial_Target));
            end
            while GetSecs()- Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start <= params.feedbacktime
                %                 WaitSecs(params.feedbacktime)
            end
            
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Stop = GetSecs;
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of Feedback phase"', Block, Trial_Target));
            end
            % Write Logfile data
            fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%.4f\n',Block,Trial_Target,Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start ,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Stop);
            % assigned necessay variables to time structure
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Trial =  Trial_Target;
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Block = Block;
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).trialStatus = trialstatus;
            
            SetMouse(params.xCent, params.yCent, window);
            %         save(strcat(save_dir, SubjectID),'PreAdap')
            [pressed, firstpress] = KbQueueCheck();
            exitDemo = checkExit(pressed, firstpress);
            
            
        end
        Reach_Localizer_TimeEvents(Block).BlockOnset = Reach_Localizer_TimeEvents(Block).t(1).startPoint_Start - params.Intro
        
        Reach_Localizer_TimeEvents(Block).block_duration =  Reach_Localizer_TimeEvents(Block).t(end).Feedback_Stop - Reach_Localizer_TimeEvents(Block).t(1).startPoint_Start
        save(strcat(save_dir, filename,'.mat'), 'T_Reach_VF','T_Reach_Obs','Reach_Localizer_TimeEvents' )
        
        
    elseif params.Block_seq(Block) == 3
        %         only Eye trajectory
        Screen('TextSize', window, params.textsize)
        fprintf(LogFile,'block\tTrial\tInitial_Fixation(time)\tDspl_target(time)\tfeedback_startTime\tfeedback_stopTime)\n');
        load(strcat(save_dir, filename,'.mat'), 'T_Reach_VF')
        if exist('T_Reach_VF.Block_seq','var') && sum(T_Reach_VF.Block_seq == 1) >= 15
            if sum(sum(T_Reach_VF.Block_seq == 1 & T_Reach_VF.Status==1)) > params.n_Trials_blck % 15
                Points_tmp = T_Reach_VF.Points(T_Reach_VF.Block_seq == 1 & T_Reach_VF.Status==1)  % Extract movements with trial status ==1 and from Blocks with visual feedback
                Points = Points_tmp(randperm(params.n_Trials_blck))
            elseif sum(sum(T_Reach_VF.Block_seq == 1 & T_Reach_VF.Status==1)) <= params.n_Trials_blck % in case of many failed trials that a set of 15 succeccfull trials cannot be selected
                Points_tmp = T_Reach_VF.Points(T_Reach_VF.Block_seq == 1) %
                Points = Points_tmp(randperm(params.n_Trials_blck)) % shuffle among succ/failed trials
            end
        elseif ~exist('T_Reach_VF.Block_seq','var') || sum(T_Reach_VF.Block_seq == 1) < params.n_Trials_blck
            load('samplePoints.mat','SamplePoints')
            Points_tmp = SamplePoints;
            Points = Points_tmp(randperm(size(Points_tmp,1)))
        end
        
        Reach_Localizer_TimeEvents(Block).t = struct('Trial', [], 'Block', [], 'startPoint_Start', [], 'startPoint_Stop', [], 'Target_displayTime', ...
            [],'Traj_start',[], 'Traj_stop',[],'Traj_Duration',[]);
        M_dis = [];
        for Trial_Target = 1: size(Points,1) % instead of params.n_Trials_blck, in case the first block is less than 15
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Start"', Block, Trial_Target));
            end
            
            
            CheckIfMouseIsReleased;
            
            % Draw a white cross in the middle of the screen as fixation
            Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Plus sign appears "', Block, Trial_Target));
            end
            
            SetMouse(params.xCent, params.yCent, window);
            
            %wait for 500ms in fixation phase until target appears
            while GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start <= params.fix %500ms
            end
            
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Stop = GetSecs;
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of plus sign, beginning of start point"', Block, Trial_Target));
            end
            
            % target appears after 500ms and allows subject to initiate movement
            Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
            Screen('DrawDots', window, [params.xCent params.yCent],params.fixdotsize, params.white, [], 2);
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime = Screen('Flip',window);
            
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d Target appears.. Eye Movement Phase "', Block, Trial_Target));
            end
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_start = GetSecs;
            % movement phase for 3 seconds
            while (GetSecs - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime) <= params.trial_mvmntdur && ~exitDemo
                
                
                for i = 1 : length(Points{Trial_Target});
                    params.Xdot = Points{Trial_Target,1}(i,1)+params.xCent
                    params.Ydot = -Points{Trial_Target,1}(i,2)+ params.yCent
                    M_dis = sqrt((Points{Trial_Target,1}(i,1))^2 + (Points{Trial_Target,1}(i,2))^2);
                    if M_dis < params.fixdotsize
                        Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.green, [], 2);
                        Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                        Reach_Localizer_TimeEvents(Block).t(Trial_Target).Mvmnt_Start = GetSecs; % Movement Starts
                        
                    else
                        Screen('DrawDots', window, [params.xCent params.yCent], params.fixdotsize, params.white, [], 2);
                    end
                    Screen('DrawDots', window, [params.tXpos params.tYpos], params.Rtarget, params.white, [], 2);
                    Screen('DrawDots', window, [params.Xdot params.Ydot],params.cursorsize, params.white, [], 2);
                    Screen('Flip',window);
                    %                     WaitSecs(params.ifi)
                end
                break;
                if eye_Tracker
                    vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d  Trial %02d End of Trial "', Block, Trial_Target));
                end
                [pressed, firstpress] = KbQueueCheck();
                exitDemo = checkExit(pressed, firstpress);
                
            end
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_stop = GetSecs;
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_Duration = Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_stop - Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_start
            T_tmp = table(cellstr(SubjectID),cellstr(subjectNumber), Block , Trial_Target, {Points{Trial_Target}},{[params.tXpos; params.tYpos]},Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_Duration,params.Block_seq(Block));
            %             T_Reach_VF = table;
            
            
            T_tmp.Properties.VariableNames = Names_Obs;
            T_Reach_Obs = [T_Reach_Obs ; T_tmp]
            
            
            % Write Logfile data
            %             fprintf(LogFile,'%02d\t%02d\t%.4f\t%.4f\t%.4f\t%.4f\n',Block,Trial_Target,Reach_Localizer_TimeEvents(Block).t(Trial_Target).startPoint_Start ,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Target_displayTime,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Start,Reach_Localizer_TimeEvents(Block).t(Trial_Target).Feedback_Stop);
            % assigned necessay variables to time structure
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Trial =  Trial_Target;
            Reach_Localizer_TimeEvents(Block).t(Trial_Target).Block = Block;
            
            SetMouse(params.xCent, params.yCent, window);
            [pressed, firstpress] = KbQueueCheck();
            exitDemo = checkExit(pressed, firstpress);
            
            
        end
        Reach_Localizer_TimeEvents(Block).BlockOnset = Reach_Localizer_TimeEvents(Block).t(1).startPoint_Start - params.Intro
        
        Reach_Localizer_TimeEvents(Block).block_duration =  Reach_Localizer_TimeEvents(Block).t(Trial_Target).Traj_stop - Reach_Localizer_TimeEvents(Block).t(1).startPoint_Start
        save(strcat(save_dir, filename,'.mat'), 'T_Reach_VF','T_Reach_Obs','Reach_Localizer_TimeEvents' )
        
    end
    %%% ++++++++++++++++++++   End of the Block ++++++++++++++++++++++++++++++++++++++
    %%% =========================================================================
    
    Block = Block+1
    
    
end
if Block == params.n_blcks_reach_localizer+1 && ~exitDemo
    Screen('DrawLines', window, params.allCoords,params.lineWidthPix, params.white, [params.xCent params.yCent], 2);
    Reach_Localizer_TimeEvents(Block).rest_start = Screen('Flip',window); % beginning of rest
    if eye_Tracker
        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Last Rest Block starts"', Block));
    end
    Screen('TextSize', window, params.textsize_counter)
    while  GetSecs - Reach_Localizer_TimeEvents(Block).rest_start <= params.rest && ~exitDemo % 15s fixartion
       [x_mouse, y_mouse, buttons] = GetMouse(window);
        if GetSecs - Reach_Localizer_TimeEvents(Block).rest_start >= params.Tcountdown_Instruction
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Display Message"', Block));
            end
            DrawFormattedText(window,'Thank you :) ... It ends soon', 'centerblock', 'center', params.white,[],0);
            Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start = Screen('Flip',window);
            WaitSecs(params.MSG)
            Reach_Localizer_TimeEvents(Block).IntialMSG_stop = GetSecs;
            Reach_Localizer_TimeEvents(Block).IntialMSG_Duration = Reach_Localizer_TimeEvents(Block).IntialMSG_stop - Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start;
            
        end
        
        if GetSecs - Reach_Localizer_TimeEvents(Block).rest_start >= params.Tcountdown_rest
            if eye_Tracker
                vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Start countdown"', Block));
            end
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
    Reach_Localizer_TimeEvents(Block).rest_stop = GetSecs;  % end of rest block
    Reach_Localizer_TimeEvents(Block).rest_oneset = Reach_Localizer_TimeEvents(Block).rest_start - params.Intro;
    Reach_Localizer_TimeEvents(Block).rest_duration_all = Reach_Localizer_TimeEvents(Block).rest_stop - Reach_Localizer_TimeEvents(Block).rest_start
    Reach_Localizer_TimeEvents(Block).rest_duration = Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start - Reach_Localizer_TimeEvents(Block).rest_start
    % save Oneset and duration of MSG+3+2+1
    Reach_Localizer_TimeEvents(Block).MSG_TMinus_Onset = Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start - params.Intro
    Reach_Localizer_TimeEvents(Block).MSG_TMinus_Duration = Reach_Localizer_TimeEvents(Block).rest_stop - Reach_Localizer_TimeEvents(Block).IntialMSG_Tminus_start
%     Reach_Localizer_TimeEvents(Block).Block_seq = params.Block_seq(Block);
    if eye_Tracker
        vpx_SendCommandString( sprintf('dataFile_InsertString "Block %02d Stop Countdown/Stop Rest"', Block));
    end
end
save(strcat(save_dir, filename,'.mat'), 'T_Reach_VF','T_Reach_Obs','Reach_Localizer_TimeEvents' )
save(strcat(save_dir, filename,'_params.mat'), 'params')
if eye_Tracker
    vpx_SendCommandString( 'dataFile_Close');
    % end VPX properly
    vpx_Unload;
end
Screen('CloseAll')
