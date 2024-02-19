%FM 2/20/24
%Creating bellhop ray traces to support "sunken reef" idea

cd 'C:\Users\fmm17241\OneDrive - University of Georgia\data\bellhopTesting'


bellhop('frank2D')

figure()
plotray('frank2D')

%Frank needs to test soundsource depths and distances from sunken portion
%of reef. Might end up being separate work
stationWindsAnalysis

mooredEfficiency
%We're looking at {11}, FS17 hearing STSNew1


figure()
scatter(hourlyDetections{11}.time,hourlyDetections{11}.detections)
