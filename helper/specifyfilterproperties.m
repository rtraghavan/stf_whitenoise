function [parameters] = specifyfilterproperties(varargin)

%SPECIFYFILTERPROPERTIES: defines a structure that species parameters used in
%calculating a set of frequency space filters that are in turn used to make
%filtered noise stimuli. 
%
%INPUT:
%
% npix_x:       horizontal size of noise cube in pixels (Default = 256).
% npix_y:       vertical size of noise cube in pixels (Default = 256).
% frames:       frame length of noise cube. (Default = 120)
% ppd:          pixels per degree on your screen. Default = (64)
% framerate:    frame rate of monitor in Hz (Default = 120).
% center_sf:    center spatial frequency (cpd). (Default = 1 cpd)
% sf_bw:        spatial frequency bandwidth (octaves) (Default = 1)
% transbw_sf:   spatial Frequency transition bandwidth  (Default = 0.5)
% dir:          motion direction (degrees) (Default = 90)
% speed:        central speed (dps) (Default = 1)
% speed_bw:     speed bandwidth (octaves) (Default = 1)
% ori:          orientation of stimulus (degrees) (Default = 90).
% ori_bw:       orientation bandwidth (degrees) (Default = 10).


%
%OUTPUT:
% parameters:   a struct with the following fields
% --------------------------------------------------
% npix_x:       horizontal size of noise cube (pix)
% x_sizedeg:    horizontal size of noise cube (deg)
% npix_y:       vertical size of noise cube (pix)
% y_sizedeg:    vertical size of noise cube (deg)
% frames:       number of frames in movie
% movielength:  length of movie in seconds 
% speed_dps:    speed of noise (dps)
% speed_ppf:    speed of noise (pix/frame)
% speed_phi:    speed filter angle (deg)
% speed_phbw:   bandwidth of speed filter (octaves)
% speed_exp:    speed filter exponent for bandwidth (unitless).
% sf_cpd:       center spatial frequency (cpd)
% sf_cpi:       center spatial frequency of stimulus (cpi)
% sf_bw:        sf frequency bandwidth (octaves)
% transbw_sf:   transition bandwidth of sf frequency filter (octaves)
% ori:          orientation filter center (degrees)
% ori_bw:       orientation filter bandwidth (degrees)
% ori_exp:      orientation filter exponent given bandwidth (unitless)



%specify default properties
assert(~any(~cellfun(@isnumeric,varargin))); %test to see if someone stuck in inappropriate inputs

% Default motion cloud parameters as follows
% 1 cycle per degree center spatial frequency with 1 octave Bandwidth and half octave transition Bandwidth
% 1 degree/s speed with 1 octave speed Bandwidth drifting rightwards
% vertically oriented with a 10 degree orientation bandwidth.
% this is assigned below.
default_values = [256 256 120 64 120 1 1 .5 90 1 1 90 10];
all_parameters = default_values;
all_parameters(~cellfun(@isempty,varargin)) = deal(cell2mat(varargin));


npix_x = all_parameters(1);
npix_y = all_parameters(2);
frames = all_parameters(3);
ppd = all_parameters(4);
framerate = all_parameters(5);


center_sf = all_parameters(6);
sf_bw = all_parameters(7);
transbw_sf = all_parameters(8);
direction = all_parameters(9);
speed = all_parameters(10);
speed_bw = all_parameters(11);
ori = all_parameters(12);
ori_bw = all_parameters(13);

% create a filter properties structure that has everything you need in it.
parameters = struct;

parameters.npix_x = npix_x;
parameters.x_sizedeg = round(npix_x*(1/ppd));

parameters.npix_y = npix_y;
parameters.y_sizedeg = round(npix_y*(1/ppd));

parameters.frames = frames;
parameters.movielength = frames/framerate;

%Speed Filter Properties and Converstions
parameters.direction = direction;
parameters.speed_dps = speed;
parameters.speed_ppf = (speed*ppd)/framerate; %convert degrees/s to pixels/frame
parameters.speed_phi = rad2deg(atan(parameters.speed_dps));
parameters.speed_phibw  = speed_bw;
parameters.speed_exp = lookupspeedexponent(parameters);

%Radial Frequency Filter Properties
parameters.sf_cpd = center_sf;
parameters.sf_cpi = [center_sf * parameters.x_sizedeg; center_sf * parameters.y_sizedeg] ;
parameters.sf_bw = sf_bw; %spatial Frequency bandwidth = radial frequency Bandwidth.
parameters.transbw_sf = transbw_sf;

%Orientation Filter bandwidth
parameters.ori = ori;
parameters.ori_bw = ori_bw;
parameters.ori_exp = log(.5)/log(cos(deg2rad(ori_bw/2)));


end
