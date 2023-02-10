a=5; % horizontal radius
b=10; % vertical radius
x0=0; % x0,y0 ellipse centre coordinates
y0=0;
t=-pi:0.01:pi;
x=x0+a*cos(t);
y=y0+b*sin(t);
figure()
plot(x,y)
axis equal
hold on
scatter(x(471),y(471),'r','filled')
title('No Rotation')
% 
% %Plot the same ellipses, rotating by each calculated orientation angle.

radRot = deg2rad(-90);

[X Y] = rot(x,y,radRot)

figure()
plot(X,Y)
axis equal
hold on
scatter(X(471),Y(471),'r','filled')
%%
%Frank: Buildup angles and foundations
load mooredGPS 
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
%Tidal data and Predictions

%Creates my tides for 2020
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

%Classic rotation like a DJ's record
tidalz = [tideU;tideV].';
[coef, ~,~,~] = pca(tidalz);
tidalTheta = coef(3);
thetaDegree = rad2deg(tidalTheta);
[rotUtide,rotVtide] = rot(ut,vt,tidalTheta);
%%
close all

%%
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
%%
pairing = [1 1 2 2 3 3 4 4 5 5 6 6];

diff = [60 60 85.5 85.5 144.7 144.7 -6.6 -6.6 -0.2 -0.2 121.3 121.3]
for COUNT = 1:2:length(AnglesR)
    nameit= sprintf('Pairing %d Angle vs Tidal Ellipses, Diff: %d',pairing(COUNT),round(diff(COUNT)))
    figure()
    polarscatter(AnglesR(1,COUNT),x(1),280,'X')
    hold on
    polarplot(AnglesR(1,COUNT:COUNT+1),x(1:2),'-.');
    polarscatter(AnglesR(1,COUNT+1),x(1),200,'square','filled','k')
    polarplot(tideAnglesR,x2(1:2),'r')
    polarscatter(tideAnglesR,x2(1:2),130,'r','filled')
    pax = gca;
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir = 'clockwise';
    title(nameit)
end

%%
% AnglesD are the transceiver orientations

rotatorsR = deg2rad(AnglesD-tideAnglesD(2));
rotatorsD = rad2deg(rotatorsR);

for COUNT = 1:length(rotatorsR)
    [rotatedTidesX(COUNT,:) rotatedTidesY(COUNT,:)] = rot(ut,vt,rotatorsR(1,COUNT));
end


%max offshore for ut/rotUtide: 15393
%max onshore for ut/rotUtide:  15430

figure()
nexttile
plot(ut,vt)
axis equal
hold on
scatter(ut(15393),vt(15393),'filled','r')
scatter(ut(15430),vt(15430),'filled','k')
title('OG')
xline(0)
yline(0)

[testX testY] = rot(ut,vt,(rotatorsR(1)));

nexttile
plot(testX,testY)
axis equal
hold on
scatter(testX(15393),testY(15393),'filled','r')
scatter(testX(15430),testY(15430),'filled','k')
xline(0)
yline(0)
title('Should be -60 CCW')

[testX testY] = rot(ut,vt,rotatorsR(2));

nexttile
plot(testX,testY)
axis equal
hold on
scatter(testX(15393),testY(15393),'filled','r')
scatter(testX(15430),testY(15430),'filled','k')
title('Should be -240 CCW')
xline(0)
yline(0)

[testX testY] = rot(ut,vt,(rotatorsR(3)));

nexttile
plot(testX,testY)
axis equal
hold on
scatter(testX(15393),testY(15393),'filled','r')
scatter(testX(15430),testY(15430),'filled','k')
title('Should be -85d CCW')
xline(0)
yline(0)

[testX testY] = rot(ut,vt,(rotatorsR(4)));

nexttile
plot(testX,testY)
axis equal
hold on
scatter(testX(15393),testY(15393),'filled','r')
scatter(testX(15430),testY(15430),'filled','k')
title('Should be -265d CCW')
xline(0)
yline(0)


%%Combine in big tiled picture. You can do this!!!!
for COUNT = 1:2:length(AnglesR)
    nameit= sprintf('Pairing %d Angle vs Tidal Ellipses, Diff: %d',pairing(COUNT),round(diff(COUNT)))
    figure()
    tiledlayout(2,2)
    nexttile
    polarscatter(AnglesR(1,COUNT),x(1),280,'X')
    hold on
    polarplot(AnglesR(1,COUNT:COUNT+1),x(1:2),'-.');
    polarscatter(AnglesR(1,COUNT+1),x(1),200,'square','filled','k')
    polarplot(tideAnglesR,x2(1:2),'r')
    polarscatter(tideAnglesR,x2(1:2),130,'r','filled')
    pax = gca;
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir = 'clockwise';
    title(nameit)
    
    nexttile
    plot(ut,vt)
    axis equal
    hold on
    scatter(ut(15393),vt(15393),'filled','r')
    scatter(ut(15430),vt(15430),'filled','k')
    title('OG')
    xline(0)
    yline(0)

    nexttile
    plot(rotatedTidesX(COUNT,:),rotatedTidesY(COUNT,:))
    axis equal
    hold on
    scatter(rotatedTidesX(COUNT,15393),rotatedTidesY(COUNT,15393),'filled','r')
    scatter(rotatedTidesX(COUNT,15430),rotatedTidesY(COUNT,15430),'filled','k')
    xline(0)
    yline(0)
    title(sprintf('Should be %0.1f CCW',rotatorsD(1,COUNT)))
    
    nexttile
    plot(rotatedTidesX(COUNT+1,:),rotatedTidesY(COUNT+1,:))
    axis equal
    hold on
    scatter(rotatedTidesX(COUNT+1,15393),rotatedTidesY(COUNT+1,15393),'filled','r')
    scatter(rotatedTidesX(COUNT+1,15430),rotatedTidesY(COUNT+1,15430),'filled','k')
    xline(0)
    yline(0)
    title(sprintf('Should be %0.1f CCW',rotatorsD(1,COUNT+1)))


end








