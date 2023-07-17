%FM 2023, Testing diurnal differences during different seasons. The annual
%difference in day vs night is not as clear as expected.

%Run binnedAVG

%Index formed by using the fullData area created in binnedAVG
for COUNT= 1:length(fullData)
    for k = 1:length(seasons)
        daylightIndex{COUNT}{k}(1,:) =  fullData{COUNT}.sunlight==1 & fullData{COUNT}.season ==k;
        daylightIndex{COUNT}{k}(2,:) =  fullData{COUNT}.sunlight==2 & fullData{COUNT}.season ==k;
        daylightIndex{COUNT}{k}(3,:) =  fullData{COUNT}.sunlight==0 & fullData{COUNT}.season ==k;
    
        %Separating data by day, sunset, and night. "Sunset" is defined as
        %the hour in which the sun sets, attempting to find crepuscular
        %period.
        dayHours{k,COUNT}    = fullData{1,COUNT}(daylightIndex{1,COUNT}{1,k}(1,:),:)
        sunsetHours{k,COUNT}  = fullData{1,COUNT}(daylightIndex{1,COUNT}{1,k}(2,:),:)
        nightHours{k,COUNT}  = fullData{1,COUNT}(daylightIndex{1,COUNT}{1,k}(3,:),:)
        %Isolating just the detections and noise. All other variables can
        %be helpful but this is just a way of finding averages 
        dayDets{k}(COUNT,:)    = dayHours{k,COUNT}.detections;
        nightDets{k}(COUNT,:)  = nightHours{k,COUNT}.detections;
        sunsetDets{k}(COUNT,:)  = sunsetHours{k,COUNT}.detections;
        daySounds{k}(COUNT,:)     =dayHours{k,COUNT}.noise;
        nightSounds{k}(COUNT,:)   = nightHours{k,COUNT}.noise;
        sunsetSounds{k}(COUNT,:)   = sunsetHours{k,COUNT}.noise;

    end
end


for k = 1:length(seasons)
    %1st row: DayHoursxSeasons
    %2nd row: SunsetHoursxSeasons
    %3rd row: NightHoursxSeasons
    dayAverages(1,k)    = mean(daySounds{1,k}(:,:),'all')
    dayAverages(2,k)  = mean(sunsetSounds{1,k}(:,:),'all')
    dayAverages(3,k) = mean(nightSounds{1,k}(:,:),'all')
    %Finding standard deviations/CIs of values
    errDay(1,k)   = std(daySounds{1,k}(:))
    errDay(2,k)   = std(sunsetSounds{1,k}(:))
    errDay(3,k)   = std(nightSounds{1,k}(:))
end




figure()
scatter(1:5,dayAverages(1,:),'r','filled')
hold on
scatter(1:5,dayAverages(2,:),'o','filled')
scatter(1:5,dayAverages(3,:),'k','filled')
errorbar(1:5,dayAverages(1,:),errDay(1,:),'LineStyle','none')
errorbar(1:5,dayAverages(2,:),errDay(2,:),'LineStyle','none')
errorbar(1:5,dayAverages(3,:),errDay(3,:),'LineStyle','none')
ylim([0480 800])
xlim([0.85 5.2])
xlabel('Seasons 1:5')
ylabel('Ambient Sounds (db/mV)')
title('Average across Entire Reef')
legend('Day','Sunset','Night')
%%
%Frank separated all the bin creation to not clutter one massive script
%with so many different goals.

% createTideBins
% createTideBinsABS
% createTiltBins
% createWindSpeedBins
% createWindDirBins
% 
% % The big'un. Looking to bin by both tide and wind directions.
% AxisAndAllies   


for COUNT=1:length(fullData)
    sumD(COUNT) = sum(fullData{COUNT}.detections);
end
