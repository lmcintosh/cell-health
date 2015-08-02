function [Vchannel,Ichannel] = HeadstageChannelNames(paq_Obj)
%using the headstage field as a reference give back the name of the correct
%channel used in PaqIO. if PaqIO changes this function can be changed to
%reflect that. Can use this with paq2lab to only extract data from desired
%channels 
%
%ex. 
%to just get the voltage channel from the cell being analyzed
% [Vchannel,Ichannel] = HeadstageChannelNames(paq_Obj);
% Vm = paq_Obj.data('channels',strcmp(Vchannel,paq_Obj.channels));
%
%or
%
%ex. 
%to reference the voltage or current channels just for the desired cell
% [Vchannel,Ichannel] = HeadstageChannelNames(paq_Obj);
% nChannels = length(paq_Obj.channels);
% [data, names, units] = paq_Obj.data('channels',1:nChannels);
% Vm = data(:,strcmp(Vchannel,names));
% I = data(:,strcmp(Ichannel,names));



% find active voltage channels
if paq_Obj.headstage == 1
    Ichannel = 'current1';
    Vchannel = 'volts1';
elseif paq_Obj.headstage == 2
    Ichannel = 'current2';
    Vchannel = 'volts2';
else
    error('need to specify a headstage number to use under the field paq_Obj.headstage')
end
