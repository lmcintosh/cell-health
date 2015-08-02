classdef paq
% paq_Obj = paq(path.paq)
% creates an instanse of a paq object given the full path to the .paq file
% to look at available methods and fields type
% paq_Obj.methods
% or 
% paq_Obj.fields
%
% paq provides the following methods
%
% paq_obj = extractinfo(paq_obj)
% this is called on the creation of a paq object
% it uses the .paq files header information to fill in the basic paq_Obj
% fields
%
% subclass_obj = createPaqSubClass(paq_Obj,subclassName)
% allows for protocol spesific subclasses
%
% plot(paq)
% calles EphysViewer to plot a paq object
% plot(paq_obj) or paq_obj.plot are equivalent
%
%[varargout] = data(paq,varargin)
%calls paq2lab and allows for paq2labs variable inputs
%ex. instead of call 
%data = paq2lab(fullpath) or
%data = paq2lab(fullpath,'channels',1:nChannels,[starttimes(istep),stoptimes(istep)]);
%call
%paq_Obj.data or
%paq_Obj.data('channels',1:nChannels,[starttimes(istep),stoptimes(istep)])
% no input: paq_Obj.data calles a GUI interface which is bypassed by
% passing values directly
% starttimes and stoptimes are in seconds
% 'channels' is followed by the index of the desired channels which are in
% the same order for the fields 

    properties
        SampleRate
        SamplesAcquired
        channels %cell array of stings for each channnel label
        HWchannels %cell array of stings for each channnels hardware label
        units %cell array of stings for each channnels units label
        protocol = 'unnamed' 
        fullpath = ''   %path to the location of the .paq file
        paqfile = ''    %just the string of the name of the paq file
        
        headstage = 0 %= 1 or 2 allows the paq object to be associated with only a certain headstage
        plots = 0
    end
    
    
    methods
        
        %Object construction
        function paq_obj = paq(fullpath)
            if nargin == 0
                paq_obj.fullpath = '';
            else
                if exist(fullpath,'file')
                    paq_obj.fullpath = fullpath;
                    paq_obj = paq_obj.extractinfo;
                    paq_obj.paqfile = fullpath(end-20:end);
                else
                    error('provided path does not exist')
                end
            end
        end

        function paq_obj = extractinfo(paq_obj)
            % uses the .paq files header information to fill in the basic paq_Obj
            % fields
            info = paq2lab(paq_obj.fullpath,'info');
            paq_obj.SampleRate = info.ObjInfo.SampleRate;
            paq_obj.SamplesAcquired = info.ObjInfo.SamplesAcquired;
            for i = 1:length(info.ObjInfo.Channel)
                paq_obj.channels{i} = info.ObjInfo.Channel(i).ChannelName;
                paq_obj.HWchannels{i} = info.ObjInfo.Channel(i).HwChannel;
                paq_obj.units{i} = info.ObjInfo.Channel(i).Units;
            end
        end

        function plot(paq)
            EphysViewer(paq.fullpath)
        end
        
        
        function [varargout] = data(paq,varargin)
            %calls paq2lab and allows for paq2labs variable inputs and
            %variable outputs
            %
            %ex. instead of calline
            %data = paq2lab(fullpath,'channels',1:nChannels,[starttimes(istep),stoptimes(istep)]);
            %call
            %paq_Obj.data('channels',1:nChannels,[starttimes(istep),stoptimes(istep)])
            %
            
            if isempty(varargin)
                [varargout{1},varargout{2},varargout{3}] = paq2lab(paq.fullpath);
            elseif length(varargin) == 2
                [varargout{1},varargout{2},varargout{3}] = paq2lab(paq.fullpath,varargin{1},varargin{2});
            elseif length(varargin) == 3
                [varargout{1},varargout{2},varargout{3}] = paq2lab(paq.fullpath,varargin{1},varargin{2},varargin{3});
            end
        end
        
        
        function subclass_obj = createPaqSubClass(paq_Obj,varargin)
            %allow for protocol spesific subclasses
                
            if length(varargin) >= 1 && ischar(varargin{1})
                subclassName = varargin{1};
            else %if not specified requires user input from a list
                defaultSubclasses = {'SpikeTestpaq','UpStatepaq','pspTest','pairing'};
                subclassName = defaultSubclasses{listdlg('ListString',defaultSubclasses,'SelectionMode','single')};
            end
            
            switch subclassName
                %general subclasses
                case {'SpikeTestpaq'}
                    subclass_obj = SpikeTestPaq(paq_Obj);
                    if paq_Obj.headstage == 0
                        warning('still need to specify a headstage number')
                    else
                        subclass_obj.headstage = paq_Obj.headstage;
                    end
                case {'UpStatepaq'}
                    subclass_obj = UpStatepaq(paq_Obj);
                    %STDP subclasses
                case {'pspTest'}
                    subclass_obj = pspTest(paq_Obj);
                    
                    if paq_Obj.headstage == 0
                        warning('still need to specify a headstage number')
                    else
                        subclass_obj.headstage = paq_Obj.headstage;
                    end
                    
                    if strcmp(paq_Obj.protocol,'unnamed')

                        if length(varargin) >= 2 && ischar(varargin{2})
                            subclass_obj.protocol = varargin{2};
                        else
                            defaultProtocols = {'prepairtest','postpairtest'};
                            subclass_obj.protocol = defaultProtocols{listdlg('ListString',defaultProtocols,'SelectionMode','single')};
                        end
                        
                    end

                case {'pairing'}
                    subclass_obj = pairing(paq_Obj);
                    if paq_Obj.headstage == 0
                        warning('still need to specify a headstage number')
                    else
                        subclass_obj.headstage = paq_Obj.headstage;
                    end
            end
        end
        
    end
    
    %get and set methods
    methods
        %samplerate
        function paq = set.SampleRate(paq,SampleRate)
            paq.SampleRate = SampleRate;
        end
        function SampleRate = get.SampleRate(paq)
            SampleRate = paq.SampleRate;
        end
        %SamplesAcquired
        function paq = set.SamplesAcquired(paq,SamplesAcquired)
            paq.SamplesAcquired = SamplesAcquired;
        end
        function SamplesAcquired = get.SamplesAcquired(paq)
            SamplesAcquired = paq.SamplesAcquired;
        end
        %protocol
        function paq = set.protocol(paq,protocol)
            paq.protocol = protocol;
        end
        function protocol = get.protocol(paq)
            protocol = paq.protocol;
        end
        %fullpath
        function paq = set.fullpath(paq,fullpath)
                    paq.fullpath = fullpath;
        end
        function fullpath = get.fullpath(paq)
            fullpath = paq.fullpath;
        end
        %paqfile
        function paq = set.paqfile(paq,paqfile)
                    paq.paqfile = paqfile;
        end
        function paqfile = get.paqfile(paq)
            paqfile = paq.paqfile;
        end
        %channels
        function paq = set.channels(paq,channels)
                    paq.channels = channels;
        end
        function channels = get.channels(paq)
            channels = paq.channels;
        end
        %HWchannels
        function paq = set.HWchannels(paq,HWchannels)
            paq.HWchannels = HWchannels;
        end
        function HWchannels = get.HWchannels(paq)
            HWchannels = paq.HWchannels;
        end
        %units
        function paq = set.units(paq,units)
            paq.units = units;
        end
        function units = get.units(paq)
            units = paq.units;
        end
        %plots
        function paq = set.plots(paq,plots)
            paq.plots = plots;
        end
        function plots = get.plots(paq)
            plots = paq.plots;
        end
        
        function display(paq)
            disp([paq.protocol, '  ', paq.fullpath])
        end
        
    end

end