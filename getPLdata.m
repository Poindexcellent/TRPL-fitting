% A temporary script to get PL data from a figure (hence requires some user
% interaction with this code).
%
% Created: August 8, Jeremy R. Poindexter


timeDataRaw = get(gco,'XData');
PLdata = get(gco,'YData');

[maxVal,maxIndex] = max(PLdata);

% % startTime = 0;  %# Enter start window time for fitting
startTime = timeDataRaw(maxIndex);
endTime = 1500; %# Enter end window time for fitting

timeData = timeDataRaw(timeDataRaw(:) >= startTime &...
    timeDataRaw(:) <= endTime);


PLdata = PLdata(timeDataRaw(:) >= startTime &...
    timeDataRaw(:) <= endTime);


%% Make sure it's the right data:

figure;
semilogy(timeData,PLdata)