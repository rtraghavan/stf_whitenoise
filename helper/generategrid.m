function [wx,wy,wt] = generategrid(params)
%GENERATEGRID: Generates a grid of values using the meshgrid function that
%can be used to derive the filters required to generate 3D filtered noise
%stimuli
%
%[Y1] = GENERATEGRID(X1) takes as its input a structure X1. This structure
%is defined by the function specifyfilterproperties.m. It contains many
%variables but the relevant ones are the variables X1.pixelsX, X1.pixelsY,
%X1.frames. These three variables are  used in concert with the matlab
%function meshgrid to create a 3D matrix Y1 that will be passed to
%filtering functions
%
%INPUT:
%       filterProperties: structure with several variables. Important ones
%       listed below
%
%       filterProperties.pixelsX: horizontal size of noise cube in pixels
%
%       filterProperties.pixelsY: vertical size of noise cube in pixels.
%
%       filterProperties.frames:  number of frames


img_X = params.npix_x;
img_Y = params.npix_y;
img_T = params.frames;
ppd = params.ppd;
fps = params.framerate;

[wx,wy,wt] = meshgrid(-(img_X/2):((img_X)/2-1),-(img_Y/2):((img_Y)/2-1),-(img_T/2):((img_T)/2-1));
wx = wx.*(ppd/img_X);
wy = wy.*(ppd/img_Y);
wt = wt.*(fps/img_T);

end