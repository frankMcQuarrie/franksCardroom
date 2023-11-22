%
%FM 11/16 testing hypothesis about high-frequency noise on and off the reef

%Load in the detection files
cd ([oneDrive,'Moored\GRNMS\VRLs'])
rawDetFile{1,1} = readtable('VR2Tx_483062_20211112_1.csv'); %SURTASSSTN20
rawDetFile{2,1} = readtable('VR2Tx_483064_20211025_1.csv'); %SURTASS05IN
rawDetFile{3,1} = readtable('VR2Tx_483066_20211018_1.csv'); %Roldan
rawDetFile{4,1} = readtable('VR2Tx_483067_20211112_3.csv'); %33OUT??
rawDetFile{5,1} = readtable('VR2Tx_483068_20211223_1.csv'); %FS17??
rawDetFile{6,1} = readtable('VR2Tx_483070_20211223_1.csv'); % 08C
rawDetFile{7,1} = readtable('VR2Tx_483073_20211112_4.csv'); %STSNew1
rawDetFile{8,1} = readtable('VR2Tx_483074_20211025_1.csv'); %STSNEW2
rawDetFile{9,1} = readtable('VR2Tx_483075_20211025_1.csv'); %FS6
rawDetFile{10,1} = readtable('VR2Tx_483076_20211018_1.csv'); %08ALTIN
rawDetFile{11,1} = readtable('VR2Tx_483079_20211130_1.csv'); %34ALTOUT
rawDetFile{12,1} = readtable('VR2Tx_483080_20211223_1.csv'); %09T
rawDetFile{13,1} = readtable('VR2Tx_483081_20211005_1.csv'); %39IN

%Frank's adding in measure of when they hear themselves
selfID = ['A69-1601-63062';'A69-1601-63064';'A69-1601-63066';'A69-1601-63067';...
    'A69-1601-63068';'A69-1601-63070';'A69-1601-63073';'A69-1601-63074';...
    'A69-1601-63075';'A69-1601-63076';'A69-1601-63079';'A69-1601-63080';...
    'A69-1601-63081'];

for transceiver = 1:length(rawDetFile)
    heardSelf{transceiver} = strcmp(rawDetFile{transceiver,1}.Var3,selfID(transceiver,:))
    countSelfDetects(transceiver,1) = sum(heardSelf{transceiver});
end

    selfDetects{transceiver} = rawDetFile{transceiver,heardSelf{transceiver}};

%%FM 5/24: trying bulk strat using bottom receiver + buoy info
cd ([oneDrive,'Moored'])
% Separate dets, temps, and noise by which receiver is giving the data
data = readtable('VUE_Export.csv');


dataDN = datenum(data.DateAndTime_UTC_);
dataDT = datetime(dataDN,'convertFrom','datenum');

%FM 3/6/23 Ordered the transceivers and doubled some up; this is to match
%the transceiver order listed in "matchAngles"/"thetaFinder"
%FM 11/16/23 NEW Frank says that's dumb. We shall go in numerical order, so
%it is written so shall it be done.
uniqueReceivers =  [{'VR2Tx-483062';  % 'VR2Tx-483062' SURTASSSTN20, A
                     'VR2Tx-483064';   % 'VR2Tx-483064' SURTASS_05IN, B
                     'VR2Tx-483066';   % 'VR2Tx-483066' Roldan, C
                     'VR2Tx-483067';    % 33OUT, D
                     'VR2Tx-483068';    %FS17, E
                     'VR2Tx-483070';    %08C, F
                     'VR2Tx-483073';  % 'VR2Tx-483073' STSNew1, G
                     'VR2Tx-483074';   % 'VR2Tx-483074' STSNew2, H
                     'VR2Tx-483075';   % 'VR2Tx-483075' FS6, I
                     'VR2Tx-483076';     % 'VR2Tx-483076' 08ALTIN, J
                     'VR2Tx-483079';   % 34ALTOUT, K
                     'VR2Tx-483080';     %09T, L
                     'VR2Tx-483081'}]   % 'VR2Tx-483081' 39IN, M


%%
% uniqueReceivers = unique(data.Receiver);
letters = 'A':'M';
transceiverNames = {'SURTASSSTN20','SURTASS_05IN','Roldan','33OUT','FS17','08C','STSNew1','STSNew2',...
    'FS6','08ALTIN','34ALTOUT','09T','39IN'};


%% 

%%
%Frank testing
for PT = 1:length(uniqueReceivers)
%     clearvars tempIndex detectionIndex noiseIndex pingIndex tiltIndex
    tempIndex{PT,1}      = strcmp(data.Receiver,uniqueReceivers(PT)) & strcmp(data.Description,'Temperature');
    detectionIndex{PT,1} = strcmp(data.Receiver,uniqueReceivers(PT)) & strcmp(data.Description,'Hourly Detections on 69 kHz');
    noiseIndex{PT,1}     = strcmp(data.Receiver,uniqueReceivers(PT)) & strcmp(data.Description,'Average noise');
    pingIndex{PT,1}      = strcmp(data.Receiver,uniqueReceivers(PT)) & strcmp(data.Description,'Hourly Pings on 69 kHz');
    tiltIndex{PT,1}      = strcmp(data.Receiver,uniqueReceivers(PT)) & strcmp(data.Description,'Tilt angle');
    

    receiverData{PT}     = table(datetime(dataDN(detectionIndex{PT}),'ConvertFrom','datenum','TimeZone','UTC'), ...
                                    dataDN(detectionIndex{PT}), ...
                                    data.Data(detectionIndex{PT}), ...
                                    data.Data(noiseIndex{PT}), ...
                                    data.Data(pingIndex{PT}), ...
                                    data.Data(tiltIndex{PT}), ...
                                    data.Data(tempIndex{PT}))
    receiverData{PT}.Properties.VariableNames = {'DT','DN','HourlyDets','Noise','Pings','Tilt','Temp'};



    receiverIdentity{PT}        = {uniqueReceivers{PT},transceiverNames{PT}, letters(PT)};
    % receiverData{PT}.name            = transceiverNames{PT};
    % receiverData{PT}.letter          = letters(PT);
    % receiverData{PT}.bottomTemp(:,1) = dataDN(tempIndex{PT}); receiverData{PT}.bottomTemp(:,2) = data.Data(tempIndex{PT});
    % receiverData{PT}.hourlyDets(:,1) = dataDN(detectionIndex{PT}); receiverData{PT}.hourlyDets(:,2) = data.Data(detectionIndex{PT});
    % receiverData{PT}.avgNoise(:,1)   = dataDN(noiseIndex{PT}); receiverData{PT}.avgNoise(:,2) = data.Data(noiseIndex{PT});
    % receiverData{PT}.pings(:,1)      = dataDN(pingIndex{PT});  receiverData{PT}.pings(:,2)    = data.Data(pingIndex{PT});
    % receiverData{PT}.tilt(:,1)       = dataDN(tiltIndex{PT}); receiverData{PT}.tilt(:,2)          = data.Data(tiltIndex{PT});
    % receiverData{PT}.DT               = datetime(receiverData{PT}.hourlyDets(:,1),'ConvertFrom','datenum','TimeZone','UTC');

end


%FM need to separate the seasons out for each transceiver :(

months = month(dataDT);

%Winter: Jan/Feb/Nov/Dec
seasonIndex{1} = [1:2,11:12];
%Spring: Mar/Apr/May
seasonIndex{2} = [3:5];
%Summer: Jun/Jul
seasonIndex{3} = [6:7];
%Fall: Aug
seasonIndex{4} = [8];
%Mariner's Fall: Sept/Oct
seasonIndex{5} = [9:10];

%Frank trying to automate separation of months/seasons
for k = 1:length(receiverData)
    originalSeason   = zeros(height(receiverData{k}),1);
    % receiverData{k}.Season = 
    whatMonth{k}     = month(receiverData{k}.DT);
    receiverData{k}.Season = originalSeason;
    winter{k} = ismember(whatMonth{k},seasonIndex{1});
    spring{k} = ismember(whatMonth{k},seasonIndex{2});
    summer{k} = ismember(whatMonth{k},seasonIndex{3});
    fall{k}   = ismember(whatMonth{k},seasonIndex{4});
    mFall{k}  = ismember(whatMonth{k},seasonIndex{5});

    receiverData{k}.Season(winter{k}) = 1;
    receiverData{k}.Season(spring{k}) = 2;
    receiverData{k}.Season(summer{k}) = 3;
    receiverData{k}.Season(fall{k}) = 4;
    receiverData{k}.Season(mFall{k}) = 5;
end

%Frank cleaning up data from deploy/retrieve
%Not the prettiest, but this removes times where tilt and temperature are
%clearly showing its out of the water, or datetimes years after the last
%reliable data.
receiverData{1}= receiverData{1}(20:end,:);
receiverData{2}= receiverData{2}(17:end,:);
receiverData{3}= receiverData{3}(15:10154,:);
receiverData{4}= receiverData{4}(24:end,:);
receiverData{5}= receiverData{5}(20:end,:);
receiverData{6}= receiverData{6}(96:end,:);
receiverData{7}= receiverData{7}(96:end,:);
receiverData{8}= receiverData{8}(23:end,:);
receiverData{9}= receiverData{9}(17:end,:);
receiverData{10}= receiverData{10}(25:end,:);
receiverData{11}= receiverData{11}(4:7685,:);

receiverData{12}= receiverData{12}(3:end,:);
receiverData{13}= receiverData{13}(17:9373,:);

%%
%Frank's testing which had the most pings/dets/noise to check hypothesis of
%the reef being very loud
for k = 1:length(receiverData)
    testingAnnualPings(k) = mean(receiverData{k}.Pings);
    testingAnnualNoise(k) = mean(receiverData{k}.Noise);
    testingAnnualDets(k)  = mean(receiverData{k}.HourlyDets);
end


%Test difference in variables during different seasons
for k = 1:length(receiverData)
    for season = 1:5
        testingPings(k,season) = mean(receiverData{k}.Pings(receiverData{k}.Season == season));
        testingNoise(k,season) = mean(receiverData{k}.Noise(receiverData{k}.Season == season));
        testingDets(k,season)  = mean(receiverData{k}.HourlyDets(receiverData{k}.Season == season));

        %Creating Confidence Intervals
        %Noise
        clearvars ts
        SEMnoise{k}(season,:) = std(receiverData{k}.Noise(receiverData{k}.Season == season),'omitnan')/sqrt(length(receiverData{k}.Noise(receiverData{k}.Season == season)));  
        ts = tinv([0.025  0.975],height(receiverData{k})-1);  
        ciNoise{k}(season,:) = (mean(receiverData{k}.Noise(receiverData{k}.Season == season),'all','omitnan') + ts*SEMnoise{k}(season,:)); 

        %Dets
        clearvars ts
        SEMdets{k}(season,:) = std(receiverData{k}.HourlyDets(receiverData{k}.Season == season),'omitnan')/sqrt(length(receiverData{k}.HourlyDets(receiverData{k}.Season == season)));  
        ts = tinv([0.025  0.975],height(receiverData{k})-1);  
        ciHourlyDets{k}(season,:) = (mean(receiverData{k}.HourlyDets(receiverData{k}.Season == season),'all','omitnan') + ts*SEMdets{k}(season,:)); 

        %Pings
        clearvars ts
        SEMpings{k}(season,:) = std(receiverData{k}.Pings(receiverData{k}.Season == season),'omitnan')/sqrt(length(receiverData{k}.Pings(receiverData{k}.Season == season)));  
        ts = tinv([0.025  0.975],height(receiverData{k})-1);  
        ciPings{k}(season,:) = (mean(receiverData{k}.Pings(receiverData{k}.Season == season),'all','omitnan') + ts*SEMpings{k}(season,:)); 

        %Tilt
        clearvars ts
        SEMtilt{k}(season,:) = std(receiverData{k}.Tilt(receiverData{k}.Season == season),'omitnan')/sqrt(length(receiverData{k}.Tilt(receiverData{k}.Season == season)));  
  
        ts = tinv([0.025  0.975],height(receiverData{k})-1);  
        ciTilt{k}(season,:) = (mean(receiverData{k}.Tilt(receiverData{k}.Season == season),'all','omitnan') + ts*SEMtilt{k}(season,:)); 
    end
end

X = 1:5;

for k = 1:length(receiverData)
    figure()
    hold on
    scatter(X,testingDets(k,:))
end



figure()
scatter(testingNoise,testingDets)

%%
% FM detrending the noise data: removing the mean from all of my
% transceivers

for k = 1:length(receiverData)
    testingDetrend{k} = detrend(receiverData{k}.Noise,'constant')
end

cd ([oneDrive,'exportedfigures\NoiseTesting'])

%Frank needs to define loud and quiet stations from the data
%LOUD: Average noise above 600 mV
%QUIET: Average noise below 600 mV
%Problem with this is that some were deployed for longer winter and such,
%might have to break down by season.


loudStations  = ['A','B','D','H','I','K','L']
quietStations = ['C','E','F','G','J','M']

%L and F both have very low transmissions, BUT different noise



figure()
scatter(testingAnnualNoise,testingAnnualDets,testingAnnualPings,'filled')



figure()
hold on
for k = 1:length(receiverData)
    plot(receiverData{k}.DT,receiverData{k}.Noise)
end
title('Hourly High-Frequency Noise')
ylabel('HF Noise (mV)')


figure()
hold on
for k = 1:length(receiverData)
    plot(receiverData{k}.DT,testingDetrend{k})
end
title('Hourly High-Frequency Noise','DeTrended, Removed Mean')
ylabel('Detrended HF Noise (mV)')


%Frank: Scattering different seasons, loud transceivers vas quiet
%transceivers

loudNumbers  = [1,2,4,8,9,11,12];
quietNumbers = [3,5,6,7,10,13];
X = 1:5;


figure()
hold on
scatter(testingAnnualPings(loudNumbers),testingAnnualDets(loudNumbers),'r','filled')
scatter(testingAnnualPings(quietNumbers),testingAnnualDets(quietNumbers),'b','filled')
title('Detections vs Pings','Annual')
legend('Loud (>600 mV)','Quiet (<600 mV)')
ylabel('Avg. Hourly Detections')
xlabel('Avg. Pings/hour')

for season = 1:5
    figure(season)
    hold on
    scatter(testingPings(loudNumbers,season),testingDets(loudNumbers,season),'r','filled')
    scatter(testingPings(quietNumbers,season),testingDets(quietNumbers,season),'b','filled')
    title(sprintf('Detections vs Pings, %d',season))
    legend('Loud (>600 mV)','Quiet (<600 mV)')
    ylabel('Avg. Hourly Detections')
    xlabel('Avg. Pings/hour')

end

% 2 has tons and tons of noise and pings
% 4 and 5 never heard themselves, assumed never transmitting


figure()
hold on
scatter(testingNoise(loudNumbers,1),testingDets(loudNumbers,1),'r','*')
scatter(testingNoise(quietNumbers,1),testingDets(quietNumbers,1),'b','*')
scatter(testingNoise(loudNumbers,4),testingDets(loudNumbers,4),'r','>','filled')
scatter(testingNoise(quietNumbers,4),testingDets(quietNumbers,4),'b','>','filled')
legend('Winter, On Reef','Winter, Off Reef','Summer, On Reef','Summer, Off Reef')
title('On and Off the Reef','Testing Differences in Noise and Detections')
ylabel('Avg. Hourly Dets')
xlabel('HF Noise (mV)')

figure()
hold on
scatter(testingPings(6,:),testingNoise(6,:),'b','filled')
ciplot(ciPings{6},ciNoise{6},X,'b')
scatter(testingPings(12,:),testingNoise(12,:),'r','filled')
ciplot(ciPings{12},ciNoise{12},X,'r')


LineSpecLoud = ['r','^']
LineSpecQuiet = ['b','^']


figure()
hold on
errorbar(testingPings(6,:),testingNoise(6,:),SEMnoise{6},SEMnoise{6},SEMpings{6},SEMpings{6},LineSpecQuiet)
errorbar(testingPings(12,:),testingNoise(12,:),SEMnoise{12},SEMnoise{12},SEMpings{12},SEMpings{12},LineSpecLoud)
legend('Off Reef','On Reef')