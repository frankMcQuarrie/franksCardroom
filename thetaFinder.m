%FM 2/16/23
% Trying an idea from advisors/Yargo: We have transceiver orientation as
% compared to 0N rose, done, constant. For each hour timestep, we have the
% angle at which the tides are flowing compared to 0N rose; comparing the
% two will let us know when the tides are parallel or perpendicular to the
% known transceiver angle (+/- a few degrees, TBD).


%Idea: Tide is XX degrees, Transceivers are oriented forever at YY

% thetaHourly = YY-XX
% closeNuff = thetaHourly < 5 & thetaHourly >-5

matchAngles
close all

tideAnglesD(1) = 326.6;
tideAnglesD(2) = 146.6;
tideAnglesD(3) = tideAnglesD(1)-90;
tideAnglesD(4) = tideAnglesD(2)-90;


figure()
plot(ut,vt)
title('Original tides')


hourlyAngle = atan2d(tideV,tideU);


histogram(hourlyAngle)


figure()
plot(tideU,tideV)
hold on
scatter(tideU(50),tideV(50),'filled','r')
scatter(tideU(55),tideV(55),'filled','k')
axis equal






thetaHourly = 



