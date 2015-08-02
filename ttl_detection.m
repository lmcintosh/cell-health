function [start_times,durations] = TTLdetect(timeseries,varargin)
% Assumes baseline is at 0. can try and automate this by subtracting
% median(timeseries) from the the timeseries input

%check if timeseries is the right dimention
dim = find(size(timeseries)==1);
if dim~=1
	timeseries = timeseries'; 
end

%TTL detector
if ~isempty(varargin)
	TTLind = find(timeseries>varargin{1});
else
	TTLind = find(timeseries>2.9);
end

if ~isempty(TTLind)
	start_times = TTLind([1,find(diff(TTLind)>1)+1]);
	durations = TTLind([find(diff(TTLind)>1),length(TTLind)]) - start_times +1;
else
	start_times = [];
	durations = [];
end