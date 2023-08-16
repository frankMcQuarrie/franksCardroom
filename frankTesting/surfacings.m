%McQuarrie 2021, running scripts at surfacings to model sound speed
%profiles and sound propagation.


addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Matlab');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Matlab/Bellhop');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Matlab/Plot');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Matlab/Misc');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Bellhop');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Kraken');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/RAM off oalib');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/Scooter');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/misc');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/RAM');
addpath('/Users/imager/matlab/frankstuff/at_2020_11_4/tslib');


%Data directory that holds nbd. Change as needed.
datadir= '/Users/imager/dataviz/frankstuff/';


%Reading data out of specific nbd
files = wilddir(datadir, 'nbdasc');
nfile = size(files,1);
sstruct = read_gliderasc([datadir,files(nfile,:)]);

%Current iteration (11/29/2021) of Frank's data cleanup
[dn,temperature,salt,density,depth,speed]=beautifyData(sstruct);


%%  Defining single profile, creating SSP
[yoSSP,yotemps,yotimes,yodepths,yosalt,yospeed] = yoDefinerAuto(dn, depth, temperature, salt, speed);


%% Creates and uses Bellhop Environmental File. Saves environmental file, rayfile, and plotted
%Bellhop model into a directory chosen in CreateEnv.

%Directory to put all files; change as needed.
directory = '/Users/imager/dataviz/frankstuff/';


%Full ray tracing, show all
[waterdepth,beamFile] = ModelSoundSingle(yoSSP,directory);


% Beam Density Analysis, finding ray propagation down range
[gridpoints, gridrays, sumRays] = bdaSingle(beamFile, directory);


% Beam Density Plot, visualization of the beam density analysis
bdaPlotSingle(beamFile,gridpoints,sumRays)



%Gives output file for the yo, giving percentage of rays reaching
%distances down range, and by proxy estimated detection efficiency.
[percentage]=writeBDAoutput(sumRays,gridpoints);



