function [random_numbers,XX,YY,value,selected_number,response_start,response_stop]= gradedcircle (params, window,yCenter, xCenter)

THETA=linspace(0,2*pi,params.IntegersNumber);
RHO=ones(1,params.IntegersNumber)*(params.gradedcircle1); % 65 is the amount of numbers to present  %(params.gradedcircle1+10)
[xx,yy] = pol2cart(THETA,RHO);
YY=yy+params.yCent;% +10
XX=xx+params.xCent; %-10
random_numbers = randperm(params.IntegersNumber); % N = 65;

pointer = 102
ans_select = false;
response_start = GetSecs();
firstpress = [];
while GetSecs - response_start <=  params.duration  && ~ans_select
    numberOfSecondsElapsed = round((GetSecs() - response_start));
    params.numberOfSecondsRemaining = params.duration   - numberOfSecondsElapsed;
    Screen('DrawText', window, sprintf('%i seconds remaining...', params.numberOfSecondsRemaining), 20, 50, params.white);
    for ii=1:length(XX)-1
        numberString=num2str(random_numbers(ii));
        value(ii,:)=[XX(ii);YY(ii);random_numbers(ii)]';
%         DrawFormattedText(window, sprintf('%02d',random_numbers(ii)), XX(ii), YY(ii), params.white,[],0);
        Screen('DrawDots', window, [XX(ii) YY(ii)], params.markersize, params.white, [], 2);

    end
    [pressed, firstpress] = KbQueueCheck(); % Check if there was a button box input
    if firstpress(KbName('7&')) % 7&
        % If key 1 is pressed cursor to the left
        pointer = pointer - 1;
        if pointer <= 0
            pointer = size(value,1); % going left from 0, takes cursor to 9
        end
        
    elseif firstpress(KbName('6^')) %6^
        % If key 2 is pressed, move cursor to the right
        pointer = pointer + 1;
        if pointer > size(value,1)
            pointer = 1; % going left from 0, takes cursor to 9
        end
    elseif firstpress(KbName('8*')) %8*
        % If key 4 is pressed, the user has selected an answer
        ans_select = true;% user has selected an answer so this loop can come to an end
        response_stop = GetSecs();
        selected_number = value(pointer,3)
    else
        selected_number = NaN;
        response_stop =NaN;
    end
    
    xOffset = (params.gradedcircle1) * cos(THETA(pointer)); %(params.gradedcircle1+10)
    yOffset = (params.gradedcircle1) * sin(THETA(pointer));%(params.gradedcircle1+10)
    offsetCenteredspotRect = OffsetRect(params.centeredspotRect, xOffset, yOffset);
    
%     Screen('FrameArc',window,params.white,[params.xCent-params.gradedcircle params.yCent-params.gradedcircle (params.xCent+params.gradedcircle) (params.yCent+params.gradedcircle)],0,360, 3,3, [])
    %     Screen('FrameArc',window,params.white,[value(pointer,1)-10 value(pointer,2)-10 (value(pointer,1)+10) (value(pointer,2)+10)],0,360, 3,3, [])
    Screen('FrameArc',window,params.red,offsetCenteredspotRect,0,360, 3,3, [])
    
    Screen('Flip', window); % Display everything
    
    
    
    
end


