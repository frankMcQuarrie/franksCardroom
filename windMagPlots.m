%%
%Related to paraPerpPlots, run binnedAVG then use this script to bin and
%visualize how detection efficiency changes with increases/decreases in
%wind power.

%binnedAVG


cd ([oneDrive,'exportedFigures'])

%Creating an X-axis to emulate the bins of Wind data, 0-14 m/s
X = 0:14;

seasonName = [{'Winter','Spring','Summer','Fall','Mariner''s Fall','Fall'}]
color = ['r','r','g','g','k','k','b','b','m','m'];


figure()
scatter(X,yearlyWinds,'filled')
ylabel('Normalized Det. Efficiency')
xlabel('Wind Magnitude (m/s)')
title('Wind Magnitude''s Enabling of Detection Success')

for COUNT = 1:length(normalizedWind)
    figure()
    hold on
    for season = 1:length(seasons)
        scatter(X,normalizedWind{COUNT}{season},'filled')
        plot(X,normalizedWind{COUNT}{season})
    end
    nameit = sprintf('Wind Magnitude on Transceiver: %d',COUNT);
    title(nameit)
    ylabel('Normalized Det. Efficiency')
    xlabel('Wind Magnitude (m/s)')
%    lgd =  legend('Winter','Spring','Summer','Fall','Mariners Fall',loc='upper left')
%    lgd.Location = 'northwest';
    exportgraphics(gcf,sprintf('Transceiver%dWinds.png',COUNT),'Resolution',300)
end


%All seasons together
for season = 1:length(seasons)
    figure()
    hold on
    for COUNT = 1:length(normalizedWind)
        scatter(X,normalizedWind{COUNT}{season},'filled')
    end
    nameit = sprintf('Winds During %s',seasonName{season});
    title(nameit)
    ylabel('Normalized Det. Efficiency')
    xlabel('Wind Magnitude (m/s)')
%     legend('Winter','Spring','Summer','Fall','Mariners Fall')
    exportgraphics(gcf,sprintf('WindsDuring %s .png',seasonName{season}),'Resolution',300)
end
