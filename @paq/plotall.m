function plotall(paq_Obj,varargin)

% plots the full trace of the paqfile over several figures and subplots.
% plotall(paqObj) will save figures to the current folder with 10 subplots
% per figure each displaying 20 seconds. each figure then shows a little
% more then 3 min of data. 
%
% Options
%
% plotall(paqObj,'nWindows',w) will allow you to specify the number of
% subplots per figure w (w must be an integer, if not it will be rounded up)
%
% plotall(paqObj,'nSeconds',s) will allow you to specify the number of
% seconds to view per subplot 
%
% plotall(paqObj,'savepath',path) will allow you to specify where to save
% the figures. the default is the current folder. path is a string
% referencing a folder, if the folder does not exist it will be constructed
%
% if paqObj is a known protocol specific plotting options will be used
%
% if paqObj is a pspTest subclass, figures will be split up according to
% psp tests and plotall(paqObj,'nTests',t) specifies the number of psp
% tests to view per row and plotall(paqObj,'nWindows',w,'nTests',t) will
% have w rows with t columns with each subolot being a different test.
% default is t = 4

%% extract varargin

%Varargin nWindows: windows per figure
if any(strcmp(varargin,'nWindows'))
    nwind = ceil(varargin{find(strcmp(varargin,'nWindows'))+1});
else
    nwind = 5;
end

%Varargin 'nSeconds': seconds to veiw
if any(strcmp(varargin,'nSeconds'))
    secperwin = ceil(varargin{find(strcmp(varargin,'nSeconds'))+1});
else
    secperwin = 10;
end

%Varargin 'savepath'
if any(strcmp(varargin,'savepath'))
    savepath = varargin{find(strcmp(varargin,'savepath'))+1};
    if ~exist(savepath,'dir')
        mkdir(savepath)
    end
else
    savepath = pwd;
end

% vRange
if any(strcmp(varargin,'vRange'))
    vRange = varargin{find(strcmp(varargin,'vRange'))+1};
    if length(vRange) ~= 2
            error(' vRange must be an array with 2 elements')
    end
else
    vRange = [-80,40];
end


%%
[Vchannel,Ichannel] = HeadstageChannelNames(paq_Obj);
    
if ~isa(paq_Obj,'pspTest')

    [starttimes,stoptimes] = BreakdownPaqTimes(paq_Obj,'maxSec',secperwin,'overlap',0);
    
    figure
    figID = 1;
    
    for isection = 1:length(starttimes)

        data = paq_Obj.data('channels',strcmp(Vchannel,paq_Obj.channels),[starttimes(isection),stoptimes(isection)]);
        
        subplot(nwind,1,mod(isection-1,nwind)+1)

        %time check and plot
        if length(data) == (stoptimes(isection)-starttimes(isection))*paq_Obj.SampleRate
            plot(linspace(starttimes(isection),stoptimes(isection),length(data)),data)
            ylim(vRange)
        else
            timeInSec = starttimes(isection)+(1:length(data))./paq_Obj.SampleRate;
            plot(timeInSec,data)
            ylim(vRange)
        end

        if mod(isection,nwind) == 0
            saveas(gcf,[savepath '/' num2str(figID)],'fig')
            saveas(gcf,[savepath '/' num2str(figID)],'tif')

            figID = figID + 1;
        end

    end
    
    saveas(gcf,[savepath '/' num2str(figID)],'fig')
    saveas(gcf,[savepath '/' num2str(figID)],'tif')
    close

%%
else
    
    %tests to view per window
    ntests = 4;
    
    %plot voltages
    
    if length(paq_Obj.VclampEndtimes) == length(paq_Obj.VclampStarttimes)
        VmStarts = [0;paq_Obj.VclampEndtimes./paq_Obj.SampleRate];
        VmEnds = [paq_Obj.VclampStarttimes./paq_Obj.SampleRate;0];
    else
        error('Vclamp start and end times have different lengths')
    end
    

    figure
    figID = 1;

    for itest = 1:length(VmStarts)

        
        data = paq_Obj.data('channels',strcmp(Vchannel,paq_Obj.channels),[VmStarts(itest),VmEnds(itest)]);
        
        subplot(nwind,ntests,1+mod(itest-1,nwind*ntests))

        %time check and plot
        if length(data) == (VmEnds(itest)-VmStarts(itest))*paq_Obj.SampleRate
            plot(linspace(VmStarts(itest),VmEnds(itest),length(data)),data)
            axis tight
            ylim(vRange)
        else
            timeInSec = VmStarts(itest)+(1:length(data))./paq_Obj.SampleRate;
            plot(timeInSec,data)
            axis tight
            ylim(vRange)
        end
        
        if mod(itest,nwind*ntests) == 0
            saveas(gcf,[savepath '/Voltages' num2str(figID)],'fig')
            saveas(gcf,[savepath '/Voltages' num2str(figID)],'tif')
            figID = figID + 1;
        end

    end
    saveas(gcf,[savepath '/Voltages' num2str(figID)],'fig')
    saveas(gcf,[savepath '/Voltages' num2str(figID)],'tif')
    close
    
    
    %plot reschecks

    

    VclampStarts = paq_Obj.VclampStarttimes./paq_Obj.SampleRate;
    VclampEnds =  paq_Obj.VclampEndtimes./paq_Obj.SampleRate;

    figure
    figID = 1;

    for itest = 1:length(VclampStarts)

        data = paq_Obj.data('channels',strcmp(Vchannel,paq_Obj.channels),[VclampStarts(itest),VclampEnds(itest)]);
        
        subplot(nwind,ntests,1+mod(itest-1,nwind*ntests))
        
        %time check and plot
        if length(data) == (VclampEnds(itest)-VclampStarts(itest))*paq_Obj.SampleRate
            plot(linspace(VclampStarts(itest),VclampEnds(itest),length(data)),data)
            axis tight
            ylim([-30,20])
        else
            timeInSec = VclampStarts(itest)+(1:length(data))./paq_Obj.SampleRate;
            plot(timeInSec,data)
            axis tight
            ylim([-30,20])
        end

        if mod(itest,nwind*ntests) == 0
            saveas(gcf,[savepath '/Vclamp' num2str(figID)],'fig')
            saveas(gcf,[savepath '/Vclamp' num2str(figID)],'tif')

            figID = figID + 1;
        end

    end
    saveas(gcf,[savepath '/Vclamp' num2str(figID)],'fig')
    saveas(gcf,[savepath '/Vclamp' num2str(figID)],'tif')
    close
    
end


