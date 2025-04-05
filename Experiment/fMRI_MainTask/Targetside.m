function [PerturbationDeg,targetposition,theta_target,theta_targetWM] = Targetside(WhichTargetSide)
%This funtion defines target location in different stages of the experiment
% for mirror setup.
switch WhichTargetSide
    case 'Right'
        TargetSide = 0;
    case 'Left'
        TargetSide = 1;
    otherwise
        error('Target Side is not defined..please indicate Left or Right.')
end


%% 
if TargetSide == 0 %Right side
  % Target Position in 45° used in the Familiarization and Adaptation
    targetposition = -pi/180*(45); % target degree for right side
    % Tartget Positions used in Pre/Post Adaptation Generalization
        
    theta_target= -pi/180*[15 25 35 45 55 65 75 90];
    PerturbationDeg = 30; %for adaptation
    theta_targetWM = -pi/180*[0:8:90];
elseif TargetSide == 1;  %Left side
%      Target Position in -45° used in the Familiarization and Adaptation
    targetposition = -pi/180*(135); % target degree for left side
    % Target Position
    
%    Tartget Positions used in Pre/Post Adaptation Generalization
        
    theta_target=-pi/180* [105 115 125 135 145 155 165 90];
    
   PerturbationDeg =  30; % for adaptation 
   theta_targetWM = -pi/180*[90:8:180];
end
