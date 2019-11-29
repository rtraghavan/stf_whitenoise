function [pixelsPerDegree] = calculateppd(monitorResolution,screenWidth,distanceToObserver)

% CALCULATEPPD: a function for calculating pixels per degree from monitor
% characteristics
%
% Y = CALCULATEPPD(X1,X2,X3) returns a single scalar value which allows
% conversions of any object, defined in pixels, to degrees of visual angle. It
% calculates this on the basis of monitor resolution (X1), screen width (X2) and
% distance between observer and screen (X3). Screen width and distance to
% observer MUST be in the same units (centimeters, inches, etc). Resolution is
% in pixels.
% 
% INPUT:
%       monitorResolution: horizontalScreenResolution in pixels screenWidth:
%       screen width measured in units of (x) distanceToObserver: distance
%       between subject and screen measured in
%                           units of (x)

%OUTPUT:
%       pixelsPerDegree: pixels per degree


degreesPerPixel = atand((screenWidth/2)/distanceToObserver)/(monitorResolution/2);
pixelsPerDegree = 1/degreesPerPixel;


end
