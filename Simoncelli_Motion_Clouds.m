%% make grid
clear variables
filter_settings = load('filter.mat');

%% some defualt parameters
addpath('~/Code/simoncelli_noise/helper')
%%
params = specifyfilterproperties;
%%

%parameters for size of image
img_X = 256; %pixels in x
img_Y = 256; %pixels in y
img_T = 120; %frames
ppd = 64; %pixels per degree
fps = 120; %frames per second
speed = 1; %degrees/s
ori = 0;


%parameters for filtering in temporal domain
rho = 1; %this is fixed, needs to be a unit vector
theta = ori; %this can be edited, translation to the right is default now
phi = atand(speed); %this is default elevation, I'll need to figure out how fast the object is moving and set up reasonable numbers

%parameters for filtering orientation
rho_ori = 1; %still a unit vector
ori_target_radians = deg2rad(0); %same theta

%step 1: define mesh grid
[wx,wy,wt] = generategrid(params);

%step 2: define frequency radius
frequency_1D = [reshape(wx,1,[]);reshape(wy,1,[]);reshape(wt,1,[])];
frequency_radius_1D = sqrt(sum(frequency_1D.^2));

% sf2 = frequency_radius_1D_sf(:).^-color;
% sf2(isinf(sf2)) = NaN;
% sf2 = sf2./max(sf2);
% sf2(isnan(sf2)) = 1;

%env = reshape(sf2,size(sf));

%step 4: define unit vector that is oriented in the direction you want (has given
%orientation and tilt for speed filter

%phi is speed, theta is direction!

x = rho*sind(phi)*cosd(theta);
y = rho*sind(phi)*sind(theta);
z = rho*cosd(phi);
u_vec = [x y z]/norm([x y z]);

%step 5: calculate (sin)^9 of 1 - squared dot product of unit vector by frequency radius

dot_product = u_vec*frequency_1D;
cos_dot_product = dot_product./frequency_radius_1D;
cos_dot_product_squared = (cos_dot_product).^2;
sin_dot_product = (1-cos_dot_product_squared).^.5; %max(x,0)
raised_sin = real(sin_dot_product).^params.speed_exp; %order 9

%take care of the inf at 0,0,0
raised_sin(isnan(raised_sin)) = 0;

%reshape raised sin
reshaped_raised_sin = reshape(raised_sin,img_X,img_Y,img_T);

%step 6: prepare orientation filter
[x_temp,y_temp] = pol2cart(ori_target_radians,1);
u_vec_orientation = [x_temp y_temp];

%multiply this vector by wx,wy (skip wt)
frequency_1D_sf = frequency_1D(1:2,:);
frequency_1D_sf_radius = sqrt(sum(frequency_1D_sf.^2));
dot_product_ori = u_vec_orientation*frequency_1D_sf;
cos_ori = dot_product_ori./frequency_1D_sf_radius;

%make orientation filter
orientation_filter = abs(cos_ori).^200; %classic simoncelli wedge
orientation_filter(isnan(orientation_filter)) = 0;
orientation_filter_reshaped = reshape(orientation_filter,img_X,img_Y,img_T);


%step 7: apply prespecified bandpass filter
[xparams,yparams] = radialfrequencyfilter(2,4,.5,false);
radius_filter = interp1(xparams,yparams,frequency_1D_sf_radius,'linear','extrap'); %schrater filter
radius_filter_reshaped = reshape(radius_filter,img_X,img_Y,img_T);


%
%step 8: make a noise cube
random_noise = randn(img_X,img_Y,img_T);
random_noise_to_fourier = fftn(random_noise);

%step 9: Filter noise
filter_convolution= random_noise_to_fourier.*reshaped_raised_sin.*radius_filter_reshaped;
Fz = ifftshift(filter_convolution);
Fz(1,1,1) = 0; %remove DC
Fz2 = ifftn(Fz);

%for diagnostics
Fz2_real = real(Fz2);
Fz2_imag = imag(Fz2);
ratio_imag_to_real = mean(abs(Fz2_imag(:)))./mean(abs(real(Fz2_real(:))));
Fz3 = ifftn(Fz,'symmetric');
%

%step 10: normalize images for contrast. Change this ENTIRELY.
contrast = 1;
meanSubFz3 = Fz3-mean(Fz3(:));
z = meanSubFz3;
z = z./std(z(:)) * 0.1;
%meanSubFz3 = meanSubFz3/(4*std(meanSubFz3(:)));


%output = mat2gray(meanSubFz3);
%
% output = mat2gray(z);
% v = VideoWriter(['example3_' datestr(datetime('now'),'yyyy-mm-dd_HH:MM:SS')]);
% v.FrameRate = 120;
% open(v)
% for i = 1:size(output,3)
%     writeVideo(v,output(:,:,i));
% end
% close (v);
