﻿using System;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Reactive.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using ESME;
using ESME.Behaviors;
using ESME.Environment;
using ESME.Locations;
using ESME.Plugins;
using ESME.Scenarios;
using ESME.Simulator;
using ESME.Views.Controls;
using ESME.Views.Scenarios;
using ESME.Views.Simulation;
using ESMEWorkbench.ViewModels.Map;
using ESMEWorkbench.ViewModels.Tree;
using HRC;
using HRC.Aspects;
using HRC.Navigation;
using HRC.ViewModels;
using HRC.WPF;

namespace ESMEWorkbench.ViewModels.Main
{
    public partial class MainViewModel
    {
        Scenario _scenario;

        [Initialize] public LayerTreeViewModel LayerTreeViewModel { get; set; }
        public MapViewModel MapViewModel { get; set; }

        [Affects("IsScenarioLoaded", "CanPlaceAnalysisPoint", "IsRunSimulationCommandEnabled", "MainWindowTitle", "IsSaveScenarioCommandEnabled")] 
        public Scenario Scenario
        {
            get { return _scenario; }
            set
            {
                try
                {
                    if (_scenario != null)
                    {
                        _scenario.RemoveMapLayers();
                        _scenario.PropertyChanged -= ScenarioPropertyChangedMonitor;
                        _scenario.IsLoaded = false;
                    }
                    if (_mouseHoverSubscription != null) _mouseHoverSubscription.Dispose();
                    _mouseHoverSubscription = null;
                    _scenario = value;
                    LayerTreeViewModel.Scenario = _scenario;
                    if (_scenario == null) return;
                    _mouseHoverSubscription = MapViewModel.MouseHoverGeo.ObserveOnDispatcher().Subscribe(g => _scenario.MouseHoverGeo = g);
                    _scenario.PropertyChanged += ScenarioPropertyChangedMonitor;
                    _scenario.UpdateMapLayers();
                    Globals.EnvironmentalCacheService[_scenario.Wind].ContinueWith(t => Globals.Dispatcher.InvokeInBackgroundIfRequired(() =>
                    {
                        if (_scenario.Wind.SampleCount == 0) Globals.MessageBoxService.ShowError(string.Format("No wind data was found in this location using source {0}", Globals.PluginManagerService[_scenario.Wind.SourcePlugin].PluginName));
                        else
                        {
                            _scenario.Wind.UpdateMapLayers();
                            _scenario.Wind.LayerSettings.MoveLayerToBack();
                        }
                    }));
                    Globals.EnvironmentalCacheService[_scenario.SoundSpeed].ContinueWith(t => Globals.Dispatcher.InvokeInBackgroundIfRequired(() =>
                    {
                        if (_scenario.SoundSpeed.SampleCount == 0) Globals.MessageBoxService.ShowError(string.Format("No sound speed data was found in this location using source {0}", Globals.PluginManagerService[_scenario.SoundSpeed.SourcePlugin].PluginName));
                        else
                        {
                            _scenario.SoundSpeed.UpdateMapLayers();
                            _scenario.SoundSpeed.LayerSettings.MoveLayerToBack();
                        }
                    }));
                    Globals.EnvironmentalCacheService[_scenario.Bathymetry].ContinueWith(t => Globals.Dispatcher.InvokeInBackgroundIfRequired(() =>
                    {
                        if (_scenario.Bathymetry.SampleCount == 0) Globals.MessageBoxService.ShowError(string.Format("No bathymetry data was found in this location using source {0}", Globals.PluginManagerService[_scenario.Bathymetry.SourcePlugin].PluginName));
                        else
                        {
                            _scenario.Bathymetry.UpdateMapLayers();
                            _scenario.Bathymetry.LayerSettings.MoveLayerToBack();
                        }
                    }));
                    Globals.EnvironmentalCacheService[_scenario.Sediment].ContinueWith(t => Globals.Dispatcher.InvokeInBackgroundIfRequired(() =>
                    {
                        if (_scenario.Sediment.SampleCount == 0) Globals.MessageBoxService.ShowError(string.Format("No sediment data was found in this location using source {0}", Globals.PluginManagerService[_scenario.Sediment.SourcePlugin].PluginName));
                        else
                        {
                            _scenario.Sediment.UpdateMapLayers();
                            _scenario.Sediment.LayerSettings.MoveLayerToBack();
                        }
                    }));
                    _scenario.IsLoaded = true;
                    _scenario.Location.LayerSettings.IsChecked = true;
                    MediatorMessage.Send(MediatorMessage.SetMapExtent, (GeoRect)_scenario.Location.GeoRect);
                    MediatorMessage.Send(MediatorMessage.RefreshMap, true);
                    foreach (var analysisPoint in _scenario.AnalysisPoints) analysisPoint.CheckForErrors();
                }
                catch (Exception e)
                {
                    Globals.MessageBoxService.ShowError(e.Message);
                    _scenario = null;
                    OnPropertyChanged("Scenario");
                }
            }
        }

        IDisposable _mouseHoverSubscription;

        void ScenarioPropertyChangedMonitor(object s, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == "Name") OnPropertyChanged("MainWindowTitle");
        }
        public bool IsScenarioLoaded { get { return Scenario != null; } }
        public string CanPlaceAnalysisPointTooltip { get; set; }

        public bool CanPlaceAnalysisPoint
        {
            get
            {
                var sb = new StringBuilder();
                if (Scenario == null | IsSimulationRunning)
                {
                    sb.AppendLine("You can't place an analysis point right now because:");
                    if (Scenario == null) sb.AppendLine("  • No scenario is selected");
                    if (IsSimulationRunning) sb.AppendLine("  • A simulation is currently running");
                    CanPlaceAnalysisPointTooltip = sb.ToString();
                    OnPropertyChanged("IsRunSimulationCommandEnabled");
                    return false;
                }

                if (!Scenario.CanPlaceAnalysisPoints())
                {
                    sb.AppendLine("You can't place an analysis point right now because:");
                    sb.AppendLine(Scenario.GenerateCanPlaceAnalysisPointsErrorString());
                    CanPlaceAnalysisPointTooltip = sb.ToString();
                    OnPropertyChanged("IsRunSimulationCommandEnabled");
                    return false;
                }
                CanPlaceAnalysisPointTooltip = "After clicking on this button, click within the simulation boundaries on the map to place a new analysis point";
                OnPropertyChanged("IsRunSimulationCommandEnabled");
                OnPropertyChanged("IsSaveScenarioCommandEnabled");
                return true;
            }
        }

        [Affects("CanPlaceAnalysisPoint", "IsRunSimulationCommandEnabled")]
        public bool IsSimulationRunning { get; set; }

        public bool IsInAnalysisPointMode { get; set; }

        public string MainWindowTitle { get { return string.Format("ESME 2014: {0}", _scenario == null ? "<No scenario loaded>" : _scenario.Name); } }

        #region CreateScenarioCommand
        public SimpleCommand<object, EventToCommandArgs> CreateScenarioCommand { get { return _createScenario ?? (_createScenario = new SimpleCommand<object, EventToCommandArgs>(o => IsCreateScenarioCommandEnabled, o => CreateScenarioHandler())); } }
        SimpleCommand<object, EventToCommandArgs> _createScenario;

        bool IsCreateScenarioCommandEnabled
        {
            get
            {
                return Globals.MasterDatabaseService != null && Globals.MasterDatabaseService.Context != null && Globals.MasterDatabaseService.Context.Locations.Local.Count > 0;
            }
        }

        Location _lastCreateScenarioLocation;
        [MediatorMessageSink(MediatorMessage.CreateScenario)]
        void CreateScenarioHandler(Location location = null)
        {
            try
            {
                if (_lastCreateScenarioLocation == null) _lastCreateScenarioLocation = Globals.MasterDatabaseService.Context.Locations.Local.First();
                var vm = new CreateScenarioViewModel
                {
                    Locations = Globals.MasterDatabaseService.Context.Locations.Local,
                    PluginManager = Globals.PluginManagerService,
                    Location = location ?? _lastCreateScenarioLocation,
                    TimePeriod = (TimePeriod)DateTime.Today.Month,
                    IsLocationSelectable = location == null
                };
                var result = Globals.VisualizerService.ShowDialog("CreateScenarioView", vm);
                if ((!result.HasValue) || (!result.Value)) return;
                if (location == null) _lastCreateScenarioLocation = vm.Location;
                var scenario = CreateScenario(vm.Location,
                                              vm.ScenarioName,
                                              vm.Comments,
                                              vm.TimePeriod,
                                              vm.Duration,
                                              vm.SelectedPlugins[PluginSubtype.Wind].SelectedDataSet,
                                              vm.SelectedPlugins[PluginSubtype.SoundSpeed].SelectedDataSet,
                                              vm.SelectedPlugins[PluginSubtype.Bathymetry].SelectedDataSet,
                                              vm.SelectedPlugins[PluginSubtype.Sediment].SelectedDataSet);
                Scenario = scenario;
            }
            catch (DuplicateNameException exception)
            {
                Globals.MessageBoxService.ShowError("Error creating this Scenario: " + exception.Message);
            }
        }

        Scenario CreateScenario(Location location, string scenarioName, string comments, TimePeriod timePeriod, TimeSpan duration, EnvironmentalDataSet wind, EnvironmentalDataSet soundSpeed, EnvironmentalDataSet bathymetry, EnvironmentalDataSet sediment)
        {
            var scenario = new Scenario
            {
                Wind = Globals.MasterDatabaseService.LoadOrCreateEnvironmentalDataSet(location, wind.Resolution, timePeriod, wind.SourcePlugin),
                SoundSpeed = Globals.MasterDatabaseService.LoadOrCreateEnvironmentalDataSet(location, soundSpeed.Resolution, timePeriod, soundSpeed.SourcePlugin),
                Bathymetry = Globals.MasterDatabaseService.LoadOrCreateEnvironmentalDataSet(location, bathymetry.Resolution, TimePeriod.Invalid, bathymetry.SourcePlugin),
                Sediment = Globals.MasterDatabaseService.LoadOrCreateEnvironmentalDataSet(location, sediment.Resolution, TimePeriod.Invalid, sediment.SourcePlugin),
                Name = scenarioName,
                Location = location,
                Comments = comments,
                TimePeriod = timePeriod,
                Duration = duration,
                ShowAllPerimeters = true,
                ShowAllAnalysisPoints = true,
                ShowAllSpecies = false,
            };
            scenario.SoundSpeed.LayerSettings.LineOrSymbolSize = 5;
            var existing = (from s in location.Scenarios
                            where s.Name == scenario.Name && s.Location == scenario.Location
                            select s).FirstOrDefault();
            if (existing != null) throw new DuplicateNameException(String.Format("a Scenario named \"{0}\" already exists in the Location \"{1}\"; please select another name.", scenario.Name, scenario.Location.Name));
            location.Scenarios.Add(scenario);
            Globals.MasterDatabaseService.Context.Scenarios.Add(scenario);
            return scenario;
        }
        #endregion

        #region SaveScenarioCommand
        public SimpleCommand<object, object> SaveScenarioCommand
        {
            get
            {
                return _save ?? (_save = new SimpleCommand<object, object>(o =>
                {
                    if (IsSaveScenarioCommandEnabled)
                    {
                        Globals.MasterDatabaseService.SaveChanges();
                        OnPropertyChanged("IsSaveScenarioCommandEnabled");
                    }
                }));
            }
        }

        SimpleCommand<object, object> _save;
        public bool IsSaveScenarioCommandEnabled { get { return (!IsTransmissionLossBusy) && Globals.MasterDatabaseService != null && Globals.MasterDatabaseService.Context != null && Globals.MasterDatabaseService.Context.IsModified; } }
        #endregion

        #region Handlers for Scenario-related MediatorMessages
        [MediatorMessageSink(MediatorMessage.LoadScenario), UsedImplicitly]
        void LoadScenario(Scenario scenario) { Scenario = scenario; }

        [MediatorMessageSink(MediatorMessage.DeleteAllScenarios), UsedImplicitly]
        void DeleteAllScenarios(Location location)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete all scenarios in location \"{0}\"?", location.Name), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            foreach (var scenario in location.Scenarios.ToList()) scenario.Delete();
        }

        [MediatorMessageSink(MediatorMessage.DeleteScenario), UsedImplicitly]
        void DeleteScenario(Scenario scenario)
        {
            if (IsSimulationRunning || IsTransmissionLossBusy)
            {
                Globals.MessageBoxService.ShowInformation("A scenario cannot be deleted while a simulation is running or transmission losses are being calculated.  Please wait until these tasks finish.");
            }
            else
            {
                if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete the scenario \"{0}\"?", scenario.Name), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
                scenario.Delete();
            }
        }

        [MediatorMessageSink(MediatorMessage.ViewScenarioProperties), UsedImplicitly]
        void ViewScenarioProperties(Scenario scenario)
        {
            Globals.VisualizerService.ShowDialog("ScenarioPropertiesView", new ScenarioPropertiesViewModel(scenario));
        }

        [MediatorMessageSink(MediatorMessage.SaveScenarioCopy), UsedImplicitly]
        void SaveScenarioCopy(Scenario scenario)
        {
            var copy = new Scenario(scenario) { Name = "Copy of " + scenario.Name };
            var copyNumber = 2;
            while ((from s in scenario.Location.Scenarios
                    where s.Name == copy.Name
                    select s).FirstOrDefault() != null) copy.Name = "Copy " + copyNumber++ + " of " + scenario.Name;
            scenario.Location.Scenarios.Add(copy);
            Globals.MasterDatabaseService.Context.Scenarios.Add(copy);
        }
        #endregion

        #region Handlers for AnalysisPoint-related MediatorMessages
        [MediatorMessageSink(MediatorMessage.DeleteAnalysisPoint), UsedImplicitly]
        void DeleteAnalysisPoint(AnalysisPoint analysisPoint)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete this analysis point \"{0}\"?", analysisPoint.Geo), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            //analysisPoint.LayerSettings.IsChecked = false;
            //analysisPoint.RemoveMapLayers();
            //await Task.Delay(50);
            analysisPoint.Delete();
            OnPropertyChanged("IsRunSimulationCommandEnabled");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.DeleteAllAnalysisPoints), UsedImplicitly]
        void DeleteAllAnalysisPoints(bool dummy)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete all analysis points from the scenario {0} ?", Scenario.Name), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            //foreach (var analysisPoint in Scenario.AnalysisPoints) analysisPoint.LayerSettings.IsChecked = false;
            //foreach (var analysisPoint in Scenario.AnalysisPoints) analysisPoint.RemoveMapLayers();
            //await Task.Delay(50);
            foreach (var analysisPoint in Scenario.AnalysisPoints.ToList()) analysisPoint.Delete();
            OnPropertyChanged("IsRunSimulationCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.RecalculateAnalysisPoint), UsedImplicitly]
        void RecalculateAnalysisPoint(AnalysisPoint analysisPoint)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to recalculate this analysis point \"{0}\"?", analysisPoint.Geo), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            analysisPoint.Recalculate();
        }

        [MediatorMessageSink(MediatorMessage.ViewAnalysisPointProperties), UsedImplicitly]
        void ViewAnalysisPointProperties(AnalysisPoint analysisPoint) { Globals.VisualizerService.ShowDialog("TreeViewItemPropertiesView", new AnalysisPointPropertiesViewModel { PropertyObject = analysisPoint }); }

        [MediatorMessageSink(MediatorMessage.RecalculateAllAnalysisPoints), UsedImplicitly]
        void RecalculateAllAnalysisPoints(bool dummy)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to recalculate all analysis points from the scenario {0} ?", Scenario.Name), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            foreach (var analysisPoint in Scenario.AnalysisPoints) analysisPoint.Recalculate();
        }
        #endregion

        #region Handlers for TransmissionLoss-related MediatorMessages
        [MediatorMessageSink(MediatorMessage.DeleteTransmissionLoss), UsedImplicitly]
        void DeleteTransmissionLoss(TransmissionLoss transmissionLoss)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete this transmission loss \"{0}\"?", transmissionLoss.AnalysisPoint.Geo), MessageBoxImage.Warning) !=
                MessageBoxResult.Yes) return;
            //transmissionLoss.LayerSettings.IsChecked = false;
            //transmissionLoss.RemoveMapLayers();
            //await Task.Delay(50);
            transmissionLoss.Delete();
        }

        [MediatorMessageSink(MediatorMessage.RecalculateTransmissionLoss), UsedImplicitly]
        void RecalculateTransmissionLoss(TransmissionLoss transmissionLoss)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to recalculate this transmission loss \"{0}\"?", transmissionLoss.AnalysisPoint.Geo), MessageBoxImage.Warning) !=
                MessageBoxResult.Yes) return;
            transmissionLoss.Recalculate();
        }

        [MediatorMessageSink(MediatorMessage.TransmissionLossLayerChanged), UsedImplicitly]
        void TransmissionLossLayerChanged(IHaveLayerSettings transmissionLoss)
        {
            Globals.Dispatcher.InvokeInBackgroundIfRequired(() =>
            {
                transmissionLoss.RemoveMapLayers();
                if (!transmissionLoss.IsDeleted) transmissionLoss.UpdateMapLayers();
            });
        }
        #endregion

        #region Handlers for Platform-related MediatorMessages and associated utility routines
        [MediatorMessageSink(MediatorMessage.AddPlatform), UsedImplicitly]
        void AddPlatform(Scenario scenario)
        {
            if (scenario.LayerControl != null) ((LayerControl)scenario.LayerControl).Expand();
            var platform = new Platform
            {
                Scenario = scenario,
                Course = 0,
                Depth = 0,
                Description = null,
                Geo = ((GeoRect)scenario.Location.GeoRect).Center,
                PlatformName = "New Platform",
                IsRandom = false,
                Launches = false,
                TrackType = TrackType.Stationary,
                IsNew = true,
            };
            scenario.Platforms.Add(platform);
            platform.UpdateMapLayers();
            OnPropertyChanged("CanPlaceAnalysisPoint");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        static void AddPlatform(Scenario scenario, Platform platform)
        {
            scenario.Platforms.Add(platform);
            platform.UpdateMapLayers();
        }

        [MediatorMessageSink(MediatorMessage.PlatformBoundToLayer), UsedImplicitly]
        async void PlatformBoundToLayer(Platform platform)
        {
            if (!platform.IsNew) return;
            platform.IsNew = false;
            ((LayerControl)platform.LayerControl).Select();
            await Task.Delay(50);
            ((LayerControl)platform.LayerControl).Edit();
        }

        [MediatorMessageSink(MediatorMessage.DeletePlatform), UsedImplicitly]
        void DeletePlatform(Platform platform)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete the platform \"{0}\"?", platform.PlatformName), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            platform.Delete();
            OnPropertyChanged("CanPlaceAnalysisPoint");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.PlatformProperties), UsedImplicitly]
        void PlatformProperties(Platform platform)
        {
            var vm = new PlatformPropertiesViewModel(platform);
            Globals.VisualizerService.ShowDialog("PlatformPropertiesView", vm);
            //ESME.Globals.VisualizerService.ShowDialog("TreeViewItemPropertiesView", new PlatformPropertiesViewModel { Platform = platform });
        }
        #endregion

        #region Handlers for Source-related MediatorMessages and associated utility routines
        [MediatorMessageSink(MediatorMessage.AddSource), UsedImplicitly]
        void AddSource(Platform platform)
        {
            //var vm = new CreateSourceViewModel();
            //var result = ESME.Globals.VisualizerService.ShowDialog("CreateSourceView", vm);
            //if (!result.HasValue || !result.Value) return;
            ((LayerControl)platform.LayerControl).Expand();
            AddSource(platform, "New Source", true);
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        static Source AddSource(Platform platform, string name, bool isNew)
        {
            var source = new Source
            {
                Platform = platform,
                SourceName = name,
                SourceType = null,
                IsNew = isNew,
            };
            platform.Sources.Add(source);
            return source;
        }

        [MediatorMessageSink(MediatorMessage.SourceBoundToLayer), UsedImplicitly]
        async void SourceBoundToLayer(Source source)
        {
            if (!source.IsNew) return;
            source.IsNew = false;
            ((LayerControl)source.LayerControl).Select();
            await Task.Delay(50);
            ((LayerControl)source.LayerControl).Edit();
        }

        [MediatorMessageSink(MediatorMessage.DeleteSource), UsedImplicitly]
        void DeleteSource(Source source)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete the source \"{0}\"?", source.SourceName), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            source.Delete();
            OnPropertyChanged("CanPlaceAnalysisPoint");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.SourceProperties), UsedImplicitly]
        void SourceProperties(Source source)
        {
            //ESME.Globals.VisualizerService.ShowDialog("TreeViewItemPropertiesView", new SourcePropertiesViewModel { Source = source });
            var vm = new PropertiesViewModel { PropertyObject = source, WindowTitle = "Source Properties: " + source.SourceName };
            Globals.VisualizerService.ShowDialog("SourcePropertiesView", vm);
        }
        #endregion

        #region Handlers for Mode-related MediatorMessages and associated utility routines
        [MediatorMessageSink(MediatorMessage.AddMode), UsedImplicitly]
        void AddMode(Source source)
        {
            //var vm = new CreateModeViewModel();
            //var result = ESME.Globals.VisualizerService.ShowDialog("CreateModeView", vm);
            //if (!result.HasValue || !result.Value) return;
            ((LayerControl)source.LayerControl).Expand();
            AddMode(source, "New Mode", true);
            OnPropertyChanged("CanPlaceAnalysisPoint");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        void AddMode(Source source, string name, bool isNew, float frequency = 1000f, float depth = 0f, float maxPropagationRadius = 25000f)
        {
            var mode = new Mode
            {
                ActiveTime = 1f,
                Depth = depth,
                DepressionElevationAngle = 0f,
                HighFrequency = frequency,
                LowFrequency = frequency,
                MaxPropagationRadius = maxPropagationRadius,
                ModeName = name,
                ModeType = null,
                PulseInterval = new TimeSpan(0, 0, 0, 30),
                PulseLength = new TimeSpan(0, 0, 0, 0, 500),
                RelativeBeamAngle = 0,
                Source = source,
                SourceLevel = 200,
                VerticalBeamWidth = 180f,
                HorizontalBeamWidth = 90,
                IsNew = isNew,
                TransmissionLossPluginType = Globals.PluginManagerService[PluginType.TransmissionLossCalculator][PluginSubtype.Bellhop].DefaultPlugin.PluginIdentifier.Type,
            };
            source.Modes.Add(mode);
            //source.Platform.Scenario.Add(mode);
            source.Platform.Scenario.UpdateAnalysisPoints();
        }

        [MediatorMessageSink(MediatorMessage.ModeBoundToLayer), UsedImplicitly]
        async void ModeBoundToLayer(Mode mode)
        {
            if (!mode.IsNew) return;
            mode.IsNew = false;
            ((LayerControl)mode.LayerControl).Select();
            await Task.Delay(50);
            ((LayerControl)mode.LayerControl).Edit();
        }

        [MediatorMessageSink(MediatorMessage.DeleteMode), UsedImplicitly]
        void DeleteMode(Mode mode)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete the mode \"{0}\"?", mode.ModeName), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            mode.Delete();
            OnPropertyChanged("CanPlaceAnalysisPoint");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.RecalculateMode), UsedImplicitly]
        void RecalculateMode(Mode mode)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to recalculate all transmission losses for the mode \"{0}\"?", mode.ModeName), MessageBoxImage.Warning) !=
                MessageBoxResult.Yes) return;
            foreach (var transmissionLoss in mode.TransmissionLosses) transmissionLoss.Recalculate();
        }

        [MediatorMessageSink(MediatorMessage.ModeProperties), UsedImplicitly]
        void ModeProperties(Mode mode)
        {
            var vm = new ModePropertiesViewModel(mode);
            var result = Globals.VisualizerService.ShowDialog("ModePropertiesWindowView", vm);
            if (!(result.HasValue && result.Value)) return;
            mode.LowFrequency = mode.HighFrequency;
            Scenario.UpdateAnalysisPoints();
        }
        #endregion

        #region Handlers for Species-related MediatorMessages
        [MediatorMessageSink(MediatorMessage.AddSpecies), UsedImplicitly]
        async void AddSpecies(Scenario scenario)
        {
            var vm = new SpeciesPropertiesViewModel(new ScenarioSpecies
            {
                LatinName = "Generic odontocete", 
                PopulationDensity = 0.01f, 
                SpeciesDefinitionFilename = "Generic odontocete.spe"
            })
            {
                WindowTitle = "Add new species"
            };
            var result = Globals.VisualizerService.ShowDialog("SpeciesPropertiesView", vm);
            if ((!result.HasValue) || (!result.Value)) return;
            var species = new ScenarioSpecies
            {
                Scenario = scenario,
                LatinName = vm.LatinName,
                PopulationDensity = vm.PopulationDensity,
                SpeciesDefinitionFilename = vm.SpeciesDefinitionFilename,
            };

            try
            {
                scenario.ScenarioSpecies.Add(species);
                species.LayerSettings.LineOrSymbolSize = 3;
                var animats = await Animat.SeedAsync(species, scenario.Location.GeoRect, scenario.BathymetryData);
                animats.Save(species.PopulationFilePath);
                species.UpdateMapLayers();
            }
            catch (Exception e)
            {
                scenario.ScenarioSpecies.Remove(species);
                Globals.MessageBoxService.ShowError(e.Message);
            }
            OnPropertyChanged("IsRunSimulationCommandEnabled");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.DeleteAllSpecies), UsedImplicitly]
        void DeleteAllSpecies(Scenario scenario)
        {
            if (Globals.MessageBoxService.ShowYesNo("Are you sure you want to delete ALL the species from this scenario?", MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            foreach (var species in scenario.ScenarioSpecies.ToList())
            {
                species.Delete();
                OnPropertyChanged("IsRunSimulationCommandEnabled");
            }
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.RepopulateAllSpecies), UsedImplicitly]
        async void RepopulateAllSpecies(Scenario scenario)
        {
            foreach (var species in scenario.ScenarioSpecies)
                await RepopulateSpeciesAsync(species);
        }

        [MediatorMessageSink(MediatorMessage.DeleteSpecies), UsedImplicitly]
        void DeleteSpecies(ScenarioSpecies species)
        {
            if (Globals.MessageBoxService.ShowYesNo(string.Format("Are you sure you want to delete the species \"{0}\"?", species.LatinName), MessageBoxImage.Warning) != MessageBoxResult.Yes) return;
            species.Delete();
            OnPropertyChanged("IsRunSimulationCommandEnabled");
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.RepopulateSpecies), UsedImplicitly]
        void RepopulateSpecies(ScenarioSpecies species)
        {
            RepopulateSpeciesAsync(species);
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        static async Task RepopulateSpeciesAsync(ScenarioSpecies species)
        {
            species.RemoveMapLayers();
            species.Animat = await Animat.SeedAsync(species, species.Scenario.Location.GeoRect, species.Scenario.BathymetryData);
            species.Animat.Save(species.PopulationFilePath);
            species.UpdateMapLayers();
        }

        [MediatorMessageSink(MediatorMessage.SpeciesProperties), UsedImplicitly]
        void SpeciesProperties(ScenarioSpecies species)
        {
            var vm = new SpeciesPropertiesViewModel(species) { WindowTitle = "Species Properties" };
            var result = Globals.VisualizerService.ShowDialog("SpeciesPropertiesView", vm);
            if ((result.HasValue) && (result.Value))
            {
                if (Math.Abs(vm.PopulationDensity - species.PopulationDensity) > 0.0001 || species.SpeciesDefinitionFilename != vm.SpeciesDefinitionFilename)
                {
                    species.PopulationDensity = vm.PopulationDensity;
                    species.SpeciesDefinitionFilename = vm.SpeciesDefinitionFilename;
                    RepopulateSpeciesAsync(species);
                }
                if (vm.LatinName != species.LatinName) species.LatinName = vm.LatinName;
            }
        }
        #endregion

        #region Handlers for Perimeter-related MediatorMessages
        [MediatorMessageSink(MediatorMessage.AddPerimeter), UsedImplicitly]
        void AddPerimeter(Scenario scenario)
        {
            try
            {
                var locationGeoRect = (GeoRect)Scenario.Location.GeoRect;
                var initialGeoRect = new GeoRect((locationGeoRect.North + locationGeoRect.Center.Latitude) / 2,
                                                 (locationGeoRect.South + locationGeoRect.Center.Latitude) / 2,
                                                 (locationGeoRect.East + locationGeoRect.Center.Longitude) / 2,
                                                 (locationGeoRect.West + locationGeoRect.Center.Longitude) / 2);
                MapViewModel.EditablePolygonOverlayViewModel.GeoArray = new GeoArray(initialGeoRect.NorthWest, initialGeoRect.NorthEast, initialGeoRect.SouthEast, initialGeoRect.SouthWest, initialGeoRect.NorthWest);
                MapViewModel.EditablePolygonOverlayViewModel.IsVisible = true;
                MapViewModel.EditablePolygonOverlayViewModel.LocationBounds = locationGeoRect;
                MapViewModel.EditablePolygonOverlayViewModel.AreCrossingSegmentsAllowed = false;

                Globals.VisualizerService.ShowWindow("CreateOrEditPerimeterView",
                                       new CreateOrEditPerimeterViewModel { EditablePolygonOverlayViewModel = MapViewModel.EditablePolygonOverlayViewModel, PerimeterName = "New perimeter", DialogTitle = "Create perimeter" },
                                       true,
                                       (sender, args) =>
                                       {
                                           MapViewModel.EditablePolygonOverlayViewModel.IsVisible = false;
                                           var vm = (CreateOrEditPerimeterViewModel)args.State;
                                           if (vm.IsCanceled) return;
                                           Perimeter perimeter = MapViewModel.EditablePolygonOverlayViewModel.GeoArray;
                                           perimeter.Name = vm.PerimeterName;
                                           perimeter.Scenario = Scenario;
                                           Scenario.Perimeters.Add(perimeter);
                                           perimeter.UpdateMapLayers();
                                           perimeter.LayerSettings.IsChecked = true;
                                       });
                OnPropertyChanged("IsSaveScenarioCommandEnabled");
            }
            catch (Exception e) { Globals.MessageBoxService.ShowError(e.Message); }
        }

        [MediatorMessageSink(MediatorMessage.DeletePerimeter), UsedImplicitly]
        void DeletePerimeter(Perimeter perimeter)
        {
            perimeter.Delete();
            OnPropertyChanged("IsSaveScenarioCommandEnabled");
        }

        [MediatorMessageSink(MediatorMessage.EditPerimeter), UsedImplicitly]
        void EditPerimeter(Perimeter perimeter)
        {
            try
            {
                var locationGeoRect = (GeoRect)Scenario.Location.GeoRect;
                MapViewModel.EditablePolygonOverlayViewModel.GeoArray = (GeoArray)((GeoArray)perimeter).Closed;
                MapViewModel.EditablePolygonOverlayViewModel.IsVisible = true;
                MapViewModel.EditablePolygonOverlayViewModel.LocationBounds = locationGeoRect;
                MapViewModel.EditablePolygonOverlayViewModel.AreCrossingSegmentsAllowed = false;
                perimeter.RemoveMapLayers();
                foreach (var platform in Scenario.Platforms.Where(platform => (platform.Perimeter!=null && platform.Perimeter.Guid == perimeter.Guid))) platform.RemoveMapLayers();
                Globals.VisualizerService.ShowWindow("CreateOrEditPerimeterView",
                                       new CreateOrEditPerimeterViewModel { EditablePolygonOverlayViewModel = MapViewModel.EditablePolygonOverlayViewModel, PerimeterName = perimeter.Name, DialogTitle = "Edit perimeter" },
                                       true,
                                       (sender, args) =>
                                       {
                                           MapViewModel.EditablePolygonOverlayViewModel.IsVisible = false;
                                           var vm = (CreateOrEditPerimeterViewModel)args.State;
                                           if (!vm.IsCanceled)
                                           {
                                               perimeter.SetPerimeterCoordinates(MapViewModel.EditablePolygonOverlayViewModel.GeoArray);
                                               perimeter.Name = vm.PerimeterName;
                                           }
                                           perimeter.UpdateMapLayers();
                                           foreach (var platform in Scenario.Platforms.Where(platform => (platform.Perimeter!=null && platform.Perimeter.Guid == perimeter.Guid))) platform.UpdateMapLayers();
                                       });
                OnPropertyChanged("IsSaveScenarioCommandEnabled");
            }
            catch (Exception e) { Globals.MessageBoxService.ShowError(e.Message); }
        }
        #endregion

        #region RunSimulationCommand
        public SimpleCommand<object, object> RunSimulationCommand { get { return _runSimulation ?? (_runSimulation = new SimpleCommand<object, object>(RunSimulationHandler)); } }
        SimpleCommand<object, object> _runSimulation;

        public bool IsRunSimulationCommandEnabled
        {
            get
            {
                var sb = new StringBuilder();
                if (Scenario == null || IsTransmissionLossBusy || IsSimulationRunning)
                {
                    sb.AppendLine("You can't run a scenario right now because:");
                    if (Scenario == null) sb.AppendLine("  • No scenario is selected");
                    else
                    {
                        if (IsTransmissionLossBusy) sb.AppendLine("  • The acoustic simulator is currently running");
                        if (IsSimulationRunning) sb.AppendLine("  • Another scenario simulation is currently running");
                    }
                    RunSimulationCommandToolTip = sb.ToString();
                    return false;
                }
                var result = Scenario.CanBeSimulated();
                if (!result)
                {
                    sb.AppendLine("You can't run a scenario right now because:");
                    sb.AppendLine(Scenario.GenerateCanBeSimulatedErrorString());
                    RunSimulationCommandToolTip = sb.ToString();
                    return false;
                }
                RunSimulationCommandToolTip = "The scenario simulator is ready";
                return true;
            }
        }

        public SimulationProgressViewModel SimulationProgressViewModel { get; set; }
        void RunSimulationHandler(object o)
        {
            var now = DateTime.Now;
            var name = Scenario.Name;
            foreach (var c in Path.GetInvalidPathChars().Where(name.Contains)) name = name.Replace(c, '-');
            var simulationDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "ESME Simulations", name, string.Format("{0}-{1}-{2}-{3}-{4}-{5}",now.Year,now.Month,now.Day,now.Hour,now.Minute,now.Second));
            if (Directory.Exists(simulationDirectory)) try { Directory.Delete(simulationDirectory, true); } catch{}

            var simulation = Simulation.Create(Scenario, simulationDirectory);
            SimulationProgressViewModel = new SimulationProgressViewModel(Globals.VisualizerService,Globals.MessageBoxService) {Simulation = simulation};
            SimulationProgressViewModel.SimulationStarting += (s, e) => IsSimulationRunning = true;
            var window = Globals.VisualizerService.ShowWindow("SimulationProgressView", SimulationProgressViewModel, false, (s, e) => IsSimulationRunning = false);
            SimulationProgressViewModel.Window = window;
        }
            
        public string RunSimulationCommandToolTip { get; set; }
        #endregion
    }
}