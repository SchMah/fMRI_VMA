function [exitDemo] = checkExit(pressed, firstpress)
exitDemo = false;
% [pressed,firstpress]= KbQueueCheck ();
if firstpress (KbName('ESCAPE'))
    exitDemo = true;
    Screen('CloseAll')
end
end


