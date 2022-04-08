using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Threading;
using Microsoft.Win32;
using Newtonsoft.Json;
using System.ComponentModel; // CancelEventArgs
using System.Text.RegularExpressions;
using LsonLib; // necessasry for the future lua integration
using System.Globalization; // used for the date
using System.Threading; // used for the port listener
using MaterialDesignColors;
using MaterialDesignThemes.Wpf;
using System.Windows.Media;
using LuaInterface;
using System.Collections;
using MoonSharp;
using MoonSharp.Interpreter;

//change colors in app.xaml

//https://github.com/MaterialDesignInXAML/MaterialDesignInXamlToolkit/wiki/Super-Quick-Start
//https://github.com/rstarkov/LsonLib

/// <summary>
/// Welcome to DCS DTC Mission Planning Software (DCS-DMPS, a play on JMPS).
/// With DMPS you can program your very own missions. 
/// 
/// Along the top you will be able to select your aircraft, terrain (map), date, and the name
/// of the DTC cartridge. You will then, based on the module, be able to enter data such as:
/// Waypoint name, Lat, long, altitude, cp, pd, rd, rho, theta, dalt, dnorth, and deast.
/// 
/// Notes: 
/// Currently made for the M2k, other modules to possibly be added.
/// Cartridges are loaded on plane spawn.
/// This app is standalone, which means that you don't need DCS installed to use it.
/// User will be able to make DTCs.
/// M2K can store up to 20 waypoints
/// ? Can the user skip waypoints in the dtc file? Test to confirm.
/// </summary>

/// <flows>
/// 
/// Export Flow:
/// User opens exe.
/// user picks aircraft
/// user picks terrain
/// user can opt to pick a date
/// user puts in dtc name
/// user puts things in each textbox
/// user clicks export
/// user then picks the location for export and file name via a dialog box
/// the program:
/// if wp1_lat and wp1_long are populated
/// then 
/// export that line with the populated entries using he formated method
/// when done,
/// move to wp2,
/// and so on until wp20. 
/// Export the file.
/// 
/// 
/// Clear all data Flow:
/// when clicked, confirm with user,
/// if yes, clear all fields
/// if no, close dialog box
/// 
/// 
/// Import Flow: TODO
/// 
/// 
/// </flows>
/// 

/// <TODO>
/// TODO for release:
/// 
/// TODO Extra credit: 
/// make the waypoint lines "tiles" where you can click and drag to re-order them
/// Make crosshairs work on windowed dcs
/// remove the blank DetailedInstructions.xaml, somehow, without breaking the program
/// If a textbox ends with a : or . add two zeros (eventually regex this possibility, maybe)
/// if a text box leads with a decimal, add a zero to the front. (eventually regex this out)
/// enable more maps
/// enable more aircraft when they have the capability
/// </TODO>



namespace DCS_DTC_Mission_Planning_Software
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        private const int listenPort = 42080; //thge port to listen for the dcs info on.
                                                //TODO: make the port changable

        //https://stackoverflow.com/questions/39850292/c-sharp-wpf-real-time-udp-message
        private readonly Dispatcher _uiDispatcher;


        public MainWindow()
        {
            InitializeComponent();

            //https://stackoverflow.com/questions/3819832/changing-the-string-format-of-the-wpf-datepicker
            //fixes the date import to be ISO 8601-ish
            CultureInfo ci = CultureInfo.CreateSpecificCulture(CultureInfo.CurrentCulture.Name);
            ci.DateTimeFormat.ShortDatePattern = "dd/MM/yyyy";

            Thread.CurrentThread.CurrentCulture = ci;
            _uiDispatcher = Dispatcher.CurrentDispatcher;
            Task.Factory.StartNew(UDP_listening_PI1);
            //MoonSharpFactorial();
            MoonSharpString(); //results in void :(
        }

        private static String latitude;
        private static String longitude;
        private static String elevation;
        private static String modelName;

        UdpClient listener = new UdpClient(listenPort);
        IPEndPoint groupEP = new IPEndPoint(IPAddress.Any, listenPort);
        bool _isClosed;
        public void UDP_listening_PI1()
        {
            try
            {
                while (true)
                {
                    //Console.WriteLine("Waiting for broadcast");
                    if (_isClosed) return;
                    byte[] bytes = listener.Receive(ref groupEP);
                  

                    //Console.WriteLine($"Received broadcast from {groupEP} :");
                    //Console.WriteLine($" {Encoding.ASCII.GetString(bytes, 0, bytes.Length)}");
                    var exportedInfo = Encoding.ASCII.GetString(bytes, 0, bytes.Length);


                    //https://stackoverflow.com/questions/6620165/how-can-i-parse-json-with-c
                    dynamic exportedInfoJson = JsonConvert.DeserializeObject(exportedInfo);
             
                    modelName = exportedInfoJson.model;
                    latitude = exportedInfoJson.coords.lat;
                    longitude = exportedInfoJson.coords.lon;
                    elevation = exportedInfoJson.elev;

                    //TODO this is an attempt at making a connection status
                    this.Dispatcher.Invoke(() =>
                    {
                        if (String.IsNullOrEmpty(modelName))
                        {
                            label_dcs_connection.Content = ("Connection Status: ???");
                            //label_dcs_connection.Foreground = Colors.Green;
                        }
                        else
                        {
                            label_dcs_connection.Content = ("Connection Status: OK");
                            //label_dcs_connection.Foreground = "Green";
                        }
                    });

                    //https://stackoverflow.com/questions/9732709/the-calling-thread-cannot-access-this-object-because-a-different-thread-owns-it
                    this.Dispatcher.Invoke(() =>
                    {
                        label_readout_aircraft.Content = "Aircraft: " + modelName;
                        label_readout_lat.Content = "Lat: " + latitude + ", Long: " + longitude;   
                        //label_readout_long.Content = longitude;
                        label_readout_elevation.Content = "Elevation (m): " + elevation;
                        
                    }); 
                }
            }
            catch (SocketException e)
            {
                Console.WriteLine(e);
            }
            finally
            {
                listener.Close();
            }
        }

        public void StopListener()
        {
            listener.Close();   // forcibly end communication 
        }

        void DataWindow_Closing(object sender, CancelEventArgs e)
        {
            _isClosed = true;
            StopListener();
            
            //https://stackoverflow.com/questions/2688923/how-to-exit-all-running-threads
            Environment.Exit(Environment.ExitCode); //this quits the program and the threads
        }
        private void button_export_Click(object sender, RoutedEventArgs e)
        {
            if (String.IsNullOrEmpty(textbox_dtcName.Text))
            {
                //https://docs.microsoft.com/en-us/dotnet/desktop/wpf/windows/how-to-open-message-box?view=netdesktop-6.0
                MessageBox.Show("Name your DTC.", "Configuration", MessageBoxButton.OK, MessageBoxImage.Warning);

                return;
            }
            UserSaveExportDialog();
        }

        private void UserSaveExportDialog()
        {
            SaveFileDialog saveFileDialog1 = new SaveFileDialog();

            saveFileDialog1.Filter = "DTC files (*.dtc)|*.dtc";
            saveFileDialog1.FilterIndex = 1;
            saveFileDialog1.RestoreDirectory = true;
            saveFileDialog1.DefaultExt = "dtc";
            saveFileDialog1.Title = "Save DTC to `C:/User/ProfileName/Saved Games/DCS/Datacartridges`";
            saveFileDialog1.CheckPathExists = true;

            if (Directory.Exists(System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS.openbeta", "Datacartridges")))
            {
                saveFileDialog1.InitialDirectory = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS.openbeta", "Datacartridges");
            }
            else if (Directory.Exists(System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS", "Datacartridges")))
            {
                saveFileDialog1.InitialDirectory = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS", "Datacartridges");
            }
            else
            {
                saveFileDialog1.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            }

            if (saveFileDialog1.ShowDialog() == true)
            {
                WriteExportData();//might want to move this somewhere else.
                File.WriteAllText(saveFileDialog1.FileName, totalOutText);
                //TODO: dont let the user export without a name for the dtc
            }
        }

        string totalOutText;
        private void WriteExportData()
        {
            ClearPreviousInfo();

            WriteLeadingInformation();
            WriteWaypoint01();
            WriteWaypoint02();
            WriteWaypoint03();
            WriteWaypoint04();
            WriteWaypoint05();
            WriteWaypoint06();
            WriteWaypoint07();
            WriteWaypoint08();
            WriteWaypoint09();
            WriteWaypoint10();
            WriteWaypoint11();
            WriteWaypoint12();
            WriteWaypoint13();
            WriteWaypoint14();
            WriteWaypoint15();
            WriteWaypoint16();
            WriteWaypoint17();
            WriteWaypoint18();
            WriteWaypoint19();
            WriteWaypoint20();

            totalOutText = leadingInformation + waypointLineOut_01 + waypointLineOut_02 + waypointLineOut_03 + 
                waypointLineOut_04 + waypointLineOut_05 + waypointLineOut_06 + waypointLineOut_07 + 
                waypointLineOut_08 + waypointLineOut_09 + waypointLineOut_10 + waypointLineOut_11 + 
                waypointLineOut_12 + waypointLineOut_13 + waypointLineOut_14 + waypointLineOut_15 + 
                waypointLineOut_16 + waypointLineOut_17 + waypointLineOut_18 + waypointLineOut_19 + 
                waypointLineOut_20;

            Console.WriteLine(totalOutText);
        }

       
       

        string leadingInformation;
        string waypointLineOut_01;
        string waypointLineOut_02;
        string waypointLineOut_03;
        string waypointLineOut_04;
        string waypointLineOut_05;
        string waypointLineOut_06;
        string waypointLineOut_07;
        string waypointLineOut_08;
        string waypointLineOut_09;
        string waypointLineOut_10;
        string waypointLineOut_11;
        string waypointLineOut_12;
        string waypointLineOut_13;
        string waypointLineOut_14;
        string waypointLineOut_15;
        string waypointLineOut_16;
        string waypointLineOut_17;
        string waypointLineOut_18;
        string waypointLineOut_19;
        string waypointLineOut_20;

        private void ClearPreviousInfo()
        {
            totalOutText = null;
            leadingInformation = null;
            waypointLineOut_01 = null;
            waypointLineOut_02 = null;
            waypointLineOut_03 = null;
            waypointLineOut_04 = null;
            waypointLineOut_05 = null;
            waypointLineOut_06 = null;
            waypointLineOut_07 = null;
            waypointLineOut_08 = null;
            waypointLineOut_09 = null;
            waypointLineOut_10 = null;
            waypointLineOut_11 = null;
            waypointLineOut_12 = null;
            waypointLineOut_13 = null;
            waypointLineOut_14 = null;
            waypointLineOut_15 = null;
            waypointLineOut_16 = null;
            waypointLineOut_17 = null;
            waypointLineOut_18 = null;
            waypointLineOut_19 = null;
            waypointLineOut_20 = null;
        }

        private void WriteLeadingInformation()
        {
            leadingInformation =
                "terrain = \"" + combobox_terrain.Text + "\"\n" +
                "aircraft = \"" + combobox_aircraft.Text + "\"\n" +
                "date = \"" + datepicker_date.Text + "\"\n" +
                "name = \"" + textbox_dtcName.Text + "\"\n" +
                "waypoints = {}\n";
        }

        private void WriteWaypoint01()
        {
            //https://stackoverflow.com/questions/34298857/check-whether-a-textbox-is-empty-or-not
            if (!String.IsNullOrEmpty(wp01_lat.Text) && !String.IsNullOrEmpty(wp01_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 01");
                waypointLineOut_01 = "waypoints[1] = { ";
                if (!String.IsNullOrEmpty(wp01_name.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + "name=\"" + wp01_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp01_lat.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " lat=\""  + wp01_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp01_long.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " lon=\"" + wp01_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp01_alt.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " alt=" + wp01_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_cp.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " cp=" + wp01_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_pd.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " pd=" + wp01_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_rd.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " rd=" + wp01_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_rho.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " rho=" + wp01_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_theta.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " theta=" + wp01_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_dalt.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " dalt=" + wp01_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_dnorth.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " dnorth=" + wp01_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp01_deast.Text))
                {
                    waypointLineOut_01 = waypointLineOut_01 + " deast=" + wp01_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_01.EndsWith(","))
                {
                    waypointLineOut_01 = waypointLineOut_01.Remove(waypointLineOut_01.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_01 = waypointLineOut_01 + " }\n";

                Console.WriteLine(waypointLineOut_01);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 01.");
            }
        }

        private void WriteWaypoint02()
        {
            if (!String.IsNullOrEmpty(wp02_lat.Text) && !String.IsNullOrEmpty(wp02_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 02");
                waypointLineOut_02 = "waypoints[2] = { ";
                if (!String.IsNullOrEmpty(wp02_name.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + "name=\"" + wp02_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp02_lat.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " lat=\""  + wp02_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp02_long.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " lon=\"" + wp02_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp02_alt.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " alt=" + wp02_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_cp.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " cp=" + wp02_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_pd.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " pd=" + wp02_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_rd.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " rd=" + wp02_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_rho.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " rho=" + wp02_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_theta.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " theta=" + wp02_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_dalt.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " dalt=" + wp02_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_dnorth.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " dnorth=" + wp02_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp02_deast.Text))
                {
                    waypointLineOut_02 = waypointLineOut_02 + " deast=" + wp02_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_02.EndsWith(","))
                {
                    waypointLineOut_02 = waypointLineOut_02.Remove(waypointLineOut_02.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_02 = waypointLineOut_02 + " }\n";

                Console.WriteLine(waypointLineOut_02);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 02.");
            }
        }

        private void WriteWaypoint03()
        {
            if (!String.IsNullOrEmpty(wp03_lat.Text) && !String.IsNullOrEmpty(wp03_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 03");
                waypointLineOut_03 = "waypoints[3] = { ";
                if (!String.IsNullOrEmpty(wp03_name.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + "name=\"" + wp03_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp03_lat.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " lat=\""  + wp03_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp03_long.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " lon=\"" + wp03_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp03_alt.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " alt=" + wp03_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_cp.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " cp=" + wp03_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_pd.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " pd=" + wp03_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_rd.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " rd=" + wp03_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_rho.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " rho=" + wp03_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_theta.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " theta=" + wp03_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_dalt.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " dalt=" + wp03_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_dnorth.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " dnorth=" + wp03_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp03_deast.Text))
                {
                    waypointLineOut_03 = waypointLineOut_03 + " deast=" + wp03_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_03.EndsWith(","))
                {
                    waypointLineOut_03 = waypointLineOut_03.Remove(waypointLineOut_03.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_03 = waypointLineOut_03 + " }\n";

                Console.WriteLine(waypointLineOut_03);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 03.");
            }
        }

        private void WriteWaypoint04()
        {
            if (!String.IsNullOrEmpty(wp04_lat.Text) && !String.IsNullOrEmpty(wp04_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 04");
                waypointLineOut_04 = "waypoints[4] = { ";
                if (!String.IsNullOrEmpty(wp04_name.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + "name=\"" + wp04_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp04_lat.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " lat=\""  + wp04_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp04_long.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " lon=\"" + wp04_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp04_alt.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " alt=" + wp04_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_cp.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " cp=" + wp04_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_pd.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " pd=" + wp04_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_rd.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " rd=" + wp04_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_rho.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " rho=" + wp04_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_theta.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " theta=" + wp04_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_dalt.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " dalt=" + wp04_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_dnorth.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " dnorth=" + wp04_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp04_deast.Text))
                {
                    waypointLineOut_04 = waypointLineOut_04 + " deast=" + wp04_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_04.EndsWith(","))
                {
                    waypointLineOut_04 = waypointLineOut_04.Remove(waypointLineOut_04.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_04 = waypointLineOut_04 + " }\n";

                Console.WriteLine(waypointLineOut_04);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 04.");
            }
        }

        private void WriteWaypoint05()
        {
            if (!String.IsNullOrEmpty(wp05_lat.Text) && !String.IsNullOrEmpty(wp05_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 05");
                waypointLineOut_05 = "waypoints[5] = { ";
                if (!String.IsNullOrEmpty(wp05_name.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + "name=\"" + wp05_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp05_lat.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " lat=\""  + wp05_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp05_long.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " lon=\"" + wp05_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp05_alt.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " alt=" + wp05_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_cp.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " cp=" + wp05_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_pd.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " pd=" + wp05_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_rd.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " rd=" + wp05_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_rho.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " rho=" + wp05_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_theta.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " theta=" + wp05_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_dalt.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " dalt=" + wp05_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_dnorth.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " dnorth=" + wp05_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp05_deast.Text))
                {
                    waypointLineOut_05 = waypointLineOut_05 + " deast=" + wp05_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_05.EndsWith(","))
                {
                    waypointLineOut_05 = waypointLineOut_05.Remove(waypointLineOut_05.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_05 = waypointLineOut_05 + " }\n";

                Console.WriteLine(waypointLineOut_05);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 05.");
            }
        }

        private void WriteWaypoint06()
        {
            if (!String.IsNullOrEmpty(wp06_lat.Text) && !String.IsNullOrEmpty(wp06_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 06");
                waypointLineOut_06 = "waypoints[6] = { ";
                if (!String.IsNullOrEmpty(wp06_name.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + "name=\"" + wp06_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp06_lat.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " lat=\""  + wp06_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp06_long.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " lon=\"" + wp06_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp06_alt.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " alt=" + wp06_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_cp.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " cp=" + wp06_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_pd.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " pd=" + wp06_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_rd.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " rd=" + wp06_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_rho.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " rho=" + wp06_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_theta.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " theta=" + wp06_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_dalt.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " dalt=" + wp06_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_dnorth.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " dnorth=" + wp06_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp06_deast.Text))
                {
                    waypointLineOut_06 = waypointLineOut_06 + " deast=" + wp06_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_06.EndsWith(","))
                {
                    waypointLineOut_06 = waypointLineOut_06.Remove(waypointLineOut_06.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_06 = waypointLineOut_06 + " }\n";

                Console.WriteLine(waypointLineOut_06);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 06.");
            }
        }

        private void WriteWaypoint07()
        {
            if (!String.IsNullOrEmpty(wp07_lat.Text) && !String.IsNullOrEmpty(wp07_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 07");
                waypointLineOut_07 = "waypoints[7] = { ";
                if (!String.IsNullOrEmpty(wp07_name.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + "name=\"" + wp07_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp07_lat.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " lat=\""  + wp07_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp07_long.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " lon=\"" + wp07_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp07_alt.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " alt=" + wp07_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_cp.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " cp=" + wp07_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_pd.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " pd=" + wp07_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_rd.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " rd=" + wp07_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_rho.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " rho=" + wp07_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_theta.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " theta=" + wp07_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_dalt.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " dalt=" + wp07_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_dnorth.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " dnorth=" + wp07_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp07_deast.Text))
                {
                    waypointLineOut_07 = waypointLineOut_07 + " deast=" + wp07_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_07.EndsWith(","))
                {
                    waypointLineOut_07 = waypointLineOut_07.Remove(waypointLineOut_07.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_07 = waypointLineOut_07 + " }\n";

                Console.WriteLine(waypointLineOut_07);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 07.");
            }
        }

        private void WriteWaypoint08()
        {
            if (!String.IsNullOrEmpty(wp08_lat.Text) && !String.IsNullOrEmpty(wp08_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 08");
                waypointLineOut_08 = "waypoints[8] = { ";
                if (!String.IsNullOrEmpty(wp08_name.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + "name=\"" + wp08_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp08_lat.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " lat=\""  + wp08_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp08_long.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " lon=\"" + wp08_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp08_alt.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " alt=" + wp08_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_cp.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " cp=" + wp08_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_pd.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " pd=" + wp08_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_rd.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " rd=" + wp08_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_rho.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " rho=" + wp08_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_theta.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " theta=" + wp08_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_dalt.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " dalt=" + wp08_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_dnorth.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " dnorth=" + wp08_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp08_deast.Text))
                {
                    waypointLineOut_08 = waypointLineOut_08 + " deast=" + wp08_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_08.EndsWith(","))
                {
                    waypointLineOut_08 = waypointLineOut_08.Remove(waypointLineOut_08.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_08 = waypointLineOut_08 + " }\n";

                Console.WriteLine(waypointLineOut_08);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 08.");
            }
        }

        private void WriteWaypoint09()
        {
            if (!String.IsNullOrEmpty(wp09_lat.Text) && !String.IsNullOrEmpty(wp09_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 09");
                waypointLineOut_09 = "waypoints[9] = { ";
                if (!String.IsNullOrEmpty(wp09_name.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + "name=\"" + wp09_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp09_lat.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " lat=\""  + wp09_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp09_long.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " lon=\"" + wp09_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp09_alt.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " alt=" + wp09_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_cp.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " cp=" + wp09_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_pd.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " pd=" + wp09_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_rd.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " rd=" + wp09_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_rho.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " rho=" + wp09_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_theta.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " theta=" + wp09_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_dalt.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " dalt=" + wp09_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_dnorth.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " dnorth=" + wp09_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp09_deast.Text))
                {
                    waypointLineOut_09 = waypointLineOut_09 + " deast=" + wp09_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_09.EndsWith(","))
                {
                    waypointLineOut_09 = waypointLineOut_09.Remove(waypointLineOut_09.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_09 = waypointLineOut_09 + " }\n";

                Console.WriteLine(waypointLineOut_09);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 09.");
            }
        }

        private void WriteWaypoint10()
        {
            if (!String.IsNullOrEmpty(wp10_lat.Text) && !String.IsNullOrEmpty(wp10_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 10");
                waypointLineOut_10 = "waypoints[10] = { ";
                if (!String.IsNullOrEmpty(wp10_name.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + "name=\"" + wp10_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp10_lat.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " lat=\""  + wp10_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp10_long.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " lon=\"" + wp10_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp10_alt.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " alt=" + wp10_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_cp.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " cp=" + wp10_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_pd.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " pd=" + wp10_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_rd.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " rd=" + wp10_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_rho.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " rho=" + wp10_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_theta.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " theta=" + wp10_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_dalt.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " dalt=" + wp10_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_dnorth.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " dnorth=" + wp10_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp10_deast.Text))
                {
                    waypointLineOut_10 = waypointLineOut_10 + " deast=" + wp10_deast.Text + ",";
                }

                //if there is a comma at the end, remove it
                if (waypointLineOut_10.EndsWith(","))
                {
                    waypointLineOut_10 = waypointLineOut_10.Remove(waypointLineOut_10.Length - 1, 1);
                }

                //end the entry
                waypointLineOut_10 = waypointLineOut_10 + " }\n";

                Console.WriteLine(waypointLineOut_10);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 10.");
            }
        }

        private void WriteWaypoint11()
        {
            if (!String.IsNullOrEmpty(wp11_lat.Text) && !String.IsNullOrEmpty(wp11_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 11");
                waypointLineOut_11 = "waypoints[11] = { ";
                if (!String.IsNullOrEmpty(wp11_name.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + "name=\"" + wp11_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp11_lat.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " lat=\""  + wp11_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp11_long.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " lon=\"" + wp11_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp11_alt.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " alt=" + wp11_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_cp.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " cp=" + wp11_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_pd.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " pd=" + wp11_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_rd.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " rd=" + wp11_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_rho.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " rho=" + wp11_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_theta.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " theta=" + wp11_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_dalt.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " dalt=" + wp11_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_dnorth.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " dnorth=" + wp11_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp11_deast.Text))
                {
                    waypointLineOut_11 = waypointLineOut_11 + " deast=" + wp11_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_11.EndsWith(","))
                {
                    waypointLineOut_11 = waypointLineOut_11.Remove(waypointLineOut_11.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_11 = waypointLineOut_11 + " }\n";

                Console.WriteLine(waypointLineOut_11);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 11.");
            }
        }
        private void WriteWaypoint12()
        {
            if (!String.IsNullOrEmpty(wp12_lat.Text) && !String.IsNullOrEmpty(wp12_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 12");
                waypointLineOut_12 = "waypoints[12] = { ";
                if (!String.IsNullOrEmpty(wp12_name.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + "name=\"" + wp12_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp12_lat.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " lat=\""  + wp12_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp12_long.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " lon=\"" + wp12_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp12_alt.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " alt=" + wp12_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_cp.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " cp=" + wp12_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_pd.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " pd=" + wp12_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_rd.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " rd=" + wp12_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_rho.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " rho=" + wp12_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_theta.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " theta=" + wp12_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_dalt.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " dalt=" + wp12_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_dnorth.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " dnorth=" + wp12_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp12_deast.Text))
                {
                    waypointLineOut_12 = waypointLineOut_12 + " deast=" + wp12_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_12.EndsWith(","))
                {
                    waypointLineOut_12 = waypointLineOut_12.Remove(waypointLineOut_12.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_12 = waypointLineOut_12 + " }\n";

                Console.WriteLine(waypointLineOut_12);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 12.");
            }
        }
        private void WriteWaypoint13()
        {
            if (!String.IsNullOrEmpty(wp13_lat.Text) && !String.IsNullOrEmpty(wp13_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 13");
                waypointLineOut_13 = "waypoints[13] = { ";
                if (!String.IsNullOrEmpty(wp13_name.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + "name=\"" + wp13_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp13_lat.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " lat=\""  + wp13_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp13_long.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " lon=\"" + wp13_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp13_alt.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " alt=" + wp13_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_cp.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " cp=" + wp13_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_pd.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " pd=" + wp13_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_rd.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " rd=" + wp13_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_rho.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " rho=" + wp13_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_theta.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " theta=" + wp13_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_dalt.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " dalt=" + wp13_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_dnorth.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " dnorth=" + wp13_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp13_deast.Text))
                {
                    waypointLineOut_13 = waypointLineOut_13 + " deast=" + wp13_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_13.EndsWith(","))
                {
                    waypointLineOut_13 = waypointLineOut_13.Remove(waypointLineOut_13.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_13 = waypointLineOut_13 + " }\n";

                Console.WriteLine(waypointLineOut_13);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 13.");
            }
        }
        private void WriteWaypoint14()
        {
            if (!String.IsNullOrEmpty(wp14_lat.Text) && !String.IsNullOrEmpty(wp14_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 14");
                waypointLineOut_14 = "waypoints[14] = { ";
                if (!String.IsNullOrEmpty(wp14_name.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + "name=\"" + wp14_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp14_lat.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " lat=\""  + wp14_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp14_long.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " lon=\"" + wp14_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp14_alt.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " alt=" + wp14_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_cp.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " cp=" + wp14_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_pd.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " pd=" + wp14_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_rd.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " rd=" + wp14_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_rho.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " rho=" + wp14_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_theta.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " theta=" + wp14_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_dalt.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " dalt=" + wp14_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_dnorth.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " dnorth=" + wp14_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp14_deast.Text))
                {
                    waypointLineOut_14 = waypointLineOut_14 + " deast=" + wp14_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_14.EndsWith(","))
                {
                    waypointLineOut_14 = waypointLineOut_14.Remove(waypointLineOut_14.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_14 = waypointLineOut_14 + " }\n";

                Console.WriteLine(waypointLineOut_14);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 14.");
            }
        }
        private void WriteWaypoint15()
        {
            if (!String.IsNullOrEmpty(wp15_lat.Text) && !String.IsNullOrEmpty(wp15_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 15");
                waypointLineOut_15 = "waypoints[15] = { ";
                if (!String.IsNullOrEmpty(wp15_name.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + "name=\"" + wp15_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp15_lat.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " lat=\""  + wp15_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp15_long.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " lon=\"" + wp15_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp15_alt.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " alt=" + wp15_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_cp.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " cp=" + wp15_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_pd.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " pd=" + wp15_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_rd.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " rd=" + wp15_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_rho.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " rho=" + wp15_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_theta.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " theta=" + wp15_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_dalt.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " dalt=" + wp15_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_dnorth.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " dnorth=" + wp15_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp15_deast.Text))
                {
                    waypointLineOut_15 = waypointLineOut_15 + " deast=" + wp15_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_15.EndsWith(","))
                {
                    waypointLineOut_15 = waypointLineOut_15.Remove(waypointLineOut_15.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_15 = waypointLineOut_15 + " }\n";

                Console.WriteLine(waypointLineOut_15);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 15.");
            }
        }
        private void WriteWaypoint16()
        {
            if (!String.IsNullOrEmpty(wp16_lat.Text) && !String.IsNullOrEmpty(wp16_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 16");
                waypointLineOut_16 = "waypoints[16] = { ";
                if (!String.IsNullOrEmpty(wp16_name.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + "name=\"" + wp16_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp16_lat.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " lat=\""  + wp16_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp16_long.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " lon=\"" + wp16_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp16_alt.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " alt=" + wp16_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_cp.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " cp=" + wp16_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_pd.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " pd=" + wp16_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_rd.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " rd=" + wp16_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_rho.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " rho=" + wp16_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_theta.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " theta=" + wp16_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_dalt.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " dalt=" + wp16_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_dnorth.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " dnorth=" + wp16_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp16_deast.Text))
                {
                    waypointLineOut_16 = waypointLineOut_16 + " deast=" + wp16_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_16.EndsWith(","))
                {
                    waypointLineOut_16 = waypointLineOut_16.Remove(waypointLineOut_16.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_16 = waypointLineOut_16 + " }\n";

                Console.WriteLine(waypointLineOut_16);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 16.");
            }
        }
        private void WriteWaypoint17()
        {
            if (!String.IsNullOrEmpty(wp17_lat.Text) && !String.IsNullOrEmpty(wp17_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 17");
                waypointLineOut_17 = "waypoints[17] = { ";
                if (!String.IsNullOrEmpty(wp17_name.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + "name=\"" + wp17_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp17_lat.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " lat=\""  + wp17_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp17_long.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " lon=\"" + wp17_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp17_alt.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " alt=" + wp17_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_cp.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " cp=" + wp17_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_pd.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " pd=" + wp17_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_rd.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " rd=" + wp17_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_rho.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " rho=" + wp17_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_theta.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " theta=" + wp17_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_dalt.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " dalt=" + wp17_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_dnorth.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " dnorth=" + wp17_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp17_deast.Text))
                {
                    waypointLineOut_17 = waypointLineOut_17 + " deast=" + wp17_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_17.EndsWith(","))
                {
                    waypointLineOut_17 = waypointLineOut_17.Remove(waypointLineOut_17.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_17 = waypointLineOut_17 + " }\n";

                Console.WriteLine(waypointLineOut_17);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 17.");
            }
        }
        private void WriteWaypoint18()
        {
            if (!String.IsNullOrEmpty(wp18_lat.Text) && !String.IsNullOrEmpty(wp18_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 18");
                waypointLineOut_18 = "waypoints[18] = { ";
                if (!String.IsNullOrEmpty(wp18_name.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + "name=\"" + wp18_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp18_lat.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " lat=\""  + wp18_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp18_long.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " lon=\"" + wp18_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp18_alt.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " alt=" + wp18_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_cp.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " cp=" + wp18_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_pd.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " pd=" + wp18_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_rd.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " rd=" + wp18_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_rho.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " rho=" + wp18_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_theta.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " theta=" + wp18_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_dalt.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " dalt=" + wp18_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_dnorth.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " dnorth=" + wp18_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp18_deast.Text))
                {
                    waypointLineOut_18 = waypointLineOut_18 + " deast=" + wp18_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_18.EndsWith(","))
                {
                    waypointLineOut_18 = waypointLineOut_18.Remove(waypointLineOut_18.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_18 = waypointLineOut_18 + " }\n";

                Console.WriteLine(waypointLineOut_18);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 18.");
            }
        }
        private void WriteWaypoint19()
        {
            if (!String.IsNullOrEmpty(wp19_lat.Text) && !String.IsNullOrEmpty(wp19_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 19");
                waypointLineOut_19 = "waypoints[19] = { ";
                if (!String.IsNullOrEmpty(wp19_name.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + "name=\"" + wp19_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp19_lat.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " lat=\""  + wp19_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp19_long.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " lon=\"" + wp19_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp19_alt.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " alt=" + wp19_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_cp.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " cp=" + wp19_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_pd.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " pd=" + wp19_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_rd.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " rd=" + wp19_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_rho.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " rho=" + wp19_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_theta.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " theta=" + wp19_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_dalt.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " dalt=" + wp19_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_dnorth.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " dnorth=" + wp19_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp19_deast.Text))
                {
                    waypointLineOut_19 = waypointLineOut_19 + " deast=" + wp19_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_19.EndsWith(","))
                {
                    waypointLineOut_19 = waypointLineOut_19.Remove(waypointLineOut_19.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_19 = waypointLineOut_19 + " }\n";

                Console.WriteLine(waypointLineOut_19);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 19.");
            }
        }
        private void WriteWaypoint20()
        {
            if (!String.IsNullOrEmpty(wp20_lat.Text) && !String.IsNullOrEmpty(wp20_long.Text))
            {
                Console.WriteLine("Export conditions met for waypoint 20");
                waypointLineOut_20 = "waypoints[20] = { ";
                if (!String.IsNullOrEmpty(wp20_name.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + "name=\"" + wp20_name.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp20_lat.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " lat=\""  + wp20_lat.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp20_long.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " lon=\"" + wp20_long.Text + "\",";
                }
                if (!String.IsNullOrEmpty(wp20_alt.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " alt=" + wp20_alt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_cp.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " cp=" + wp20_cp.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_pd.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " pd=" + wp20_pd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_rd.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " rd=" + wp20_rd.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_rho.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " rho=" + wp20_rho.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_theta.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " theta=" + wp20_theta.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_dalt.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " dalt=" + wp20_dalt.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_dnorth.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " dnorth=" + wp20_dnorth.Text + ",";
                }
                if (!String.IsNullOrEmpty(wp20_deast.Text))
                {
                    waypointLineOut_20 = waypointLineOut_20 + " deast=" + wp20_deast.Text + ",";
                }
                //if there is a comma at the end, remove it
                if (waypointLineOut_20.EndsWith(","))
                {
                    waypointLineOut_20 = waypointLineOut_20.Remove(waypointLineOut_20.Length - 1, 1);
                }
                //end the entry
                waypointLineOut_20 = waypointLineOut_20 + " }\n";

                Console.WriteLine(waypointLineOut_20);
            }
            else
            {
                Console.WriteLine("Export conditions not met for waypoint 20.");
            }
        }

        int textboxWithSomethingInside;
        private void button_GetCoordsFromDcs_Click(object sender, RoutedEventArgs e)
        {
            //This is where the network data is grabbed, if any
            //Set up a listener for port 42080 in a different thread
            string modelNameToEnter = modelName; //unused for now
            string latitudeToEnter = latitude;
            string longitudeToEnter = longitude;
            string elevationToEnter = elevation;



            //if no textboxes have values, check the first one and then fill it
            //https://stackoverflow.com/questions/8750290/how-can-i-check-multiple-textboxes-if-null-or-empty-without-a-unique-test-for-ea
            textboxWithSomethingInside = 0;
            foreach (Control c in containerCanvas.Children) // this breaks with the textblock hints
            {
                if (c is TextBox)
                {
                    TextBox textBox = c as TextBox;
                    if (textBox.Text != string.Empty)
                    {
                        textboxWithSomethingInside++;
                    }
                }
            }

            if (textboxWithSomethingInside == 0)
            {
                wp01_RadioButton.IsChecked = true;
            }


            if ((bool)wp01_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp01_name.Text))
                {
                    wp01_name.Text = "Waypoint 01";
                }
                wp01_lat.Text = latitudeToEnter;
                wp01_long.Text = longitudeToEnter;
                wp01_alt.Text = elevationToEnter;
                wp02_RadioButton.IsChecked = true;
            }

            else if ((bool)wp02_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp02_name.Text))
                {
                    wp02_name.Text = "Waypoint 02";
                }
                wp02_lat.Text = latitudeToEnter;
                wp02_long.Text = longitudeToEnter;
                wp02_alt.Text = elevationToEnter;
                wp03_RadioButton.IsChecked = true;
            }

            else if ((bool)wp03_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp03_name.Text))
                {
                    wp03_name.Text = "Waypoint 03";
                }
                wp03_lat.Text = latitudeToEnter;
                wp03_long.Text = longitudeToEnter;
                wp03_alt.Text = elevationToEnter;
                wp04_RadioButton.IsChecked = true;
            }

            else if ((bool)wp04_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp04_name.Text))
                {
                    wp04_name.Text = "Waypoint 04";
                }
                wp04_lat.Text = latitudeToEnter;
                wp04_long.Text = longitudeToEnter;
                wp04_alt.Text = elevationToEnter;
                wp05_RadioButton.IsChecked = true;
            }

            else if ((bool)wp05_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp05_name.Text))
                {
                    wp05_name.Text = "Waypoint 05";
                }
                wp05_lat.Text = latitudeToEnter;
                wp05_long.Text = longitudeToEnter;
                wp05_alt.Text = elevationToEnter;
                wp06_RadioButton.IsChecked = true;
            }

            else if ((bool)wp06_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp06_name.Text))
                {
                    wp06_name.Text = "Waypoint 06";
                }
                wp06_lat.Text = latitudeToEnter;
                wp06_long.Text = longitudeToEnter;
                wp06_alt.Text = elevationToEnter;
                wp07_RadioButton.IsChecked = true;
            }

            else if ((bool)wp07_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp07_name.Text))
                {
                    wp07_name.Text = "Waypoint 07";
                }
                wp07_lat.Text = latitudeToEnter;
                wp07_long.Text = longitudeToEnter;
                wp07_alt.Text = elevationToEnter;
                wp08_RadioButton.IsChecked = true;
            }

            else if ((bool)wp08_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp08_name.Text))
                {
                    wp08_name.Text = "Waypoint 08";
                }
                wp08_lat.Text = latitudeToEnter;
                wp08_long.Text = longitudeToEnter;
                wp08_alt.Text = elevationToEnter;
                wp09_RadioButton.IsChecked = true;
            }

            else if ((bool)wp09_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp09_name.Text))
                {
                    wp09_name.Text = "Waypoint 09";
                }
                wp09_lat.Text = latitudeToEnter;
                wp09_long.Text = longitudeToEnter;
                wp09_alt.Text = elevationToEnter;
                wp10_RadioButton.IsChecked = true;
            }

            else if ((bool)wp10_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp10_name.Text))
                {
                    wp10_name.Text = "Waypoint 10";
                }
                wp10_lat.Text = latitudeToEnter;
                wp10_long.Text = longitudeToEnter;
                wp10_alt.Text = elevationToEnter;
                wp11_RadioButton.IsChecked = true;
            }

            else if ((bool)wp11_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp11_name.Text))
                {
                    wp11_name.Text = "Waypoint 11";
                }
                wp11_lat.Text = latitudeToEnter;
                wp11_long.Text = longitudeToEnter;
                wp11_alt.Text = elevationToEnter;
                wp12_RadioButton.IsChecked = true;
            }
            else if ((bool)wp12_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp12_name.Text))
                {
                    wp12_name.Text = "Waypoint 12";
                }
                wp12_lat.Text = latitudeToEnter;
                wp12_long.Text = longitudeToEnter;
                wp12_alt.Text = elevationToEnter;
                wp13_RadioButton.IsChecked = true;
            }

            else if ((bool)wp13_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp13_name.Text))
                {
                    wp13_name.Text = "Waypoint 13";
                }
                wp13_lat.Text = latitudeToEnter;
                wp13_long.Text = longitudeToEnter;
                wp13_alt.Text = elevationToEnter;
                wp14_RadioButton.IsChecked = true;
            }

            else if ((bool)wp14_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp14_name.Text))
                {
                    wp14_name.Text = "Waypoint 14";
                }
                wp14_lat.Text = latitudeToEnter;
                wp14_long.Text = longitudeToEnter;
                wp14_alt.Text = elevationToEnter;
                wp15_RadioButton.IsChecked = true;
            }

            else if ((bool)wp15_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp15_name.Text))
                {
                    wp15_name.Text = "Waypoint 15";
                }
                wp15_lat.Text = latitudeToEnter;
                wp15_long.Text = longitudeToEnter;
                wp15_alt.Text = elevationToEnter;
                wp16_RadioButton.IsChecked = true;
            }

            else if ((bool)wp16_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp16_name.Text))
                {
                    wp16_name.Text = "Waypoint 16";
                }
                wp16_lat.Text = latitudeToEnter;
                wp16_long.Text = longitudeToEnter;
                wp16_alt.Text = elevationToEnter;
                wp17_RadioButton.IsChecked = true;
            }

            else if ((bool)wp17_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp17_name.Text))
                {
                    wp17_name.Text = "Waypoint 17";
                }
                wp17_lat.Text = latitudeToEnter;
                wp17_long.Text = longitudeToEnter;
                wp17_alt.Text = elevationToEnter;
                wp18_RadioButton.IsChecked = true;
            }

            else if ((bool)wp18_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp18_name.Text))
                {
                    wp18_name.Text = "Waypoint 18";
                }
                wp18_lat.Text = latitudeToEnter;
                wp18_long.Text = longitudeToEnter;
                wp18_alt.Text = elevationToEnter;
                wp19_RadioButton.IsChecked = true;
            }

            else if ((bool)wp19_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp19_name.Text))
                {
                    wp19_name.Text = "Waypoint 19";
                }
                wp19_lat.Text = latitudeToEnter;
                wp19_long.Text = longitudeToEnter;
                wp19_alt.Text = elevationToEnter;
                wp20_RadioButton.IsChecked = true;
            }

            else if ((bool)wp20_RadioButton.IsChecked)
            {
                if (String.IsNullOrEmpty(wp20_name.Text))
                {
                    wp20_name.Text = "Waypoint 20";
                }
                wp20_lat.Text = latitudeToEnter;
                wp20_long.Text = longitudeToEnter;
                wp20_alt.Text = elevationToEnter;
                wp01_RadioButton.IsChecked = true;
            }
            GetDcsCoordsButtonText();
        }

        Crosshair Crosshair = new Crosshair();

        //https://stackoverflow.com/questions/9668872/how-to-get-windows-position
        //https://stackoverflow.com/questions/11133947/how-do-i-open-a-second-window-from-the-first-window-in-wpf
        private void button_ShowCrosshair_Click(object sender, RoutedEventArgs e)
        {
            if (Crosshair.IsVisible == false)
            {
                Crosshair.Show();
                button_ShowCrosshair.Content = "Hide Crosshair";
            }
            else 
            { 
                Crosshair.Hide();
                button_ShowCrosshair.Content = "Show Crosshair";
            }
            //TODO: dont show if already shown.
            //close if dcs is closed
            //do a isDcsRunning check
        }

        private void button_clearAllFormData_Click(object sender, RoutedEventArgs e)
        {
            //https://stackoverflow.com/questions/37739338/c-sharp-clear-all-textboxes-and-uncheck-all-checkboxes-in-wpf
            foreach (Control ctl in containerCanvas.Children)
            {
                if (ctl.GetType() == typeof(CheckBox))
                    ((CheckBox)ctl).IsChecked = false;
                if (ctl.GetType() == typeof(TextBox))
                    ((TextBox)ctl).Text = String.Empty;
            }
        }

        private void scrollviewer_data_ScrollChanged(object sender, ScrollChangedEventArgs e)
        {
            ////if (sender == scrollviewer_data)
            ////{
            //    scrollviewer_wp.ScrollToVerticalOffset(e.VerticalOffset);
            //    scrollviewer_wpProperties.ScrollToHorizontalOffset(e.HorizontalOffset);
            ////}
        }
        DetailedInstructionsWindow DetailedInstructionsWindow = new DetailedInstructionsWindow();
        private void button_detailedInstructions_Click(object sender, RoutedEventArgs e)
        {
            //if (DetailedInstructionsWindow.IsVisible == false)
            //{
            //    DetailedInstructionsWindow.Show();
            //}
            //else
            //{
            //    DetailedInstructionsWindow.Hide();
            //}
            DetailedInstructionsWindow.Show();
        }

        DefinitionsWindow DefinitionsWindow = new DefinitionsWindow();
        private void button_definitions_Click(object sender, RoutedEventArgs e)
        {
            DefinitionsWindow.Show();
        }

        private void clicked_radiobutton(object sender, RoutedEventArgs e)
        {
            GetDcsCoordsButtonText();
        }

        private void GetDcsCoordsButtonText()
        {
            if (wp01_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP01)";
            }
            if (wp02_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP02)";
            }
            if (wp03_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP03)";
            }
            if (wp04_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP04)";
            }
            if (wp05_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP05)";
            }
            if (wp06_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP06)";
            }
            if (wp07_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP07)";
            }
            if (wp08_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP08)";
            }
            if (wp09_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP09)";
            }
            if (wp10_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP10)";
            }
            if (wp11_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP11)";
            }
            if (wp12_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP12";
            }
            if (wp13_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP13)";
            }
            if (wp14_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP14)";
            }
            if (wp15_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP15)";
            }
            if (wp16_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP16)";
            }
            if (wp17_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP17)";
            }
            if (wp18_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP18)";
            }
            if (wp19_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP19)";
            }
            if (wp20_RadioButton.IsChecked == true)
            {
                button_GetCoordsFromDcs.Content = "Get DCS Coords (WP20)";
            }
        }

        string importedFile;
        string importedName;
        double MoonSharpFactorial()
        {
            string script = @"    
		-- defines a factorial function
		function fact (n)
			if (n == 0) then
				return 1
			else
				return n*fact(n - 1)
			end
		end

	return fact(5)";

            DynValue res = Script.RunString(script);
            Console.WriteLine(res.ToString());
            return res.Number;
        }

        string MoonSharpString()
        {

            DynValue res = Script.RunFile(@"H:\Downloads\[TEMP]\EXAMPLE.dtc");
            Console.WriteLine(res.ToString());
            return "1";
        }

        private void button_import_Click(object sender, RoutedEventArgs e)
        {
            //"are you sure" prompt
            //pick the file dialog



            Regex regex_aircraftGet = new Regex("(?:aircraft\\s+=\\s+\")(.[^\"]*)"); //(?:aircraft\s+=\s +)(\"[^"]*")
                                                                                     //(?:aircraft\s+=\s+")(.[^"]*)

            string regex_aircraftFinder = @"aircraft\s+=\s+";

            Regex regex_dateGet = new Regex("(?:date\\s+=\\s+\")(.[^\"]*)");
            string regex_dateFinder = @"date\s+=\s+";

            Regex regex_DtcNameGet = new Regex("(?:name\\s+=\\s+\")(.[^\"]*)");
            string regex_DtcNameFinder = @"name\s+=\s+";

            Regex regex_WaypointNameGet = new Regex("(waypoints\\[\\d+]\\s*=\\s*{\\s*)(name\\s*=\\s*\")(.[^\\\"]*)"); // (waypoints\[\d+]\s*=\s*{\s*)(name\s*=\s*")(.[^\"]*)
            string regex_WaypointNameFinder = @"name\s*=";

            Regex regex_latNameGet = new Regex("lat\\s*=\\s*\"\\s*(\\w.[^\"]*)"); // lat\s*=\s*"\s *\w(.[^"]*)
            Regex regex_lonNameGet = new Regex("lon\\s*=\\s*\"\\s*(\\w.[^\"]*)");

            Regex regex_altGet = new Regex("(?:alt\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_cpGet = new Regex("(?:cp\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)

            Regex regex_pdGet = new Regex("(?:pd\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_rdGet = new Regex("(?:rd\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_rhoGet = new Regex("(?:rho\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_thetaGet = new Regex("(?:theta\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_daltGet = new Regex("(?:dalt\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_dnorthGet = new Regex("(?:dnorth\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)
            Regex regex_deastGet = new Regex("(?:deast\\s*=\\s*)(\\d*)(\\.?)(\\d*)"); // (?:alt\s*=\s*)(\d*)(\.?)(\d*)

            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "DTC files (*.dtc)|*.dtc|All files (*.*)|*.*";

            if (Directory.Exists(System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS.openbeta", "Datacartridges")))
            {
                openFileDialog.InitialDirectory = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS.openbeta", "Datacartridges");
            }
            else if (Directory.Exists(System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS", "Datacartridges")))
            {
                openFileDialog.InitialDirectory = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Saved Games", "DCS", "Datacartridges");
            }
            else
            {
                openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            }


            if (openFileDialog.ShowDialog() == true)
            {
                Console.WriteLine(openFileDialog.FileName);
                string theFile = openFileDialog.FileName;

                //different way of doing the test
                //string theFile1 = File.ReadAllText(openFileDialog.FileName);
                //theFile1 = theFile1.Replace("terrain", "[\"terrain\"]").Replace("aircraft", "[\"aircraft\"]").
                //    Replace("date", "[\"date\"]").Replace("name", "[\"name\"]").Replace("waypoints = {}", "[\"waypoints\"] = {").
                //    Replace("waypoints[1] = {", "[\"waypoints1\"] = {").Replace("name=", "[\"name\"] = ").Replace("lat=", "[\"lat\"] = ").
                //    Replace("lon=", "[\"lon\"] = ").Replace("alt=", "[\"alt\"] = ").Replace("}", "},");

                //Console.WriteLine(theFile1);
                //return;




                ////for testing only
                ////var importFileLua = LsonVars.Parse(File.ReadAllText(theFile)); // the lua method lua parse way
                //var importFileLua = LsonVars.Parse(File.ReadAllText(theFile));

                //textbox_dtcName.Text = importFileLua["Datacartridge"]["name"].GetString();
                //combobox_terrain.Text = importFileLua["Datacartridge"]["terrain"].GetString();
                //var importedDates = importFileLua["Datacartridge"]["date"].GetStringSafe();
                //datepicker_date.Text = importedDates;
                //Console.WriteLine(importedDates);
                //combobox_aircraft.Text = importFileLua["Datacartridge"]["aircraft"].GetString();

                //wp01_name.Text  = importFileLua["Datacartridge"]["waypoints"]["waypoints1"]["name"].GetString();
                //wp01_lat.Text   = importFileLua["Datacartridge"]["waypoints"]["waypoints1"]["lat"].GetString();
                //wp01_long.Text  = importFileLua["Datacartridge"]["waypoints"]["waypoints1"]["lon"].GetString();
                //wp01_alt.Text   = importFileLua["Datacartridge"]["waypoints"]["waypoints1"]["alt"].GetDecimal().ToString();

                //Console.WriteLine(importFileLua["waypoint[1]"]["name"].GetString()); //a different way?


                //return;
                foreach (string line in System.IO.File.ReadLines(openFileDialog.FileName))
                {
                    //aircraft import changing the combo box isnt working. sad. TODO
                    Match m = Regex.Match(line, regex_aircraftFinder, RegexOptions.IgnoreCase);
                    if (m.Success)
                    {
                        Console.WriteLine("Found '{0}' at position {1}.", m.Value, m.Index);
                        Match matches = regex_aircraftGet.Match(line);
                        Console.WriteLine("Found '{0}' at position {1}.", matches.Groups[1], matches.Index);
                        string importedAircraft = matches.Groups[1].ToString();
                        //button_export.Content = importedAircraft;

                        //TODO: for export, if the combobox is blank, don't export
                        if (combobox_aircraft.Items.Cast<ComboBoxItem>().Any(cbi => cbi.Content.Equals(importedAircraft)))
                        {
                           // combobox_aircraft.Text = importedAircraft;
                            combobox_aircraft.SelectedItem = importedAircraft;
                        }
                    }

                    //skip terrain importing. it will have same issue as "aircrafT". TODO

                    //get date
                    Match m2 = Regex.Match(line, regex_dateFinder, RegexOptions.IgnoreCase);
                    if (m2.Success)
                    {
                        //Console.WriteLine("Found '{0}' at position {1}.", m2.Value, m2.Index);
                        Match matches = regex_dateGet.Match(line);
                        //Console.WriteLine("Found '{0}' at position {1}.", matches.Groups[1], matches.Index);
                        string importedDate = matches.Groups[1].ToString();
                        //button_export.Content = importedDate;

                        datepicker_date.Text = importedDate;
                    }
                    
                    //get dtc name. if there wasnt a name, it defaults to 
                    Match m3 = Regex.Match(line, regex_DtcNameFinder, RegexOptions.IgnoreCase);
                    if (m3.Success)
                    {
                        //Console.WriteLine("Found '{0}' at position {1}.", m3.Value, m3.Index);
                        Match matches = regex_DtcNameGet.Match(line);
                        //Console.WriteLine("Found '{0}' at position {1}.", matches.Groups[1], matches.Index);
                        importedName = matches.Groups[1].ToString();
                        //button_export.Content = importedName;

                        textbox_dtcName.Text = importedName;
                    }
                    
                    if ((String.IsNullOrEmpty(textbox_dtcName.Text)))
                    {
                        textbox_dtcName.Text = "Awesome Mixtape 01";
                    }

                    //evaluate the waypoint stuff
                    if (line.Contains("waypoints[1]"))//determines which waypoint[x] to use for the following variables
                    {
                        
                         if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                            {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp01_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp01_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp01_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp01_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                    
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp01_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            //Console.WriteLine(wp01_cp.Text);
                            //Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp01_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp01_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp01_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp01_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp01_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp01_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp01_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[2]"))
                    {

                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp02_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp02_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp02_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp02_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();

                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp02_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp02_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp02_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp02_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp02_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp02_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp02_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp02_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp02_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[3]"))
                    {

                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp03_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp03_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp03_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp03_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp03_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            //Console.WriteLine(wp03_cp.Text);
                            //Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp03_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp03_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp03_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp03_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp03_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp03_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp03_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[4]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp04_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp04_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp04_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp04_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp04_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            //Console.WriteLine(wp04_cp.Text);
                            //Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp04_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp04_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp04_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp04_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp04_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp04_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp04_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[5]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp05_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp05_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp05_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp05_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp05_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            //Console.WriteLine(wp05_cp.Text);
                            //Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp05_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp05_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp05_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp05_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp05_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp05_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp05_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[6]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp06_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp06_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp06_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp06_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp06_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            //Console.WriteLine(wp06_cp.Text);
                            //Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp06_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp06_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp06_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp06_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp06_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp06_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp06_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[7]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp07_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp07_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp07_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp07_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp07_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp07_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp07_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp07_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp07_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp07_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp07_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp07_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp07_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[8]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp08_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp08_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp08_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp08_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp08_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp08_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp08_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp08_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp08_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp08_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp08_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp08_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp08_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[9]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp09_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp09_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp09_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp09_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp09_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp09_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp09_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp09_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp09_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp09_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp09_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp09_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp09_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[10]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp10_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp10_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp10_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp10_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp10_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp10_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp10_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp10_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp10_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp10_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp10_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp10_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp10_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }

                    if (line.Contains("waypoints[11]"))//determines which waypoint[x] to use for the following variables
                    {

                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp11_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp11_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp11_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp11_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();

                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp11_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp11_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp11_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp11_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp11_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp11_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp11_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp11_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp11_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[12]"))
                    {

                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp12_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp12_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp12_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp12_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();

                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp12_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp12_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp12_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp12_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp12_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp12_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp12_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp12_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp12_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[13]"))
                    {

                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp13_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp13_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp13_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp13_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp13_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp13_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp13_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp13_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp13_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp13_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp13_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp13_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp13_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[14]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp14_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp14_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp14_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp14_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp14_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp14_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp14_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp14_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp14_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp14_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp14_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp14_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp14_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[15]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp15_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp15_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp15_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp15_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp15_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp15_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp15_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp15_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp15_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp15_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp15_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp15_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp15_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[16]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp16_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp16_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp16_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp16_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp16_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp16_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp16_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp16_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp16_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp16_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp16_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp16_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp16_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[17]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp17_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp17_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp17_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp17_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp17_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp17_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp17_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp17_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp17_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp17_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp17_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp17_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp17_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[18]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp18_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp18_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp18_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp18_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp18_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp18_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp18_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp18_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp18_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp18_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp18_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp18_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp18_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[19]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp19_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp19_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp19_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp19_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp19_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp19_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp19_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp19_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp19_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp19_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp19_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp19_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp19_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                    if (line.Contains("waypoints[20]"))
                    {
                        if (Regex.IsMatch(line, "({).*(name\\s*=\\s*)"))
                        {
                            Match matches = regex_WaypointNameGet.Match(line);
                            wp20_name.Text = matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "lat\\s*=\\s*\""))
                        {
                            Match matches = regex_latNameGet.Match(line);
                            wp20_lat.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "lon\\s*=\\s*\""))
                        {
                            Match matches = regex_lonNameGet.Match(line);
                            wp20_long.Text = matches.Groups[1].ToString();
                        }
                        if (Regex.IsMatch(line, "alt\\s*=\\s*"))
                        {
                            Match matches = regex_altGet.Match(line);
                            wp20_alt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "cp\\s*=\\s*"))
                        {
                            Match matches = regex_cpGet.Match(line);
                            wp20_cp.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                            Console.WriteLine(wp20_cp.Text);
                            Console.WriteLine("yolo");
                        }
                        if (Regex.IsMatch(line, "pd\\s*=\\s*"))
                        {
                            Match matches = regex_pdGet.Match(line);
                            wp20_pd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rd\\s*=\\s*"))
                        {
                            Match matches = regex_rdGet.Match(line);
                            wp20_rd.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "rho\\s*=\\s*"))
                        {
                            Match matches = regex_rhoGet.Match(line);
                            wp20_rho.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "theta\\s*=\\s*"))
                        {
                            Match matches = regex_thetaGet.Match(line);
                            wp20_theta.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dalt\\s*=\\s*"))
                        {
                            Match matches = regex_daltGet.Match(line);
                            wp20_dalt.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "dnorth\\s*=\\s*"))
                        {
                            Match matches = regex_dnorthGet.Match(line);
                            wp20_dnorth.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                        if (Regex.IsMatch(line, "deast\\s*=\\s*"))
                        {
                            Match matches = regex_deastGet.Match(line);
                            wp20_deast.Text = matches.Groups[1].ToString() + matches.Groups[2].ToString() + matches.Groups[3].ToString();
                        }
                    }
                }
            }
        }

        private void ParseViaLua()
        {
            
        }

        //https://stackoverflow.com/questions/16914224/wpf-textbox-to-enter-decimal-values
        private void PreviewTextInput(object sender, TextCompositionEventArgs e)
        {
            bool approvedDecimalPoint = false;

            if (e.Text == ".")
            {
                if (!((TextBox)sender).Text.Contains("."))
                    approvedDecimalPoint = true;
            }

            if (e.Text == ":")
            {
                e.Handled = false;
            }

            if (!(char.IsDigit(e.Text, e.Text.Length - 1) || approvedDecimalPoint))
                e.Handled = true;
        }
        

        //https://social.msdn.microsoft.com/Forums/vstudio/en-US/5460722b-619b-4937-b939-38610e9e01ea/textbox-preventing-a-space?forum=wpf
        private void OnPreviewKeyDown(object sender, KeyEventArgs e)
        {

            if (e.Key == Key.Space)
            {
                e.Handled = true;
            }
            base.OnPreviewKeyDown(e);
        }

        //https://stackoverflow.com/questions/32572460/wpf-mvvm-textbox-restrict-to-specific-characters
        private void PreviewTextInputLat(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("^[NS]?[0-9]*[:]{0,1}[0-9]*[:]{0,1}[0-9]*[.]{0,1}[0-9]*$", RegexOptions.IgnoreCase);
            e.Handled = !regex.IsMatch((sender as TextBox).Text.Insert((sender as TextBox).SelectionStart, e.Text));
        }

        private void PreviewTextInputLon(object sender, TextCompositionEventArgs e)
        {
            Regex regex = new Regex("^[EW]?[0-9]*[:]{0,1}[0-9]*[:]{0,1}[0-9]*[.]{0,1}[0-9]*$", RegexOptions.IgnoreCase);
            e.Handled = !regex.IsMatch((sender as TextBox).Text.Insert((sender as TextBox).SelectionStart, e.Text));
        }

        //https://www.codeproject.com/Questions/1066790/How-can-I-restrict-special-character-in-WPF-text-b
        private void OnPreviewKeyDownLimitSpecial(object sender, KeyEventArgs e)
        {
            if (e.Key == Key.OemCloseBrackets || e.Key == Key.OemOpenBrackets || e.Key == Key.OemQuotes ||
               e.Key == Key.OemTilde || e.Key == Key.OemQuestion || e.Key == Key.OemPipe)
            {
                e.Handled = true;
            }
            base.OnPreviewKeyDown(e);
        }

        private void button_copyToClipboard_Click(object sender, RoutedEventArgs e)
        {
            if (String.IsNullOrEmpty(textbox_dtcName.Text))
            {
                //https://docs.microsoft.com/en-us/dotnet/desktop/wpf/windows/how-to-open-message-box?view=netdesktop-6.0
                MessageBox.Show("Name your DTC.", "Configuration", MessageBoxButton.OK, MessageBoxImage.Warning);

                return;
            }

            WriteExportData();
            //https://stackoverflow.com/questions/3546016/how-to-copy-data-to-clipboard-in-c-sharp
            Clipboard.SetText(totalOutText);
        }
    }
}
