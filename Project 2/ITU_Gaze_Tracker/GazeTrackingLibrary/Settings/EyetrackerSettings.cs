﻿using System;
using System.ComponentModel;
using System.Drawing;
using System.Xml;
using Emgu.CV;
using GazeTrackingLibrary.Logging;

namespace GazeTrackingLibrary.Settings
{
    public class EyetrackerSettings : INotifyPropertyChanged
    {
        #region Constants

        public const string Name = "EyetrackerSettings";

        #endregion

        #region Variables

        private HaarCascade haarCascade;
        private string haarCascadePath;

        private double scaleFactor = 4; // originally 1.1
        private double scaleFactorDefault = 1.2;
        private Size sizeMax = new Size(200, 200);

        private Size sizeMin = new Size(30, 30); // smaller values finds a larger range of eyes (less sensitive to eye-size)

        //private int skipFrameCount = 5;

        #endregion

        #region Events 

        #region Delegates

        public delegate void HaarcascadeChangeHandler(bool success);

        #endregion

        public event PropertyChangedEventHandler PropertyChanged;
        public event HaarcascadeChangeHandler OnHaarCascadeLoaded;

        #endregion

        #region Get/Set

        public HaarCascade HaarCascade
        {
            get { return haarCascade; }
            set
            {
                haarCascade = value;
                OnPropertyChanged("HaarCascade");
            }
        }

        public string HaarCascadePath
        {
            get { return haarCascadePath; }
            set
            {
                haarCascadePath = value;
                OnPropertyChanged("HaarCascadePath");
            }
        }


        public Size SizeMin
        {
            get { return sizeMin; }
            set
            {
                sizeMin = value;
                OnPropertyChanged("SizeMin");
            }
        }

        public Size SizeMax
        {
            get { return sizeMax; }
            set
            {
                sizeMax = value;
                OnPropertyChanged("SizeMax");
            }
        }

        public double ScaleFactor
        {
            get { return scaleFactor; }
            set
            {
                scaleFactor = value;
                OnPropertyChanged("ScaleFactor");
            }
        }

        public double ScaleFactorDefault
        {
            get { return scaleFactorDefault; }
            set { scaleFactorDefault = value; }
        }

        #endregion

        #region Public Methods - Read/Write/encode configuration files 

        public void WriteConfigFile(XmlTextWriter xmlWriter)
        {
            xmlWriter.WriteStartElement("EyetrackerSettings");

            GTSettings.WriteElement(xmlWriter, "HaarCascadePath", HaarCascadePath);
            GTSettings.WriteElement(xmlWriter, "SizeMin", SizeMin.Width.ToString());
            GTSettings.WriteElement(xmlWriter, "SizeMax", SizeMax.Width.ToString());
            GTSettings.WriteElement(xmlWriter, "ScaleFactor", ScaleFactor.ToString());

            xmlWriter.WriteEndElement();
        }

        public void LoadConfigFile(XmlReader xmlReader)
        {
            string sName = "";
            int min;
            int max;

            while (xmlReader.Read())
            {
                switch (xmlReader.NodeType)
                {
                    case XmlNodeType.Element:
                        sName = xmlReader.Name;
                        break;
                    case XmlNodeType.Text:
                        switch (sName)
                        {
                            case "HaarCascadePath":
                                HaarCascadePath = xmlReader.Value;
                                break;
                            case "SizeMin":
                                min = int.Parse(xmlReader.Value);
                                SizeMin = new Size(min, min);
                                break;
                            case "SizeMax":
                                max = int.Parse(xmlReader.Value);
                                SizeMax = new Size(max, max);
                                break;
                            case "ScaleFactor":
                                ScaleFactor = double.Parse(xmlReader.Value);
                                break;
                        }
                        break;
                }
            }
        }

        public string SettingsEncodeString()
        {
            string sep = ",";
            string str = "";

            //str += "Brightness=" + Brightness.ToString() + sep;
            //str += "Contrast=" + Contrast.ToString() + sep;
            //str += "Saturation=" + Saturation.ToString() + sep;
            //str += "Sharpness=" + Sharpness.ToString() + sep;
            //str += "Zoom=" + Zoom.ToString() + sep;
            //str += "Focus=" + Focus.ToString() + sep;
            //str += "Exposure=" + Exposure.ToString() + sep;
            //str += "FlipImage=" + FlipImage.ToString();

            return str;
        }

        public void ExtractParametersFromString(string parameterStr)
        {
            //try
            //{
            //    // Seperating commands
            //    char[] sepParam = { ',' };
            //    string[] camParams = parameterStr.Split(sepParam, 20);

            //    // Seperating values/parameters
            //    char[] sepValues = { '=' };

            //    for (int i = 0; i < camParams.Length; i++)
            //    {
            //        string[] cmdString = camParams[i].Split(sepValues, 5);
            //        string subCmdStr = cmdString[0];
            //        string value = cmdString[1];

            //        switch (subCmdStr)
            //        {
            //            case "Brightness":
            //                this.Brightness = int.Parse(value);
            //                break;
            //            case "Contrast":
            //                this.Contrast = int.Parse(value);
            //                break;
            //            case "Saturation":
            //                this.Saturation = int.Parse(value);
            //                break;
            //            case "Sharpness":
            //                this.Sharpness = int.Parse(value);
            //                break;
            //            case "Zoom":
            //                this.Zoom = int.Parse(value);
            //                break;
            //            case "Focus":
            //                this.Focus = int.Parse(value);
            //                break;
            //            case "Exposure":
            //                this.Exposure = int.Parse(value);
            //                break;
            //            case "FlipImage":
            //                this.FlipImage = bool.Parse(value);
            //                break;
            //        }
            //    }
            //}
            //catch (Exception ex)
            //{
            //}
        }

        public void LoadHaarCascade(string filepath)
        {
            if(System.IO.File.Exists(filepath) == false)
            {
                System.Windows.MessageBox.Show("Unable to find the haar cascade XML file: " + filepath);
                return;
            }

            try
            {
                haarCascade = new HaarCascade(filepath);
                haarCascadePath = filepath;

                if (OnHaarCascadeLoaded != null)
                    OnHaarCascadeLoaded(true);
            }
            catch (Exception ex)
            {
                if (OnHaarCascadeLoaded != null)
                    OnHaarCascadeLoaded(false);

                ErrorLogger.ProcessException(ex, true);
            }
        }

        #endregion

        #region EVENTHANDLER

        private void OnPropertyChanged(string parameter)
        {
            if (PropertyChanged != null)
            {
                PropertyChanged(this, new PropertyChangedEventArgs(parameter));
            }
        }

        #endregion //EVENTHANDLER
    }
}