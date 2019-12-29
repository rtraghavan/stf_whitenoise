function [filter] = speedfilter(params)

%calculates speed filter. The speed filter is the sin of a unit vector
%pointing orthogonal to the plane of motion. It imparts both a direction
%and speed.

%extract relevant parameters from params.
rho = 1; %by definition a unit vector has magnitude 1. 
theta = params.direction;
phi = params.speed_phi;
speedexp = params.speed_exp;

%generate grid of points
[wx,wy,wt] = generategrid(params);
frequency_1D = [reshape(wx,1,[]);reshape(wy,1,[]);reshape(wt,1,[])];
frequency_radius_1D = sqrt(sum(frequency_1D.^2));

%define unit vector
x = rho*sind(phi)*cosd(theta);
y = rho*sind(phi)*sind(theta);
z = rho*cosd(phi);
u_vec = [x y z]/norm([x y z]);

%calculate sin of all angles in your cube relative to the unit vector,
%raised to an exponent. Dot product of vectors normalized by magnitude is
%the cosine. The square root of 1-cosine squared is the sin. 

dot_product = u_vec*frequency_1D;
cos_dot_product = dot_product./frequency_radius_1D;
cos_dot_product_squared = (cos_dot_product).^2;
sin_dot_product = (1-cos_dot_product_squared).^.5; %max(x,0)
raised_sin = real(sin_dot_product).^speedexp; %order 9

%take care of the inf at 0,0,0
raised_sin(isnan(raised_sin)) = 0;

%reshape raised sin
filter = reshape(raised_sin,params.npix_x,params.npix_y,params.frames);



end
