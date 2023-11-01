%%
%FM isolating seasonal effects, maybe?


for COUNT = 1:length(fullData)
    for season = 1:length(seasons)
        seasonBin{COUNT}{season} = fullData{COUNT}.season ==season;
    end
end


for COUNT = 1:length(fullData)
    for season = 1:length(seasons)
        seasonScenario{COUNT}{season}= fullData{COUNT}(seasonBin{COUNT}{season},:);
        averageDets{COUNT}(season) = mean(seasonScenario{COUNT}{season}.detections);
        noiseCompare{COUNT}(season) = mean(seasonScenario{COUNT}{season}.noise);
        wavesCompare{COUNT}(season) = mean(seasonScenario{COUNT}{season}.waveHeight);
        tiltCompareWind{COUNT}(season) = mean(seasonScenario{COUNT}{season}.tilt);
        stratCompare{COUNT}(season) = mean(seasonScenario{COUNT}{season}.stratification)
        pingCompare{COUNT}(season) = mean(seasonScenario{COUNT}{season}.pings)
    end
end
% end
% % 

X = 1:5
seasonName = [{'Winter','Spring','Summer','Fall','Mariner''s Fall','Fall'}]
color = ['r','r','g','g','k','k','b','b','m','m'];



for COUNT = 1:length(fullData)
    figure()
    hold on
    for season = 1:length(seasons)
        plot(X,pingCompare{COUNT},color(COUNT))
    end
end


figure()
hold on
for COUNT = 1:length(fullData)
    for season = 1:length(seasons)
        plot(X,pingCompare{COUNT},color(COUNT))
    end
end
xlabel('Season')
ylabel('Pings per hour')
title('Let''s play a game called:','Which Transceiver is in the middle?')



for COUNT = 1:length(fullData)
    for season = 1:length(seasons)
        test = (seasonScenario{COUNT}{season}.detections)*8;
        removeFull{COUNT,season} = seasonScenario{COUNT}{season}.pings - test;
    end
end





%windSpeed by season
for season = 1:length(seasons)
    windSpeedIndex{season,1} = seasonScenario{1}{season}.windSpeed < 2;
    windSpeedIndex{season,2} = seasonScenario{1}{season}.windSpeed < 6 & seasonScenario{1}{season}.windSpeed > 2;
    windSpeedIndex{season,3} = seasonScenario{1}{season}.windSpeed < 10 & seasonScenario{1}{season}.windSpeed > 6;
    windSpeedIndex{season,4} = seasonScenario{1}{season}.windSpeed > 10;
    compareCounts(1,season) = height(seasonScenario{1}{season}(windSpeedIndex{season,1},:))/height(seasonScenario{1}{season});
    compareCounts(2,season) = height(seasonScenario{1}{season}(windSpeedIndex{season,2},:))/height(seasonScenario{1}{season});
    compareCounts(3,season) = height(seasonScenario{1}{season}(windSpeedIndex{season,3},:))/height(seasonScenario{1}{season});
    compareCounts(4,season) = height(seasonScenario{1}{season}(windSpeedIndex{season,4},:))/height(seasonScenario{1}{season});

end

clear compareCounts

%windDir by direction
for season = 1:length(seasons)
    windDirIndex{season,1} = seasonScenario{1}{season}.windDir < 90;
    windDirIndex{season,2} = seasonScenario{1}{season}.windDir < 180 & seasonScenario{1}{season}.windDir > 90;
    windDirIndex{season,3} = seasonScenario{1}{season}.windDir < 270 & seasonScenario{1}{season}.windDir > 180;
    windDirIndex{season,4} = seasonScenario{1}{season}.windDir > 270;
    compareCounts(1,season) = height(seasonScenario{1}{season}(windDirIndex{season,1},:))/height(seasonScenario{1}{season});
    compareCounts(2,season) = height(seasonScenario{1}{season}(windDirIndex{season,2},:))/height(seasonScenario{1}{season});
    compareCounts(3,season) = height(seasonScenario{1}{season}(windDirIndex{season,3},:))/height(seasonScenario{1}{season});
    compareCounts(4,season) = height(seasonScenario{1}{season}(windDirIndex{season,4},:))/height(seasonScenario{1}{season});
end


%Testing pings and detection efficiency
for season = 1:length(seasons)
    windDirIndex{season,1} = seasonScenario{1}{season}.windDir < 90;
    windDirIndex{season,2} = seasonScenario{1}{season}.windDir < 180 & seasonScenario{1}{season}.windDir > 90;
    windDirIndex{season,3} = seasonScenario{1}{season}.windDir < 270 & seasonScenario{1}{season}.windDir > 180;
    windDirIndex{season,4} = seasonScenario{1}{season}.windDir > 270;
    compareCounts(1,season) = height(seasonScenario{1}{season}(windDirIndex{season,1},:))/height(seasonScenario{1}{season});
    compareCounts(2,season) = height(seasonScenario{1}{season}(windDirIndex{season,2},:))/height(seasonScenario{1}{season});
    compareCounts(3,season) = height(seasonScenario{1}{season}(windDirIndex{season,3},:))/height(seasonScenario{1}{season});
    compareCounts(4,season) = height(seasonScenario{1}{season}(windDirIndex{season,4},:))/height(seasonScenario{1}{season});
end

