function [starttimes,stoptimes] = BreakdownPaqTimes(paq_Obj,varargin)
%looks at a paq file and if it's to long it gives the start and stop times
%for breaking it into chuncks in terms of seconds
%[starttimes,stoptimes] = getPaqBreakdown(paq_Obj) defualts with a maximum
%paq length of 600 seconds per chunck and overlaps each chunk by 1 second
%
%starttimes and stoptimes can be used in paq2lab to specify how much data
%to extract, ex. 
%
%[starttimes,stoptimes] = BreakdownPaqTimes(paq_Obj);
%nChannels = length(paq_Obj.info.Channel);
%for i = 1:length(starttimes)
%[data, names, units] = paq_Obj.data('channels',1:nChannels,[starttimes(i),stoptimes(i)])
%end
%
%[starttimes,stoptimes] = BreakdownPaqTimes(paq_Obj,'maxSec',s) allows a
%specified maximum length alowed for each chunck of data with s as a number
%in seconds
%[starttimes,stoptimes] = BreakdownPaqTimes(paq_Obj,'overlap',t) allows a
%specified maximum length alowed for each chunck of data with t as a number
%in seconds


if any(strcmp(varargin,'maxSec'))
    maxSec = find(strcmp(varargin,'maxSec'))+1;
else
    maxSec = 600; %in sec (1800 sec = 30 min)
end
if any(strcmp(varargin,'overlap'))
    step_overlap = find(strcmp(varargin,'overlap'))+1;
else
    step_overlap = 1;
end

%pull out some basic information
nChannels = length(paq_Obj.channels);
samplingrate = paq_Obj.SampleRate; %in samples
nSamples = paq_Obj.SamplesAcquired; %length in samples
length_of_recording = nSamples/samplingrate; %length in sec

%number of steps we must break the data file into
nsteps = ceil(nSamples/(maxSec*samplingrate));

%find the start times and stop times to give paq2lab for
%referencing out the data chunks
starttimes = zeros(1,nsteps);
stoptimes = zeros(1,nsteps);
for istep = 2:nsteps
    %note 0 for starttime is the beggining of the file and 0 for stoptimes is
    %the end of the file when read by paq2lab
    stoptimes(istep-1) = starttimes(istep-1) + maxSec;
    starttimes(istep) = stoptimes(istep-1) - step_overlap;
end

%put within the resolution of the sampling rate
stoptimes = round(stoptimes.*samplingrate)./samplingrate;
starttimes = round(starttimes.*samplingrate)./samplingrate;
