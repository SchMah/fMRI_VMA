function pix = deg2pix(params,deg)
%pix = angle2pix(display,ang)
%
%converts visual angles in degrees to pixels.
%
%Inputs:
%display.dist (distance from screen (cm))
%display.width (width of screen (cm))
%display.resolution (number of pixels of display in horizontal direction)
%
%ang (visual angle)
%
%Warning: assumes isotropic (square) pixels

%Written 11/1/07 gmb zre

%Calculate pixel size
pixSize = params.display.width/params.display.resolution(1);   %cm/pix

sz = 2*params.display.dist*tan(pi*deg/(2*180));  %cm

pix = round(sz/pixSize);   %pix 


return

%test code

% display.dist = 45; %cm
% display.width = 44.5; %cm
% display.resolution = [1280,1024];
% ang = 2.529;

deg2pix(display,deg)



