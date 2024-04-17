%Frank needs to focus on FS17 and 33OUT and the relationship between


mooredEfficiency
%We're looking at {11}, FS17 hearing STSNew1
% stationWindsAnalysis
buildReceiverData
%%
fallIndex = receiverData{5}.Season ==4;
winterIndex = receiverData{5}.Season ==1;

fallNoise = mean(receiverData{5}.Noise(fallIndex))
winterNoise = mean(receiverData{5}.Noise(winterIndex))
% cd 'C:\Users\fmac4\OneDrive - University of Georgia\data\Glider\whatever'
cd ([oneDrive,'Glider\whatever'])

cd 03192020_04112020\


load Mar_2020_angus_alldbds.mat
load Mar_2020_angus_ebds.mat

[matstruct1,dn,z,temp,rho] = Bindata(fstruct,sstruct);

[bulktime1, bulkrho1, bulktemp1] = binnedbulkstrat(matstruct1);
bulkdepth1 = z;

cd ([oneDrive,'Glider\whatever\04212020_05212020'])

load April_2020_angus_alldbds.mat
load April_2020_angus_allebds.mat


[matstruct2,dn,z,temp,rho] = Bindata(fstruct,sstruct);

[bulktime2,bulkrho2,bulktemp2] = binnedbulkstrat(matstruct2);
bulkdepth2 = z;
% figure()
% plot(bulktime,bulktemp)


cd ([oneDrive,'Glider\whatever\11042020_11162020'])

load November_2020_franklin_alldbds.mat
load November_2020_franklin_allebds.mat


[matstruct3,dn,z,temp,rho] = Bindata(fstruct,sstruct);

[bulktime3,bulkrho3,bulktemp3] = binnedbulkstrat(matstruct3);
bulkdepth3 = z;

%
cd ([oneDrive,'Glider\Data'])
load nov19dbd.mat
load nov19ebd.mat


[matstruct4,dn,z,temp,rho] = Bindata(fstruct,sstruct);

[bulktime4,bulkrho4,bulktemp4] = binnedbulkstrat(matstruct4);
bulkdepth4 = z;



%  Combine all stratifications

bulktime   = [bulktime1,bulktime2,bulktime3,bulktime4];
bulkrho    = [bulkrho1,bulkrho2,bulkrho3,bulkrho4];
bulktemp   = [bulktemp1,bulktemp2,bulktemp3,bulktemp4];
bulkdepth  = [bulkdepth1,bulkdepth2,bulkdepth3,bulkdepth4];

matrixDT    = [matstruct4.dt; matstruct1.dt;matstruct2.dt;matstruct3.dt]; matrixDT.TimeZone = 'UTC';
matrixTemp  = [matstruct4.temp; matstruct1.temp;matstruct2.temp;matstruct3.temp];
matrixRho   = [matstruct4.rho; matstruct1.rho;matstruct2.rho;matstruct3.rho];
matrixDepth = [matstruct4.z; matstruct1.z;matstruct2.z;matstruct3.z];





% %%
% clearvars -except receiverData hourlyDetections mooredReceivers oneDrive githubToolbox matstruct bulktime bulkrho bulktemp bulkdepth matstruct* matrix*
% close all

%Aight, Frank needs to pick specific time chunks to compare statistically.
cd 'C:\Users\fmm17241\OneDrive - University of Georgia\statisticalAnalysis\envStatsSpring2024'
% cd 'C:\Users\fmac4\OneDrive - University of Georgia\statisticalAnalysis\envStatsSpring2024'
winterSpringFLAT   = receiverData{4}(1613:3797,:); %Jan 27 to April 27
winterSpringSUNKEN = receiverData{5}(1081:3265,:);  % samesies
winterSpringTAGS   = receiverData{2}(1232:3416,:);  % samesies







% % Interpolate Temp. Weakens dataset but good to just truth my bulk thermal
% % estimation.
% b = 0.5 * (fillmissing(matrixTemp, 'previous') + fillmissing(matrixTemp, 'next'))
% 
% 

figure()
tiledlayout(6,1,'TileSpacing','compact')
% ax1 = nexttile()
% plot(bulktime,bulktemp);
% title('Bulk Thermal Strat. From Glider')

ax1 = nexttile([2 1])
pcolor(matrixDT,matrixDepth(1,:),matrixTemp'); shading interp; cb = colorbar; set(gca,'ydir','reverse'); datetick('x');
set(gca,'Xticklabel',[]); set(gca,'xtick',[]); cb.Label.String = 'Temp (C)';
title('Thermal Stratification','Glider Data')
ylabel('Depth (m)')
clim([18 20])


% figure; h1=pcolor(dn,z,temp'); shading interp; colorbar; set(gca,'ydir','reverse'); datetick('x','keeplimits');
ax2 = nexttile()
plot(receiverData{2}.DT,receiverData{2}.bulkThermalStrat);
title('Bulk Thermal Stratification','Surface (Buoy) - Bottom (Transceiver)')
ylabel('Gradient (C)')

ax3 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.windSpd);
title('Windspeed')
ylabel('Windspeed (m/s)')

ax4 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.Noise);
title('High-Frequency (50-90 kHz) Noise')
yline(650)
ylabel('Noise (mV)')

%
% averageDetections = receiverData
% frank , ugh, make this work to give us average hourly for every hour
% then use it to plot against stratification in April/May
% %




% ax5 = nexttile()
% hold on
% for COUNT = 1:length(receiverData)
%     plot(receiverData{COUNT}.DT,receiverData{COUNT}.HourlyDets);
% end
% title('Flat','Detections')


ax5 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.HourlyDets);
title('Hourly Detections')
ylabel('Detections')

linkaxes([ax1 ax2 ax3 ax4 ax5],'x')

print(gcf,'timeseriesApril.png','-dpng','-r300'); 

%%%


sunkenReef = receiverData{5};
flatReef{1}   = receiverData{4};
flatReef{2}   = receiverData{1};
flatReef{3}   = receiverData{2};
flatReef{4}   = receiverData{13};


hillToSunken = hourlyDetections{11};
hillToFlat   = hourlyDetections{14};
% 
% clearvars -except receiverData sunkenReef flatReef hillTo* oneDrive githubToolbox
% close all

%Okay. Two scenarios to compare, quantitatively

sunkenLowNoiseIndex = receiverData{5}.Noise < 650;
flatLowNoiseIndex   = receiverData{4}.Noise < 650;

sunkenHighNoiseIndex = receiverData{5}.Noise > 650;
flatHighNoiseIndex = receiverData{4}.Noise > 650;

sunkenLowNoise = receiverData{5}(sunkenLowNoiseIndex,:);
sunkenHighNoise = receiverData{5}(sunkenHighNoiseIndex,:);
flatLowNoise = receiverData{4}(flatLowNoiseIndex,:);
flatHighNoise = receiverData{4}(flatHighNoiseIndex,:);


avgSunkLow  = mean(sunkenLowNoise.HourlyDets)
avgSunkHigh = mean(sunkenHighNoise.HourlyDets)

avgFlatLow  = mean(flatLowNoise.HourlyDets)
avgFlatHigh = mean(flatHighNoise.HourlyDets)


sunkenLowSTD = std(sunkenLowNoise.HourlyDets);
sunkenHighSTD = std(sunkenHighNoise.HourlyDets);
flatLowSTD = std(flatLowNoise.HourlyDets);
flatHighSTD = std(flatHighNoise.HourlyDets);

sunkenLowInterval = [sunkenLowNoise.HourlyDets + sunkenLowSTD, sunkenLowNoise.HourlyDets - sunkenLowSTD ];
sunkenHighInterval = [sunkenHighNoise.HourlyDets + sunkenHighSTD,sunkenHighNoise.HourlyDets - sunkenHighSTD ];
flatLowInterval = [flatLowNoise.HourlyDets + flatLowSTD,flatLowNoise.HourlyDets - flatLowSTD ];
flatHighInterval = [flatHighNoise.HourlyDets + flatHighSTD,flatHighNoise.HourlyDets - flatHighSTD ];


figure()
tiledlayout(2,2,'TileSpacing','Compact')
nexttile()
hist(sunkenLowNoise.Noise)
title('Low Noise Levels, <650','Sunken Lagoon')
ylabel('Hours')
% xlabel(' HF Noise (mV)')
ylim([0 2300])
xlim([200 650])

nexttile()
hist(sunkenHighNoise.Noise)
title('High Noise Levels, >650','Sunken Lagoon')
% ylabel('Hours')
% xlabel(' HF Noise (mV)')
ylim([0 2300])
xlim([650 850])
set(gca, 'YTickLabel', [])

nexttile()
hist(flatLowNoise.Noise)
title('','Flat Reef')
ylabel('Hours')
xlabel(' HF Noise (mV)')
ylim([0 2300])
xlim([200 650])

nexttile()
hist(flatHighNoise.Noise)
title('','Flat Reef')
% ylabel('Hours')
xlabel(' HF Noise (mV)')
ylim([0 2300])
xlim([650 850])
set(gca, 'YTickLabel', [])

figure()
scatter(1, flatLowNoise.HourlyDets)
hold on
scatter(2, flatHighNoise.HourlyDets)
scatter(3, sunkenLowNoise.HourlyDets)
scatter(4, sunkenHighNoise.HourlyDets)





figure()
scatter(1, avgSunkLow,'filled','b')
hold on
errorbar(1,avgSunkLow,sunkenLowSTD)




sunkenLMWindNoise = fitlm(sunkenReef.windSpd,sunkenReef.Noise)
sunkenLMWindDets = fitlm(sunkenReef.windSpd,sunkenReef.HourlyDets)
sunkenLMTempNoise = fitlm(sunkenReef.Temp,sunkenReef.Noise)
sunkenLMNoiseDets = fitlm(sunkenReef.Noise,sunkenReef.HourlyDets)


for COUNT = 1:4
    flatLMWindNoise{COUNT}   = fitlm(flatReef{COUNT}.windSpd,flatReef{COUNT}.Noise)
    flatLMTempNoise{COUNT}   = fitlm(flatReef{COUNT}.Temp,flatReef{COUNT}.Noise)
    flatLMWindDets{COUNT}    = fitlm(flatReef{COUNT}.windSpd,flatReef{COUNT}.HourlyDets)
    flatLMNoiseDets{COUNT}   = fitlm(flatReef{COUNT}.Noise,flatReef{COUNT}.HourlyDets)
end




%%
%
figure()
tiledlayout(3,1,'TileSpacing','Compact')
ax1 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.windSpd)
title('Seasonal Differences','Windspeed')
ylabel('W.Speed (m/s)')

% ax2 = nexttile()
% plot(receiverData{4}.DT,receiverData{4}.crossShore)
% title('','X-Shore Tides, Neg Flood Pos Ebb')
% ylabel('Currents (m/s)')

ax2 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.Noise,'k')
title('','HF Noise (50-100 kHz)')
ylabel('Noise (mV)')

ax3 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.HourlyDets)
title('','DETECTIONS')
ylabel('Hourly Dets')

linkaxes([ax1,ax2,ax3],'x')


figure()
plot(sunkenReef.DT,sunkenReef.Temp)



%%
%Alright, gotta bring in environmental data from the gliders. Instead
%of just seasonal differences, I need to find times where stratification
%was minimal, there was winds, and STILL the detection rate increased


%
figure()
tiledlayout(3,1,'TileSpacing','Compact')
ax1 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.windSpd)
title('Windspeed')
ax2 = nexttile()
plot(bulktime,bulktemp)
title('Thermal Stratification')
ax3 = nexttile()
plot(receiverData{4}.DT,receiverData{4}.HourlyDets)
title('Detections')
linkaxes([ax1 ax2 ax3],'x')
%%


tbl = crosstab(receiverData{4}.HeardSomething,receiverData{4}.NoiseThreshold)
tbl = crosstab(receiverData{5}.HeardSomething,receiverData{5}.NoiseThreshold)
tbl = crosstab(receiverData{2}.HeardSomething,receiverData{2}.NoiseThreshold)

%%
%
mean(receiverData{4}.HourlyDets(receiverData{4}.Noise < 550))
mean(receiverData{4}.HourlyDets(receiverData{4}.Noise > 550 & receiverData{4}.Noise < 649))
mean(receiverData{4}.HourlyDets(receiverData{4}.Noise > 650))


mean(receiverData{5}.HourlyDets(receiverData{5}.Noise < 550))
mean(receiverData{5}.HourlyDets(receiverData{5}.Noise > 550 & receiverData{5}.Noise < 649))
mean(receiverData{5}.HourlyDets(receiverData{5}.Noise > 650))

mean(receiverData{2}.HourlyDets(receiverData{2}.Noise < 550))
mean(receiverData{2}.HourlyDets(receiverData{2}.Noise > 550 & receiverData{2}.Noise < 649))
mean(receiverData{2}.HourlyDets(receiverData{2}.Noise > 650))












