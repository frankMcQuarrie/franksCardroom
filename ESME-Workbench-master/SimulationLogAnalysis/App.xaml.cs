﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.Hosting;
using System.Windows;
using ESME.Views;
using HRC;
using HRC.Utility;
using SimulationLogAnalysis.Properties;

namespace SimulationLogAnalysis
{
    /// <summary>
    ///   Interaction logic for App.xaml
    /// </summary>
    public partial class App
    {
        public static AppEventLog Log { get; private set; }
        public static readonly string Logfile, DumpFile;
        public const string Name = "Simulation Log Analysis";

        static App()
        {
            Logfile = Path.Combine(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "ESME Workbench"), "simulation_log_analysis.log");
            if (File.Exists(Logfile)) File.Delete(Logfile);
            Trace.Listeners.Add(new TextWriterTraceListener(Logfile, "logfile") { TraceOutputOptions = TraceOptions.None });
            Trace.AutoFlush = true;
            Trace.WriteLine(Name + " initializing");

            if (OSInfo.OperatingSystemName != "XP")
            {
                DumpFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "simulation_log_analysis_crash.mdmp");
                AppDomain.CurrentDomain.UnhandledException += LastChanceExceptionHandler;
            }
#if DEBUG
            Log = new AppEventLog(Name);
            Log.Debug(EventLogEntryType.Information, "Starting");
#endif
        }

        #region Initialization

        public App()
        {
            // You must close or flush the trace to empty the output buffer.
            Trace.WriteLine(Name + " starting up");

            try
            {
                HRCBootstrapper.Initialise(new List<Assembly>
                                             {
                                                 typeof (App).Assembly,
                                                 typeof (TestView).Assembly,
                                             });
            }
            catch (Exception e)
            {
                Trace.Indent();
                Trace.TraceError("HRCBootstrapper threw an exception: {0}", e.Message);
                var inner = e.InnerException;
                while (inner != null)
                {
                    Trace.Indent();
                    Trace.TraceError("Inner exception: {0}", inner.Message);
                    if (inner is ReflectionTypeLoadException)
                    {
                        Trace.Indent();
                        var rtl = inner as ReflectionTypeLoadException;
                        foreach (var exception in rtl.LoaderExceptions)
                        {
                            Trace.TraceError("Loader Exception: {0}", exception.Message);
                            if (exception.InnerException != null)
                                Trace.TraceError("Inner Exception: {0}", exception.InnerException.Message);
                        }
                        Trace.Unindent();
                    }
                    inner = inner.InnerException;
                    Trace.Unindent();
                }
                Trace.Unindent();
                throw;
            }
            InitializeComponent();
        }

        #endregion

        protected override void OnStartup(StartupEventArgs e)
        {
            Properties["SelectedFileName"] = null;
            if (e.Args.Length > 0) Properties["SelectedFileName"] = e.Args[0];
            base.OnStartup(e);
        }

        void ApplicationExit(object sender, ExitEventArgs e)
        {
            Trace.WriteLine(string.Format(Name + " exiting with code {0}", e.ApplicationExitCode));

            Trace.Flush();
            Settings.Default.Save();
        }

        static void LastChanceExceptionHandler(object sender, UnhandledExceptionEventArgs ex)
        {
            Trace.TraceError("{0} encountered an unhandled exception and is exiting.  A dump file will be created in {1}", Name, DumpFile);
            Trace.TraceError("{0} Exception type: {1}", Name, ex.ExceptionObject.GetType());
            Trace.TraceError("{0} Exception message: {1}", Name, ((Exception)ex.ExceptionObject).Message);
            if (((Exception)ex.ExceptionObject).InnerException != null)
            {
                Trace.TraceError("{0} Inner exception type: {1}", Name, ((Exception)ex.ExceptionObject).InnerException.GetType());
                Trace.TraceError("{0} Inner exception message: {1}", Name, ((Exception)ex.ExceptionObject).InnerException.Message);
            }

            MiniDump.Write(DumpFile, MiniDump.Option.WithoutAuxiliaryState | MiniDump.Option.WithoutOptionalData, MiniDump.ExceptionInfo.Present);
        }
    }
}