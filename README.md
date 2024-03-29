# DMPS (DCS DTC Mission Planning System)
Showcase video: https://youtu.be/C1SH7A-Tvgk  

[![DMPS](https://cdn.discordapp.com/attachments/894076351139708929/965625876500873267/dmps_youtube.jpg)](https://youtu.be/C1SH7A-Tvgk)

"It is pronounced 'dimps'".  
DMPS provides a GUI (Graphical User Interface) for DTC creation, for modules that support text-based DTC editing. At the time of this readme, the only module to support such a feature is the M-2000C by Razbam. Hopefully more can be added in the future. DMPS can be used in VR or Flatscreen, in Single Player or Multiplayer, and passes MP Integrity check. This is a proof of concept with the hope that it grows into something much bigger for DCS.

DMPS can be used in two ways. Either standalone or in-game via the integrated app. You can use one, either, or both methods whenever you like. Both support DTC export and import (work in progress). There are pros and cons for each. DMPS Standalone can be used at any time, with or without a DCS Install. It has the ability to allow you to create waypoints by grabbing then from your current centered view of the F10 map. DMPS Integrated App is only available while in-game, which may be optimal for VR users, for example.

### DMPS Standalone
DMPS Standalone is launched via `DMPS.exe`. It uses a DCS hook to retrieve coordinate data from the sim.
### DMPS Integrated App
DMPS Integrated App launces when DCS starts. It can be toggled with the hotkey `Ctrl+Shift+F1`. 

|*Pros and cons*|Standalone|In-game App|
|--|--|--|
|Use|Any Time|Within DCS|
|Coordinate Entry|By hand or via "Get DCS Coord"|By hand or via "Get DCS Coord"|
|Lauch|via exe|with DCS|
|Share DTC Data|via file or clipboard|via file or copy/paste|
|DTC Import|via `.dtc` files|via `.dtc` file information|
|DTC Storage (M-2000C)|20 Waypoints|10 Waypoints|

# Installing DMPS
1. Download DMPS which can be found at the ED User Files https://www.digitalcombatsimulator.com/en/files/3321705/.
2. Once downloaded, extract the files via your preferred zip software.
3. Click and Drag the `Scripts` folder into your `Saved Games/DCS` folder. If you are updating, remove all DMPS related files and then drag the new ones over.
4. If you want to use the "Get DCS Coords" feature in DMPS Standalone, add the following to the bottom of your `Scripts/Export.lua` file: `local DMPSLfs=require('lfs'); dofile(DMPSLfs.writedir()..'Scripts/DMPS.lua')`
5. (After reading the rest of this readme) You are now ready to use DMPS! You can move DMPS.exe to any location on your computer or you can create a shortcut, your choice.


## How to use DMPS
**New DTCs are available after aircraft respawn or re-arm**  
1. Start DMPS by either double clicking DMPS.exe (DMPS Standalone) or by starting DCS (DMPS Integrated App).
2. Select your aircraft. If your aircraft is not in the list, it is not supported by DMPS.
3. Select the map for the DTC. If your map is not on the list, it is not supported by DMPS.
4. Enter the date for the DTC. The format is DD/MM/YYYY. Two number day, two number month, four number year. E.g. 25/04/2006.  Acceptable days are 01-31 (keep in mind that different months have different number of days, and leap years). Acceptable months are 01 - 12. Acceptable years are between 1900 and 2099.
5. Enter the name of the DTC. In DMPS Integrated App this will also be the name of the `.dtc` file.
6. Enter your waypoint data. Waypoints with a `Lat` and `Long` entry will be exported. You can use the "Get DCS Coords" button to grab `Lat`, `Long`, and `Alt` from DCS while on the F10 Map with your preferred location centered on the screen (works in VR too). You can also use the `Ctrl+Shift+F2` keybind to capture coordinates.
7. After entering all desired data, press the Export button. In DMPS Standalone you will be prompted to save the DTC to `Saved Games/DCS/Datacartridges`. In DMPS Integrated App the DTC will automatically be exported to the correct location.
8. If you would like to share your DTC you can:  
    a. Navigate to `Saved Games/DCS/Datacartridges` and locate the correct `.dtc` file, or  
    b. In DMPS Standalone click the Copy to Clipboard button to copy the export to your clipboard. You can then paste it in your messaging platform such as Discord, or  
    c. In DMPS Integrated App copy the Export output from the Output box. You can then paste it in your messaging platform such as Discord.  
9. Be aware that some messaging platforms may attempt to format your DTC text. It may be best to share the `.dtc` file itself.

### DTC Import using DMPS Standalone
1. Click the Import button.
2. Locate and pick a `.dtc` file.
3. If it was formatted correctly, the `.dtc` file will be loaded into DMPS.

### DTC Import using DMPS Integrated App  
1. Click the Clear All Data button.
2. In the DTC Name box, type the filename of a DTC. If the name you typed does not exist, options may be shown to you. If necessary, retype a valid name.
3. Click the Import button. The DTC information will be loaded into DMPS.

**New DTCs are available after aircraft respawn or re-arm**  
This can be achieved by one of these methods:
- Re-arm the aircraft
- In single player use the `RShift+R` keybind to restart the mission.
- In Multiplayer go to a Spectator slot and then getting back into the aircraft.
- Restart DCS
    
## Tips and Tricks
- **If you are having some issues upgrading from v0.3.0 to v0.4.0, delete your `C:\Users\...\Saved Games\DCS\Config\DMPS.config` file and restart DCS.**
- You can change the keybinds via the config folder located at `C:\Users\...\Saved Games\DCS\Config\DMPS.config`. You can bind the keybind hotkey to your controller or HOTAS using a 3rd party program like Voice Attack (https://voiceattack.com/).
- You can type in the name of an airport, city or significant location on the F10 map into the waypoint _Name_. The lat and long cooordinates will automatically fill in. If you want to type in Navaid Identifiers, enable the switch left of the waypoint _Name_.
- The Nav Data+ toggle will enable Navaid information withing the DTC database.
- When using DMPS Integrated app with the F10 Map, the in-game coordinate location is "frozen" when the mouse is over the DMPS App. Use this to your advantage and position the App and your F10 Map view in a location where the coordinates will "freeze" where you want them to, allowing you to reference them while typing them in.
- In DMPS Standalone you can combine DTCs by first populating the desired fields and then importing another. The imported fields will take precedence per field. This is useful for situations in which you have a DTC with a few often used waypoints.
- Garbage in, garbage out... Enter information accurately.
- The "Get DCS Coords" feature will work for flatscreen, VR, and windowed. DMPS Crosshair feature is only a visual overlay, designed to work accurately only when DCS occupies the entire primary screen. "Get DCS Coords" will get the coordinates at the center of your current F10 view. If you zoom in enough, your coordinates will be accurate, even without the Crosshair. Remember this for VR and when DCS is windowed and many not be centered on your monitor.
- The DCS: M-2000C DTC is stil WIP. Use with care.
- M-2000C: When the PP BUTs are 10 or less, only BUTS 11-20 will be filled. With PP BUTs more than 10 the DTC fill starting on BUT 1.
- BAD Calculations. Select a populated WPT with the radio selection icon on the left. Aim the crosshair at the desired BAD location. Click the **Convert to Bad** button. Entry is in meters. Displays as nautical miles in-cockpit. DD(.dddd) calculation only.
## Definitions
Different aircraft have different properties for their waypoints. You can learn about what they are and what they mean below.

### M-2000C Waypoint Definitions
|Item|Description|
|--|--|
|Waypoint Name|The name of the waypoint|
|Latitude|The latitude segment of the waypoint. There are three acceptable formats. XDD:MM:SS(.ssss), XDD:MM(.mmmm), and XDD(.dddd). Parentheses are optional extra precision digits of arbitrary length|
|Longitude|The longitude segment of the waypoint. Same rules as Latitude.|
|Altitude|The altitude/elevation of the waypoint. Numbers only.|
|CP|Cap Piste = (True) Runway Heading. Numbers only.|
|PD|Pente Désirée = Desired Glideslope. Numbers only.|
|RD|Route Désirée = Desired Inbound course (towards the waypoint). Numbers only.|
|Rho| Used for Polar BADs, defines the distance from the BUT to the BAD (the offset distance) in meters. Numbers only.|
|Theta|Polar BADs, defines the bearing from the BUT to the BAD. Numbers only.|
|dAlt|deltaL/L BADs, defines the altitude delta between  the BUT and BAD. Numbers only.|
|dNorth|defines the BAD by the distance N/S from the BUT to the BAD. Numbers only.|
|dEast|defines the BAD by the distance E/W from the BUT to the BAD. Numbers only.|  

_Thank you TheSkipjack95_

# Acknowledgements
- Thank you
  - rkusa for DCS-Scratchpad https://github.com/rkusa/dcs-scratchpad/blob/main/Scripts/Hooks/scratchpad-hook.lua  
  - Noisy for DCS-Stopwatch https://forum.dcs.world/topic/256390-stopwatch-overlay-for-vr-like-srs-or-scratchpad/#comment-4521467  
  - aronCiucu for DCSTheWay https://github.com/aronCiucu/DCSTheWay  
  - Lazyboot for finding out and sharing that **re-arming will refresh M-2000C DTCs.**  
  - Razbam team who implemented the unique and accessible aircraft DTC method. Hopefully it can be used by the devs of many more modules.
  - Hoggit for answering my many, many lua questions.
- If you are feeling charitable, please feel free to donate. All donations go to supporting the creation of even more free apps and mods for DCS, just like this one! https://www.paypal.com/paypalme/asherao  
- Join Bailey's VoiceAttack Discord Here https://discord.gg/PbYgC5e  
- See more of my mods here https://www.digitalcombatsimulator.com/en/files/filter/user-is-baileywa/apply/?PER_PAGE=100  
- Talk about DMPS here https://forum.dcs.world/topic/298257-dcs-dmps-dtc-mission-planning-system-by-bailey/  
- Thank you for reading the readme

## Future Project Goals
- [ ] More Aircraft
  - [x] M-2000C
  - [ ] Explore Viggen DTC
  - [ ] Explore Apache DTC
- [ ] Export format checks (to catch user mistakes)
- [x] All Maps
  - [x] Cuacasus
  - [x] Syria
  - [x] Marianas
  - [x] The Channel
  - [x] Persian Gulf
  - [x] Normandy
- [x] Waypoint auto-fill lat/long by F10 Map Name (Cities, Navaids, Airports, significant locaitons)
- [x] DMPS Integrated App "Get DCS Coords"
- [x] DMPS Integrated App Import (v0.3.0)
- [x] Keybind for capturing coordinates
