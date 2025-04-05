
function   CheckIfMouseIsReleased
[x_mouse, y_mouse, buttons] = GetMouse;
            if any(buttons)
                
                % wait until the mouse is released
                while(any(buttons))
                    [~, ~, buttons] =GetMouse();
                    WaitSecs(.001); % wait 1 ms
                end
            end
end

