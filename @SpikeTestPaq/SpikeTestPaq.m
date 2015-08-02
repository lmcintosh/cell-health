classdef SpikeTestPaq < paq
    
properties
    
    TestStartTimes = [] %in 
    TestEndTimes = []
    CurrentAmp = []
    Reobase %current at first spike but not he real reobase

    %only has value for pulses with APs
    SpikeTimes = cell(0)
    isi = cell(0)
    spikecount = [] 
    firingrate = cell(0) 
    APhights = cell(0) 
    AHP = cell(0) 
    
    %only has value for hyperolarizing pulses
    Hcurrent = [] 
    
end

methods

    function SpikeTest_obj = SpikeTestPaq(ID)

        % inputes either a paq class or the fullpath name'
        if nargin == 0
        elseif ischar(ID)
            fullpath = ID;
            SpikeTest_obj.fullpath = fullpath;
            SpikeTest_obj.paqfile = ID(end-20:end);
            SpikeTest_obj.protocol = 'spiketest';
            SpikeTest_obj = SpikeTest_obj.extractinfo;
        elseif isa(ID,'paq')
            fullpath = ID.fullpath;
            SpikeTest_obj.fullpath = fullpath;
            SpikeTest_obj.paqfile = ID.paqfile;
            
            if strcmp(ID.protocol,'unnamed')
                SpikeTest_obj.protocol = 'spiketest';
            else
                SpikeTest_obj.protocol = ID.protocol;
            end
            
            if ID.headstage == 0
                warning('headstage not specified, need to specify a headstage for most methods')
            end
            
            SpikeTest_obj.headstage = ID.headstage;
            SpikeTest_obj = SpikeTest_obj.extractinfo;
        else
            error('incorect input');
        end
        
    end

    function SpikeTest_obj = getStepTimes(SpikeTest_obj)
        %find current steps bigger then some threshold minIstep

        minIstep = 10;

         SpikeTest_obj.TestStartTimes = [];
            SpikeTest_obj.TestEndTimes = [];

        [Vchannel,Ichannel] = HeadstageChannelNames(SpikeTest_obj);
        
        %make sure the correct headstage was recorded in this
        if any(strcmp(Ichannel,SpikeTest_obj.channels)) && any(strcmp(Vchannel,SpikeTest_obj.channels))
        
        %pull out some basic information
        nChannels = length(SpikeTest_obj.channels);
        samplingrate = SpikeTest_obj.SampleRate; %in samples
        
        [starttimes,stoptimes] = SpikeTest_obj.BreakdownPaqTimes;
        
        for istep = 1:length(starttimes)
            I = SpikeTest_obj.data('channels',find(strcmp(Ichannel,SpikeTest_obj.channels)),[starttimes(istep),stoptimes(istep)]);
            V = SpikeTest_obj.data('channels',find(strcmp(Vchannel,SpikeTest_obj.channels)),[starttimes(istep),stoptimes(istep)]);
            %the resting potential of the neuron should be the value it is
            %mostly at and therefore median should be a good estimate of it
            baseline = median(I);
            %find steps above the minIstep
            [TTLstart,TTLduration] = TTLdetect(abs(I-median(I))',minIstep);
            
            
            if ~isempty(TTLstart)

                %if broke up data in the middle of a test drop it and let the
                %overlap of the next chunk get it
                if TTLstart(end)+TTLduration(end) >= length(I)-1
                    TTLstart = TTLstart(1:end-1);
                    TTLduration = TTLduration(1:end-1);
                end

                for jstep = 1:length(TTLstart)
                    if TTLduration(jstep) > .05*SpikeTest_obj.SampleRate
                        %add the times to the objects fields
                        SpikeTest_obj.TestStartTimes = [SpikeTest_obj.TestStartTimes,TTLstart(jstep)+starttimes(istep)*samplingrate];
                        SpikeTest_obj.TestEndTimes = [SpikeTest_obj.TestEndTimes,TTLstart(jstep)+TTLduration(jstep)+starttimes(istep)*samplingrate];
                    end
                end
            end

        end

        %some times are overcounted because of the overlap so get rid of
        %double counting
        SpikeTest_obj.TestStartTimes = unique(SpikeTest_obj.TestStartTimes);
        SpikeTest_obj.TestEndTimes = unique(SpikeTest_obj.TestEndTimes);
        end
    end
    
    function SpikeTest_obj = AnalyzeSteps(SpikeTest_obj)
        
            
            for istep = 1:length(SpikeTest_obj.TestStartTimes)
            
                %get the data around the spike test times
                start = (SpikeTest_obj.TestStartTimes(istep)/SpikeTest_obj.SampleRate)-.01;
                stop = (SpikeTest_obj.TestEndTimes(istep)/SpikeTest_obj.SampleRate)+.15;
                [data names units] = SpikeTest_obj.data('channels',1:length(SpikeTest_obj.channels),[start,stop]);
                
                [Vchannel,Ichannel] = HeadstageChannelNames(SpikeTest_obj);
                
                I = data(:,find(strcmp(Ichannel,names)));
                Vm = data(:,find(strcmp(Vchannel,names)));

                [spikestart,spikestop,spiketimes] = APdetect(Vm);
                
                if ~isempty(spiketimes)
                    
                    SpikeTest_obj.SpikeTimes{end+1} = spiketimes;
                    SpikeTest_obj.isi{end+1} = diff(spiketimes);
                    SpikeTest_obj.spikecount(end+1) = length(spiketimes);
                    SpikeTest_obj.APhights{end+1} = Vm(spiketimes);
                    
%                     
%                     for i = 1:length(spiketimes)
%                         Vm(spikestop) 
%                         AHP{end+1} = ;
%                     end


                end
                
                
%                 f = figure;
%                 title('current step')
%                 timeinms = (1:length(Vm))*1000/paq_obj.SampleRate;
%                 subplot(2,1,1); plot(timeinms,Vm); ylabel('mV'); xlabel('ms')
%                 subplot(2,1,2); plot(timeinms,I);
%                 ylabel(units(find(strcmp(Ichannel,names)))); xlabel('ms')
%                 savepath = [analysis.savepath '/SpikeTest/' paq_obj.protocol];
%                 if ~exist(savepath,'dir')
%                     mkdir(savepath)
%                 end
%                 saveas(f,[savepath '/step' num2str(istep)],'fig')
%                 saveas(f,[savepath '/step' num2str(istep)],'jpg')
%                 close
            
            end
        
    end

end

%set and get
methods


    %     TestStartTimes = []
    function paq = set.TestStartTimes(paq,TestStartTimes)
        paq.TestStartTimes = TestStartTimes;
    end
    function TestStartTimes = get.TestStartTimes(paq)
        TestStartTimes = paq.TestStartTimes;
    end
    %     TestEndTimes = []
    function paq = set.TestEndTimes(paq,TestEndTimes)
        paq.TestEndTimes = TestEndTimes;
    end
    function TestEndTimes = get.TestEndTimes(paq)
        TestEndTimes = paq.TestEndTimes;
    end
    %     CurrentAmp = []
    function paq = set.CurrentAmp(paq,CurrentAmp)
        paq.CurrentAmp = CurrentAmp;
    end
    function CurrentAmp = get.CurrentAmp(paq)
        CurrentAmp = paq.CurrentAmp;
    end
    %     Reobase
    function paq = set.Reobase(paq,Reobase)
        paq.Reobase = Reobase;
    end
    function Reobase = get.Reobase(paq)
        Reobase = paq.Reobase;
    end
    %     SpikeTimes = cell(0)
    function paq = set.SpikeTimes(paq,SpikeTimes)
        paq.SpikeTimes = SpikeTimes;
    end
    function SpikeTimes = get.SpikeTimes(paq)
        SpikeTimes = paq.SpikeTimes;
    end
    %     isi = cell(0)
    function paq = set.isi(paq,isi)
        paq.isi = isi;
    end
    function isi = get.isi(paq)
        isi = paq.isi;
    end
    %     spikecount = []
    function paq = set.spikecount(paq,spikecount)
        paq.spikecount = spikecount;
    end
    function spikecount = get.spikecount(paq)
        spikecount = paq.spikecount;
    end
    %     firingrate = cell(0)
    function paq = set.firingrate(paq,firingrate)
        paq.firingrate = firingrate;
    end
    function firingrate = get.firingrate(paq)
        firingrate = paq.firingrate;
    end
    %     APhights = cell(0)
    function paq = set.APhights(paq,APhights)
        paq.APhights = APhights;
    end
    function APhights = get.APhights(paq)
        APhights = paq.APhights;
    end
    %     AHP = cell(0)
    function paq = set.AHP(paq,AHP)
        paq.AHP = AHP;
    end
    function AHP = get.AHP(paq)
        AHP = paq.AHP;
    end
    %     Hcurrent = []
    function paq = set.Hcurrent(paq,Hcurrent)
        paq.Hcurrent = Hcurrent;
    end
    function Hcurrent = get.Hcurrent(paq)
        Hcurrent = paq.Hcurrent;
    end

end
    
end
