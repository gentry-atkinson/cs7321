﻿#pragma checksum "..\..\..\TrackerViewer\PerformanceCountersUC.xaml" "{406ea660-64cf-4c82-b6f0-42d48172a799}" "3E0515EA0486DD29746B78B1ABCDC73D"
//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:4.0.30319.269
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System;
using System.Diagnostics;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Forms.Integration;
using System.Windows.Ink;
using System.Windows.Input;
using System.Windows.Markup;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Effects;
using System.Windows.Media.Imaging;
using System.Windows.Media.Media3D;
using System.Windows.Media.TextFormatting;
using System.Windows.Navigation;
using System.Windows.Shapes;


namespace GazeTrackerUI.TrackerViewer {
    
    
    /// <summary>
    /// PerformanceCountersUC
    /// </summary>
    public partial class PerformanceCountersUC : System.Windows.Controls.UserControl, System.Windows.Markup.IComponentConnector {
        
        
        #line 8 "..\..\..\TrackerViewer\PerformanceCountersUC.xaml"
        internal GazeTrackerUI.TrackerViewer.PerformanceCountersUC UserControl;
        
        #line default
        #line hidden
        
        
        #line 10 "..\..\..\TrackerViewer\PerformanceCountersUC.xaml"
        internal System.Windows.Controls.Grid LayoutRoot;
        
        #line default
        #line hidden
        
        
        #line 13 "..\..\..\TrackerViewer\PerformanceCountersUC.xaml"
        internal System.Windows.Controls.Label LabelFPS;
        
        #line default
        #line hidden
        
        
        #line 15 "..\..\..\TrackerViewer\PerformanceCountersUC.xaml"
        internal System.Windows.Controls.Label LabelCPU;
        
        #line default
        #line hidden
        
        
        #line 19 "..\..\..\TrackerViewer\PerformanceCountersUC.xaml"
        internal System.Windows.Controls.Label LabelMem;
        
        #line default
        #line hidden
        
        private bool _contentLoaded;
        
        /// <summary>
        /// InitializeComponent
        /// </summary>
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        public void InitializeComponent() {
            if (_contentLoaded) {
                return;
            }
            _contentLoaded = true;
            System.Uri resourceLocater = new System.Uri("/GazeTrackerUI;component/trackerviewer/performancecountersuc.xaml", System.UriKind.Relative);
            
            #line 1 "..\..\..\TrackerViewer\PerformanceCountersUC.xaml"
            System.Windows.Application.LoadComponent(this, resourceLocater);
            
            #line default
            #line hidden
        }
        
        [System.Diagnostics.DebuggerNonUserCodeAttribute()]
        [System.ComponentModel.EditorBrowsableAttribute(System.ComponentModel.EditorBrowsableState.Never)]
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("Microsoft.Design", "CA1033:InterfaceMethodsShouldBeCallableByChildTypes")]
        void System.Windows.Markup.IComponentConnector.Connect(int connectionId, object target) {
            switch (connectionId)
            {
            case 1:
            this.UserControl = ((GazeTrackerUI.TrackerViewer.PerformanceCountersUC)(target));
            return;
            case 2:
            this.LayoutRoot = ((System.Windows.Controls.Grid)(target));
            return;
            case 3:
            this.LabelFPS = ((System.Windows.Controls.Label)(target));
            return;
            case 4:
            this.LabelCPU = ((System.Windows.Controls.Label)(target));
            return;
            case 5:
            this.LabelMem = ((System.Windows.Controls.Label)(target));
            return;
            }
            this._contentLoaded = true;
        }
    }
}

