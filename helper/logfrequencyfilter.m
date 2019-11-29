function [sampledFrequencies,filterWeights] = logfrequencyfilter(varargin)

%LOGFREQUENCYFILTER constructs a bandpass 1D filter that reaches unit in
%the passband with raised cosine functions that define transition band with
%frequencies defined in log2 domain.
%
%[Y1,Y2] = LOGFREQUENCYFILTER(X1,X2,X3,X4) creates a bandpass filter
%centered at frequency X1 with a filter bandwidth defined as the full width
%at half height and specified in octaves (X2). The transition bands are
%governed by raised cosine soft threshold function which is also specified
%in octaves (X3).  An additional flag (X4) can be used to visualize the
%filter properties. The resulting output is a lookup table of frequencies
%(Y1) and filter weights that are between 0 and 1 (Y2);
%
%INPUT:
%
%     centerFrequency (X1): center frequency in filter (cpd/fps)
%
%     filterBandwidth (X2): bandwidth of filter defined at full width at
%                           half height and specified in octaves
%
%     transitionBandwidth (X3): transition band width (octaves)
%
%     visualizeFilter (X4): logical true or false value that is helpful for
%                           plotting filter results. 
%
%OUTPUT:
%
%     sampledFrequencies (Y1): freuqencies over which the filter is
%     evaluated.
%
%     filterWeights (Y2):      weights on filter values which are between 0
%                              and 1
%
%     Limitations: for lawful behavior the transition bandwidth can at
%     maximum be the size of the filter bandwidth
%
%     Author: Ramanujan Raghavan
%     Contact: rtraghavan@nyu.edu


% ------------------------------------------------------------------------%

% replace default values with any user specified input. Default values are
% as follows:
%
% center frequency = 1 (for example 1 cycle/degree or 1 frame/second)
% filter bandwidth = 1 (octave)
% filter transition passband = 1 (octave)
% do not visualize filter (last entry is false);

defaultValues = [1 1 .5 0];
if length(varargin)==4
    varargin{4} = double(varargin{4});
end
defaultValues(~cellfun(@isempty,varargin)) = deal(cell2mat(varargin(~cellfun(@isempty,varargin))));
allParameters = defaultValues;
allParameters(4) = logical(allParameters(4));

%assign values
centerFrequency = allParameters(1);
filterBandwidth = allParameters(2);
transitionBandwidth = allParameters(3);
visualizeFilter = allParameters(4);

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
sampledFrequencies = linspace(0,(2^filterEndPoint),100000);
filterWeights = zeros(1,length(sampledFrequencies));

%start at the half step of the rising edge of the filter
filterPass1Center = centerFrequencyLog - (filterBandwidth/2); %where passband 1 is centered
filterHalfStep1Start = filterPass1Center - (transitionBandwidth/2);
filterHalfStep1End = filterPass1Center + (transitionBandwidth/2);

% find indices for first transition band and replace with a raised cosine
transitionIndices = sampledFrequencies>=(2^filterHalfStep1Start) & sampledFrequencies<=(2^filterHalfStep1End);
filterWeights(transitionIndices) = cos(linspace(-pi/2,0,length(find(transitionIndices)))).^2;

%define second passband
filterPass2Center = centerFrequencyLog + (filterBandwidth/2);
filterHalfStep2Start = filterPass2Center - (transitionBandwidth/2);
filterHalfStep2End = filterPass2Center + (transitionBandwidth/2);

%find indices between filterHalfStep1End and filterHalfStep2Start and
%replace with 1
transitionIndices2 = sampledFrequencies>(2^filterHalfStep1End) & sampledFrequencies<(2^filterHalfStep2Start);
filterWeights(transitionIndices2) = 1;

%define a falling cosine between filterHalfStep2Start and
%filterHalfStep2End
transitionIndices3 = sampledFrequencies>=(2^filterHalfStep2Start) & sampledFrequencies<=(2^filterHalfStep2End);
filterWeights(transitionIndices3) = cos(linspace(0,pi/2,length(find(transitionIndices3)))).^2;

%just plot the filter, this is a pretty useful option to enable.
if visualizeFilter == 1
    figure;plot(sampledFrequencies,filterWeights);
end

end
