% letsgetitstarted.m
%% import

clear all;
close all;
addpath /home/lmcintosh/Dropbox/MacLean/
addpath /home/lmcintosh/Dropbox/MacLean/PaqTools
paqobj = paq([pwd '/080109-03_45_56PM.paq']);
% sample data - to simulate just voltage clamp, should take it from
% 0.95*10^5 to 1.4*10^5 (trace(:,1) - current (although labeled as
% voltage), trace(:,2) - voltage (although labeled as current))
% => translates to 9.5 sec to 14.0 sec
traces = paqobj.data;
current = traces(:,1);
voltage = traces(:,2);
figure; plot(current)
figure; plot(voltage)

%% analysis
localmin = zeros(length(current),1);
localmax = zeros(length(current),1);
stepon = zeros(length(voltage),1);
for i=2:length(current)-1;
    if current(i) < -10 && current(i+1) > current(i) && current(i-1) > current(i);
        localmin(i) = current(i);
    end
    if current(i) > 4 && current (i+1) < current(i) && current(i-1) < current(i);
        localmax(i) = current(i);
    end
    if voltage(i) > -780;
        stepon(i) = 1;
    end
end
localmin = sparse(localmin);
localmax = sparse(localmax);


% find A, B, C
a = []; k=1;
b = []; 
c = [];
v = []; j=1;
windows_capac = []; h=1;
for i=2:length(voltage)-1;
    % find A; A is steady state just before step (before transient peak)
    if stepon(i+1) == 1 && stepon(i) == 0;
        window = current(i-20:i);
        a(k) = mean(window);
        v(j) = voltage(i);
        v(j+1) = voltage(i+1);
    end
    % find B; B is transient peak
    if localmax(i) > 0;
        window = localmax(i-100:i+100);
        b(k) = max(window);
    end
    % find C; C is steady state at end of step (after transient peak)
    if stepon(i+1) == 0 && stepon(i) == 1;
        window = current(i-40:i);
        c(k) = mean(window);
        k=k+1;
        j=j+2;
        windows_capac(h,1) = current(i+1);
        q=2; g=i+2;
        if g < length(stepon);
            while stepon(g) == 0;
                windows_capac(h,q) = current(g);
                g=g+1; q=q+1;
                if g > length(stepon);
                    break
                end
            end
        end
        h=h+1;        
    end
end

% convert Voltage into V
v = (v/10)*(1e-3); % => into mV, then into V
% convert Current into A
c = c*(1e-9);
a = a*(1e-9);
 % make sure no zeros (indicates none such event)
if a(1) == 0
    a = a(2:k-1);
    b = b(2:k-1);
    c = c(2:k-1);
    v = v(3:j-2);
elseif c(k) == 0;
    a = a(1:k-2);
    b = b(1:k-2);
    c = c(1:k-2);
    v = v(1:j-4);
end

% Determine Input Resistance
input_res = []; j=1;
for i = 1:length(a);
   if j+1 <= length(v);
        input_res(i) = (v(j+1)-v(j))/(c(i)-a(i));
        j=j+2;
   end
end
  

% Determine Capacitance
% windows_capac = windows_capac(windows_capac~=0);
capacitance = []; Vs = [];
if windows_capac(size(windows_capac,1),size(windows_capac,2)) == 0;
    windows_capac = windows_capac(1:size(windows_capac,1)-1,:);
end
for i = 1:size(windows_capac,1); % Now you have just the double exp curve
    % Transform it so it's all positive; then take the log
    windows_capac(i,:) = windows_capac(i,:)-min(windows_capac(i,:));
    Vs(i) = mean(windows_capac(i,(length(windows_capac)-200):length(windows_capac)));
    figure; plot(windows_capac(i,:))
    figure; plot(-log(windows_capac(i,:)))
end
   


figure; hold on
plot(localmin,'Color','r'); plot(localmax,'Color','b'); plot(stepon,'Color','k')