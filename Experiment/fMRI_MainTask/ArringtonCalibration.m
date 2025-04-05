function ArringtonCalibration(ScreenNumber)
userInput = '';
validFullCalibrationModes = [6,9,12]; % 6, 9 or 12 point calibration;
calibrationMode = 0; % 0 for no valid calibration yet, else one of the validFullCalibrationModes

% main calibration loop: exit loop with '0'
while ~strcmp(userInput,'0')
   % determine current calibration modes
   if calibrationMode == 0 
      % if no full calibration has been done yet: 
      % choose from full calibration modes
      validCalibrationModes = validFullCalibrationModes;
   else
      % else: recalibrate single point, exit, or do full calibration
      validCalibrationModes = [-calibrationMode:0, validFullCalibrationModes];
   end
   % get user input
   
   KbQueueRelease;
   ListenChar(0)
   userInput = input(sprintf('Enter calibrationmode [%s]: ', num2str(validCalibrationModes)),'s');
    %userInput = '6';
   % evaluate user input in a try catch structure
  % try
      % convert input string to number (may fail if input is letter: catch)
      userInputNum = str2double(userInput);
     
      switch userInputNum 
         case num2cell(validFullCalibrationModes)
            % a full calibration is chosen:
            % call vpx_calibrate to execute the calibration
            fprintf('Calibration with %i\n', userInputNum)
            vpx_Calibrate_Screen(userInputNum, ScreenNumber);
            % update calibration mode
            calibrationMode = userInputNum;
         case num2cell(-calibrationMode:-1)
            % single point (-n)
            % call vpx_calibrate to execute the calibration
            fprintf('Calibration with %i\n', userInputNum)
            vpx_Calibrate_Screen(userInputNum, ScreenNumber);
         case 0
            % '0' is invalid if no full calibration has been performed
            if calibrationMode == 0
               disp('Invalid input!');
               userInput = '';
            end
         otherwise
            % invalid numbers
            disp('Invalid input!');
            userInput = '';
      end      
%    catch
%       % invalid input (no numbers)
%       disp('Invalid input!');
%       userInput = '';
%    end
end
end
