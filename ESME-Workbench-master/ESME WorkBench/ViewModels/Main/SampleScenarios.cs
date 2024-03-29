﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ESME;
using ESME.Behaviors;
using ESME.Database;
using ESME.Environment;
using ESME.Locations;
using ESME.Plugins;
using ESME.Scenarios;
using HRC.Navigation;
using HRC.WPF;

namespace ESMEWorkbench.ViewModels.Main
{
    public partial class MainViewModel
    {
        public bool IsSaveSampleDataRequested { get; set; }
        public async void CreateSampleScenariosIfRequested()
        {
            var wind = (EnvironmentalDataSourcePluginBase)ESME.Globals.PluginManagerService[PluginType.EnvironmentalDataSource, PluginSubtype.Wind];
            var soundSpeed = (EnvironmentalDataSourcePluginBase)ESME.Globals.PluginManagerService[PluginType.EnvironmentalDataSource, PluginSubtype.SoundSpeed];
            var bathymetry = (EnvironmentalDataSourcePluginBase)ESME.Globals.PluginManagerService[PluginType.EnvironmentalDataSource, PluginSubtype.Bathymetry];
            var sediment = (EnvironmentalDataSourcePluginBase)ESME.Globals.PluginManagerService[PluginType.EnvironmentalDataSource, PluginSubtype.Sediment];
            foreach (var locations in ESME.Globals.MasterDatabaseService.Context.Locations.Local) locations.UpdateMapLayers();
            if (wind == null || soundSpeed == null || bathymetry == null || sediment == null) return;
            var result = ESME.Globals.VisualizerService.ShowDialog("FirstRunQuestionView", new FirstRunQuestionViewModel { MessageBoxService = ESME.Globals.MessageBoxService });
            if (!result.HasValue || !result.Value) return;
            var progress = new FirstRunProgressViewModel { ItemCount = _sampleScenarios.Count * 4, CurrentItem = 0 };
            var window = ESME.Globals.VisualizerService.ShowWindow("FirstRunProgressView", progress, true);
            _openPopups.Add(window);
            await Task.Delay(10);
            var windData = new EnvironmentalDataSet { SourcePlugin = new DbPluginIdentifier(wind.PluginIdentifier), Resolution = wind.AvailableResolutions.Max() };
            var soundSpeedData = new EnvironmentalDataSet { SourcePlugin = new DbPluginIdentifier(soundSpeed.PluginIdentifier), Resolution = soundSpeed.AvailableResolutions.Max() };
            var bathymetryData = new EnvironmentalDataSet { SourcePlugin = new DbPluginIdentifier(bathymetry.PluginIdentifier), Resolution = bathymetry.AvailableResolutions.Max() };
            var sedimentData = new EnvironmentalDataSet { SourcePlugin = new DbPluginIdentifier(sediment.PluginIdentifier), Resolution = sediment.AvailableResolutions.Max() };
            MediatorMessage.Send(MediatorMessage.SetMapExtent, new GeoRect(45, 22, -65, -120));
            foreach (var scenario in _sampleScenarios)
            {
                //await TestCreateSample(scenario, progress, windData, soundSpeedData, bathymetryData, sedimentData);
                await CreateSample(scenario, progress, windData, soundSpeedData, bathymetryData, sedimentData);
                if (!progress.IsCanceled) continue;
                window.Close();
                return;
            }
            progress.ProgressMessage = string.Format("Updating database...");
            progress.CurrentItem++;
            MediatorMessage.Send(MediatorMessage.RefreshMap, true);
            IsSaveSampleDataRequested = true;
            //Database.SaveChanges();
            window.Close();
        }
        readonly List<SampleScenarioDescriptor> _sampleScenarios = new List<SampleScenarioDescriptor>
        {
#if false
		new SampleScenarioDescriptor
            {
                LocationName = "Gulf of Maine", 
                ScenarioName = "Maine Sample", 
                GeoRect = new GeoRect(44, 41, -65, -71), 
                TimePeriod = (TimePeriod)DateTime.Today.Month,
                PerimeterGeos = new List<Geo>{new Geo(43, -70), new Geo(43, -66), new Geo(42, -66), new Geo(42, -70), new Geo(43, -70), },
            },  
            new SampleScenarioDescriptor
            {
                LocationName = "Florida Atlantic Coast", 
                ScenarioName = "Florida Atlantic Sample", 
                GeoRect = new GeoRect(32, 27, -76, -81.5), 
                TimePeriod = (TimePeriod)DateTime.Today.Month,
                PerimeterGeos = new List<Geo>{new Geo(31, -80.5), new Geo(31, -77), new Geo(28, -77), new Geo(28, -80.5), new Geo(31, -80.5), },
            },
            new SampleScenarioDescriptor
            {
                LocationName = "Florida Gulf Coast", 
                ScenarioName = "Florida Gulf Sample", 
                GeoRect = new GeoRect(30.5, 25, -81, -87), 
                TimePeriod = (TimePeriod)DateTime.Today.Month,
                PerimeterGeos = new List<Geo>{new Geo(29.5, -86), new Geo(29.51923828125, -84.94482421875), new Geo(29.78291015625, -84.0439453125), new Geo(28.94794921875, -83.0771484375), new Geo(28.24482421875, -83.033203125), new Geo(27.40986328125, -82.83544921875), new Geo(26, -82), new Geo(26, -86), new Geo(29.5, -86), },
            },
#endif
            new SampleScenarioDescriptor
            {
                LocationName = "Carolina Coast", 
                ScenarioName = "Carolina Sample", 
                GeoRect = new GeoRect(36, 33, -75, -78), 
                TimePeriod = (TimePeriod)DateTime.Today.Month,
                PerimeterGeos = new List<Geo>{new Geo(34.505712890625, -76.8515625), new Geo(34.714453125, -76.357177734375), new Geo(35.340673828125, -75.99462890625), new Geo(34.78037109375, -75.478271484375), new Geo(33.978369140625, -75.412353515625), new Geo(33.33017578125, -76.291259765625), new Geo(33.74765625, -77.323974609375), new Geo(34.505712890625, -76.8515625), },
                AnalysisPointGeos = new List<Geo>{new Geo(34.0223144531, -75.5991210938), new Geo(33.6487792969, -76.4450683594), new Geo(33.8465332031, -77.0383300781), new Geo(34.8462890625, -75.9616699219)}
            },
            new SampleScenarioDescriptor
            {
                LocationName = "Southern California", 
                ScenarioName = "Southern California Sample", 
                GeoRect = new GeoRect(34, 31, -117.5, -120), 
                TimePeriod = (TimePeriod)DateTime.Today.Month,
                PerimeterGeos = new List<Geo>{new Geo(33.5466597663192, -119.27332988316), new Geo(33.57138671875, -118.72802734375), new Geo(33.241796875, -118.497314453125), new Geo(33.30771484375, -118.013916015625), new Geo(33.0220703125, -117.991943359375), new Geo(33.1099609375, -118.7060546875), new Geo(32.80234375, -118.673095703125), new Geo(32.6265625, -118.211669921875), new Geo(31.4533402336808, -118.22667011684), new Geo(31.4533402336808, -119.27332988316), new Geo(33.5466597663192, -119.27332988316), },
            },
            new SampleScenarioDescriptor
            {
                LocationName = "Bahamas", 
                ScenarioName = "Bahamas Sample", 
                GeoRect = new GeoRect(27, 22, -73.5, -79), 
                TimePeriod = (TimePeriod)DateTime.Today.Month,
                PerimeterGeos = new List<Geo>{new Geo(25.3470671337664, -78.0021554441618), new Geo(25.3744018554687, -77.6507568359375), new Geo(25.7589233398437, -77.2332763671875), new Geo(25.3853881835937, -76.9696044921875), new Geo(25.0338256835937, -77.7056884765625), new Geo(24.4845092773437, -77.3431396484375), new Geo(23.7985296289286, -77.1489493545971), new Geo(23.8309538525164, -77.0243722410368), new Geo(23.7870085400164, -76.6508370847868), new Geo(23.5123503368914, -76.7057687254118), new Geo(23.5453093212664, -77.2221261472868), new Geo(25.3470671337664, -78.0021554441618), },
                AnalysisPointGeos = new List<Geo>{new Geo(23.7042602539, -76.9696044922), new Geo(24.4403442383, -77.48046875), new Geo(25.3512231445, -77.4300439453)},
            },
        };
        class SampleScenarioDescriptor
        {
            public string LocationName { get; set; }
            public string ScenarioName { get; set; }
            public GeoRect GeoRect { get; set; }
            public List<Geo> PerimeterGeos { get; set; }
            public List<Geo> AnalysisPointGeos { get; set; }
            public TimePeriod TimePeriod { get; set; }
        }

        async Task TestCreateSample(SampleScenarioDescriptor scenarioDescriptor, FirstRunProgressViewModel progress, EnvironmentalDataSet windData, EnvironmentalDataSet soundSpeedData, EnvironmentalDataSet bathymetryData, EnvironmentalDataSet sedimentData)
        {
            progress.ProgressMessage = string.Format("Creating sample location \"{0}\"", scenarioDescriptor.LocationName);
            progress.CurrentItem++;
            await Task.Delay(10);
            var location = CreateLocation(scenarioDescriptor.LocationName, "Created as a sample location", scenarioDescriptor.GeoRect);
            location.UpdateMapLayers();
            progress.ProgressMessage = string.Format("Creating sample scenario \"{0}\"", scenarioDescriptor.ScenarioName);
            progress.CurrentItem++;
            await Task.Delay(10);
            var scenario = CreateScenario(location, scenarioDescriptor.ScenarioName, "Created as a sample scenario", scenarioDescriptor.TimePeriod, new TimeSpan(0, 1, 0, 0), windData, soundSpeedData, bathymetryData, sedimentData);
            var perimeterGeoArray = new GeoArray(scenarioDescriptor.PerimeterGeos);
            Perimeter perimeter = (GeoArray)perimeterGeoArray.Closed;
            perimeter.Name = "Sample Perimeter";
            perimeter.Scenario = scenario;
            var platform = new Platform
            {
                Scenario = scenario,
                Course = 0,
                Depth = 0,
                Description = null,
                Geo = ((GeoRect)scenario.Location.GeoRect).Center,
                PlatformName = "Sample Platform",
                Perimeter = perimeter,
                Speed = 10,
                IsRandom = true,
                Launches = false,
                TrackType = TrackType.PerimeterBounce,
                IsNew = false,
                LayerSettings = { IsChecked = true },
            };
            scenario.Perimeters.Add(perimeter);
            //AddMode(AddSource(platform, "High Frequency Source", false), "3 kHz mode", false, 3000, 5);
            AddMode(AddSource(platform, "100 Hz 50000", false), "100 Hz mode", false, 100, 10, 50000);
            AddMode(AddSource(platform, "300 Hz 37500", false), "300 Hz mode", false, 300, 10, 37500);
            AddMode(AddSource(platform, "300 Hz 25000", false), "300 Hz mode", false, 300, 10, 25000);

            platform.Sources[0].Modes[0].TransmissionLossPluginType = ESME.Globals.PluginManagerService[PluginType.TransmissionLossCalculator][PluginSubtype.RAMGeo].DefaultPlugin.PluginIdentifier.Type;
            platform.Sources[1].Modes[0].TransmissionLossPluginType = ESME.Globals.PluginManagerService[PluginType.TransmissionLossCalculator][PluginSubtype.RAMGeo].DefaultPlugin.PluginIdentifier.Type;
            platform.Sources[2].Modes[0].TransmissionLossPluginType = ESME.Globals.PluginManagerService[PluginType.TransmissionLossCalculator][PluginSubtype.Bellhop].DefaultPlugin.PluginIdentifier.Type;
            AddPlatform(scenario, platform);
            progress.ProgressMessage = string.Format("Generating animat population for scenario \"{0}\"", scenarioDescriptor.ScenarioName);
            var species = new ScenarioSpecies
            {
                LatinName = "Generic odontocete",
                Scenario = scenario,
                SpeciesDefinitionFilename = "Generic odontocete.spe",
                LayerSettings =
                {
                    LineOrSymbolSize = 3
                }
            };
            scenario.ScenarioSpecies.Add(species);
            scenario.RemoveMapLayers();
            var animats = await Animat.SeedAsync(species, scenarioDescriptor.GeoRect, (Bathymetry)ESME.Globals.EnvironmentalCacheService[scenario.Bathymetry].Result);
            animats.Save(species.PopulationFilePath);
            //Database.SaveChanges();
            progress.ProgressMessage = string.Format("Extracting environmental data for scenario \"{0}\"", scenarioDescriptor.ScenarioName);
            await Task.WhenAll(ESME.Globals.EnvironmentalCacheService[scenario.Wind], ESME.Globals.EnvironmentalCacheService[scenario.SoundSpeed], ESME.Globals.EnvironmentalCacheService[scenario.Bathymetry], ESME.Globals.EnvironmentalCacheService[scenario.Sediment]);
            progress.CurrentItem++;
            ESME.Globals.Dispatcher.InvokeIfRequired(() =>
            {
                progress.ProgressMessage = string.Format("Adding analysis point(s) to scenario \"{0}\"", scenarioDescriptor.ScenarioName);
                scenario.ShowAllAnalysisPoints = true;
                //if (scenarioDescriptor.AnalysisPointGeos == null || scenarioDescriptor.AnalysisPointGeos.Count < 1) scenario.Add(new AnalysisPoint { Geo = new Geo(((GeoRect)location.GeoRect).Center) });
                //else foreach (var geo in scenarioDescriptor.AnalysisPointGeos) scenario.Add(new AnalysisPoint { Geo = new Geo(geo) });
                if (scenarioDescriptor.AnalysisPointGeos == null || scenarioDescriptor.AnalysisPointGeos.Count < 1) scenario.AnalysisPoints.Add(new AnalysisPoint { Geo = new Geo(((GeoRect)location.GeoRect).Center), Scenario = scenario });
                else foreach (var geo in scenarioDescriptor.AnalysisPointGeos) scenario.AnalysisPoints.Add(new AnalysisPoint { Geo = new Geo(geo), Scenario = scenario });
                scenario.UpdateAnalysisPoints();
                progress.CurrentItem++;
            });
        }

        async Task CreateSample(SampleScenarioDescriptor scenarioDescriptor, FirstRunProgressViewModel progress, EnvironmentalDataSet windData, EnvironmentalDataSet soundSpeedData, EnvironmentalDataSet bathymetryData, EnvironmentalDataSet sedimentData)
        {
            progress.ProgressMessage = string.Format("Creating sample location \"{0}\"", scenarioDescriptor.LocationName);
            progress.CurrentItem++;
            await Task.Delay(10);
            var location = CreateLocation(scenarioDescriptor.LocationName, "Created as a sample location", scenarioDescriptor.GeoRect);
            location.UpdateMapLayers();
            progress.ProgressMessage = string.Format("Creating sample scenario \"{0}\"", scenarioDescriptor.ScenarioName);
            progress.CurrentItem++;
            await Task.Delay(10);
            var scenario = CreateScenario(location, scenarioDescriptor.ScenarioName, "Created as a sample scenario", scenarioDescriptor.TimePeriod, new TimeSpan(0, 1, 0, 0), windData, soundSpeedData, bathymetryData, sedimentData);
            var perimeterGeoArray = new GeoArray(scenarioDescriptor.PerimeterGeos);
            Perimeter perimeter = (GeoArray)perimeterGeoArray.Closed;
            perimeter.Name = "Sample Perimeter";
            perimeter.Scenario = scenario;
            var platform = new Platform
            {
                Scenario = scenario,
                Course = 0,
                Depth = 0,
                Description = null,
                Geo = ((GeoRect)scenario.Location.GeoRect).Center,
                PlatformName = "Sample Platform",
                Perimeter = perimeter,
                Speed = 10,
                IsRandom = true,
                Launches = false,
                TrackType = TrackType.PerimeterBounce,
                IsNew = false,
                LayerSettings = { IsChecked = true },
            };
            scenario.Perimeters.Add(perimeter);
            AddMode(AddSource(platform, "High Frequency Source", false), "3 kHz mode", false, 3000, 5);
            AddMode(AddSource(platform, "Low Frequency Source", false), "100 Hz mode", false, 100, 10, 50000);

            platform.Sources[0].Modes[0].TransmissionLossPluginType = ESME.Globals.PluginManagerService[PluginType.TransmissionLossCalculator][PluginSubtype.Bellhop].DefaultPlugin.PluginIdentifier.Type;
            platform.Sources[1].Modes[0].TransmissionLossPluginType = ESME.Globals.PluginManagerService[PluginType.TransmissionLossCalculator][PluginSubtype.RAMGeo].DefaultPlugin.PluginIdentifier.Type;
            AddPlatform(scenario, platform);
            progress.ProgressMessage = string.Format("Generating animat population for scenario \"{0}\"", scenarioDescriptor.ScenarioName);
            var species = new ScenarioSpecies
            {
                LatinName = "Generic odontocete", 
                Scenario = scenario, 
                SpeciesDefinitionFilename = "Generic odontocete.spe", 
                LayerSettings =
                {
                    LineOrSymbolSize = 3
                }
            };
            scenario.ScenarioSpecies.Add(species);
            scenario.RemoveMapLayers();
            var animats = await Animat.SeedAsync(species, scenarioDescriptor.GeoRect, (Bathymetry)ESME.Globals.EnvironmentalCacheService[scenario.Bathymetry].Result);
            animats.Save(species.PopulationFilePath);
            //Database.SaveChanges();
            progress.ProgressMessage = string.Format("Extracting environmental data for scenario \"{0}\"", scenarioDescriptor.ScenarioName);
            await Task.WhenAll(ESME.Globals.EnvironmentalCacheService[scenario.Wind], ESME.Globals.EnvironmentalCacheService[scenario.SoundSpeed], ESME.Globals.EnvironmentalCacheService[scenario.Bathymetry], ESME.Globals.EnvironmentalCacheService[scenario.Sediment]);
            progress.CurrentItem++;
            ESME.Globals.Dispatcher.InvokeIfRequired(() =>
            {
                progress.ProgressMessage = string.Format("Adding analysis point(s) to scenario \"{0}\"", scenarioDescriptor.ScenarioName);
                scenario.ShowAllAnalysisPoints = true;
                //if (scenarioDescriptor.AnalysisPointGeos == null || scenarioDescriptor.AnalysisPointGeos.Count < 1) scenario.Add(new AnalysisPoint { Geo = new Geo(((GeoRect)location.GeoRect).Center) });
                //else foreach (var geo in scenarioDescriptor.AnalysisPointGeos) scenario.Add(new AnalysisPoint { Geo = new Geo(geo) });
                if (scenarioDescriptor.AnalysisPointGeos == null || scenarioDescriptor.AnalysisPointGeos.Count < 1) scenario.AnalysisPoints.Add(new AnalysisPoint { Geo = new Geo(((GeoRect)location.GeoRect).Center), Scenario = scenario });
                else foreach (var geo in scenarioDescriptor.AnalysisPointGeos) scenario.AnalysisPoints.Add(new AnalysisPoint { Geo = new Geo(geo), Scenario = scenario });
                scenario.UpdateAnalysisPoints();
                progress.CurrentItem++;
            });
        }
    }
}
