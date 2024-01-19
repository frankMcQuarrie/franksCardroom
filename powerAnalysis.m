buildReceiverData
clearvars -except receiverData oneDrive githubToolbox
close all

%
%Brock's Code: data, # of bins, Detrend?, Window?, Interval (secs), cutoff
% dataout=Power_spectra(datainA,bins,DT,windoww,samplinginterval,cutoff)
for COUNT = 1:length(receiverData)
    signalNoise{COUNT}  =   receiverData{COUNT}.Noise;
    signalDets{COUNT}   =   receiverData{COUNT}.HourlyDets;
    signalPings{COUNT}  =   receiverData{COUNT}.Pings;
    signalWinds{COUNT}  =   receiverData{COUNT}.windSpd;
    signalCrossTides{COUNT}  =  receiverData{COUNT}.crossShore;
end

%%
        
%Frank's using the cross-shore tidal predictions to test his FFT skills.
%Let's see.


% Receiver 1, so 7760 hours total
% # of hours (or days) / bins
% whole Dataset / 1 bin
% 60 days / 6 bins
% 30 days / 11 bins
% 14 days / 23 bins
% 10 days / 33 bins
% 7 days / 47 bins
% 40 hours / 194 bins


orderUp = [1;11;33;47;194]; %Whole time, 30 day, 10 day, 7 day, and 40 hours
sizes   = [{'WHOLE'};{'30 Days'};{'10 Days'};{'7 Days'};{'40 Hours'}];


figure()
tiledlayout(length(orderUp),1)
for COUNT = 1:length(orderUp)
    noiseStruct{COUNT} = Power_spectra(signalNoise{1}',orderUp(COUNT),1,1,3600,0)
    %
    nexttile()
    plot(noiseStruct{COUNT}.f*86400,(noiseStruct{COUNT}.psdT))
    % xlim([0.7 12])
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title(sprintf('FFT Analysis: HF Noise, %s',sizes{COUNT}),'Windowed, Detrended')
    xticks([10^0 2 3 4 5])
    xticklabels({'Once','Twice','Thrice','4-ice','Fivesies'})
end


figure()
tiledlayout(length(orderUp),1)
for COUNT = 1:length(orderUp)
    detectionStruct{COUNT} = Power_spectra(signalDets{1}',orderUp(COUNT),1,1,3600,0)
    %
    nexttile()
    plot(detectionStruct{COUNT}.f*86400,detectionStruct{COUNT}.psdT)
    % xlim([0.7 12])
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title(sprintf('FFT Analysis: Detections, %s',sizes{COUNT}),'Windowed, Detrended')
end

figure()
tiledlayout(length(orderUp),1)
for COUNT = 1:length(orderUp)
    tideStruct{COUNT} = Power_spectra(signalCrossTides{1}',orderUp(COUNT),1,1,3600,0)
    %
    nexttile()
    plot(tideStruct{COUNT}.f*86400,tideStruct{COUNT}.psdT)
    % xlim([0.7 12])
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title(sprintf('FFT Analysis: Tides, %s',sizes{COUNT}),'Windowed, Detrended')
end
%%
%Frank plotting different outputs in the structure.

figure()
tiledlayout(4,1,'TileSpacing','Compact')
tideStruct = Power_spectra(signalCrossTides{1}',33,1,0,3600,0)

nexttile()
plot(tideStruct.f*86400,tideStruct.s)
% xlim([0.7 12])
set(gca,'XScale','log')
set(gca,'YScale','log')
title('FFT Analysis: Predicted Tides, S','10 Day Bin, Detrended')

nexttile()
plot(tideStruct.f*86400,tideStruct.psdf)
% xlim([0.7 12])
set(gca,'XScale','log')
set(gca,'YScale','log')
title('FFT Analysis: Predicted Tides, PSDF','10 Day Bin, Detrended')

nexttile()
plot(tideStruct.f*86400,tideStruct.psdw)
% xlim([0.7 12])
set(gca,'XScale','log')
set(gca,'YScale','log')
title('FFT Analysis: Predicted Tides, PSDW','10 Day Bin, Detrended')

nexttile()
plot(tideStruct.f*86400,tideStruct.psdT)
% xlim([0.7 12])
set(gca,'XScale','log')
set(gca,'YScale','log')
title('FFT Analysis: Predicted Tides, PSDT','10 Day Bin, Detrended')
xlabel('Cycles per Day')


%%
Fs = (2*pi)/(60*60);            % Sampling frequency, 1 sample every 60 minutes. Added 2pi; this is per second, Hz
FsPerDay = Fs*86400;            % This turns it to how many times per day
%%



for COUNT = 1:length(receiverData)
    struct{COUNT} = Power_spectra(signalNoise{COUNT}',2,0,0,3600,0)
end

for COUNT = 1:length(receiverData)
    figure()
    plot(struct{COUNT}.f*86400,struct{COUNT}.psdf)
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title(sprintf('%d, Per Day, PSDF',COUNT))

    figure()
    plot(struct{COUNT}.f*86400,struct{COUNT}.psdw)
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title(sprintf('%d, Per Day, PSDW',COUNT))

    figure()
    plot(struct{COUNT}.f*86400,struct{COUNT}.v)
    set(gca,'XScale','log')
    set(gca,'YScale','log')
    title(sprintf('%d, Per Day, V',COUNT))


end





for COUNT = 1:length(receiverData)
    figure()
    plot(FsPerDay/L{COUNT}*(0:L{COUNT}-1),struct.psdf)
end








%%
%Set up FFT variables
Fs = (2*pi)/(60*60);            % Sampling frequency, 1 sample every 60 minutes. Added 2pi.
FsPerDay = Fs*86400;

for COUNT =  1:length(receiverData)
    Y{COUNT} = fft(signalNoise{COUNT})              % FFT of the processed signals 
    L{COUNT} = height(signalNoise{COUNT})        % Length of signal
    magnitude{COUNT} = abs(Y{COUNT});
    averageWindowOutput{COUNT}(:,1) = mean(Y{COUNT},2); %Averaging all my windows
end


for COUNT = 1:length(receiverData)
    figure(COUNT)
    % plot(FsPerDay/L{1}*(0:L{1}-1),abs(rawSignalProcess.*conj(rawSignalProcess)),'r',"LineWidth",3)
    plot(FsPerDay/L{COUNT}*(0:L{COUNT}-1),abs(Y{COUNT}),'r',"LineWidth",3)    
    title("", "FFT Output, Log")
    xlabel("f (Hz)")
    ylabel("|fft(X)|")
    set(gca,'XScale','log')
    set(gca,'YScale','log')
end


%%
%Processing
clearvars Y L magnitude averageWindowOutput
for COUNT =  1:length(receiverData)
    signalNoiseProcessed{COUNT} = buffer(signalNoise{COUNT},40,20);  
    signalNoiseProcessed{COUNT} = padarray(signalNoiseProcessed{COUNT},height(signalNoiseProcessed{COUNT})*2,'post');
end


for COUNT =  1:length(receiverData)
    Y{COUNT} = fft(signalNoiseProcessed{COUNT})              % FFT of the processed signals 
    L{COUNT} = height(signalNoiseProcessed{COUNT})        % Length of signal
    magnitude{COUNT} = abs(Y{COUNT});
    averageWindowOutput{COUNT}(:,1) = mean(Y{COUNT},2); %Averaging all my windows
end


for COUNT = 1:length(receiverData)
    figure(COUNT)
    % plot(FsPerDay/L{1}*(0:L{1}-1),abs(rawSignalProcess.*conj(rawSignalProcess)),'r',"LineWidth",3)
    plot(FsPerDay/L{COUNT}*(0:L{COUNT}-1),abs(averageWindowOutput{COUNT}),'r',"LineWidth",3)    
    title("", "FFT Output, Log")
    xlabel("f (Hz)")
    ylabel("|fft(X)|")
    set(gca,'XScale','log')
    set(gca,'YScale','log')
end


%%
% Passing shit
wpass = (2*pi)/172800;
Fs = (2*pi)/3600 %Frequency, hertz
bandWork = [(2*pi)/2592000 (2*pi)/172800]

bandpass(signalNoise{1},bandWork,Fs)

%
mscohere(signalNoise{5},signalCrossTides{5})




% Filter white noise sampled at 1 kHz with a bandpass filter with
% passband frequencies of [150, 350] Hz. Use different steepness values.
% Plot the spectra of the filtered signals as well as the responses
% of the resulting filters. 
Fs = 1000;
x = randn(2000,1);
[y1, D1] = bandpass(x,[150,350],Fs,'Steepness',0.5);
[y2, D2] = bandpass(x,[150,350],Fs,'Steepness',0.8);
[y3, D3] = bandpass(x,[150,350],Fs,'Steepness',0.95);
pspectrum([y1 y2 y3], Fs)
legend('Steepness = 0.5','Steepness = 0.8','Steepness = 0.95')
fvt = fvtool(D1,D2,D3);
legend(fvt,'Steepness = 0.5','Steepness = 0.8','Steepness = 0.95')







