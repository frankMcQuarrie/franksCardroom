% FM 3/22/23 Bins fullData by amount of tilt felt by the instruments.
% 
% First use binnedAVG

% clearvars -except fullData fullTide*

%Changing this from just seasons to different transceiver pairings +
%seasons


for COUNT= 1:length(fullData)
    for k = 1:length(seasons)
        %Parallel: X-axis of our tides, aligned with transmissions
        tideBinsPara{COUNT}{k}(1,:) = fullData{COUNT}.paraTide < -.4 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(2,:) =  fullData{COUNT}.paraTide > -.4 &  fullData{COUNT}.paraTide < -.35 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(3,:) =  fullData{COUNT}.paraTide > -.35 &  fullData{COUNT}.paraTide < -.30 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(4,:) =  fullData{COUNT}.paraTide > -.30 & fullData{COUNT}.paraTide <-.25 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(5,:) =  fullData{COUNT}.paraTide > -.25 &  fullData{COUNT}.paraTide < -.20 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(6,:) =  fullData{COUNT}.paraTide > -.20 &  fullData{COUNT}.paraTide < -.15 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(7,:) =  fullData{COUNT}.paraTide > -.15 &  fullData{COUNT}.paraTide < -.10 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(8,:) =  fullData{COUNT}.paraTide > -.1 &  fullData{COUNT}.paraTide < -.05 & fullData{COUNT}.season ==k;

        tideBinsPara{COUNT}{k}(9,:) =  fullData{COUNT}.paraTide > -.05 &  fullData{COUNT}.paraTide < 0.05 & fullData{COUNT}.season ==k;

        tideBinsPara{COUNT}{k}(10,:) =  fullData{COUNT}.paraTide > .05 &  fullData{COUNT}.paraTide < .1 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(11,:) =  fullData{COUNT}.paraTide > .10 &  fullData{COUNT}.paraTide < .15 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(12,:) =  fullData{COUNT}.paraTide > .15 & fullData{COUNT}.paraTide < .2 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(13,:) =  fullData{COUNT}.paraTide > .20 &  fullData{COUNT}.paraTide < .25 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(14,:) =  fullData{COUNT}.paraTide > .25 &  fullData{COUNT}.paraTide < .3 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(15,:) =  fullData{COUNT}.paraTide > .30 &  fullData{COUNT}.paraTide < .35 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(16,:) =  fullData{COUNT}.paraTide > .35 &  fullData{COUNT}.paraTide < .4 & fullData{COUNT}.season ==k;
        tideBinsPara{COUNT}{k}(17,:) =  fullData{COUNT}.paraTide > .40 & fullData{COUNT}.season ==k;
    
    %Perpendicular: Y-axis of our tides, perpendicular to transmissions
        tideBinsPerp{COUNT}{k}(1,:) = fullData{COUNT}.perpTide < -.40  & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(2,:) = fullData{COUNT}.perpTide > -.40 & fullData{COUNT}.perpTide < -.35 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(3,:) = fullData{COUNT}.perpTide > -.35 & fullData{COUNT}.perpTide < -.30 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(4,:) = fullData{COUNT}.perpTide > -.30 & fullData{COUNT}.perpTide < -.25 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(5,:) = fullData{COUNT}.perpTide > -.25 & fullData{COUNT}.perpTide < -.20 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(6,:) = fullData{COUNT}.perpTide > -.20 & fullData{COUNT}.perpTide < -.15 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(7,:) = fullData{COUNT}.perpTide > -.15 & fullData{COUNT}.perpTide < -.10 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(8,:) = fullData{COUNT}.perpTide > -.10 & fullData{COUNT}.perpTide < -.05 & fullData{COUNT}.season ==k;

        tideBinsPerp{COUNT}{k}(9,:) = fullData{COUNT}.perpTide > -.05 & fullData{COUNT}.perpTide < 0.05 & fullData{COUNT}.season ==k;

        tideBinsPerp{COUNT}{k}(10,:) = fullData{COUNT}.perpTide > .05 & fullData{COUNT}.perpTide < .10 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(11,:) = fullData{COUNT}.perpTide > .10 & fullData{COUNT}.perpTide < 0.15 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(12,:) = fullData{COUNT}.perpTide > .15 & fullData{COUNT}.perpTide < .20 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(13,:) = fullData{COUNT}.perpTide > .20 & fullData{COUNT}.perpTide < .25 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(14,:) = fullData{COUNT}.perpTide > .25 & fullData{COUNT}.perpTide < .30 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(15,:) = fullData{COUNT}.perpTide > .30 & fullData{COUNT}.perpTide < .35 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(16,:) = fullData{COUNT}.perpTide > .35 & fullData{COUNT}.perpTide < .40 & fullData{COUNT}.season ==k;
        tideBinsPerp{COUNT}{k}(17,:) = fullData{COUNT}.perpTide > .40 & fullData{COUNT}.season ==k;
    end
end


%I can edit this to choose which seasons. 4 & 5 to compare to 2014
for COUNT = 1:length(fullData)
    for season = 1:length(seasons)
        for k = 1:height(tideBinsPara{COUNT}{season})
            tideScenarioPara{COUNT}{season}{k}= fullData{COUNT}(tideBinsPara{COUNT}{season}(k,:),:);
            tideScenarioPerp{COUNT}{season}{k}= fullData{COUNT}(tideBinsPerp{COUNT}{season}(k,:),:);
            averageParaTide{COUNT}{season}(1,k) = mean(tideScenarioPara{COUNT}{season}{1,k}.detections);
%             averageTilt{COUNT}{season}(1,k) = mean(tideScenarioPara{COUNT}{season}{1,k}.tilt);
%             averagePerpTide{COUNT}{season}(1,k) = mean(tideScenarioPerp{COUNT}{season}{1,k}.detections);
            if isnan(averageParaTide{COUNT}{season}(1,k))
                averageParaTide{COUNT}{season}(1,k) = 0;
            end
%             if isnan(averagePerpTide{COUNT}{season}(1,k))
%                 averagePerpTide{COUNT}{season}(1,k) = 0;
%             end
        end
%         normalizedPara{COUNT}{season}  = averageParaTide{COUNT}{season}/(max(averageParaTide{COUNT}{season}));
%         normalizedPerp{COUNT}{season}  = averagePerpTide{COUNT}{season}/(max(averagePerpTide{COUNT}{season}));
    end
end

for COUNT = 1:2:length(fullData)
    for season = 1:length(seasons)
        comboPlatter = [averageParaTide{COUNT}{season},averageParaTide{COUNT+1}{season}]
        normalizedPara{COUNT}{season}  = averageParaTide{COUNT}{season}/(max(comboPlatter));
        normalizedPara{COUNT+1}{season}  = averageParaTide{COUNT+1}{season}/(max(comboPlatter));
    end
end



for COUNT = 1:length(normalizedPara)
    for season = 1:length(seasons)
        allPara{COUNT}(season,:) = normalizedPara{COUNT}{season};
%         completePerp{COUNT}(season,:) = normalizedPerp{COUNT}{season};
    end
end

%Whole year
for COUNT = 1:length(allPara)
    yearlyParaAVG{COUNT} = mean(allPara{COUNT},1)
%     yearlyPerpAVG(COUNT,:) = mean(completePerp{COUNT},1)
end


%Frank is finding standard deviation

%Normal
for COUNT = 1:length(fullData)
    for season = 1:length(seasons)
        for k = 1:height(tideBinsPara{COUNT}{season})
            if isempty(tideScenarioPara{COUNT}{season}{1,k}) == 1
                errorData{COUNT}(season,k) = 0;
                continue
            end
            errorData{COUNT}(season,k) = std(tideScenarioPara{COUNT}{season}{1,k}.detections)
        end
    end
end