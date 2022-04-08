# DCS-DTC-Mission-Planning-System
Welcome to DCS DTC Mission planning System (DMPS)!
1. Download the zip folder containing DMPS.
2. Extract the zip folder using winrar, winzip, 7zip, or etc.
3. If you would like to use the "Get DCS Coords" feature:
    1. Click and drag the `DMPS.lua` file into your 'C:/Users/ProfileName/SavedGames/DCS/Scripts' folder.
    2. If you have a `C:/Users/ProfileName/SavedGames/DCS/Scripts/export/export.lua` file, add the following to the of the file:
        1. local DMPSLfs=require('lfs'); dofile(DMPSLfs.writedir()..'Scripts/DMPS.lua')
    3. If you don't have a Scripts folder or an `export.lua` file, you can click and drag the Scripts folder from the zip into your 'C:/Users/ProfileName/Saved Games/DCS' folder.
4. Run DCS and DMPS.exe [see note 1].
5. In DCS start the M-2000C CAUCASUS Cold Start Instant Action Mission.
6. After the game is finished loading, go to the F10 Map.
7. You can now program your DTC information using DMPS.
8. Populate the mandatory fields at the top. Aircraft, Terrain, Date, and DTC Name.
9. You can enter waypoint values by hand [see note 2] or you can use the "Get DCS Coords" tool (thank you DCSTheWay!):
    1. In DMPS, click the radial button to the left of Waypoint 1.
    2. Give the waypoint a name, if you wish.
    3. Click show crosshair [see note 3].
    4. In DCS, click and drag the map to position the crosshair over your desired coordinate.
    5. In DMPS, click "Get DCS Coords". You sould see the coordinate information in DMPS populate with the information for your selected waypoint.
    6. The radial button will automatically move to the next waypoint. Follow steps 10x to 10y for more waypoints.
11. When you have all the waypoints (up to 20) and waypoint information you desire, click Export.
12. Give the file a name
13. Save the file in Saved Games/DCS/Datacartridges. If the folder does not exist, create it.
14. While in the Datacartridges folder, click "ok" to save the dtc file. The M-2000C will only detect a max of 10 DTC files.
15. Refresh your available DTCs in DCS by doing one of the following:
    1. Pressing LShift+R to restart the mission (Single Player)
    2. Reload the mission by exiting the mission (Single Player or Multiplayer)
    3. Switching into a new aircraft of the same type (Single Player or Multiplayer)
    4. Restart DCS(Single Player or Multiplayer)
16. When you are back in a Cold and Dark M-200C, use the DTC commands to show your DTCs, pick, load, and unload your DTCs. Keybinds are in the menu.
17. Viola! DTC complete! Enjoy!

- Note 1: DMPS does not require DCS to Run.
- Note 2: Garbage in, garbage out... Enter information accurately. See Definitions for assistance on formatting.
- Note 3: The "Get DCS Coords" feature will work for flatscreen, VR, and windowed. DMPS Crosshair feature is only a visual overlay, designed to work accurately only when DCS occupies the entire primary screen. "Get DCS Coords" will get the coordinates at the center of your current F10 view. If you zoom in enough, your coordinates will be accurate, even without the Crosshair. Remember this for VR and when DCS is windowed and many not be centered on your monitor.
- Note 4: The DCS: M2000-C DTC is stil WIP. Use with care.
- Note 5: When the PP BUTs are 10 or less, only BUTS 11-20 will be filled. With PP BUTs more than 10 the DTC fill starting on BUT 1.
