﻿using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Linq;
using System.Windows.Data;
using ESME.Environment;
using ESME.Locations;
using ESME.Plugins;
using HRC.Aspects;
using HRC.Collections;
using HRC.Validation;
using HRC.ViewModels;
using HRC.WPF;

namespace ESME.Views.Scenarios
{
    /// <summary>
    /// To create and show the view as a dialog:
    /// var vm = new CreateScenarioViewModel {...};
    /// var result = _visualizerService.ShowDialog("CreateScenarioView", vm);
    /// if ((!result.HasValue) || (!result.Value)) return;
    /// 
    /// To create and show the view as a window:
    /// var vm = new CreateScenarioViewModel {...};
    /// var window = _visualizerService.ShowWindow("CreateScenarioView", vm);
    /// </summary>
    public class CreateScenarioViewModel : ValidatingViewModel
    {
        const string TimeSpanFormatString = @"hh\:mm";
        public CreateScenarioViewModel()
        {
            AddValidationRules(
                new ValidationRule<CreateScenarioViewModel>
                {
                    PropertyName = "ScenarioName",
                    Description = "Must be unique within the selected location and cannot be null or empty",
                    IsRuleValid = (target, rule) => !string.IsNullOrEmpty(target.ScenarioName),
                },
                new ValidationRule<CreateScenarioViewModel>
                {
                    PropertyName = "DurationString",
                    Description = "Must be a valid, non-negative time span value in the format hh:mm where 00 <= hh <= 23; 00 <= mm <= 59",
                    IsRuleValid = (target, rule) =>
                    {
                        if (string.IsNullOrEmpty(target.DurationString)) return false;
                        TimeSpan timeSpan;
                        var isOK = TimeSpan.TryParseExact(target.DurationString, TimeSpanFormatString, null, out timeSpan);
                        return isOK && timeSpan.Ticks > 0;
                    },
                });
            DurationString = "01:00";
            ScenarioName = "New Scenario";
        }

        public ObservableCollection<Location> Locations { get; set; }
        public string ScenarioName { get; set; }
        public Location Location { get; set; }
        public string Comments { get; set; }
        public TimePeriod TimePeriod { get; set; }
        public TimeSpan Duration { get; private set; }
        public string DurationString { get; set; }
        public bool IsLocationSelectable { get; set; }

        #region PluginManager stuff
        IPluginManagerService _pluginManager;
        public IPluginManagerService PluginManager
        {
            get { return _pluginManager; }
            set
            {
                _pluginManager = value;
                AddEnvironmentDataSourceView(PluginSubtype.Wind);
                AddEnvironmentDataSourceView(PluginSubtype.SoundSpeed);
                AddEnvironmentDataSourceView(PluginSubtype.Sediment);
                AddEnvironmentDataSourceView(PluginSubtype.Bathymetry);
            }
        }

        [Initialize] public Dictionary<PluginSubtype, ICollectionView> EnvironmentDataSourceViews { get; set; }
        [Initialize] public ObservableConcurrentDictionary<PluginSubtype, EnvironmentalDataSourcePluginBase> SelectedPlugins { get; set; }

        void AddEnvironmentDataSourceView(PluginSubtype pluginSubtype)
        {
            var curView = CollectionViewSource.GetDefaultView(PluginManager[PluginType.EnvironmentalDataSource][pluginSubtype].Values);
            ((ListCollectionView)curView).SortDescriptions.Add(new SortDescription("PluginName", ListSortDirection.Ascending));
            ((ListCollectionView)curView).Filter = p => ((IESMEPlugin)p).IsSelectable;
            EnvironmentDataSourceViews.Add(pluginSubtype, curView);
            var defaultPlugin = PluginManager[PluginType.EnvironmentalDataSource, pluginSubtype] ??
                                PluginManager[PluginType.EnvironmentalDataSource][pluginSubtype].Values.FirstOrDefault();
            SelectedPlugins.Add(pluginSubtype, (EnvironmentalDataSourcePluginBase)defaultPlugin);
        }
        #endregion

        #region OkCommand
        public SimpleCommand<object, EventToCommandArgs> OkCommand { get { return _ok ?? (_ok = new SimpleCommand<object, EventToCommandArgs>(OkHandler)); } }
        SimpleCommand<object, EventToCommandArgs> _ok;
        void OkHandler(EventToCommandArgs args)
        {
            //var parameter = args.CommandParameter;
            Duration = TimeSpan.ParseExact(DurationString, TimeSpanFormatString, null);
            CloseDialog(true);
        }
        #endregion

        #region CancelCommand
        public SimpleCommand<object, EventToCommandArgs> CancelCommand { get { return _cancel ?? (_cancel = new SimpleCommand<object, EventToCommandArgs>(CancelHandler)); } }
        SimpleCommand<object, EventToCommandArgs> _cancel;

        void CancelHandler(EventToCommandArgs args)
        {
            //var parameter = args.CommandParameter;
            CloseDialog(false);
        }
        #endregion

        #region ViewClosingCommand
        public SimpleCommand<object, object> ViewClosingCommand { get { return _viewClosing ?? (_viewClosing = new SimpleCommand<object, object>(o => Properties.Settings.Default.Save())); } }
        SimpleCommand<object, object> _viewClosing;
        #endregion
    }
}
