function [filter] = orientationfilter(params)
%calculates orientation filter. Uses expo convention for orientation (90
%degrees is vertical). Considering all orientations in noise, the filter
%carves the absolute value of the cosine of these orientations, raised to
%an exponent to ensure a given bandwidth (specified in params)

%extract relevant parameters from params
ori = deg2rad(params.ori-90); %-90 for fft convention.

%unit vector
[x_temp,y_temp] = pol2cart(ori,1); %-90 for fft convention
u_vec_orientation = [x_temp y_temp];

%calculate cosine of all angles the same way you do using the speed filter
[wx,wy] = generategrid(params);
frequency_1D_sf = [reshape(wx,1,[]);reshape(wy,1,[])];
frequency_1D_sf_radius = sqrt(sum(frequency_1D_sf.^2));
dot_product_ori = u_vec_orientation*frequency_1D_sf;
cos_ori = dot_product_ori./frequency_1D_sf_radius;

%make orientation filter
orientation_filter = abs(cos_ori).^params.ori_exp; %classic simoncelli wedge
orientation_filter(isnan(orientation_filter)) = 0;
filter = reshape(orientation_filter,params.npix_x,params.npix_y,params.frames);

end