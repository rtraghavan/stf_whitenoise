function [sampledSf,filterWeights] = radialfrequencyfilter(centerFrequency,filterBandwidth,transitionBandwidth,visualizeFilter)

%RADIALFREQUENCYFILTER constructs a simple 1D filter that is ultimately applied to all spatial frequencies within
%a given image.
% 
%     [ssf,fw] = RADIALFREQUENCYFILTER(xcenter,xbw,tbw) creates a bandpass
%     filter centered at frequency xcenter with a transition band width of
%     tbw. Center frequency is specified in cycles/image. The filter
%     bandwidth and transition bandwidth are specified in log2 units
%     (octaves).  These filters are 1 in the passband with a raised cosine
%     from zero to one over the transition band. Filter bandwidth is
%     defined as the octave length of full width at half height for the
%     overall filter. For a given matrix input, the output is a vector ssf,
%     of finely sampled spatial frequency along with a vector fw of filter
%     weights associated with those given spatial frequencies
%
%     [A,B] = RADIALFREQUENCYFILTER(xcenter,xbw,tbw,vF) performs the same
%     function as RADIALFREQUENCYFILTER(xlf,shf,tb,fmax) but has a flag
%     which displays a figure of the filter properties in 1D for
%     inspection.
%
%     Limitations: for lawful behavior the transition bandwidth can at
%     maximum be the size of the filter bandwidth
%     
%     Author: Ramanujan Raghavan
%     Version: 1.1
%     Updated: November 7, 2017
%     Contact: rtraghavan@nyu.edu
       

% ------------------------------------------------------------------------%
% Checking for a center frequency and setting default values if required

if (exist('centerFrequency') ~= 1)
    error('You must at least supply a center frequency')
end

%defaults to a hill centered over the desired frequency with one octave
%bandwidth

if (exist('filterBandwidth') ~= 1)
    filterBandwidth = 1; 
end

if (exist('transitionBandwidth') ~= 1)
    transitionBandwidth = 1; 
end

%defaults to no visualization
if (exist('visualizeFilter') ~= 1)
    visualizeFilter = 0; 
end

if transitionBandwidth>filterBandwidth
    disp(['you cannot have a transition bandwidth greater than your filter', ...
        'bandwidth, defaulting to transition bandwidth being equivalent to', ...
        'filter bandwidth'])
    transitionBandwidth = filterBandwidth;
end

% ------------------------------------------------------------------------%

%calculate center frequency in log2 

centerFrequencyLog = log2(centerFrequency);

%find end of filter
filterEndPoint = centerFrequencyLog + (filterBandwidth/2) + (transitionBandwidth/2); 

%I add another half transition width to this, only because it will look
%nicer. Will make zero impact

filterEndPoint = filterEndPoint + transitionBandwidth/2; 

%region over frequencies are evaluated. Super finely sampled. Can be
%reduced if too computationally expensive. 
sampledSf = linspace(0,(2^filterEndPoint),100000);
filterWeights = zeros(1,length(sampledSf));

%start at the half step of the rising edge of the filter
filterPass1Center = centerFrequencyLog - (filterBandwidth/2); %where passband 1 is centered
filterHalfStep1Start = filterPass1Center - (transitionBandwidth/2);
filterHalfStep1End = filterPass1Center + (transitionBandwidth/2);

% find indices for first transition band and replace with a raised cosine
transitionIndices = sampledSf>=(2^filterHalfStep1Start) & sampledSf<=(2^filterHalfStep1End);
filterWeights(transitionIndices) = cos(linspace(-pi/2,0,length(find(transitionIndices)))).^2;

%define second passband
filterPass2Center = centerFrequencyLog + (filterBandwidth/2);
filterHalfStep2Start = filterPass2Center - (transitionBandwidth/2);
filterHalfStep2End = filterPass2Center + (transitionBandwidth/2);

%find indices between filterHalfStep1End and filterHalfStep2Start and
%replace with 1
transitionIndices2 = sampledSf>(2^filterHalfStep1End) & sampledSf<(2^filterHalfStep2Start);
filterWeights(transitionIndices2) = 1;

%define a falling cosine between filterHalfStep2Start and
%filterHalfStep2End
transitionIndices3 = sampledSf>=(2^filterHalfStep2Start) & sampledSf<=(2^filterHalfStep2End);
filterWeights(transitionIndices3) = cos(linspace(0,pi/2,length(find(transitionIndices3)))).^2;

%just plot the filter, this is a pretty useful option to enable. 
if visualizeFilter == 1
    figure;plot(sampledSf,filterWeights);
end

end
