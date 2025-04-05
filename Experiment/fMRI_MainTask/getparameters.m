%% Aesthetic Parameters
% color of peresenting stimuli
params.white = [255 255 255]; 
params.black = [ 0 0 0];
params.red = [255 0 0];
params.green=[0 256 0]; %128 128 128
params.blue=[0 0 256];
params.aqua=[0 255 255];
params.grey=[128 128 128];
% font size
% text size for displaying numbers and instruction
params.textsize = 40; 
params.textsize_counter = 100
params.textsize_dscrptn = 22
%% Experimental Structure
% The experiment has several blocks with events in between
% training trials without image acquisition but inside scanner 
params.numberTrialsFam = 60;
params.numberTrials_noSpeed = 4;
params.numberTrials_VF = 30;

params.numberTrialsLoc = 10



params.n_blcks = 19; %19 % number of Blocks 3:T 8:Adap 2:D-Adap
params.n_Trials_blck = 15 % 15 Trials in each block
params.n_Trials_loc = 4  % 4 events between trials
params.Block_runPause = 10 % after 9th block , there is a 2min rest time
params.baselineBlocks = 4;
params.Blcks_trajFB  = 16;
% state of feedback
params.rotation = [0 0 0 0 5 5 10 10 15 15 20 20 25 25 30 30 0 0 0]
params.IntegersNumber = 120; % number of gradedcircle : 1-65
%% Timing Parameters
% 
params.dispdur = 120; %2 mins for displaying instruction. modify it later

params.fix = 0.5;  %initial fixation starts
params.trial_mvmntdur = 2; % allowed time to perform movement
params.warningtime = 1.4;
params.feedbacktime = 0.5; % time to display feedback
% params.resttime = 20

params.fixdur_loc = 15; %15 allocated time for ISI
params.Tcountdown_Instruction_Loc = 11;
params.MSG = 1 % time to read instruction before starting the trial
params.Tcountdown = 12 % 12 from 13th second countdown starts 3 2 1
params.countdown_dur = 1 %s
params.trial_mvmntdur_loc = 3; % allocated time for movement phase
params.response_time_loc = 4; % allocated time for response phase

params.mvmnt_time = 0.5 % exclusive time for reaching/shooting

% duration of the target presentation
params.dur1 = 0.500;
params.dur2 = 1;
params.duration = 5; % time of recording audio
params.numberOfSecondsRemaining = 5 ;

params.RestTime = 120 %2mins
%% Keyboard
% DESCRIPTIVE TEXT
% keyslist=zeros(1,256);
% KbName('UnifyKeyNames');
% keyslist(KbName({'SPACE','ESCAPE', 'RETURN','4','+','9('}))=1; %'6^', '7&','8*'
% KbQueueCreate(-1, keyslist);
% KbQueueStart;


%% EXPERIMENTAL SETUP
if strcmp (ScreenName,'Psychophysics')== 1
    
    params.screen_size=[0 0 1280 1024]; % screensize for monitor VL146
    
    params.display.dist = 45; %cm
    params.display.width = 33.52; %cm
    params.display.resolution = [params.screen_size(3),params.screen_size(4)];
    params.ScreenNumber = 2 %2
    params.xCent = params.screen_size(3)/2; %pix
    params.yCent=params.screen_size(4)/2;
    %
elseif strcmp (ScreenName,'Scanner')== 1
    
    params.screen_size=[0 0 1920 1080];
%     params.screen_size=[1 1 2560 1440];
    
    %     params.screen_size=[1 1 1400 1050];
%     params.ScreenNumber = 2
    params.ScreenNumber = 1 %1
    params.display.dist = 175;%89; %cm
    params.display.width = 64; %43; %cm
    params.display.resolution = [params.screen_size(3),params.screen_size(4)];
    
    params.xCent = params.screen_size(3)/2; %pix
    params.yCent = params.screen_size(4)/2;
    
end

% params.deg = [0.75 15 0.5 15.5 2.5 0.5]; %[fixdotdegree gradedcircledegree cursor circleradius4numbers allowancearea Rtarget(in displaytarget task)]
% params.degDsp=[0.75 15 0.5 0.5 2.5]; %[fixdotdegree gradedcircledegree cursor targetdegree allowancursor]
% params.deg = [1 4 0.5 4 2.5 1]; % 0.75 0.75
params.deg = [0.4 4 0.3 4 2.5 0.4 0.2];
params.fixdotsize = round(deg2pix( params,params.deg(1)));
params.gradedcircle = round(deg2pix( params,params.deg(2)));
params.cursorsize = round(deg2pix( params,params.deg(3)));
params.gradedcircle1 = round(deg2pix( params,params.deg(4)));
params.allowancedot = round(deg2pix( params, params.deg(5)));
params.Rtarget = round(deg2pix( params, params.deg(6)));

%%%% dim for fixation cross
params.fixCrossDimPix = 30; %size of cross
params.xCoords = [-params.fixCrossDimPix params.fixCrossDimPix 0 0]; % horizontal line
params.yCoords = [0 0 -params.fixCrossDimPix params.fixCrossDimPix]; % vertical line
params.allCoords = [params.xCoords; params.yCoords]; % concatenation of lines to form the cross
params.lineWidthPix = 6; % thickness of cross

%%% response phase-buttompress
params.markersize = round(deg2pix( params,params.deg(7)));
params.pointer = 57
params.spotRadius = 9 %15
params.spotDiameter = params.spotRadius * 2;
params.spotRect = [0 0 params.spotDiameter params.spotDiameter];


% params.AdjustMouse = 380;

params.ShowCursor = 30; %30
% params.searchingdistance = 600
params.searchingdistance = sqrt((params.xCent)^2 + (params.yCent)^2)

%%%Position for displaying %%%%%%
params.position1x = params.xCent-150; % 'Stift auf den grauen Punkt' & 'Bitte nochmal versuchen' 'Aufnahme: Nummer sagen'
params.position1y = params.yCent-50;

%
% params.INSTRUCTION1 = 0; % Instruction for familiarization
params.FAM = 1; % Familiarization
params.Loc = 2; % localization 
% params.LOCALIZATION = 3; %localization
% params.INSTRUCTION3 = 4;  %instruction for Generalization
% params.Gen = 5;
% params.INSTRUCTION4 = 6;
% params.WM = 7;
% params.showMenu =8;
%
% params.INSTRUCTION1_Post=0;
% params.Post_Gen = 1;
% params.INSTRUCTION2_Post = 2;
% params.Post_Retrain_Loc = 3;


