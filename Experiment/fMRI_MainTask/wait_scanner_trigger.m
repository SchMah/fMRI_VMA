%--------------------------------------------------------------------------	
function trigger_T = wait_scanner_trigger(window, text_scanner)
KbQueueCheck()
trigger =false;
while ~trigger
    [pressed, firstpress] = KbQueueCheck();
    if pressed
        if firstpress (KbName('9(')) % scanner trigger key
            trigger_T = firstpress(KbName('9(')) % get the time of key press
            trigger = true;
        end
    end
end



