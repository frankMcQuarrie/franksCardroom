%Frank's attempt at rotating the currents to be parallel or perpendicular
%to a transceiver pairing. In 2014, this was done purposefully so cross and
%along shore are easy to separate; in 2020, it is much more challenging. So
%instead of using the major axes of the ellipses, we can compare magnitude
%in different directions to see if the relationship is clear.

%Transceiver pairings:
%FRANK SWITCHED SO POSITIVE ALWAYS FIRST
% 1.  SURTASSSTN20 hearing STSNew1
% 2.  STSNew1 hearing SURTASSSTN20
% 3.  SURTASS05In hearing FS6
% 4.  FS6 hearing SURTASS05In
% 5.  Roldan hearing 08ALTIN
% 6.  08ALTIN hearing Roldan
% 7.  SURTASS05In hearing STSNEW2
% 8.  STSNEW2 hearing SURTASS05In
% 9.  39IN hearing SURTASS05IN
% 10. SURTASS05IN hearing 39IN
% 11. STSNEW2 hearing FS6
% 12. FS6 hearing STSNew2

load mooredGPS 
% transmitters = {'63068' '63073' '63067' '63079' '63080' '63066' '63076' '63078' '63063'...
%         '63070' '63074' '63075' '63081' '63064' '63062' '63071'};
%     
% moored = {'FS17','STSNew1','33OUT','34ALTOUT','09T','Roldan',...
%           '08ALTIN','14IN','West15','08C','STSNew2','FS6','39IN','SURTASS_05IN',...
%           'SURTASS_STN20','SURTASS_FS15'}.';

%SURTASSSTN20 and STSNew1
AnglesD(1) = atan2d((mooredGPS(15,2)-mooredGPS(2,2)),(mooredGPS(15,1)-mooredGPS(2,1)));
AnglesD(2) = atan2d((mooredGPS(2,2)-mooredGPS(15,2)),(mooredGPS(2,1)-mooredGPS(15,1)));
%SURTASS05IN and FS6
AnglesD(3) = atan2d((mooredGPS(12,2)-mooredGPS(14,2)),(mooredGPS(12,1)-mooredGPS(14,1)));
AnglesD(4) = atan2d((mooredGPS(14,2)-mooredGPS(12,2)),(mooredGPS(14,1)-mooredGPS(12,1)));
%Roldan and 08ALTIN
AnglesD(5) = atan2d((mooredGPS(6,2)-mooredGPS(7,2)),(mooredGPS(6,1)-mooredGPS(7,1)));
AnglesD(6) = atan2d((mooredGPS(7,2)-mooredGPS(6,2)),(mooredGPS(7,1)-mooredGPS(6,1)));
%SURTASS05IN and STSNew2
AnglesD(7) = atan2d((mooredGPS(11,2)-mooredGPS(14,2)),(mooredGPS(11,1)-mooredGPS(14,1)));
AnglesD(8) = atan2d((mooredGPS(14,2)-mooredGPS(11,2)),(mooredGPS(14,1)-mooredGPS(11,1)));
%39IN and SURTASS05IN
AnglesD(9) = atan2d((mooredGPS(14,2)-mooredGPS(13,2)),(mooredGPS(14,1)-mooredGPS(13,1)));
AnglesD(10) = atan2d((mooredGPS(13,2)-mooredGPS(14,2)),(mooredGPS(13,1)-mooredGPS(14,1)));
%STSNEW2 and FS6
AnglesD(11) = atan2d((mooredGPS(12,2)-mooredGPS(11,2)),(mooredGPS(12,1)-mooredGPS(11,1)));
AnglesD(12) = atan2d((mooredGPS(11,2)-mooredGPS(12,2)),(mooredGPS(11,1)-mooredGPS(12,1)));
%FMFMFMFM Adding in tidal ellipses angle, 2/8/23. These are found using
% PCA coefficients in tidalAnalysis scripts.
tideAnglesD(1) = 326.6;
tideAnglesD(2) = 146.6;


AnglesR = deg2rad(AnglesD);
tideAnglesR = deg2rad(tideAnglesD);

%%
%Okay: How do I use that information?

% Instead of rotating the tidal currents by the major axes found through
% pca, lets rotate the vectors by these values. That gives a parallel and
% perpendicular current for each pairing.

cd D:\Glider\Data\ADCP
load GR_adcp_30minave_magrot.mat;
% Cleaning data
uz = nanmean(adcp.u);
vz = nanmean(adcp.v);
xin = (uz+sqrt(-1)*vz);
[struct, xout] = t_tide(xin,'interval',adcp.dth,'start time',adcp.dn(1),'latitude',adcp.lat);


%Separate tides into vectors
tideU = real(xout);
tideV = imag(xout);
%Sets timing
datetide = [00,00,01,2020];

%t_tide order of constituents:
% 15 = M2, Lunar semidiurnal
% 17 = S2, Solar semidiurnal
% 14 = N2, Lunar elliptical, perigee
% 8 = K1,  Lunar diurnal
% 6 = O1,  Lunar Diurnal
% 5 = Q1,  Larger lunar elliptical diurnal
tTideOrder = [15,17,14,8,6,5]; % Full tides for consideration
% tTideOrder = [14]; %Isolating certain tides.


% uvpred order of constituents: 
% 1 = M2, 2 = S2, 3 = N2, 4 = K1, 6 = O1, 26 = Q1
UVOrder    = [1,2,3,4,6,26];% Full tides for consideration
% UVOrder    = [3]; %Isolating certain tides.
%Predict tides for our location
[timePrediction,ut,vt] = uvpred(struct.tidecon(tTideOrder,1),struct.tidecon(tTideOrder,3),struct.tidecon(tTideOrder,7),...
    struct.tidecon(tTideOrder,5),UVOrder,datetide,0.5,366);

%Create timing for our tidal predictions.
tideDN=datenum(2020,1,01):0.5/24:datenum(2021,1,01);
tideDT=datetime(tideDN,'ConvertFrom','datenum','TimeZone','UTC')';

%Results: ut and vt are the tides for the timing tideDT
%%

% Here's where it gets interesting: below is the way I rotate my tides
% normally, I find the major axes using Principle Component Analysis and
% rotate my axes to better fit the ellipses.

%Classic rotation like a DJ's record
tidalz = [tideU;tideV].';
[coef, ~,~,~] = pca(tidalz);
tidalTheta = coef(3);
thetaDegree = rad2deg(tidalTheta);

[rotUtide,rotVtide] = rot(ut,vt,tidalTheta);

%%
% Frank's second attempt: instead of creating that many sets of vectors, find and plot the angle on top of the tidal ellipses to
% more clearly show which way they're oriented; it got confusing when I started working with 12 different ellipses in addition to my original AND
% rotated tides. 

x = ones(1,12);
x = x+.5;
x2 = x +1;


figure()
h = polarscatter(AnglesR,x,'filled','k')

title('Transceiver Pairing, Full Array')
hold on
h = polarscatter(AnglesR(1,6),x(1),'filled','r')
for COUNT = 1:2:length(AnglesR)
    polarplot(AnglesR(1,COUNT:COUNT+1),x(1:2),'--','LineWidth',2);
end
polarplot(tideAnglesR,x2(1:2))
polarscatter(tideAnglesR,x2(1:2),'r')
pax = gca;
pax.ThetaZeroLocation = 'top';
pax.ThetaDir = 'clockwise';


% Make rotations for each transceiver pairing
pairing = [1 1 2 2 3 3 4 4 5 5 6 6];

diff = [60 60 85.5 85.5 144.7 144.7 -6.6 -6.6 -0.2 -0.2 121.3 121.3]
for COUNT = 1:2:length(AnglesR)
    nameit= sprintf('Pairing %d Angle vs Tidal Ellipses, Diff: %d',pairing(COUNT),round(diff(COUNT)))
    figure()
    polarscatter(AnglesR(1,COUNT),x(1),280,'X')
    hold on
    polarplot(AnglesR(1,COUNT:COUNT+1),x(1:2),'-.');
    polarscatter(AnglesR(1,COUNT+1),x(1),250,'square','filled','k')
    polarplot(tideAnglesR,x2(1:2),'r')
    polarscatter(tideAnglesR,x2(1:2),250,'r','filled')
    pax = gca;
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir = 'clockwise';
    title(nameit)
end


%From tidalAnalysis's PCA check, angle of principal rotation is 0.5825rad,
%or 33.3748 degrees/0.5825 radians counterclockwise, (326.6252 clockwise?)

figure()
plot(ut,vt)
axis equal
title('Raw Prediction')

figure()
plot(rotUtide,rotVtide)
axis equal
title('Rotated Tides: Original, -33.4')

%NOW need to figure out how to use these rotations and orientations
%together. Let's experiment. REMEMBER ROT() is CCWise

transRotations = deg2rad(AnglesD-thetaDegree);
transRotationsDeg = rad2deg(transRotations)



for COUNT = 1:length(transRotations)
    [rotatedUTide(COUNT,:),rotatedVTide(COUNT,:)] = rot(ut,vt,transRotations(COUNT));
end






figure()
plot(ut,vt)
axis equal
title('Tide Predicts, X/Y')
xlabel('X')
ylabel('Y')
xline(0)
yline(0)


figure()
plot(rotUtide,rotVtide)
axis equal
title('Tide Predicts,Cross/Along')
xlabel('Cross')
ylabel('Along')
xline(0)
yline(0)





%Use 2, 4, 6, 8, 9, 12 because these are in the positive directions. Still
%have to make sure this rotation is correct, may be wrong direction.
useThese = [2,4,6,8,9,12]
for COUNT = 1:length(useThese)
    figure()
    plot(tideDT,uTide(useThese(COUNT),:))
    ylabel('UMagnitude')
%     axis equal
    nameit = sprintf('Pair %d, rotation %s',COUNT,transRotations(useThese(COUNT)))
    title(nameit)
end












