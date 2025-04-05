
function [response_start,response_stop,Trial_Loc] = recordReportedNumber (Block,params,window,Trial_Loc,xCenter,yCenter,save_dir,filename)
%usage:
% [audioCounter] = recordReportedNumber ('PreAdap_Loc',params,window,audioCounter,xCenter,yCenter,save_dir)

InitializePsychSound;
% Open the default audio device [], with mode 2 (== Only audio capture),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of 44100 Hz and 2 sound channels for stereo capture.
% This returns a handle to the audio device:
freq = 48000;
%pahandle = PsychPortAudio(‘Open’ [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);
% pahandle = PsychPortAudio('Open', 1, 2, 1, freq, 2);
pahandle = PsychPortAudio('Open', [], 2, 1, freq, 2);
%                           pahandle = PsychPortAudio('Open', [], 1, 1, freq, nrchannels);
% Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
PsychPortAudio('GetAudioData', pahandle, 5);
%startTime = PsychPortAudio(‘Start’, pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
Screen('FrameArc',window,params.white,[xCenter-params.gradedcircle yCenter-params.gradedcircle (xCenter+params.gradedcircle) (yCenter+params.gradedcircle)],0,360, 3,3, [])
% Screen('DrawArc', window, params.white, [xCenter-params.gradedcircle yCenter-params.gradedcircle (xCenter+params.gradedcircle) (yCenter+params.gradedcircle)], 0,360)
PsychPortAudio('Start', pahandle, 0, 0, 1); 
DrawFormattedText(window, 'Aufnahme: Nummer sagen', xCenter-170, yCenter, params.white,[],1);
%             Screen('DrawText', window, ('Recording.... '),xCent, yCent);
response_start = Screen('Flip',window);
while GetSecs - response_start <= params.duration
end %  duration=4s
recordedaudio = [];
PsychPortAudio('Stop', pahandle);
DrawFormattedText(window, 'Nummer erfolgreich aufgenommen... ', xCenter-170,yCenter, params.white,[],1);

response_stop = Screen('Flip',window);
% WaitSecs(0.4); % 1s
% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);
% Attach it to our full sound vector:
recordedaudio = [recordedaudio audiodata];
audiodata=audiodata';
%  filename2= sprintf ('audiotrial%d.wav',Z);
%save_dir= 'C:\Users\sheumue\Desktop\Shirin\Setup'
% if save_Mode == 0
    filename2= strcat(save_dir,  sprintf ('%s_Block%02d_Loc%02d.wav',filename,Block,Trial_Loc))
% elseif save_Mode == 1
%     filename2= strcat(save_dir, sprintf ('PosAdap_Loc%d.wav',audioCounter))
% elseif save_Mode == 2
%     filename2= strcat(save_dir, sprintf ('RVFB%d.wav',audioCounter))
% elseif  save_Mode == 3
%      filename2= strcat(save_dir, sprintf ('PreAdapWM%02d.wav',audioCounter))
% end
audiowrite(filename2, audiodata,freq);
% audioCounter=audioCounter+1;
% Close the audio device:
PsychPortAudio('Close', pahandle);
end