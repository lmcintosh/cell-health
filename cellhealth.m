% cellhealth.m
function [pipette seal health] = cellhealth(voltage,current)
clamp = ones(length(current),1); % 1 if V-clamp, 0 if I-clamp.
passes = 0;
for i=1:length(current);
    if current(i) > -100;
        clamp(i) = 0;
        if voltage(i) > 5;
            passes=passes+1;
        end
    end
end
current_Vsteps = clamp*voltage';
pipette = current_Vsteps;