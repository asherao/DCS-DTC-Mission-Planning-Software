--[[ Summary:
- Thank you rkusa for DCS-Scratchpad https://github.com/rkusa/dcs-scratchpad/blob/main/Scripts/Hooks/scratchpad-hook.lua  
- Thank you Noisy for DCS-Stopwatch https://forum.dcs.world/topic/256390-stopwatch-overlay-for-vr-like-srs-or-scratchpad/#comment-4521467  
- Thank you aronCiucu for DCSTheWay https://github.com/aronCiucu/DCSTheWay  

TODO:
Make showing and hiding elements based on the aircraft combolist, including inital loading
Make framework for sending commands to DCS (apache)
Consider altitude output (meters or feet?)
Consider making the dtc import display thje native coord format of the aircraft
  for visual validation after the dtc was loaded into the aircraft


Future updates:
Consider combining the standalone and app luas
Regex and validate DTC user inputs
Add crosshair label click detection
Consider that different aircraft may not be able to export to all maps

Change Log:
See Github
https://github.com/asherao/DCS-DTC-Mission-Planning-Software/tree/master/Scripts/Hooks
--]]

local function loadDMPS()
    package.path = package.path .. ";.\\Scripts\\?.lua;.\\Scripts\\UI\\?.lua;"

    local lfs = require("lfs")
    local U = require("me_utilities")
    local Skin = require("Skin")
    local DialogLoader = require("DialogLoader")
    local Tools = require("tools")
    local Input = require("Input")
    local dxgui = require('dxgui')

    -- DMPS resources
    local window = nil
    local windowDefaultSkin = nil
    local windowSkinHidden = Skin.windowSkinChatMin()
    local panel = nil
    --local textarea = nil
    local logFile = io.open(lfs.writedir() .. [[Logs\DMPS.log]], "w")
    local config = nil
	local finalExportString
	local programName = "DMPS (DCS-DTC Mission Planning System)"
	local versionNumber = "v0.4.0"
	local author = "by Bailey"
	local windowTitle = programName .. " " .. versionNumber .. " " .. author
	
	-- Tabels
	_listAircraft = {}
	_listTerrain = {}


    --local prevButton = nil
    --local nextButton = nil

    -- State
    local isHidden = true
    local keyboardLocked = false
    local inMission = false

    -- Pages State
    local dirPath = lfs.writedir() .. [[DMPS\]]
    local currentPage = nil
    local pagesCount = 0
    local pages = {}

    -- Crosshair resources
    local crosshairWindow = nil

    local function log(str)
        if not str then
            return
        end

        if logFile then
            logFile:write("[" .. os.date("%H:%M:%S") .. "] " .. str .. "\r\n")
            logFile:flush()
        end
    end
	
	-- TODO: this
	--[[function aircraftSelectedChanged()
		-- when the user changes the selected aircraft, read the aircraft that they had selected
		local selectedAircraft = comboList_aircraft:getText()
		--log('Aircraft selected: ' .. selectedAircraft)
		
		-- clear all of the editBoxes
		clearAllData()
		
		-- change the labels to fit the categories for that aircraft
		if selectedAircraft == 'M-2000C' then
		-- do this
		log('Preparing ' .. selectedAircraft)
		prepareDtc_M2000C()
		elseif selectedAircraft == 'AV8B' then
		elseif selectedAircraft == 'A-10C' then
		elseif selectedAircraft == 'A-10C2' then
		elseif selectedAircraft == 'AH-64D_BLK_II' then
		elseif selectedAircraft == 'AV8BNA' then
		elseif selectedAircraft == 'F-16C_50' then
		elseif selectedAircraft == 'F-5E-3' then
		elseif selectedAircraft == 'F-86F Sabre' then
		elseif selectedAircraft == 'F-14A-95-GR' then
		elseif selectedAircraft == 'F-14A-135-GR' then
		elseif selectedAircraft == 'F-14B' then
		elseif selectedAircraft == 'FA-18_hornet' then
		elseif selectedAircraft == 'JF-17' then
		elseif selectedAircraft == 'Ka-50' then
		elseif selectedAircraft == 'Mi-24P' then
		elseif selectedAircraft == 'Mi-8MT' then
		elseif selectedAircraft == 'MosquitoFBMkVI' then
		elseif selectedAircraft == 'P-51D' then
		elseif selectedAircraft == 'SA342M' then
		elseif selectedAircraft == 'SA342L' then
		elseif selectedAircraft == 'SA342Mistral' then
		elseif selectedAircraft == 'SA342Minigun' then
		elseif selectedAircraft == 'SpitfireLFMkIX' then
		elseif selectedAircraft == 'SpitfireLFMkIXCW' then
		elseif selectedAircraft == 'TF-51D' then
		elseif selectedAircraft == 'UH-1H' then
		end
		
		-- change the number of boxes available for that aircraft
		
		-- in the outbox tell the user that they selected a different aircraft
	end
	--]]
	
	function aircraftSelectedChangedah64d()
		
		-- dont clear all of the editBoxes and data! (or maybe do...)
		--clearAllData()
		
			log('Preparing ' .. comboList_aircraft:getText() .. ' in DTC Area 2.')
			
			-- change the number of boxes available for that aircraft
			-- in the outbox tell the user that they selected a different aircraft
			
			--outputBoxLog("AH-64D DTC loading...")
			-- start hiding everything!
			hideArea2Stuff()
			
			-- show and change the things that are applicable
			-- change the labels to fit the categories for that aircraft
			
			-- Header labels
			label_area2_column02_title:setText('Name')
			label_area2_column03_title:setText('Lat')
			label_area2_column04_title:setText('Long')
			label_area2_column05_title:setText('Alt (ft)')
			label_area2_column06_title:setText('Type') -- WP, HZ, CM, TG
			label_area2_column07_title:setText('Ident') -- 0 to 2 alphanumeric
			label_area2_column08_title:setText('') -- unused
			label_area2_column09_title:setText('') -- unused
			label_area2_column10_title:setText('') -- unused
			label_area2_column11_title:setText('') -- unused
			label_area2_column12_title:setText('') -- unused
			label_area2_column13_title:setText('Free') -- 0 to 3 alphanumeric
		
			-- show editboxes
			show_editBox_column02()
			show_editBox_column03()
			show_editBox_column04()
			show_editBox_column05()
			show_editBox_column13()
			
			-- make Type combolist
			comboList_wp01_column06 = panel.comboList_wp01_column06
			comboList_wp02_column06 = panel.comboList_wp02_column06
			comboList_wp03_column06 = panel.comboList_wp03_column06
			comboList_wp04_column06 = panel.comboList_wp04_column06
			comboList_wp05_column06 = panel.comboList_wp05_column06
			comboList_wp06_column06 = panel.comboList_wp06_column06
			comboList_wp07_column06 = panel.comboList_wp07_column06
			comboList_wp08_column06 = panel.comboList_wp08_column06
			comboList_wp09_column06 = panel.comboList_wp09_column06
			comboList_wp10_column06 = panel.comboList_wp10_column06
			
			comboList_area2_column06 = {}
			table.insert(comboList_area2_column06, "WP")
			table.insert(comboList_area2_column06, "HZ")
			table.insert(comboList_area2_column06, "CM")
			table.insert(comboList_area2_column06, "TG")
			
			for _i,_k in pairs(comboList_area2_column06) do
				local item = ListBoxItem.new(_k)
				comboList_wp01_column06:insertItem(item)
				comboList_wp02_column06:insertItem(item)
				comboList_wp03_column06:insertItem(item)
				comboList_wp04_column06:insertItem(item)
				comboList_wp05_column06:insertItem(item)
				comboList_wp06_column06:insertItem(item)
				comboList_wp07_column06:insertItem(item)
				comboList_wp08_column06:insertItem(item)
				comboList_wp09_column06:insertItem(item)
				comboList_wp10_column06:insertItem(item)
			end
			
            comboList_wp01_column06:selectItem(comboList_wp01_column06:getItem(0))
			comboList_wp02_column06:selectItem(comboList_wp02_column06:getItem(0))
			comboList_wp03_column06:selectItem(comboList_wp03_column06:getItem(0))
			comboList_wp04_column06:selectItem(comboList_wp04_column06:getItem(0))
			comboList_wp05_column06:selectItem(comboList_wp05_column06:getItem(0))
			comboList_wp06_column06:selectItem(comboList_wp06_column06:getItem(0))
			comboList_wp07_column06:selectItem(comboList_wp07_column06:getItem(0))
			comboList_wp08_column06:selectItem(comboList_wp08_column06:getItem(0))
			comboList_wp09_column06:selectItem(comboList_wp09_column06:getItem(0))
			comboList_wp10_column06:selectItem(comboList_wp10_column06:getItem(0))
			
			
			-- Ident section
			
			waypointsList = {}
            table.insert(waypointsList, "CC Communications Check Point")
			table.insert(waypointsList, "WP Waypoint")
			table.insert(waypointsList, "SP Start Point")
			table.insert(waypointsList, "LZ Landing Zone")
			table.insert(waypointsList, "PP Passage Point")
			table.insert(waypointsList, "RP Release Point")
			
			
			comboList_wp01_column07 = panel.comboList_wp01_column07
			comboList_wp02_column07 = panel.comboList_wp02_column07
			comboList_wp03_column07 = panel.comboList_wp03_column07
			comboList_wp04_column07 = panel.comboList_wp04_column07
			comboList_wp05_column07 = panel.comboList_wp05_column07
			comboList_wp06_column07 = panel.comboList_wp06_column07
			comboList_wp07_column07 = panel.comboList_wp07_column07
			comboList_wp08_column07 = panel.comboList_wp08_column07
			comboList_wp09_column07 = panel.comboList_wp09_column07
			comboList_wp10_column07 = panel.comboList_wp10_column07
			
			for _i,_k in pairs(waypointsList) do
				local item = ListBoxItem.new(_k)
				comboList_wp01_column07:insertItem(item)
				comboList_wp02_column07:insertItem(item)
				comboList_wp03_column07:insertItem(item)
				comboList_wp04_column07:insertItem(item)
				comboList_wp05_column07:insertItem(item)
				comboList_wp06_column07:insertItem(item)
				comboList_wp07_column07:insertItem(item)
				comboList_wp08_column07:insertItem(item)
				comboList_wp09_column07:insertItem(item)
				comboList_wp10_column07:insertItem(item)
			end
			
            comboList_wp01_column07:selectItem(comboList_wp01_column07:getItem(0))
			comboList_wp02_column07:selectItem(comboList_wp02_column07:getItem(0))
			comboList_wp03_column07:selectItem(comboList_wp03_column07:getItem(0))
			comboList_wp04_column07:selectItem(comboList_wp04_column07:getItem(0))
			comboList_wp05_column07:selectItem(comboList_wp05_column07:getItem(0))
			comboList_wp06_column07:selectItem(comboList_wp06_column07:getItem(0))
			comboList_wp07_column07:selectItem(comboList_wp07_column07:getItem(0))
			comboList_wp08_column07:selectItem(comboList_wp08_column07:getItem(0))
			comboList_wp09_column07:selectItem(comboList_wp09_column07:getItem(0))
			comboList_wp10_column07:selectItem(comboList_wp10_column07:getItem(0))
			
			-- Set column properties
			editBox_wp01_column13:setAcceptDecimalPoint(false)
			editBox_wp01_column12:setAcceptDecimalPoint(false)
			editBox_wp01_column13:setAcceptDecimalPoint(false)
			editBox_wp01_column10:setAcceptDecimalPoint(false)
			editBox_wp01_column09:setAcceptDecimalPoint(false)
			editBox_wp01_column08:setAcceptDecimalPoint(false)
			editBox_wp01_column07:setAcceptDecimalPoint(false)
			editBox_wp01_column06:setAcceptDecimalPoint(false)
			editBox_wp01_column05:setAcceptDecimalPoint(false)
			editBox_wp01_column04:setAcceptDecimalPoint(false)
			editBox_wp01_column03:setAcceptDecimalPoint(false)
			editBox_wp01_column02:setAcceptDecimalPoint(false)
			
			editBox_wp01_column13:setNumeric(false)
			editBox_wp01_column12:setNumeric(false)
			editBox_wp01_column13:setNumeric(false)
			editBox_wp01_column10:setNumeric(false)
			editBox_wp01_column09:setNumeric(false)
			editBox_wp01_column08:setNumeric(false)
			editBox_wp01_column07:setNumeric(false)
			editBox_wp01_column06:setNumeric(false)
			editBox_wp01_column05:setNumeric(false)
			editBox_wp01_column04:setNumeric(false)
			editBox_wp01_column03:setNumeric(false)
			editBox_wp01_column02:setNumeric(false)
			
			show_comboList_column06()
			show_comboList_column07()
			-- Done
			--outputBoxLog("AH-64D DTC loaded...")
		
	end
	
	function aircraftSelectedChangedm2000c()
	
	end
	
	function show_comboList_column07()
	        comboList_wp01_column07:setVisible(true)
			comboList_wp02_column07:setVisible(true)
			comboList_wp03_column07:setVisible(true)
			comboList_wp04_column07:setVisible(true)
			comboList_wp05_column07:setVisible(true)
			comboList_wp06_column07:setVisible(true)
			comboList_wp07_column07:setVisible(true)
			comboList_wp08_column07:setVisible(true)
			comboList_wp09_column07:setVisible(true)
			comboList_wp10_column07:setVisible(true)
	end
	
	function show_comboList_column06()
	        comboList_wp01_column06:setVisible(true)
			comboList_wp02_column06:setVisible(true)
			comboList_wp03_column06:setVisible(true)
			comboList_wp04_column06:setVisible(true)
			comboList_wp05_column06:setVisible(true)
			comboList_wp06_column06:setVisible(true)
			comboList_wp07_column06:setVisible(true)
			comboList_wp08_column06:setVisible(true)
			comboList_wp09_column06:setVisible(true)
			comboList_wp10_column06:setVisible(true)
	end
	
	function show_editBox_column02()
		editBox_wp01_column02:setVisible(true)
		editBox_wp02_column02:setVisible(true)
		editBox_wp03_column02:setVisible(true)
		editBox_wp04_column02:setVisible(true)
		editBox_wp05_column02:setVisible(true)
		editBox_wp06_column02:setVisible(true)
		editBox_wp07_column02:setVisible(true)
		editBox_wp08_column02:setVisible(true)
		editBox_wp09_column02:setVisible(true)
		editBox_wp10_column02:setVisible(true)
	end

	function show_editBox_column03()	
		editBox_wp01_column03:setVisible(true)
		editBox_wp02_column03:setVisible(true)
		editBox_wp03_column03:setVisible(true)
		editBox_wp04_column03:setVisible(true)
		editBox_wp05_column03:setVisible(true)
		editBox_wp06_column03:setVisible(true)
		editBox_wp07_column03:setVisible(true)
		editBox_wp08_column03:setVisible(true)
		editBox_wp09_column03:setVisible(true)
		editBox_wp10_column03:setVisible(true)
	end		
		
	function show_editBox_column04()
		editBox_wp01_column04:setVisible(true)
		editBox_wp02_column04:setVisible(true)
		editBox_wp03_column04:setVisible(true)
		editBox_wp04_column04:setVisible(true)
		editBox_wp05_column04:setVisible(true)
		editBox_wp06_column04:setVisible(true)
		editBox_wp07_column04:setVisible(true)
		editBox_wp08_column04:setVisible(true)
		editBox_wp09_column04:setVisible(true)
		editBox_wp10_column04:setVisible(true)
	end		
		
	function show_editBox_column05()		
		editBox_wp01_column05:setVisible(true)
		editBox_wp02_column05:setVisible(true)
		editBox_wp03_column05:setVisible(true)
		editBox_wp04_column05:setVisible(true)
		editBox_wp05_column05:setVisible(true)
		editBox_wp06_column05:setVisible(true)
		editBox_wp07_column05:setVisible(true)
		editBox_wp08_column05:setVisible(true)
		editBox_wp09_column05:setVisible(true)
		editBox_wp10_column05:setVisible(true)
	end		
		
	function show_editBox_column06()		
		editBox_wp01_column06:setVisible(true)
		editBox_wp02_column06:setVisible(true)
		editBox_wp03_column06:setVisible(true)
		editBox_wp04_column06:setVisible(true)
		editBox_wp05_column06:setVisible(true)
		editBox_wp06_column06:setVisible(true)
		editBox_wp07_column06:setVisible(true)
		editBox_wp08_column06:setVisible(true)
		editBox_wp09_column06:setVisible(true)
		editBox_wp10_column06:setVisible(true)
	end		
		
	function show_editBox_column07()		
		editBox_wp01_column07:setVisible(true)
		editBox_wp02_column07:setVisible(true)
		editBox_wp03_column07:setVisible(true)
		editBox_wp04_column07:setVisible(true)
		editBox_wp05_column07:setVisible(true)
		editBox_wp06_column07:setVisible(true)
		editBox_wp07_column07:setVisible(true)
		editBox_wp08_column07:setVisible(true)
		editBox_wp09_column07:setVisible(true)
		editBox_wp10_column07:setVisible(true)
	end		
		
	function show_editBox_column08()		
		editBox_wp01_column08:setVisible(true)
		editBox_wp02_column08:setVisible(true)
		editBox_wp03_column08:setVisible(true)
		editBox_wp04_column08:setVisible(true)
		editBox_wp05_column08:setVisible(true)
		editBox_wp06_column08:setVisible(true)
		editBox_wp07_column08:setVisible(true)
		editBox_wp08_column08:setVisible(true)
		editBox_wp09_column08:setVisible(true)
		editBox_wp10_column08:setVisible(true)
	end		
		
	function show_editBox_column09()		
		editBox_wp01_column09:setVisible(true)
		editBox_wp02_column09:setVisible(true)
		editBox_wp03_column09:setVisible(true)
		editBox_wp04_column09:setVisible(true)
		editBox_wp05_column09:setVisible(true)
		editBox_wp06_column09:setVisible(true)
		editBox_wp07_column09:setVisible(true)
		editBox_wp08_column09:setVisible(true)
		editBox_wp09_column09:setVisible(true)
		editBox_wp10_column09:setVisible(true)
	end		
		
	function show_editBox_column10()		
		editBox_wp01_column10:setVisible(true)
		editBox_wp02_column10:setVisible(true)
		editBox_wp03_column10:setVisible(true)
		editBox_wp04_column10:setVisible(true)
		editBox_wp05_column10:setVisible(true)
		editBox_wp06_column10:setVisible(true)
		editBox_wp07_column10:setVisible(true)
		editBox_wp08_column10:setVisible(true)
		editBox_wp09_column10:setVisible(true)
		editBox_wp10_column10:setVisible(true)
	end		
		
	function show_editBox_column11()		
		editBox_wp01_column11:setVisible(true)
		editBox_wp02_column11:setVisible(true)
		editBox_wp03_column11:setVisible(true)
		editBox_wp04_column11:setVisible(true)
		editBox_wp05_column11:setVisible(true)
		editBox_wp06_column11:setVisible(true)
		editBox_wp07_column11:setVisible(true)
		editBox_wp08_column11:setVisible(true)
		editBox_wp09_column11:setVisible(true)
		editBox_wp10_column11:setVisible(true)
	end		
		
	function show_editBox_column12()		
		editBox_wp01_column12:setVisible(true)
		editBox_wp02_column12:setVisible(true)
		editBox_wp03_column12:setVisible(true)
		editBox_wp04_column12:setVisible(true)
		editBox_wp05_column12:setVisible(true)
		editBox_wp06_column12:setVisible(true)
		editBox_wp07_column12:setVisible(true)
		editBox_wp08_column12:setVisible(true)
		editBox_wp09_column12:setVisible(true)
		editBox_wp10_column12:setVisible(true)
	end		
		
	function show_editBox_column13()		
		editBox_wp01_column13:setVisible(true)
		editBox_wp02_column13:setVisible(true)
		editBox_wp03_column13:setVisible(true)
		editBox_wp04_column13:setVisible(true)
		editBox_wp05_column13:setVisible(true)
		editBox_wp06_column13:setVisible(true)
		editBox_wp07_column13:setVisible(true)
		editBox_wp08_column13:setVisible(true)
		editBox_wp09_column13:setVisible(true)
		editBox_wp10_column13:setVisible(true)
	end	
	
	function hideArea2Stuff()
		log('Hiding everything')
		editBox_wp01_column02:setVisible(false)
		editBox_wp02_column02:setVisible(false)
		editBox_wp03_column02:setVisible(false)
		editBox_wp04_column02:setVisible(false)
		editBox_wp05_column02:setVisible(false)
		editBox_wp06_column02:setVisible(false)
		editBox_wp07_column02:setVisible(false)
		editBox_wp08_column02:setVisible(false)
		editBox_wp09_column02:setVisible(false)
		editBox_wp10_column02:setVisible(false)
		
		editBox_wp01_column03:setVisible(false)
		editBox_wp02_column03:setVisible(false)
		editBox_wp03_column03:setVisible(false)
		editBox_wp04_column03:setVisible(false)
		editBox_wp05_column03:setVisible(false)
		editBox_wp06_column03:setVisible(false)
		editBox_wp07_column03:setVisible(false)
		editBox_wp08_column03:setVisible(false)
		editBox_wp09_column03:setVisible(false)
		editBox_wp10_column03:setVisible(false)
		
		editBox_wp01_column04:setVisible(false)
		editBox_wp02_column04:setVisible(false)
		editBox_wp03_column04:setVisible(false)
		editBox_wp04_column04:setVisible(false)
		editBox_wp05_column04:setVisible(false)
		editBox_wp06_column04:setVisible(false)
		editBox_wp07_column04:setVisible(false)
		editBox_wp08_column04:setVisible(false)
		editBox_wp09_column04:setVisible(false)
		editBox_wp10_column04:setVisible(false)
		
		editBox_wp01_column05:setVisible(false)
		editBox_wp02_column05:setVisible(false)
		editBox_wp03_column05:setVisible(false)
		editBox_wp04_column05:setVisible(false)
		editBox_wp05_column05:setVisible(false)
		editBox_wp06_column05:setVisible(false)
		editBox_wp07_column05:setVisible(false)
		editBox_wp08_column05:setVisible(false)
		editBox_wp09_column05:setVisible(false)
		editBox_wp10_column05:setVisible(false)
		
		editBox_wp01_column06:setVisible(false)
		editBox_wp02_column06:setVisible(false)
		editBox_wp03_column06:setVisible(false)
		editBox_wp04_column06:setVisible(false)
		editBox_wp05_column06:setVisible(false)
		editBox_wp06_column06:setVisible(false)
		editBox_wp07_column06:setVisible(false)
		editBox_wp08_column06:setVisible(false)
		editBox_wp09_column06:setVisible(false)
		editBox_wp10_column06:setVisible(false)
		
		editBox_wp01_column07:setVisible(false)
		editBox_wp02_column07:setVisible(false)
		editBox_wp03_column07:setVisible(false)
		editBox_wp04_column07:setVisible(false)
		editBox_wp05_column07:setVisible(false)
		editBox_wp06_column07:setVisible(false)
		editBox_wp07_column07:setVisible(false)
		editBox_wp08_column07:setVisible(false)
		editBox_wp09_column07:setVisible(false)
		editBox_wp10_column07:setVisible(false)
		
		editBox_wp01_column08:setVisible(false)
		editBox_wp02_column08:setVisible(false)
		editBox_wp03_column08:setVisible(false)
		editBox_wp04_column08:setVisible(false)
		editBox_wp05_column08:setVisible(false)
		editBox_wp06_column08:setVisible(false)
		editBox_wp07_column08:setVisible(false)
		editBox_wp08_column08:setVisible(false)
		editBox_wp09_column08:setVisible(false)
		editBox_wp10_column08:setVisible(false)
		
		editBox_wp01_column09:setVisible(false)
		editBox_wp02_column09:setVisible(false)
		editBox_wp03_column09:setVisible(false)
		editBox_wp04_column09:setVisible(false)
		editBox_wp05_column09:setVisible(false)
		editBox_wp06_column09:setVisible(false)
		editBox_wp07_column09:setVisible(false)
		editBox_wp08_column09:setVisible(false)
		editBox_wp09_column09:setVisible(false)
		editBox_wp10_column09:setVisible(false)
		
		editBox_wp01_column10:setVisible(false)
		editBox_wp02_column10:setVisible(false)
		editBox_wp03_column10:setVisible(false)
		editBox_wp04_column10:setVisible(false)
		editBox_wp05_column10:setVisible(false)
		editBox_wp06_column10:setVisible(false)
		editBox_wp07_column10:setVisible(false)
		editBox_wp08_column10:setVisible(false)
		editBox_wp09_column10:setVisible(false)
		editBox_wp10_column10:setVisible(false)
		
		editBox_wp01_column11:setVisible(false)
		editBox_wp02_column11:setVisible(false)
		editBox_wp03_column11:setVisible(false)
		editBox_wp04_column11:setVisible(false)
		editBox_wp05_column11:setVisible(false)
		editBox_wp06_column11:setVisible(false)
		editBox_wp07_column11:setVisible(false)
		editBox_wp08_column11:setVisible(false)
		editBox_wp09_column11:setVisible(false)
		editBox_wp10_column11:setVisible(false)
		
		editBox_wp01_column12:setVisible(false)
		editBox_wp02_column12:setVisible(false)
		editBox_wp03_column12:setVisible(false)
		editBox_wp04_column12:setVisible(false)
		editBox_wp05_column12:setVisible(false)
		editBox_wp06_column12:setVisible(false)
		editBox_wp07_column12:setVisible(false)
		editBox_wp08_column12:setVisible(false)
		editBox_wp09_column12:setVisible(false)
		editBox_wp10_column12:setVisible(false)
		
		editBox_wp01_column13:setVisible(false)
		editBox_wp02_column13:setVisible(false)
		editBox_wp03_column13:setVisible(false)
		editBox_wp04_column13:setVisible(false)
		editBox_wp05_column13:setVisible(false)
		editBox_wp06_column13:setVisible(false)
		editBox_wp07_column13:setVisible(false)
		editBox_wp08_column13:setVisible(false)
		editBox_wp09_column13:setVisible(false)
		editBox_wp10_column13:setVisible(false)
	
	end
	
	function prepareDtc_M2000C()
		log('Preparing DTC for the M-2000C')
	end
	
    local function loadPage(page)
        log("loading page " .. page.path)
        file, err = io.open(page.path, "r")
        if err then
            log("Error reading file: " .. page.path)
            return ""
        else
            local content = file:read("*all")
            file:close()
            --textarea:setText(content)

            -- update title
            --window:setText(page.name)
        end
    end

    local function savePage(path, content, override)
        if path == nil then
            return
        end

        log("saving page " .. path)
        lfs.mkdir(lfs.writedir() .. [[DMPS\]])
        local mode = "a"
        if override then
            mode = "w"
        end
        file, err = io.open(path, mode)
        if err then
            log("Error writing file: " .. path)
        else
            file:write(content)
            file:flush()
            file:close()
        end
    end

    local function nextPage()
        if pagesCount == 0 then
            return
        end

        -- make sure current changes are persisted
        --savePage(currentPage, textarea:getText(), true)

        local lastPage = nil
        for _, page in pairs(pages) do
            if currentPage == nil or (lastPage ~= nil and lastPage.path == currentPage) then
                --loadPage(page)
                currentPage = page.path
                return
            end
            lastPage = page
        end

        -- restart at the beginning
        --loadPage(pages[1])
        currentPage = pages[1].path
    end

    local function prevPage()
        if pagesCount == 0 then
            return
        end

        -- make sure current changes are persisted
        --savePage(currentPage, textarea:getText(), true)

        local lastPage = nil
        for i, page in pairs(pages) do
            if currentPage == nil or (page.path == currentPage and i ~= 1) then
                --loadPage(lastPage)
                currentPage = lastPage.path
                return
            end
            lastPage = page
        end

        -- restart at the end
        --loadPage(pages[pagesCount])
        currentPage = pages[pagesCount].path
    end

    local function loadConfiguration()
        log("Loading config file...")
        local tbl = Tools.safeDoFile(lfs.writedir() .. "Config/DMPSConfig.lua", false)
        if (tbl and tbl.config) then
            log("Configuration exists...")
            config = tbl.config

            -- config migration

            -- add default fontSize config
            --[[if config.fontSize == nil then
                config.fontSize = 14
                saveConfiguration()
            end--]]

            -- move content into text file
            if config.content ~= nil then
                --savePage(dirPath .. [[0000.txt]], config.content, false)
                config.content = nil
                saveConfiguration()
            end
        else
            log("Configuration not found, creating defaults...")
            config = {
                hotkey = "Ctrl+Shift+F1",
				getCoordHotkey = "Ctrl+Shift+F2",
                windowPosition = {x = 200, y = 200},
                windowSize = {w = 895, h = 440}, -- default windowSize = {w = 350, h = 150}
                --fontSize = 14
            }
            saveConfiguration()
        end

        -- scan DMPS dir for pages
		
        for name in lfs.dir(dirPath) do
            local path = dirPath .. name
            log(path)
            if lfs.attributes(path, "mode") == "file" then
                if name:sub(-4) ~= ".txt" then
                    log("Ignoring file " .. name .. ", because of it doesn't seem to be a text file (.txt)")
                elseif lfs.attributes(path, "size") > 1024 * 1024 then
                    log("Ignoring file " .. name .. ", because of its file size of more than 1MB")
                else
                    log("found page " .. path)
                    table.insert(
                        pages,
                        {
                            name = name:sub(1, -5),
                            path = path
                        }
                    )
                    pagesCount = pagesCount + 1
                end
            end
        end

        -- there are no pages yet, create one
		
        if pagesCount == 0 then
            path = dirPath .. [[0000.txt]]
            log("creating page " .. path)
            table.insert(
                pages,
                {
                    name = "0000",
                    path = path
                }
            )
            pagesCount = pagesCount + 1
        end
		
    end

    local function saveConfiguration()
        U.saveInFile(config, "config", lfs.writedir() .. "Config/DMPSConfig.lua")
    end

    local function unlockKeyboardInput(releaseKeyboardKeys)
        if keyboardLocked then
            DCS.unlockKeyboardInput(releaseKeyboardKeys)
            keyboardLocked = false
        end
		window:setText(windowTitle .. "  |  Toggle with " ..  config.hotkey .. ' |  Capture with ' .. config.getCoordHotkey)
    end

    local function lockKeyboardInput()
        if keyboardLocked then
            return
        end

        local keyboardEvents = Input.getDeviceKeys(Input.getKeyboardDeviceName())
        DCS.lockKeyboardInput(keyboardEvents)
        keyboardLocked = true
		window:setText(windowTitle .. "  |  Focused  |  press ESC to Un-Focus")
    end

    function formatCoord(type, isLat, d)
        local h
        if isLat then
            if d < 0 then
                h = 'S'
                d = -d
            else
                h = 'N'
            end
        else
            if d < 0 then
                h = 'W'
                d = -d
            else
                h = 'E'
            end
        end

        local g = math.floor(d)
        local m = math.floor(d * 60 - g * 60)
        local s = d * 3600 - g * 3600 - m * 60

        if type == "DMS" then -- Degree Minutes Seconds
            s = math.floor(s * 100) / 100
            return string.format('%s %2d°%.2d\'%05.2f"', h, g, m, s)
        elseif type == "DDM" then -- Degree Decimal Minutes
            s = math.floor(s / 60 * 1000)
            return string.format('%s %2d°%02d.%3.3d\'', h, g, m, s)
        else -- Decimal Degrees
            return string.format('%f',d)
        end
    end

    local function coordsType()
        local ac = DCS.getPlayerUnitType()
        if ac == "FA-18C_hornet" then
            return "DMS", true
        elseif ac == "A-10C_2" then
            return "DDM", true
        elseif ac == "F-16C_50" or ac == "M-2000C" then
            return "DDM", false
        elseif ac == "AH-64D_BLK_II" then
            return "DDM", true
        else
            return nil, false
        end
    end

    local function insertCoordinates()
	
		
        local pos = Export.LoGetCameraPosition().p
        local alt = Terrain.GetSurfaceHeightWithSeabed(pos.x, pos.z)
        local lat, lon = Terrain.convertMetersToLatLon(pos.x, pos.z)
        local mgrs = Terrain.GetMGRScoordinates(pos.x, pos.z)
        local type, includeMgrs = coordsType()
		local model = Export.LoGetSelfData().Name
		
        local result = "\n\n"
        if type == nil or type == "DMS" then
            result = result .. formatCoord("DMS", true, lat) .. ", " .. formatCoord("DMS", false, lon) .. "\n"
        end
        if type == nil or type == "DDM" then
            result = result .. formatCoord("DDM", true, lat) .. ", " .. formatCoord("DDM", false, lon) .. "\n"
        end
        if type == nil or includeMgrs then
            result = result .. mgrs .. "\n"
        end
        result = result .. string.format("%.0f", alt) .. "m, ".. string.format("%.0f", alt*3.28084) .. "ft\n\n"

        --local text = textarea:getText()
        --local lineCountBefore = textarea:getLineCount()
        --local _lineBegin, _indexBegin, lineEnd, _indexEnd = textarea:getSelectionNew()

        -- find offset into string after the line the cursor is in
--[[
        local offset = 0
        for i = 0, lineEnd do
            offset = string.find(text, "\n", offset + 1, true)
            if offset == nil then
                offset = string.len(text)
                break
            end
        end
--]]
        -- insert the coordinates after the line the cursor is in
        --textarea:setText(string.sub(text, 1, offset - 1) .. result .. string.sub(text, offset + 1, string.len(text)))

        -- place cursor after inserted text
        --local lineCountAdded = textarea:getLineCount() - lineCountBefore
        --local line = lineEnd + lineCountAdded - 1
        --textarea:setSelectionNew(line, 0, line, 0)
		
		local lat_formated = string.format("%.4f", lat)
		local lon_formated = string.format("%.4f", lon)
		local alt_formated = string.format("%.2f", alt)
		
		-- populate the information for the labels
		label_telemetry_aircraft:setText('Aircraft: ' .. model)
		label_telemetry_coordinatesLat:setText('Lat: ' .. lat_formated)
		label_telemetry_coordinatesLong:setText('Long: ' .. lon_formated)
		label_telemetry_elevation:setText('Altitude: ' .. alt_formated)
		
		
		-- Logic for the radio button part of the coordinate entry
		if radiobutton_waypoint01:getState(true) then
			editBox_wp01_column03:setText(lat_formated)
			editBox_wp01_column04:setText(lon_formated)
			editBox_wp01_column05:setText(alt_formated)
			log("Waypoint 01 info populated")
			radiobutton_waypoint02:setState(true)
		elseif radiobutton_waypoint02:getState(true) then
            editBox_wp02_column03:setText(lat_formated)
			editBox_wp02_column04:setText(lon_formated)
			editBox_wp02_column05:setText(alt_formated)
			log("Waypoint 02 info populated")
			radiobutton_waypoint03:setState(true)
        elseif radiobutton_waypoint03:getState(true) then
            editBox_wp03_column03:setText(lat_formated)
			editBox_wp03_column04:setText(lon_formated)
			editBox_wp03_column05:setText(alt_formated)
			log("Waypoint 03 info populated")
			radiobutton_waypoint04:setState(true)
        elseif radiobutton_waypoint04:getState(true) then
            editBox_wp04_column03:setText(lat_formated)
			editBox_wp04_column04:setText(lon_formated)
			editBox_wp04_column05:setText(alt_formated)
			log("Waypoint 04 info populated")
			radiobutton_waypoint05:setState(true)
        elseif radiobutton_waypoint05:getState(true) then
            editBox_wp05_column03:setText(lat_formated)
			editBox_wp05_column04:setText(lon_formated)
			editBox_wp05_column05:setText(alt_formated)
			log("Waypoint 05 info populated")
			radiobutton_waypoint06:setState(true)
        elseif radiobutton_waypoint06:getState(true) then
            editBox_wp06_column03:setText(lat_formated)
			editBox_wp06_column04:setText(lon_formated)
			editBox_wp06_column05:setText(alt_formated)
			log("Waypoint 06 info populated")
			radiobutton_waypoint07:setState(true)
        elseif radiobutton_waypoint07:getState(true) then
            editBox_wp07_column03:setText(lat_formated)
			editBox_wp07_column04:setText(lon_formated)
			editBox_wp07_column05:setText(alt_formated)
			log("Waypoint 07 info populated")
			radiobutton_waypoint08:setState(true)
        elseif radiobutton_waypoint08:getState(true) then
            editBox_wp08_column03:setText(lat_formated)
			editBox_wp08_column04:setText(lon_formated)
			editBox_wp08_column05:setText(alt_formated)
			log("Waypoint 08 info populated")
			radiobutton_waypoint09:setState(true)
        elseif radiobutton_waypoint09:getState(true) then
            editBox_wp09_column03:setText(lat_formated)
			editBox_wp09_column04:setText(lon_formated)
			editBox_wp09_column05:setText(alt_formated)
			log("Waypoint 09 info populated")
			radiobutton_waypoint10:setState(true)
        elseif radiobutton_waypoint10:getState(true) then
            editBox_wp10_column03:setText(lat_formated)
			editBox_wp10_column04:setText(lon_formated)
			editBox_wp10_column05:setText(alt_formated)
			log("Waypoint 10 info populated")
			--radiobutton_waypoint01:setState(true) -- the option to cycle to the beginning
		end
	end

    local function setVisible(b)
        window:setVisible(b)
    end
	
	local function outputBoxLog(text)
		-- clear the box if there was a valid output already there TODO: make better detection
		if string.find(editBox_output:getText(), "terrain=") then
			editBox_output:setText("") -- clears the edit box
		end
		
		if string.find(editBox_output:getText(), "terrain =") then
			editBox_output:setText("") -- clears the edit box
		end
		
		-- get the contents of the box, but puts the error message before it when re-displaying it
		local outputBoxContents = editBox_output:getText()
		editBox_output:setText("[" .. os.date("%H:%M:%S") .. "] " .. text .. "\n" .. outputBoxContents)
	end
	
	local function clearAllData()
	
	-- test for hiding the panel. success.
	--panel:setVisible(false) -- works
	--window.m2000c:setVisible(false) -- works
	--log('window.m2000c:setVisible(false)')
	
	--window.m2000c.label_aircraft:setText("Hellow") -- works
	
	
	--window.ah64d:setVisible(true)
	--log('window.ah64d:setVisible(true)')
	
	--window.ah64d.label_aircraft:setText("Hellow")
	--window.ah64d.label_aircraft:setVisible(true)
	--log('window.ah64d.label_aircraft:setVisible(true)')
	--[[
	-- test for auto inputs. multi-entry success with dcsTheWay installed
	local host, port = "127.0.0.1", 42070
	local socket = require("socket")
	local tcp = assert(socket.tcp())
	
	tcp:connect(host, port);
	--note the newline below
	--tcp:send("hello world\n");
	--local sendInformation = 'GetDevice(63):performClickableAction(3013,1)'
	local sendInformation = ('[{"code":"3029","delay":"0","addDepress":"true","activate":"1","device":"43"},{"code":"3013","delay":"0","addDepress":"true","activate":"1","device":"43"},{"code":"3023","delay":"0","addDepress":"true","activate":"1","device":"43"},{"code":"3024","delay":"10","addDepress":"true","activate":"1","device":"43"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3001","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3020","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3033","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3037","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3043","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3038","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3038","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3011","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3043","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3035","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3035","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3041","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"}]' .. '\n');
	
	outputBoxLog(sendInformation)
	tcp:send(sendInformation)
	
	--tcp:send('[{"code":"3029","delay":"0","addDepress":"true","activate":"1","device":"43"},{"code":"3013","delay":"0","addDepress":"true","activate":"1","device":"43"},{"code":"3023","delay":"0","addDepress":"true","activate":"1","device":"43"},{"code":"3024","delay":"10","addDepress":"true","activate":"1","device":"43"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3001","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3020","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3033","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3037","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3043","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3038","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3038","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3011","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3043","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3036","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3035","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3035","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3041","delay":"3","addDepress":"true","activate":"1","device":"29"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"},{"code":"3006","delay":"10","addDepress":"true","activate":"1","device":"29"}]' .. '\n');
	--]]
	
	
	--[[
	while true do
		local s, status, partial = tcp:receive()
		print(s or partial)
		if status == "closed" then break end
	end
	--]]
	--tcp:close()
	
	
	-- test range complete
	
	
		log('clearAllData() called')
		if checkbox_clearAllData:getState() then
		
			-- using one line to test. works
			--editBox_wp01_column03:setText("")
			
			-- clears all edit boxes
			-- clears the log edit box
			-- resets the date box
			-- resets the dtc name box
			---[[
			editBox_dtcName:setText("DTC Name")
			editBox_date:setText("DD/MM/YYYY")
			
			comboList_aircraft:selectItem(comboList_aircraft:getItem(0))
			comboList_terrain:selectItem(comboList_terrain:getItem(0))
			
			editBox_output:setText("")
			
			editBox_wp01_column02:setText("")
			editBox_wp02_column02:setText("")
			editBox_wp03_column02:setText("")
			editBox_wp04_column02:setText("")
			editBox_wp05_column02:setText("")
			editBox_wp06_column02:setText("")
			editBox_wp07_column02:setText("")
			editBox_wp08_column02:setText("")
			editBox_wp09_column02:setText("")
			editBox_wp10_column02:setText("")
			
			editBox_wp01_column03:setText("")
			editBox_wp02_column03:setText("")
			editBox_wp03_column03:setText("")
			editBox_wp04_column03:setText("")
			editBox_wp05_column03:setText("")
			editBox_wp06_column03:setText("")
			editBox_wp07_column03:setText("")
			editBox_wp08_column03:setText("")
			editBox_wp09_column03:setText("")
			editBox_wp10_column03:setText("")
			
			editBox_wp01_column04:setText("")
			editBox_wp02_column04:setText("")
			editBox_wp03_column04:setText("")
			editBox_wp04_column04:setText("")
			editBox_wp05_column04:setText("")
			editBox_wp06_column04:setText("")
			editBox_wp07_column04:setText("")
			editBox_wp08_column04:setText("")
			editBox_wp09_column04:setText("")
			editBox_wp10_column04:setText("")
			
			editBox_wp01_column05:setText("")
			editBox_wp02_column05:setText("")
			editBox_wp03_column05:setText("")
			editBox_wp04_column05:setText("")
			editBox_wp05_column05:setText("")
			editBox_wp06_column05:setText("")
			editBox_wp07_column05:setText("")
			editBox_wp08_column05:setText("")
			editBox_wp09_column05:setText("")
			editBox_wp10_column05:setText("")
			
			editBox_wp01_column06:setText("")
			editBox_wp02_column06:setText("")
			editBox_wp03_column06:setText("")
			editBox_wp04_column06:setText("")
			editBox_wp05_column06:setText("")
			editBox_wp06_column06:setText("")
			editBox_wp07_column06:setText("")
			editBox_wp08_column06:setText("")
			editBox_wp09_column06:setText("")
			editBox_wp10_column06:setText("")
			
			
			editBox_wp01_column07:setText("")
			editBox_wp02_column07:setText("")
			editBox_wp03_column07:setText("")
			editBox_wp04_column07:setText("")
			editBox_wp05_column07:setText("")
			editBox_wp06_column07:setText("")
			editBox_wp07_column07:setText("")
			editBox_wp08_column07:setText("")
			editBox_wp09_column07:setText("")
			editBox_wp10_column07:setText("")
			
			
			editBox_wp01_column08:setText("")
			editBox_wp02_column08:setText("")
			editBox_wp03_column08:setText("")
			editBox_wp04_column08:setText("")
			editBox_wp05_column08:setText("")
			editBox_wp06_column08:setText("")
			editBox_wp07_column08:setText("")
			editBox_wp08_column08:setText("")
			editBox_wp09_column08:setText("")
			editBox_wp10_column08:setText("")
			
			editBox_wp01_column09:setText("")
			editBox_wp02_column09:setText("")
			editBox_wp03_column09:setText("")
			editBox_wp04_column09:setText("")
			editBox_wp05_column09:setText("")
			editBox_wp06_column09:setText("")
			editBox_wp07_column09:setText("")
			editBox_wp08_column09:setText("")
			editBox_wp09_column09:setText("")
			editBox_wp10_column09:setText("")
			
			editBox_wp01_column10:setText("")
			editBox_wp02_column10:setText("")
			editBox_wp03_column10:setText("")
			editBox_wp04_column10:setText("")
			editBox_wp05_column10:setText("")
			editBox_wp06_column10:setText("")
			editBox_wp07_column10:setText("")
			editBox_wp08_column10:setText("")
			editBox_wp09_column10:setText("")
			editBox_wp10_column10:setText("")
			
			editBox_wp01_column11:setText("")
			editBox_wp02_column11:setText("")
			editBox_wp03_column11:setText("")
			editBox_wp04_column11:setText("")
			editBox_wp05_column11:setText("")
			editBox_wp06_column11:setText("")
			editBox_wp07_column11:setText("")
			editBox_wp08_column11:setText("")
			editBox_wp09_column11:setText("")
			editBox_wp10_column11:setText("")
			
			editBox_wp01_column12:setText("")
			editBox_wp02_column12:setText("")
			editBox_wp03_column12:setText("")
			editBox_wp04_column12:setText("")
			editBox_wp05_column12:setText("")
			editBox_wp06_column12:setText("")
			editBox_wp07_column12:setText("")
			editBox_wp08_column12:setText("")
			editBox_wp09_column12:setText("")
			editBox_wp10_column12:setText("")
			
			editBox_wp01_column13:setText("")
			editBox_wp02_column13:setText("")
			editBox_wp03_column13:setText("")
			editBox_wp04_column13:setText("")
			editBox_wp05_column13:setText("")
			editBox_wp06_column13:setText("")
			editBox_wp07_column13:setText("")
			editBox_wp08_column13:setText("")
			editBox_wp09_column13:setText("")
			editBox_wp10_column13:setText("")
			--end
			--]]
			radiobutton_waypoint01:setState(true)
			
			checkbox_clearAllData:setState(false)
		else -- the user didnt have the checkbox checked
			outputBoxLog("Before clicking Reset All Data, check the checkbox next to the button.")
		
		end
		 
	end

	local function import()
		-- this fumction will take the contents of the edit box and import it
		-- into the DTC fields
		-- Consider not including the aircraft
		-- The parsing should look like the standalone version of DMPS
		-- Take editbox_output:getText() and evaluate it line by line
			-- that may need a different function
			-- consider putting each line in a table and then parsing it that way, which is
				-- similar to how it is done in DMPS standalone
		-- after the attempted import, passor fail, clear the log/output box and display the results
			-- eg, 'Import of DTC: Success/Failed'
		-- you dont have to, but try to do data validation
		log("Import button pressed")
		--outputBoxLog("Import function not yet available")
		-- tell the user this is unavailable
		
		-- Idea #2 for how this will work
		-- if there is any text inn the DTC name box, then thats the DCS name that will be searched
		-- when the user clicks the import button. if that name was not found then the list of names
		-- will be printed in the Output box
		
		local requestedDtc = editBox_dtcName:getText() -- eg 'Airports'
		local requestedDtcFullPath = lfs.writedir() .. "Datacartridges\\" .. requestedDtc .. ".dtc"
		if file_exists(requestedDtcFullPath) then
			log("Requested Import file exists: " .. requestedDtc)
			loadDtc(requestedDtcFullPath)
			editBox_output:setText('')
			outputBoxLog(requestedDtc .. " DTC Imported!")
			
		else
			log("Requested Import file does not exist: " .. lfs.writedir() .. "Datacartridges\\" .. requestedDtc .. " - Listing available files:")
			--https://forum.minetest.net/viewtopic.php?t=8916
			editBox_output:setText('')
			for filename in lfs.dir(lfs.writedir() .. "/Datacartridges") do
				if filename ~= "." and filename ~= ".." then
					--https://stackoverflow.com/questions/18884396/extracting-filename-only-with-pattern-matching
					local filename = filename:match("(.+)%..+")
					log(filename)
					outputBoxLog(filename)
				end
			end
			-- reverse order becuse the log prints from the top
			outputBoxLog('Try one of these:')
			outputBoxLog('Could not find the DTC named: ' .. requestedDtc)
		end
	end
	--[[function changeColumnNames()
	
		editBox_output:setText('new aircraft selected')
	 Not working
		local item = comboList_aircraft:getSelectedItem().index)
		--local index = comboList_aircraft:getItemIndex(item)+1
		editBox_output:setText(item)
		
	
	end--]]
	
	function loadDtc(requestedDtcFullPath)
		log('Putting ' .. requestedDtcFullPath .. ' in a table...')
		
		-- https://www.oreilly.com/library/view/lua-quick-start/9781789343229/73bf1866-8311-4cb7-933d-d7e76b1098a7.xhtml
		file = io.open(requestedDtcFullPath)lines = file:lines()print("Contents of file:");
		for line in lines do
			log(line)
			
			-- clean up the file a bit
			line = line:gsub('"', '')
			line = line:gsub('{', '')
			line = line:gsub('}', '')
			
			-- matching for the headers
			if string.match(line,"terrain%s*=%s*") then
				local capture =  string.match(line,"terrain%s*=%s*(.*)")
				comboList_terrain:setText(capture)
				log("Terrain is: " .. capture)
			elseif string.match(line,"aircraft%s*=%s*") then
				local capture =  string.match(line,"aircraft%s*=%s*(.*)")
				comboList_aircraft:setText(capture)
				log("Aircraft is: " .. capture)
			elseif string.match(line,"date%s*=%s*") then
				local capture =  string.match(line,"date%s*=%s*(.*)")
				editBox_date:setText(capture)
				log("Date is: " .. capture)
			elseif string.match(line,"name%s+=%s+(.+)") then
				local capture =  string.match(line,"name%s*=%s*(.*)")
				editBox_dtcName:setText(capture)
				log("DTC Name is: " .. capture)
			
			-- matching for the waypoints
			elseif string.match(line,"waypoints%[1%]") then
				log("Wp01 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp01 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp01_column02:setText(capture)
					log("Wp01 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp01 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp01_column03:setText(capture)
					log("Wp01 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp01 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp01_column04:setText(capture)
					log("Wp01 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp01 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp01_column05:setText(capture)
					log("Wp01 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp01 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp01_column05:setText(capture)
					log("Wp01 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp01 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp01_column06:setText(capture)
					log("Wp01 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp01 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp01_column07:setText(capture)
					log("Wp01 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp01 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp01_column08:setText(capture)
					log("Wp01 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp01 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp01_column09:setText(capture)
					log("Wp01 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp01 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp01_column10:setText(capture)
					log("Wp01 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp01 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp01_column11:setText(capture)
					log("Wp01 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp01 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp01_column12:setText(capture)
					log("Wp01 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp01 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp01_column13:setText(capture)
					log("Wp01 deast is: " .. capture)
				end
			
			elseif string.match(line,"waypoints%[2%]") then
				log("Wp02 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp02 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp02_column02:setText(capture)
					log("Wp02 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp02 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp02_column03:setText(capture)
					log("Wp02 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp02 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp02_column04:setText(capture)
					log("Wp02 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp02 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp02_column05:setText(capture)
					log("Wp02 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp02 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp02_column05:setText(capture)
					log("Wp02 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp02 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp02_column06:setText(capture)
					log("Wp02 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp02 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp02_column07:setText(capture)
					log("Wp02 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp02 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp02_column08:setText(capture)
					log("Wp02 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp02 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp02_column09:setText(capture)
					log("Wp02 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp02 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp02_column10:setText(capture)
					log("Wp02 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp02 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp02_column11:setText(capture)
					log("Wp02 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp02 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp02_column12:setText(capture)
					log("Wp02 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp02 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp02_column13:setText(capture)
					log("Wp02 deast is: " .. capture)
				end
			elseif string.match(line,"waypoints%[3%]") then
				log("Wp03 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp03 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp03_column02:setText(capture)
					log("Wp03 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp03 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp03_column03:setText(capture)
					log("Wp03 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp03 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp03_column04:setText(capture)
					log("Wp03 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp03 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp03_column05:setText(capture)
					log("Wp03 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp03 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp03_column05:setText(capture)
					log("Wp03 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp03 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp03_column06:setText(capture)
					log("Wp03 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp03 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp03_column07:setText(capture)
					log("Wp03 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp03 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp03_column08:setText(capture)
					log("Wp03 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp03 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp03_column09:setText(capture)
					log("Wp03 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp03 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp03_column10:setText(capture)
					log("Wp03 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp03 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp03_column11:setText(capture)
					log("Wp03 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp03 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp03_column12:setText(capture)
					log("Wp03 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp03 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp03_column13:setText(capture)
					log("Wp03 deast is: " .. capture)
				end	
			elseif string.match(line,"waypoints%[4%]") then
				log("Wp04 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp04 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp04_column02:setText(capture)
					log("Wp04 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp04 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp04_column03:setText(capture)
					log("Wp04 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp04 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp04_column04:setText(capture)
					log("Wp04 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp04 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp04_column05:setText(capture)
					log("Wp04 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp04 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp04_column05:setText(capture)
					log("Wp04 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp04 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp04_column06:setText(capture)
					log("Wp04 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp04 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp04_column07:setText(capture)
					log("Wp04 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp04 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp04_column08:setText(capture)
					log("Wp04 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp04 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp04_column09:setText(capture)
					log("Wp04 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp04 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp04_column10:setText(capture)
					log("Wp04 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp04 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp04_column11:setText(capture)
					log("Wp04 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp04 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp04_column12:setText(capture)
					log("Wp04 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp04 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp04_column13:setText(capture)
					log("Wp04 deast is: " .. capture)
				end				
			elseif string.match(line,"waypoints%[5%]") then
				log("Wp05 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp05 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp05_column02:setText(capture)
					log("Wp05 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp05 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp05_column03:setText(capture)
					log("Wp05 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp05 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp05_column04:setText(capture)
					log("Wp05 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp05 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp05_column05:setText(capture)
					log("Wp05 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp05 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp05_column05:setText(capture)
					log("Wp05 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp05 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp05_column06:setText(capture)
					log("Wp05 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp05 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp05_column07:setText(capture)
					log("Wp05 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp05 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp05_column08:setText(capture)
					log("Wp05 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp05 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp05_column09:setText(capture)
					log("Wp05 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp05 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp05_column10:setText(capture)
					log("Wp05 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp05 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp05_column11:setText(capture)
					log("Wp05 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp05 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp05_column12:setText(capture)
					log("Wp05 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp05 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp05_column13:setText(capture)
					log("Wp05 deast is: " .. capture)
				end				
			elseif string.match(line,"waypoints%[6%]") then
				log("Wp06 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp06 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp06_column02:setText(capture)
					log("Wp06 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp06 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp06_column03:setText(capture)
					log("Wp06 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp06 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp06_column04:setText(capture)
					log("Wp06 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp06 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp06_column05:setText(capture)
					log("Wp06 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp06 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp06_column05:setText(capture)
					log("Wp06 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp06 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp06_column06:setText(capture)
					log("Wp06 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp06 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp06_column07:setText(capture)
					log("Wp06 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp06 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp06_column08:setText(capture)
					log("Wp06 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp06 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp06_column09:setText(capture)
					log("Wp06 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp06 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp06_column10:setText(capture)
					log("Wp06 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp06 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp06_column11:setText(capture)
					log("Wp06 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp06 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp06_column12:setText(capture)
					log("Wp06 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp06 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp06_column13:setText(capture)
					log("Wp06 deast is: " .. capture)
				end
			
			elseif string.match(line,"waypoints%[7%]") then
				log("Wp07 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp07 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp07_column02:setText(capture)
					log("Wp07 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp07 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp07_column03:setText(capture)
					log("Wp07 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp07 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp07_column04:setText(capture)
					log("Wp07 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp07 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp07_column05:setText(capture)
					log("Wp07 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp07 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp07_column05:setText(capture)
					log("Wp07 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp07 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp07_column06:setText(capture)
					log("Wp07 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp07 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp07_column07:setText(capture)
					log("Wp07 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp07 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp07_column08:setText(capture)
					log("Wp07 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp07 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp07_column09:setText(capture)
					log("Wp07 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp07 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp07_column10:setText(capture)
					log("Wp07 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp07 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp07_column11:setText(capture)
					log("Wp07 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp07 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp07_column12:setText(capture)
					log("Wp07 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp07 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp07_column13:setText(capture)
					log("Wp07 deast is: " .. capture)
				end
			elseif string.match(line,"waypoints%[8%]") then
				log("Wp08 detected")
				if string.match(line,"name%s*=%s*") then
					log("Wp08 name detected")
					local capture =  string.match(line,"name%s*=%s*([^,]+)")
					editBox_wp08_column02:setText(capture)
					log("Wp08 Name is: " .. capture)
				end
				
				if string.match(line,"lat%s*=%s*") then
					log("Wp08 lat detected")
					local capture =  string.match(line,"lat%s*=%s*([^,]+)")
					editBox_wp08_column03:setText(capture)
					log("Wp08 lat is: " .. capture)
				end
				
				if string.match(line,"lon%s*=%s*") then
					log("Wp08 long detected")
					local capture =  string.match(line,"lon%s*=%s*([^,]+)")
					editBox_wp08_column04:setText(capture)
					log("Wp08 long is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp08 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp08_column05:setText(capture)
					log("Wp08 alt is: " .. capture)
				end
				
				if string.match(line,"alt%s*=%s*") then
					log("Wp08 alt detected")
					local capture =  string.match(line,"alt%s*=%s*([^,]+)")
					editBox_wp08_column05:setText(capture)
					log("Wp08 alt is: " .. capture)
				end
				
				if string.match(line,"cp%s*=%s*") then
					log("Wp08 cp detected")
					local capture =  string.match(line,"cp%s*=%s*([^,]+)")
					editBox_wp08_column06:setText(capture)
					log("Wp08 cp is: " .. capture)
				end
				
				if string.match(line,"pd%s*=%s*") then
					log("Wp08 pd detected")
					local capture =  string.match(line,"pd%s*=%s*([^,]+)")
					editBox_wp08_column07:setText(capture)
					log("Wp08 pd is: " .. capture)
				end
				
				if string.match(line,"rd%s*=%s*") then
					log("Wp08 rd detected")
					local capture =  string.match(line,"rd%s*=%s*([^,]+)")
					editBox_wp08_column08:setText(capture)
					log("Wp08 rd is: " .. capture)
				end
				
				if string.match(line,"rho%s*=%s*") then
					log("Wp08 rho detected")
					local capture =  string.match(line,"rho%s*=%s*([^,]+)")
					editBox_wp08_column09:setText(capture)
					log("Wp08 rho is: " .. capture)
				end
				
				if string.match(line,"theta%s*=%s*") then
					log("Wp08 theta detected")
					local capture =  string.match(line,"theta%s*=%s*([^,]+)")
					editBox_wp08_column10:setText(capture)
					log("Wp08 theta is: " .. capture)
				end
				
				if string.match(line,"dalt%s*=%s*") then
					log("Wp08 dalt detected")
					local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
					editBox_wp08_column11:setText(capture)
					log("Wp08 dalt is: " .. capture)
				end
				
				if string.match(line,"dnorth%s*=%s*") then
					log("Wp08 dnorth detected")
					local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
					editBox_wp08_column12:setText(capture)
					log("Wp08 dnorth is: " .. capture)
				end
				
				if string.match(line,"deast%s*=%s*") then
					log("Wp08 deast detected")
					local capture =  string.match(line,"deast%s*=%s*([^,]+)")
					editBox_wp08_column13:setText(capture)
					log("Wp08 deast is: " .. capture)
				end	
		elseif string.match(line,"waypoints%[9%]") then
			log("Wp09 detected")
			if string.match(line,"name%s*=%s*") then
				log("Wp09 name detected")
				local capture =  string.match(line,"name%s*=%s*([^,]+)")
				editBox_wp09_column02:setText(capture)
				log("Wp09 Name is: " .. capture)
			end
			
			if string.match(line,"lat%s*=%s*") then
				log("Wp09 lat detected")
				local capture =  string.match(line,"lat%s*=%s*([^,]+)")
				editBox_wp09_column03:setText(capture)
				log("Wp09 lat is: " .. capture)
			end
			
			if string.match(line,"lon%s*=%s*") then
				log("Wp09 long detected")
				local capture =  string.match(line,"lon%s*=%s*([^,]+)")
				editBox_wp09_column04:setText(capture)
				log("Wp09 long is: " .. capture)
			end
			
			if string.match(line,"alt%s*=%s*") then
				log("Wp09 alt detected")
				local capture =  string.match(line,"alt%s*=%s*([^,]+)")
				editBox_wp09_column05:setText(capture)
				log("Wp09 alt is: " .. capture)
			end
			
			if string.match(line,"alt%s*=%s*") then
				log("Wp09 alt detected")
				local capture =  string.match(line,"alt%s*=%s*([^,]+)")
				editBox_wp09_column05:setText(capture)
				log("Wp09 alt is: " .. capture)
			end
			
			if string.match(line,"cp%s*=%s*") then
				log("Wp09 cp detected")
				local capture =  string.match(line,"cp%s*=%s*([^,]+)")
				editBox_wp09_column06:setText(capture)
				log("Wp09 cp is: " .. capture)
			end
			
			if string.match(line,"pd%s*=%s*") then
				log("Wp09 pd detected")
				local capture =  string.match(line,"pd%s*=%s*([^,]+)")
				editBox_wp09_column07:setText(capture)
				log("Wp09 pd is: " .. capture)
			end
			
			if string.match(line,"rd%s*=%s*") then
				log("Wp09 rd detected")
				local capture =  string.match(line,"rd%s*=%s*([^,]+)")
				editBox_wp09_column08:setText(capture)
				log("Wp09 rd is: " .. capture)
			end
			
			if string.match(line,"rho%s*=%s*") then
				log("Wp09 rho detected")
				local capture =  string.match(line,"rho%s*=%s*([^,]+)")
				editBox_wp09_column09:setText(capture)
				log("Wp09 rho is: " .. capture)
			end
			
			if string.match(line,"theta%s*=%s*") then
				log("Wp09 theta detected")
				local capture =  string.match(line,"theta%s*=%s*([^,]+)")
				editBox_wp09_column10:setText(capture)
				log("Wp09 theta is: " .. capture)
			end
			
			if string.match(line,"dalt%s*=%s*") then
				log("Wp09 dalt detected")
				local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
				editBox_wp09_column11:setText(capture)
				log("Wp09 dalt is: " .. capture)
			end
			
			if string.match(line,"dnorth%s*=%s*") then
				log("Wp09 dnorth detected")
				local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
				editBox_wp09_column12:setText(capture)
				log("Wp09 dnorth is: " .. capture)
			end
			
			if string.match(line,"deast%s*=%s*") then
				log("Wp09 deast detected")
				local capture =  string.match(line,"deast%s*=%s*([^,]+)")
				editBox_wp09_column13:setText(capture)
				log("Wp09 deast is: " .. capture)
			end				
		elseif string.match(line,"waypoints%[10%]") then
			log("Wp10 detected")
			if string.match(line,"name%s*=%s*") then
				log("Wp10 name detected")
				local capture =  string.match(line,"name%s*=%s*([^,]+)")
				editBox_wp10_column02:setText(capture)
				log("Wp10 Name is: " .. capture)
			end
			
			if string.match(line,"lat%s*=%s*") then
				log("Wp10 lat detected")
				local capture =  string.match(line,"lat%s*=%s*([^,]+)")
				editBox_wp10_column03:setText(capture)
				log("Wp10 lat is: " .. capture)
			end
			
			if string.match(line,"lon%s*=%s*") then
				log("Wp10 long detected")
				local capture =  string.match(line,"lon%s*=%s*([^,]+)")
				editBox_wp10_column04:setText(capture)
				log("Wp10 long is: " .. capture)
			end
			
			if string.match(line,"alt%s*=%s*") then
				log("Wp10 alt detected")
				local capture =  string.match(line,"alt%s*=%s*([^,]+)")
				editBox_wp10_column05:setText(capture)
				log("Wp10 alt is: " .. capture)
			end
			
			if string.match(line,"alt%s*=%s*") then
				log("Wp10 alt detected")
				local capture =  string.match(line,"alt%s*=%s*([^,]+)")
				editBox_wp10_column05:setText(capture)
				log("Wp10 alt is: " .. capture)
			end
			
			if string.match(line,"cp%s*=%s*") then
				log("Wp10 cp detected")
				local capture =  string.match(line,"cp%s*=%s*([^,]+)")
				editBox_wp10_column06:setText(capture)
				log("Wp10 cp is: " .. capture)
			end
			
			if string.match(line,"pd%s*=%s*") then
				log("Wp10 pd detected")
				local capture =  string.match(line,"pd%s*=%s*([^,]+)")
				editBox_wp10_column07:setText(capture)
				log("Wp10 pd is: " .. capture)
			end
			
			if string.match(line,"rd%s*=%s*") then
				log("Wp10 rd detected")
				local capture =  string.match(line,"rd%s*=%s*([^,]+)")
				editBox_wp10_column08:setText(capture)
				log("Wp10 rd is: " .. capture)
			end
			
			if string.match(line,"rho%s*=%s*") then
				log("Wp10 rho detected")
				local capture =  string.match(line,"rho%s*=%s*([^,]+)")
				editBox_wp10_column09:setText(capture)
				log("Wp10 rho is: " .. capture)
			end
			
			if string.match(line,"theta%s*=%s*") then
				log("Wp10 theta detected")
				local capture =  string.match(line,"theta%s*=%s*([^,]+)")
				editBox_wp10_column10:setText(capture)
				log("Wp10 theta is: " .. capture)
			end
			
			if string.match(line,"dalt%s*=%s*") then
				log("Wp10 dalt detected")
				local capture =  string.match(line,"dalt%s*=%s*([^,]+)")
				editBox_wp10_column11:setText(capture)
				log("Wp10 dalt is: " .. capture)
			end
			
			if string.match(line,"dnorth%s*=%s*") then
				log("Wp10 dnorth detected")
				local capture =  string.match(line,"dnorth%s*=%s*([^,]+)")
				editBox_wp10_column12:setText(capture)
				log("Wp10 dnorth is: " .. capture)
			end
			
			if string.match(line,"deast%s*=%s*") then
				log("Wp10 deast detected")
				local capture =  string.match(line,"deast%s*=%s*([^,]+)")
				editBox_wp10_column13:setText(capture)
				log("Wp10 deast is: " .. capture)
			end
			end
		end
		
		file:close() -- closes the file 
	end
	
	
	function file_exists(name)
		local f=io.open(name,"r")
		if f~=nil then io.close(f) return true else return false end
	end

	local function export()
		log("Export button pressed")
		-- run the regex depending on the box (date, name, wp name, lat, long)
		-- after those checks are done, we can select which ones to export
		-- export using the format previously written in the other program, or something similar
		
		--[[ Format checks (skip checks for v1. remind user garbage in/out
		--TODO: stop export process if the checks fail
		checkWaypointNames()
		checkLat()
		checkLong()
		checkDate()
		checkDtcName()
		checkDecimalEntryBoxes()
		--]]
		
		-- populate 'finalExportString' with the export information
		-- When deciding to export or not, check that both lat and long variables have something. if they
		-- dont, skip that waypoint export (or opt to finish exporting, otherwise waypoints will be jumped in the DTC)
		create_header_set()
		create_wp01_set()
		create_wp02_set()
		create_wp03_set()
		create_wp04_set()
		create_wp05_set()
		create_wp06_set()
		create_wp07_set()
		create_wp08_set()
		create_wp09_set()
		create_wp10_set()
		
		-- done making the string. now export it to the folder location and the log/export box
		outputBoxDtcExport(finalExportString)
		saveToFile(finalExportString)
		
		log("Exports complete")
	end
	
	function create_header_set()
		--creates the entries for terrain, aircraft, date, and dtc name
		finalExportString = '' -- init/clear the export string
		-- The likely future map names
		-- Marianas
		-- Persian Gulf
		
		finalExportString = ('terrain = "' ..  comboList_terrain:getText() .. '"\n' .. 
							'aircraft = "' ..  comboList_aircraft:getText() .. '"\n' .. 
							'date = "' ..  editBox_date:getText() .. '"\n' .. 
							'name = "' ..  editBox_dtcName:getText() .. '"\n' .. '\n' ..
							'waypoints = {}')
	end
	
	function isempty(s) -- https://stackoverflow.com/questions/19664666/check-if-a-string-isnt-nil-or-empty-in-lua
		return s == nil or s == ''
	end

	function create_wp01_set()
		-- check if lat or long is empty. if one is, dont evaluate
		if isempty(editBox_wp01_column03:getText()) then
			log("Waypoint 01 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp01_column04:getText()) then
			log("Waypoint 01 did not have a Long entry")
			return
		end
		
		_wp01_set = {}
		table.insert(_wp01_set, "name=\"" .. editBox_wp01_column02:getText() .. "\",")
		table.insert(_wp01_set, "lat=\"" .. editBox_wp01_column03:getText() .. "\",")
		table.insert(_wp01_set, "lon=\"" .. editBox_wp01_column04:getText() .. "\",")
		table.insert(_wp01_set, "alt=" .. editBox_wp01_column05:getText() .. ",")
		table.insert(_wp01_set, "cp=" .. editBox_wp01_column06:getText() .. ",")
		table.insert(_wp01_set, "pd=" .. editBox_wp01_column07:getText() .. ",")
		table.insert(_wp01_set, "rd=" .. editBox_wp01_column08:getText() .. ",")
		table.insert(_wp01_set, "rho=" .. editBox_wp01_column09:getText() .. ",")
		table.insert(_wp01_set, "theta=" .. editBox_wp01_column10:getText() .. ",")
		table.insert(_wp01_set, "dalt=" .. editBox_wp01_column11:getText() .. ",")
		table.insert(_wp01_set, "dnorth=" .. editBox_wp01_column12:getText() .. ",")
		table.insert(_wp01_set, "deast=" .. editBox_wp01_column13:getText() .. ",")
		
		if isempty(editBox_wp01_column13:getText()) then table.remove(_wp01_set, 12) end
		if isempty(editBox_wp01_column12:getText()) then table.remove(_wp01_set, 11) end
		if isempty(editBox_wp01_column11:getText()) then table.remove(_wp01_set, 10) end
		if isempty(editBox_wp01_column10:getText()) then table.remove(_wp01_set, 9) end
		if isempty(editBox_wp01_column09:getText()) then table.remove(_wp01_set, 8) end
		if isempty(editBox_wp01_column08:getText()) then table.remove(_wp01_set, 7) end
		if isempty(editBox_wp01_column07:getText()) then table.remove(_wp01_set, 6) end
		if isempty(editBox_wp01_column06:getText()) then table.remove(_wp01_set, 5) end
		if isempty(editBox_wp01_column05:getText()) then table.remove(_wp01_set, 4) end
		if isempty(editBox_wp01_column04:getText()) then table.remove(_wp01_set, 3) end
		if isempty(editBox_wp01_column03:getText()) then table.remove(_wp01_set, 2) end
		if isempty(editBox_wp01_column02:getText()) then table.remove(_wp01_set, 1) end
		
		local output = "waypoints[1] = { "
		for _i,_k in pairs(_wp01_set) do -- try to understand this more. It works though.
			output = output .. _k
		end
		
		output = output:sub(1, -2) -- removed the last comma https://stackoverflow.com/questions/24799105/how-to-delete-the-last-character-of-the-text
		output = output .. "}" -- adds the final closing bracket
		
		-- add it to the finalExportString (the export list)
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 01 to the final Export string")
	end
	
	function create_wp02_set()
		if isempty(editBox_wp02_column03:getText()) then
		log("Waypoint 02 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp02_column04:getText()) then
		log("Waypoint 02 did not have a Long entry")
			return
		end
		
		_wp02_set = {}
		table.insert(_wp02_set, "name=\"" .. editBox_wp02_column02:getText() .. "\",")
		table.insert(_wp02_set, "lat=\"" .. editBox_wp02_column03:getText() .. "\",")
		table.insert(_wp02_set, "lon=\"" .. editBox_wp02_column04:getText() .. "\",")
		table.insert(_wp02_set, "alt=" .. editBox_wp02_column05:getText() .. ",")
		table.insert(_wp02_set, "cp=" .. editBox_wp02_column06:getText() .. ",")
		table.insert(_wp02_set, "pd=" .. editBox_wp02_column07:getText() .. ",")
		table.insert(_wp02_set, "rd=" .. editBox_wp02_column08:getText() .. ",")
		table.insert(_wp02_set, "rho=" .. editBox_wp02_column09:getText() .. ",")
		table.insert(_wp02_set, "theta=" .. editBox_wp02_column10:getText() .. ",")
		table.insert(_wp02_set, "dalt=" .. editBox_wp02_column11:getText() .. ",")
		table.insert(_wp02_set, "dnorth=" .. editBox_wp02_column12:getText() .. ",")
		table.insert(_wp02_set, "deast=" .. editBox_wp02_column13:getText() .. ",")
		
		if isempty(editBox_wp02_column13:getText()) then table.remove(_wp02_set, 12) end
		if isempty(editBox_wp02_column12:getText()) then table.remove(_wp02_set, 11) end
		if isempty(editBox_wp02_column11:getText()) then table.remove(_wp02_set, 10) end
		if isempty(editBox_wp02_column10:getText()) then table.remove(_wp02_set, 9) end
		if isempty(editBox_wp02_column09:getText()) then table.remove(_wp02_set, 8) end
		if isempty(editBox_wp02_column08:getText()) then table.remove(_wp02_set, 7) end
		if isempty(editBox_wp02_column07:getText()) then table.remove(_wp02_set, 6) end
		if isempty(editBox_wp02_column06:getText()) then table.remove(_wp02_set, 5) end
		if isempty(editBox_wp02_column05:getText()) then table.remove(_wp02_set, 4) end
		if isempty(editBox_wp02_column04:getText()) then table.remove(_wp02_set, 3) end
		if isempty(editBox_wp02_column03:getText()) then table.remove(_wp02_set, 2) end
		if isempty(editBox_wp02_column02:getText()) then table.remove(_wp02_set, 1) end
		
		local output = "waypoints[2] = { "
		for _i,_k in pairs(_wp02_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 02 to the final Export string")
	end
	
	function create_wp03_set()
		if isempty(editBox_wp03_column03:getText()) then
			log("Waypoint 03 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp03_column04:getText()) then
			log("Waypoint 03 did not have a Long entry")
			return
		end
		
		_wp03_set = {}
		table.insert(_wp03_set, "name=\"" .. editBox_wp03_column02:getText() .. "\",")
		table.insert(_wp03_set, "lat=\"" .. editBox_wp03_column03:getText() .. "\",")
		table.insert(_wp03_set, "lon=\"" .. editBox_wp03_column04:getText() .. "\",")
		table.insert(_wp03_set, "alt=" .. editBox_wp03_column05:getText() .. ",")
		table.insert(_wp03_set, "cp=" .. editBox_wp03_column06:getText() .. ",")
		table.insert(_wp03_set, "pd=" .. editBox_wp03_column07:getText() .. ",")
		table.insert(_wp03_set, "rd=" .. editBox_wp03_column08:getText() .. ",")
		table.insert(_wp03_set, "rho=" .. editBox_wp03_column09:getText() .. ",")
		table.insert(_wp03_set, "theta=" .. editBox_wp03_column10:getText() .. ",")
		table.insert(_wp03_set, "dalt=" .. editBox_wp03_column11:getText() .. ",")
		table.insert(_wp03_set, "dnorth=" .. editBox_wp03_column12:getText() .. ",")
		table.insert(_wp03_set, "deast=" .. editBox_wp03_column13:getText() .. ",")
		
		if isempty(editBox_wp03_column13:getText()) then table.remove(_wp03_set, 12) end
		if isempty(editBox_wp03_column12:getText()) then table.remove(_wp03_set, 11) end
		if isempty(editBox_wp03_column11:getText()) then table.remove(_wp03_set, 10) end
		if isempty(editBox_wp03_column10:getText()) then table.remove(_wp03_set, 9) end
		if isempty(editBox_wp03_column09:getText()) then table.remove(_wp03_set, 8) end
		if isempty(editBox_wp03_column08:getText()) then table.remove(_wp03_set, 7) end
		if isempty(editBox_wp03_column07:getText()) then table.remove(_wp03_set, 6) end
		if isempty(editBox_wp03_column06:getText()) then table.remove(_wp03_set, 5) end
		if isempty(editBox_wp03_column05:getText()) then table.remove(_wp03_set, 4) end
		if isempty(editBox_wp03_column04:getText()) then table.remove(_wp03_set, 3) end
		if isempty(editBox_wp03_column03:getText()) then table.remove(_wp03_set, 2) end
		if isempty(editBox_wp03_column02:getText()) then table.remove(_wp03_set, 1) end
		
		local output = "waypoints[3] = { "
		for _i,_k in pairs(_wp03_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 03 to the final Export string")
	end
	
	function create_wp04_set()
		if isempty(editBox_wp04_column03:getText()) then
		log("Waypoint 01 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp04_column04:getText()) then
		log("Waypoint 01 did not have a Long entry")
			return
		end
		
		_wp04_set = {}
		table.insert(_wp04_set, "name=\"" .. editBox_wp04_column02:getText() .. "\",")
		table.insert(_wp04_set, "lat=\"" .. editBox_wp04_column03:getText() .. "\",")
		table.insert(_wp04_set, "lon=\"" .. editBox_wp04_column04:getText() .. "\",")
		table.insert(_wp04_set, "alt=" .. editBox_wp04_column05:getText() .. ",")
		table.insert(_wp04_set, "cp=" .. editBox_wp04_column06:getText() .. ",")
		table.insert(_wp04_set, "pd=" .. editBox_wp04_column07:getText() .. ",")
		table.insert(_wp04_set, "rd=" .. editBox_wp04_column08:getText() .. ",")
		table.insert(_wp04_set, "rho=" .. editBox_wp04_column09:getText() .. ",")
		table.insert(_wp04_set, "theta=" .. editBox_wp04_column10:getText() .. ",")
		table.insert(_wp04_set, "dalt=" .. editBox_wp04_column11:getText() .. ",")
		table.insert(_wp04_set, "dnorth=" .. editBox_wp04_column12:getText() .. ",")
		table.insert(_wp04_set, "deast=" .. editBox_wp04_column13:getText() .. ",")
		
		if isempty(editBox_wp04_column13:getText()) then table.remove(_wp04_set, 12) end
		if isempty(editBox_wp04_column12:getText()) then table.remove(_wp04_set, 11) end
		if isempty(editBox_wp04_column11:getText()) then table.remove(_wp04_set, 10) end
		if isempty(editBox_wp04_column10:getText()) then table.remove(_wp04_set, 9) end
		if isempty(editBox_wp04_column09:getText()) then table.remove(_wp04_set, 8) end
		if isempty(editBox_wp04_column08:getText()) then table.remove(_wp04_set, 7) end
		if isempty(editBox_wp04_column07:getText()) then table.remove(_wp04_set, 6) end
		if isempty(editBox_wp04_column06:getText()) then table.remove(_wp04_set, 5) end
		if isempty(editBox_wp04_column05:getText()) then table.remove(_wp04_set, 4) end
		if isempty(editBox_wp04_column04:getText()) then table.remove(_wp04_set, 3) end
		if isempty(editBox_wp04_column03:getText()) then table.remove(_wp04_set, 2) end
		if isempty(editBox_wp04_column02:getText()) then table.remove(_wp04_set, 1) end
		
		local output = "waypoints[4] = { "
		for _i,_k in pairs(_wp04_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 04 to the final Export string")
	end
	
	function create_wp05_set()
		if isempty(editBox_wp05_column03:getText()) then
		log("Waypoint 01 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp05_column04:getText()) then
		log("Waypoint 01 did not have a Long entry")
			return
		end
		
		_wp05_set = {}
		table.insert(_wp05_set, "name=\"" .. editBox_wp05_column02:getText() .. "\",")
		table.insert(_wp05_set, "lat=\"" .. editBox_wp05_column03:getText() .. "\",")
		table.insert(_wp05_set, "lon=\"" .. editBox_wp05_column04:getText() .. "\",")
		table.insert(_wp05_set, "alt=" .. editBox_wp05_column05:getText() .. ",")
		table.insert(_wp05_set, "cp=" .. editBox_wp05_column06:getText() .. ",")
		table.insert(_wp05_set, "pd=" .. editBox_wp05_column07:getText() .. ",")
		table.insert(_wp05_set, "rd=" .. editBox_wp05_column08:getText() .. ",")
		table.insert(_wp05_set, "rho=" .. editBox_wp05_column09:getText() .. ",")
		table.insert(_wp05_set, "theta=" .. editBox_wp05_column10:getText() .. ",")
		table.insert(_wp05_set, "dalt=" .. editBox_wp05_column11:getText() .. ",")
		table.insert(_wp05_set, "dnorth=" .. editBox_wp05_column12:getText() .. ",")
		table.insert(_wp05_set, "deast=" .. editBox_wp05_column13:getText() .. ",")
		
		if isempty(editBox_wp05_column13:getText()) then table.remove(_wp05_set, 12) end
		if isempty(editBox_wp05_column12:getText()) then table.remove(_wp05_set, 11) end
		if isempty(editBox_wp05_column11:getText()) then table.remove(_wp05_set, 10) end
		if isempty(editBox_wp05_column10:getText()) then table.remove(_wp05_set, 9) end
		if isempty(editBox_wp05_column09:getText()) then table.remove(_wp05_set, 8) end
		if isempty(editBox_wp05_column08:getText()) then table.remove(_wp05_set, 7) end
		if isempty(editBox_wp05_column07:getText()) then table.remove(_wp05_set, 6) end
		if isempty(editBox_wp05_column06:getText()) then table.remove(_wp05_set, 5) end
		if isempty(editBox_wp05_column05:getText()) then table.remove(_wp05_set, 4) end
		if isempty(editBox_wp05_column04:getText()) then table.remove(_wp05_set, 3) end
		if isempty(editBox_wp05_column03:getText()) then table.remove(_wp05_set, 2) end
		if isempty(editBox_wp05_column02:getText()) then table.remove(_wp05_set, 1) end
		
		local output = "waypoints[5] = { "
		for _i,_k in pairs(_wp05_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 05 to the final Export string")
	end
	
	function create_wp06_set()
		if isempty(editBox_wp06_column03:getText()) then
		log("Waypoint 06 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp06_column04:getText()) then
		log("Waypoint 06 did not have a Long entry")
			return
		end
		
		_wp06_set = {}
		table.insert(_wp06_set, "name=\"" .. editBox_wp06_column02:getText() .. "\",")
		table.insert(_wp06_set, "lat=\"" .. editBox_wp06_column03:getText() .. "\",")
		table.insert(_wp06_set, "lon=\"" .. editBox_wp06_column04:getText() .. "\",")
		table.insert(_wp06_set, "alt=" .. editBox_wp06_column05:getText() .. ",")
		table.insert(_wp06_set, "cp=" .. editBox_wp06_column06:getText() .. ",")
		table.insert(_wp06_set, "pd=" .. editBox_wp06_column07:getText() .. ",")
		table.insert(_wp06_set, "rd=" .. editBox_wp06_column08:getText() .. ",")
		table.insert(_wp06_set, "rho=" .. editBox_wp06_column09:getText() .. ",")
		table.insert(_wp06_set, "theta=" .. editBox_wp06_column10:getText() .. ",")
		table.insert(_wp06_set, "dalt=" .. editBox_wp06_column11:getText() .. ",")
		table.insert(_wp06_set, "dnorth=" .. editBox_wp06_column12:getText() .. ",")
		table.insert(_wp06_set, "deast=" .. editBox_wp06_column13:getText() .. ",")
		
		if isempty(editBox_wp06_column13:getText()) then table.remove(_wp06_set, 12) end
		if isempty(editBox_wp06_column12:getText()) then table.remove(_wp06_set, 11) end
		if isempty(editBox_wp06_column11:getText()) then table.remove(_wp06_set, 10) end
		if isempty(editBox_wp06_column10:getText()) then table.remove(_wp06_set, 9) end
		if isempty(editBox_wp06_column09:getText()) then table.remove(_wp06_set, 8) end
		if isempty(editBox_wp06_column08:getText()) then table.remove(_wp06_set, 7) end
		if isempty(editBox_wp06_column07:getText()) then table.remove(_wp06_set, 6) end
		if isempty(editBox_wp06_column06:getText()) then table.remove(_wp06_set, 5) end
		if isempty(editBox_wp06_column05:getText()) then table.remove(_wp06_set, 4) end
		if isempty(editBox_wp06_column04:getText()) then table.remove(_wp06_set, 3) end
		if isempty(editBox_wp06_column03:getText()) then table.remove(_wp06_set, 2) end
		if isempty(editBox_wp06_column02:getText()) then table.remove(_wp06_set, 1) end
		
		local output = "waypoints[6] = { "
		for _i,_k in pairs(_wp06_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 06 to the final Export string")
	end
	
	function create_wp07_set()
		if isempty(editBox_wp07_column03:getText()) then
			log("Waypoint 07 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp07_column04:getText()) then
			log("Waypoint 07 did not have a Long entry")
			return
		end
		
		_wp07_set = {}
		table.insert(_wp07_set, "name=\"" .. editBox_wp07_column02:getText() .. "\",")
		table.insert(_wp07_set, "lat=\"" .. editBox_wp07_column03:getText() .. "\",")
		table.insert(_wp07_set, "lon=\"" .. editBox_wp07_column04:getText() .. "\",")
		table.insert(_wp07_set, "alt=" .. editBox_wp07_column05:getText() .. ",")
		table.insert(_wp07_set, "cp=" .. editBox_wp07_column06:getText() .. ",")
		table.insert(_wp07_set, "pd=" .. editBox_wp07_column07:getText() .. ",")
		table.insert(_wp07_set, "rd=" .. editBox_wp07_column08:getText() .. ",")
		table.insert(_wp07_set, "rho=" .. editBox_wp07_column09:getText() .. ",")
		table.insert(_wp07_set, "theta=" .. editBox_wp07_column10:getText() .. ",")
		table.insert(_wp07_set, "dalt=" .. editBox_wp07_column11:getText() .. ",")
		table.insert(_wp07_set, "dnorth=" .. editBox_wp07_column12:getText() .. ",")
		table.insert(_wp07_set, "deast=" .. editBox_wp07_column13:getText() .. ",")
		
		if isempty(editBox_wp07_column13:getText()) then table.remove(_wp07_set, 12) end
		if isempty(editBox_wp07_column12:getText()) then table.remove(_wp07_set, 11) end
		if isempty(editBox_wp07_column11:getText()) then table.remove(_wp07_set, 10) end
		if isempty(editBox_wp07_column10:getText()) then table.remove(_wp07_set, 9) end
		if isempty(editBox_wp07_column09:getText()) then table.remove(_wp07_set, 8) end
		if isempty(editBox_wp07_column08:getText()) then table.remove(_wp07_set, 7) end
		if isempty(editBox_wp07_column07:getText()) then table.remove(_wp07_set, 6) end
		if isempty(editBox_wp07_column06:getText()) then table.remove(_wp07_set, 5) end
		if isempty(editBox_wp07_column05:getText()) then table.remove(_wp07_set, 4) end
		if isempty(editBox_wp07_column04:getText()) then table.remove(_wp07_set, 3) end
		if isempty(editBox_wp07_column03:getText()) then table.remove(_wp07_set, 2) end
		if isempty(editBox_wp07_column02:getText()) then table.remove(_wp07_set, 1) end
		
		local output = "waypoints[7] = { "
		for _i,_k in pairs(_wp07_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 07 to the final Export string")
	end
	
	function create_wp08_set()
		if isempty(editBox_wp08_column03:getText()) then
			log("Waypoint 08 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp08_column04:getText()) then
			log("Waypoint 08 did not have a Long entry")
			return
		end
		
		_wp08_set = {}
		table.insert(_wp08_set, "name=\"" .. editBox_wp08_column02:getText() .. "\",")
		table.insert(_wp08_set, "lat=\"" .. editBox_wp08_column03:getText() .. "\",")
		table.insert(_wp08_set, "lon=\"" .. editBox_wp08_column04:getText() .. "\",")
		table.insert(_wp08_set, "alt=" .. editBox_wp08_column05:getText() .. ",")
		table.insert(_wp08_set, "cp=" .. editBox_wp08_column06:getText() .. ",")
		table.insert(_wp08_set, "pd=" .. editBox_wp08_column07:getText() .. ",")
		table.insert(_wp08_set, "rd=" .. editBox_wp08_column08:getText() .. ",")
		table.insert(_wp08_set, "rho=" .. editBox_wp08_column09:getText() .. ",")
		table.insert(_wp08_set, "theta=" .. editBox_wp08_column10:getText() .. ",")
		table.insert(_wp08_set, "dalt=" .. editBox_wp08_column11:getText() .. ",")
		table.insert(_wp08_set, "dnorth=" .. editBox_wp08_column12:getText() .. ",")
		table.insert(_wp08_set, "deast=" .. editBox_wp08_column13:getText() .. ",")
		
		if isempty(editBox_wp08_column13:getText()) then table.remove(_wp08_set, 12) end
		if isempty(editBox_wp08_column12:getText()) then table.remove(_wp08_set, 11) end
		if isempty(editBox_wp08_column11:getText()) then table.remove(_wp08_set, 10) end
		if isempty(editBox_wp08_column10:getText()) then table.remove(_wp08_set, 9) end
		if isempty(editBox_wp08_column09:getText()) then table.remove(_wp08_set, 8) end
		if isempty(editBox_wp08_column08:getText()) then table.remove(_wp08_set, 7) end
		if isempty(editBox_wp08_column07:getText()) then table.remove(_wp08_set, 6) end
		if isempty(editBox_wp08_column06:getText()) then table.remove(_wp08_set, 5) end
		if isempty(editBox_wp08_column05:getText()) then table.remove(_wp08_set, 4) end
		if isempty(editBox_wp08_column04:getText()) then table.remove(_wp08_set, 3) end
		if isempty(editBox_wp08_column03:getText()) then table.remove(_wp08_set, 2) end
		if isempty(editBox_wp08_column02:getText()) then table.remove(_wp08_set, 1) end
		
		local output = "waypoints[8] = { "
		for _i,_k in pairs(_wp08_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 08 to the final Export string")
	end
	
	function create_wp09_set()
		if isempty(editBox_wp09_column03:getText()) then
			log("Waypoint 09 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp09_column04:getText()) then
			log("Waypoint 09 did not have a Long entry")
			return
		end
		
		_wp09_set = {}
		table.insert(_wp09_set, "name=\"" .. editBox_wp09_column02:getText() .. "\",")
		table.insert(_wp09_set, "lat=\"" .. editBox_wp09_column03:getText() .. "\",")
		table.insert(_wp09_set, "lon=\"" .. editBox_wp09_column04:getText() .. "\",")
		table.insert(_wp09_set, "alt=" .. editBox_wp09_column05:getText() .. ",")
		table.insert(_wp09_set, "cp=" .. editBox_wp09_column06:getText() .. ",")
		table.insert(_wp09_set, "pd=" .. editBox_wp09_column07:getText() .. ",")
		table.insert(_wp09_set, "rd=" .. editBox_wp09_column08:getText() .. ",")
		table.insert(_wp09_set, "rho=" .. editBox_wp09_column09:getText() .. ",")
		table.insert(_wp09_set, "theta=" .. editBox_wp09_column10:getText() .. ",")
		table.insert(_wp09_set, "dalt=" .. editBox_wp09_column11:getText() .. ",")
		table.insert(_wp09_set, "dnorth=" .. editBox_wp09_column12:getText() .. ",")
		table.insert(_wp09_set, "deast=" .. editBox_wp09_column13:getText() .. ",")
		
		if isempty(editBox_wp09_column13:getText()) then table.remove(_wp09_set, 12) end
		if isempty(editBox_wp09_column12:getText()) then table.remove(_wp09_set, 11) end
		if isempty(editBox_wp09_column11:getText()) then table.remove(_wp09_set, 10) end
		if isempty(editBox_wp09_column10:getText()) then table.remove(_wp09_set, 9) end
		if isempty(editBox_wp09_column09:getText()) then table.remove(_wp09_set, 8) end
		if isempty(editBox_wp09_column08:getText()) then table.remove(_wp09_set, 7) end
		if isempty(editBox_wp09_column07:getText()) then table.remove(_wp09_set, 6) end
		if isempty(editBox_wp09_column06:getText()) then table.remove(_wp09_set, 5) end
		if isempty(editBox_wp09_column05:getText()) then table.remove(_wp09_set, 4) end
		if isempty(editBox_wp09_column04:getText()) then table.remove(_wp09_set, 3) end
		if isempty(editBox_wp09_column03:getText()) then table.remove(_wp09_set, 2) end
		if isempty(editBox_wp09_column02:getText()) then table.remove(_wp09_set, 1) end
		
		local output = "waypoints[9] = { "
		for _i,_k in pairs(_wp09_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 09 to the final Export string")
	end
	
	function create_wp10_set()
		if isempty(editBox_wp10_column03:getText()) then
			log("Waypoint 10 did not have a Lat entry")
			return
		end
		
		if isempty(editBox_wp10_column04:getText()) then
			log("Waypoint 10 did not have a Long entry")
			return
		end
		
		_wp10_set = {}
		table.insert(_wp10_set, "name=\"" .. editBox_wp10_column02:getText() .. "\",")
		table.insert(_wp10_set, "lat=\"" .. editBox_wp10_column03:getText() .. "\",")
		table.insert(_wp10_set, "lon=\"" .. editBox_wp10_column04:getText() .. "\",")
		table.insert(_wp10_set, "alt=" .. editBox_wp10_column05:getText() .. ",")
		table.insert(_wp10_set, "cp=" .. editBox_wp10_column06:getText() .. ",")
		table.insert(_wp10_set, "pd=" .. editBox_wp10_column07:getText() .. ",")
		table.insert(_wp10_set, "rd=" .. editBox_wp10_column08:getText() .. ",")
		table.insert(_wp10_set, "rho=" .. editBox_wp10_column09:getText() .. ",")
		table.insert(_wp10_set, "theta=" .. editBox_wp10_column10:getText() .. ",")
		table.insert(_wp10_set, "dalt=" .. editBox_wp10_column11:getText() .. ",")
		table.insert(_wp10_set, "dnorth=" .. editBox_wp10_column12:getText() .. ",")
		table.insert(_wp10_set, "deast=" .. editBox_wp10_column13:getText() .. ",")
		
		if isempty(editBox_wp10_column13:getText()) then table.remove(_wp10_set, 12) end
		if isempty(editBox_wp10_column12:getText()) then table.remove(_wp10_set, 11) end
		if isempty(editBox_wp10_column11:getText()) then table.remove(_wp10_set, 10) end
		if isempty(editBox_wp10_column10:getText()) then table.remove(_wp10_set, 9) end
		if isempty(editBox_wp10_column09:getText()) then table.remove(_wp10_set, 8) end
		if isempty(editBox_wp10_column08:getText()) then table.remove(_wp10_set, 7) end
		if isempty(editBox_wp10_column07:getText()) then table.remove(_wp10_set, 6) end
		if isempty(editBox_wp10_column06:getText()) then table.remove(_wp10_set, 5) end
		if isempty(editBox_wp10_column05:getText()) then table.remove(_wp10_set, 4) end
		if isempty(editBox_wp10_column04:getText()) then table.remove(_wp10_set, 3) end
		if isempty(editBox_wp10_column03:getText()) then table.remove(_wp10_set, 2) end
		if isempty(editBox_wp10_column02:getText()) then table.remove(_wp10_set, 1) end
		
		local output = "waypoints[10] = { "
		for _i,_k in pairs(_wp10_set) do
			output = output .. _k
		end
		
		output = output:sub(1, -2)
		output = output .. "}"
		
		finalExportString = finalExportString .. "\n" .. output
		log("Added Waypoint 10 to the final Export string")
	end


	--[[ These are the export checks that we are doing at a later time
	function checkWaypointNames()

	table.insert(_waypointNameEditBoxes, editBox_wp01_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp02_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp03_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp04_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp05_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp06_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp07_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp08_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp09_column02:getText())
	table.insert(_waypointNameEditBoxes, editBox_wp10_column02:getText())
	
	for _i,_k in pairs(_waypointNameEditBoxes) do -- try to understand this more. It works though.
		--local output = _k:getText()
		local output = _k
		if (output:match("[^%w%s]")) then 
			net.log("[Scratchpad] Illegal characters in Waypoint Name detected. Export cancled: " .. output) 
			outputBoxError("Illegal characters in Waypoint Name detected, Export cancled: " .. output)
			do return end
		else -- the test is good
			-- net.log("[Scratchpad] Condition 2 Match: " .. output) 
		end
    end
	net.log("[Scratchpad] Waypoint Names Evaluation is complete") 
end

function checkLat()

	_column03EditBoxes = {} -- init the table
    table.insert(_column03EditBoxes, editBox_wp01_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp02_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp03_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp04_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp05_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp06_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp07_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp08_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp09_column03:getText())
	table.insert(_column03EditBoxes, editBox_wp10_column03:getText())
	
	for _i,_k in pairs(_column03EditBoxes) do -- try to understand this more. It works though.
		--local output = _k:getText()
		local output = _k
		if (output:match("[^%dNS:.]")) then --very lazy regex. will NOT catch everything. it is case sensitive, sry
			net.log("[Scratchpad] Illegal characters in Lat detected. Export cancled: " .. output) 
			outputBoxError("Illegal characters in Lat detected, Export cancled: " .. output)
			do return end
		else -- the test is good
			-- net.log("[Scratchpad] Condition 2 Match: " .. output) 
		end
    end
	net.log("[Scratchpad] Waypoint Lat Evaluation is complete") 
end

function checkLong()

	_column04EditBoxes = {} -- init the table
    table.insert(_column04EditBoxes, editBox_wp01_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp02_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp03_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp04_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp05_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp06_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp07_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp08_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp09_column04:getText())
	table.insert(_column04EditBoxes, editBox_wp10_column04:getText())
	
	for _i,_k in pairs(_column04EditBoxes) do -- try to understand this more. It works though.
		--local output = _k:getText()
		local output = _k
		if (output:match("[^%dEW:.]")) then --very lazy regex. will NOT catch everything. it is case sensitive, sry
			net.log("[Scratchpad] Illegal characters in Long detected. Export cancled: " .. output) 
			outputBoxError("Illegal characters in Long detected, Export cancled: " .. output)
			do return end
		else -- the test is good
			-- net.log("[Scratchpad] Condition 2 Match: " .. output) 
		end
    end
	net.log("[Scratchpad] Waypoint Long Evaluation is complete") 
end

function checkDate()
	-- usefull for date check function getLineTextLength(self, lineIndex)
	local dateText = editBox_date:getText()
	local lengthOfDateString = #dateText
	if lengthOfDateString == 10 then
		if (dateText:match("[0123]%d\/[01]%d\/[12][019]%d%d")) then 
			-- if the date is within a valid range
			net.log("[Scratchpad] Date check pass: " .. dateText) 
		else
			-- date is not within a valid range
			outputBoxError("Date check fail for format: " .. dateText)
			net.log("[Scratchpad] Date check fail for range: " .. dateText)
			return
		end
	else
		-- date string is not the correct number of characters
		outputBoxError("Date is formated incorrectly: " .. dateText .. " Length: " .. lengthOfDateString)
		net.log("[Scratchpad] Date check fail for format: " .. dateText .. " Length: " .. lengthOfDateString)
		return
	end
end

function checkDtcName()
	local dtcNameText = editBox_dtcName:getText()
	local lengthOfNameString = #dtcNameText
	
	if lengthOfNameString  < 2 or lengthOfNameString > 28 then
		if lengthOfNameString < 2 then
			-- dtc name string is not the correct number of characters
			outputBoxError("DTC Name is too short: " .. dtcNameText)
			net.log("[Scratchpad] Dtc Name check fail for length: " .. dtcNameText)
			return
		else --lengthOfNameString > 28 then
			-- dtc name string is not the correct number of characters
			outputBoxError("DTC Name is too long: " .. dtcNameText)
			net.log("[Scratchpad] Dtc Name check fail for length: " .. dtcNameText)
			return
		end
	end
	
	if (dtcNameText:match("[^%w%s]")) then -- this allows the user to put in something like multiple spaces as the name... TODO: fix that
		-- dtc name is not valid 
		outputBoxError("DTC Name contains illegal characters: " .. dtcNameText)
		net.log("[Scratchpad] Date check fail for characters: " .. dtcNameText)
		return
	else
		-- if the dtc name is valid
		net.log("[Scratchpad] DTC Name check pass: " .. dtcNameText) 
	end
	
	if dtcNameText:find('  ') then -- if multiple spaces are detected
		outputBoxError("DTC Name contains too many spaces in a row: " .. dtcNameText)
		net.log("[Scratchpad] Date check fail for multiple spaces in a row: " .. dtcNameText)
		return
	end
end

function checkDecimalEntryBoxes()
 
	_decimalEditBoxes = {} -- init the table
	table.insert(_decimalEditBoxes, editBox_wp01_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column05:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column05:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column06:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column06:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column07:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column07:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column08:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column08:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column09:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column09:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column10:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column10:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column11:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column11:getText())
		
	table.insert(_decimalEditBoxes, editBox_wp01_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column12:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column12:getText())
		
		
	table.insert(_decimalEditBoxes, editBox_wp01_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp02_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp03_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp04_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp05_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp06_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp07_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp08_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp09_column13:getText())
	table.insert(_decimalEditBoxes, editBox_wp10_column13:getText())

	for _i,_k in pairs(_decimalEditBoxes) do -- try to understand this more. It works though.
		local output = _k
		if (output:match("[^%d.]")) then --very lazy regex. will NOT catch everything
			net.log("[Scratchpad] Illegal characters as a decimal number detected, Export cancled: " .. output) 
			outputBoxError("Illegal characters as a decimal number detected, Export cancled: " .. output)
			do return end
		else -- the test is good
			-- net.log("[Scratchpad] Condition 2 Match: " .. output) 
		end
    end
	net.log("[Scratchpad] Decimal check complete") 
end
	--]]
	
	function saveToFile(text)
		--make the Datacartridges folder if there isnt one
		lfs.mkdir(lfs.writedir() .. [[Datacartridges\]])
		
		-- saves the result of the export to the correct dtc file in /Saved Games/DCS/Datacartridges/nameOfDtc.dtc
		local a_path = lfs.writedir() .. 'Datacartridges/' .. editBox_dtcName:getText() .. '.dtc'
		
		local file,err = io.open(a_path,'w')
		if file then
			file:write(tostring(text))
			file:close()
			log("Export saved to Datacartridges folder")
		else
			log("Export write error: " .. err)
		end
		file:close()
	end
	
	function outputBoxDtcExport(text)
		editBox_output:setText("") -- clears the edit box
		
		editBox_output:setText('-- "' .. editBox_dtcName:getText() .. '" has been exported via  ' .. windowTitle .. ' on ' .. os.date() .. '\n' .. text)
		log("Export to Output box complete")
	end

	
    local function handleResize(self)
        local w, h = self:getSize()

        panel:setBounds(0, 0, w, h - 20)
        --textarea:setBounds(0, 0, w, h - 20 - 20)
        --prevButton:setBounds(0, h - 40, 50, 20)
        --nextButton:setBounds(55, h - 40, 50, 20)
        --crosshairCheckbox:setBounds(120, h - 39, 20, 20)

		--[[ Removed because we don'e have pages
        if pagesCount > 1 then
            insertCoordsBtn:setBounds(145, h - 40, 50, 20)
        else
            insertCoordsBtn:setBounds(0, h - 40, 50, 20)
        end
		--]]
        config.windowSize = {w = w, h = h}
        saveConfiguration()
    end

    local function handleMove(self)
        local x, y = self:getPosition()
        config.windowPosition = {x = x, y = y}
        saveConfiguration()
    end

    local function updateCoordsMode()
        -- insert coords only works if the client is the server, so hide the button otherwise
        crosshairCheckbox:setVisible(inMission and Export.LoIsOwnshipExportAllowed())
		label_crosshairCheckbox:setVisible(inMission and Export.LoIsOwnshipExportAllowed())
        crosshairWindow:setVisible(inMission and crosshairCheckbox:getState())
        --insertCoordsBtn:setVisible(inMission and crosshairCheckbox:getState())
		insertCoordsBtn:setVisible(inMission)
    end

    local function show()
        if window == nil then
            local status, err = pcall(createDMPSWindow)
            if not status then
                net.log("[DMPS] Error creating window: " .. tostring(err))
            end
        end

        window:setVisible(true)
        window:setSkin(windowDefaultSkin)
        panel:setVisible(true)
        window:setHasCursor(true)

        --[[ show prev/next buttons only if we have more than one page
        if pagesCount > 1 then
            prevButton:setVisible(true)
            nextButton:setVisible(true)
        else
            prevButton:setVisible(false)
            nextButton:setVisible(false)
        end
		--]]
        updateCoordsMode()

        isHidden = false
    end

    local function hide()
        window:setSkin(windowSkinHidden)
        panel:setVisible(false)
        --textarea:setFocused(false)
        window:setHasCursor(false)
        -- window.setVisible(false) -- if you make the window invisible, its destroyed
        unlockKeyboardInput(true)

        crosshairWindow:setVisible(false)

        isHidden = true
    end

    local function createCrosshairWindow()
        if crosshairWindow ~= nil then
            return
        end

        crosshairWindow = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\DCS-DMPS\\CrosshairWindow.dlg",
            cdata
        )

        local screenWidth, screenHeigt = dxgui.GetScreenSize()
        local x = screenWidth/2 - 4
        local y = screenHeigt/2 - 4
        crosshairWindow:setBounds(math.floor(x), math.floor(y), 8, 8)
		
		
        log("Crosshair window created")
    end

    local function createDMPSWindow()
		
        if window ~= nil then
            return
        end

        createCrosshairWindow()

        window = DialogLoader.spawnDialogFromFile(
            lfs.writedir() .. "Scripts\\DCS-DMPS\\DMPSWindow.dlg",
            cdata
        )

        windowDefaultSkin = window:getSkin()
        panel = window.Box
        --textarea = panel.DMPSEditBox
		-- buttons
        crosshairCheckbox = panel.DMPSCrosshairCheckBox
		checkbox_clearAllData = panel.checkbox_clearAllData
        insertCoordsBtn = panel.button_getDcsCoords
		button_clearAllData = panel.button_clearAllData
		button_export = panel.button_export
		button_import = panel.button_import
		
        --prevButton = panel.DMPSPrevButton
        --nextButton = panel.DMPSNextButton
		
		-- DMPS lable panels
		label_telemetry_elevation = panel.label_telemetry_elevation
		label_telemetry_coordinatesLat = panel.label_telemetry_coordinatesLat
		label_telemetry_coordinatesLong = panel.label_telemetry_coordinatesLong
		label_telemetry_aircraft = panel.label_telemetry_aircraft
		label_crosshairCheckbox = panel.label_crosshairCheckbox
		
		
		label_area2_column02_title = panel.label_area2_column02_title
		label_area2_column03_title = panel.label_area2_column03_title
		label_area2_column04_title = panel.label_area2_column04_title
		label_area2_column05_title = panel.label_area2_column05_title
		label_area2_column06_title = panel.label_area2_column06_title
		label_area2_column07_title = panel.label_area2_column07_title
		label_area2_column08_title = panel.label_area2_column08_title
		label_area2_column09_title = panel.label_area2_column09_title
		label_area2_column10_title = panel.label_area2_column10_title
		label_area2_column11_title = panel.label_area2_column11_title
		label_area2_column12_title = panel.label_area2_column12_title
		label_area2_column13_title = panel.label_area2_column13_title
		
		-- Radio button panels
		radiobutton_waypoint01 = panel.radiobutton_waypoint01
		radiobutton_waypoint02 = panel.radiobutton_waypoint02
		radiobutton_waypoint03 = panel.radiobutton_waypoint03
		radiobutton_waypoint04 = panel.radiobutton_waypoint04
		radiobutton_waypoint05 = panel.radiobutton_waypoint05
		radiobutton_waypoint06 = panel.radiobutton_waypoint06
		radiobutton_waypoint07 = panel.radiobutton_waypoint07
		radiobutton_waypoint08 = panel.radiobutton_waypoint08
		radiobutton_waypoint09 = panel.radiobutton_waypoint09
		radiobutton_waypoint10 = panel.radiobutton_waypoint10
		
		-- combolist panels
		comboList_aircraft = panel.comboList_aircraft
		_listAircraft = {}
		table.insert(_listAircraft, "M-2000C")
		--table.insert(_listAircraft, "AH-64D") -- TODO: Uncomment this to resume apache work
		--table.insert(_listAircraft, "F/A-18C")
		--table.insert(_listAircraft, "AV-8BNA")
		
		for _i,_k in pairs(_listAircraft) do -- try to understand this more. It works though.
			local item = ListBoxItem.new(_k)
			comboList_aircraft:insertItem(item)
		end
		comboList_aircraft:selectItem(comboList_aircraft:getItem(0))
	
		
		comboList_terrain = panel.comboList_terrain
		_listTerrain = {}
		table.insert(_listTerrain, "Caucasus")
		--table.insert(_listTerrain, "Persian Gulf")
		table.insert(_listTerrain, "Syria")
		--table.insert(_listTerrain, "Channel")
		
		for _i,_k in pairs(_listTerrain) do -- try to understand this more. It works though.
			local item = ListBoxItem.new(_k)
			comboList_terrain:insertItem(item)
		end
		comboList_terrain:selectItem(comboList_terrain:getItem(0))

		
		-- Create all of the EditBox panel links
		editBox_dtcName = panel.editBox_dtcName
		editBox_date = panel.editBox_date
		editBox_output = panel.editBox_output
		
		editBox_wp01_column02 = panel.editBox_wp01_column02
		editBox_wp02_column02 = panel.editBox_wp02_column02
		editBox_wp03_column02 = panel.editBox_wp03_column02
		editBox_wp04_column02 = panel.editBox_wp04_column02
		editBox_wp05_column02 = panel.editBox_wp05_column02
		editBox_wp06_column02 = panel.editBox_wp06_column02
		editBox_wp07_column02 = panel.editBox_wp07_column02
		editBox_wp08_column02 = panel.editBox_wp08_column02
		editBox_wp09_column02 = panel.editBox_wp09_column02
		editBox_wp10_column02 = panel.editBox_wp10_column02
		
		editBox_wp01_column03 = panel.editBox_wp01_column03
		editBox_wp02_column03 = panel.editBox_wp02_column03
		editBox_wp03_column03 = panel.editBox_wp03_column03
		editBox_wp04_column03 = panel.editBox_wp04_column03
		editBox_wp05_column03 = panel.editBox_wp05_column03
		editBox_wp06_column03 = panel.editBox_wp06_column03
		editBox_wp07_column03 = panel.editBox_wp07_column03
		editBox_wp08_column03 = panel.editBox_wp08_column03
		editBox_wp09_column03 = panel.editBox_wp09_column03
		editBox_wp10_column03 = panel.editBox_wp10_column03
	
		editBox_wp01_column04 = panel.editBox_wp01_column04
		editBox_wp02_column04 = panel.editBox_wp02_column04
		editBox_wp03_column04 = panel.editBox_wp03_column04
		editBox_wp04_column04 = panel.editBox_wp04_column04
		editBox_wp05_column04 = panel.editBox_wp05_column04
		editBox_wp06_column04 = panel.editBox_wp06_column04
		editBox_wp07_column04 = panel.editBox_wp07_column04
		editBox_wp08_column04 = panel.editBox_wp08_column04
		editBox_wp09_column04 = panel.editBox_wp09_column04
		editBox_wp10_column04 = panel.editBox_wp10_column04
		
		editBox_wp01_column05 = panel.editBox_wp01_column05
		editBox_wp02_column05 = panel.editBox_wp02_column05
		editBox_wp03_column05 = panel.editBox_wp03_column05
		editBox_wp04_column05 = panel.editBox_wp04_column05
		editBox_wp05_column05 = panel.editBox_wp05_column05
		editBox_wp06_column05 = panel.editBox_wp06_column05
		editBox_wp07_column05 = panel.editBox_wp07_column05
		editBox_wp08_column05 = panel.editBox_wp08_column05
		editBox_wp09_column05 = panel.editBox_wp09_column05
		editBox_wp10_column05 = panel.editBox_wp10_column05
		
		editBox_wp01_column06 = panel.editBox_wp01_column06
		editBox_wp02_column06 = panel.editBox_wp02_column06
		editBox_wp03_column06 = panel.editBox_wp03_column06
		editBox_wp04_column06 = panel.editBox_wp04_column06
		editBox_wp05_column06 = panel.editBox_wp05_column06
		editBox_wp06_column06 = panel.editBox_wp06_column06
		editBox_wp07_column06 = panel.editBox_wp07_column06
		editBox_wp08_column06 = panel.editBox_wp08_column06
		editBox_wp09_column06 = panel.editBox_wp09_column06
		editBox_wp10_column06 = panel.editBox_wp10_column06
		
		editBox_wp01_column07 = panel.editBox_wp01_column07
		editBox_wp02_column07 = panel.editBox_wp02_column07
		editBox_wp03_column07 = panel.editBox_wp03_column07
		editBox_wp04_column07 = panel.editBox_wp04_column07
		editBox_wp05_column07 = panel.editBox_wp05_column07
		editBox_wp06_column07 = panel.editBox_wp06_column07
		editBox_wp07_column07 = panel.editBox_wp07_column07
		editBox_wp08_column07 = panel.editBox_wp08_column07
		editBox_wp09_column07 = panel.editBox_wp09_column07
		editBox_wp10_column07 = panel.editBox_wp10_column07
		
		editBox_wp01_column08 = panel.editBox_wp01_column08
		editBox_wp02_column08 = panel.editBox_wp02_column08
		editBox_wp03_column08 = panel.editBox_wp03_column08
		editBox_wp04_column08 = panel.editBox_wp04_column08
		editBox_wp05_column08 = panel.editBox_wp05_column08
		editBox_wp06_column08 = panel.editBox_wp06_column08
		editBox_wp07_column08 = panel.editBox_wp07_column08
		editBox_wp08_column08 = panel.editBox_wp08_column08
		editBox_wp09_column08 = panel.editBox_wp09_column08
		editBox_wp10_column08 = panel.editBox_wp10_column08
		
		editBox_wp01_column09 = panel.editBox_wp01_column09
		editBox_wp02_column09 = panel.editBox_wp02_column09
		editBox_wp03_column09 = panel.editBox_wp03_column09
		editBox_wp04_column09 = panel.editBox_wp04_column09
		editBox_wp05_column09 = panel.editBox_wp05_column09
		editBox_wp06_column09 = panel.editBox_wp06_column09
		editBox_wp07_column09 = panel.editBox_wp07_column09
		editBox_wp08_column09 = panel.editBox_wp08_column09
		editBox_wp09_column09 = panel.editBox_wp09_column09
		editBox_wp10_column09 = panel.editBox_wp10_column09
		
		editBox_wp01_column10 = panel.editBox_wp01_column10
		editBox_wp02_column10 = panel.editBox_wp02_column10
		editBox_wp03_column10 = panel.editBox_wp03_column10
		editBox_wp04_column10 = panel.editBox_wp04_column10
		editBox_wp05_column10 = panel.editBox_wp05_column10
		editBox_wp06_column10 = panel.editBox_wp06_column10
		editBox_wp07_column10 = panel.editBox_wp07_column10
		editBox_wp08_column10 = panel.editBox_wp08_column10
		editBox_wp09_column10 = panel.editBox_wp09_column10
		editBox_wp10_column10 = panel.editBox_wp10_column10
		
		editBox_wp01_column11 = panel.editBox_wp01_column11
		editBox_wp02_column11 = panel.editBox_wp02_column11
		editBox_wp03_column11 = panel.editBox_wp03_column11
		editBox_wp04_column11 = panel.editBox_wp04_column11
		editBox_wp05_column11 = panel.editBox_wp05_column11
		editBox_wp06_column11 = panel.editBox_wp06_column11
		editBox_wp07_column11 = panel.editBox_wp07_column11
		editBox_wp08_column11 = panel.editBox_wp08_column11
		editBox_wp09_column11 = panel.editBox_wp09_column11
		editBox_wp10_column11 = panel.editBox_wp10_column11
		
		editBox_wp01_column12 = panel.editBox_wp01_column12
		editBox_wp02_column12 = panel.editBox_wp02_column12
		editBox_wp03_column12 = panel.editBox_wp03_column12
		editBox_wp04_column12 = panel.editBox_wp04_column12
		editBox_wp05_column12 = panel.editBox_wp05_column12
		editBox_wp06_column12 = panel.editBox_wp06_column12
		editBox_wp07_column12 = panel.editBox_wp07_column12
		editBox_wp08_column12 = panel.editBox_wp08_column12
		editBox_wp09_column12 = panel.editBox_wp09_column12
		editBox_wp10_column12 = panel.editBox_wp10_column12
		
		editBox_wp01_column13 = panel.editBox_wp01_column13
		editBox_wp02_column13 = panel.editBox_wp02_column13
		editBox_wp03_column13 = panel.editBox_wp03_column13
		editBox_wp04_column13 = panel.editBox_wp04_column13
		editBox_wp05_column13 = panel.editBox_wp05_column13
		editBox_wp06_column13 = panel.editBox_wp06_column13
		editBox_wp07_column13 = panel.editBox_wp07_column13
		editBox_wp08_column13 = panel.editBox_wp08_column13
		editBox_wp09_column13 = panel.editBox_wp09_column13
		editBox_wp10_column13 = panel.editBox_wp10_column13
	
        -- setup textarea
        --local skin = textarea:getSkin()
        --skin.skinData.states.released[1].text.fontSize = config.fontSize
        --textarea:setSkin(skin)
		
        panel:addFocusCallback(
            function(self)
                if self:getFocused() then
                    lockKeyboardInput()
                else
                    unlockKeyboardInput(true)
                    --savePage(currentPage, self:getText(), true)
                end
            end
        )
        panel:addKeyDownCallback(
            function(self, keyName, unicode)
                if keyName == "escape" then
                    self:setFocused(false)
                    unlockKeyboardInput(true)
                    --savePage(currentPage, self:getText(), true)
                end
            end
        )

        -- setup button and checkbox callbacks
        --[[prevButton:addMouseDownCallback(
            function(self)
                prevPage()
            end
        )
        nextButton:addMouseDownCallback(
            function(self)
                nextPage()
            end
        )--]]
		
        crosshairCheckbox:addChangeCallback(
            function(self)
                local checked = self:getState()
                --insertCoordsBtn:setVisible(checked)
                crosshairWindow:setVisible(checked)
            end
        )
		
        insertCoordsBtn:addMouseDownCallback(
            function(self)
                insertCoordinates()
            end
        )
		
		
		comboList_aircraft:addChangeCallback(
            function(self)
				log('Aircraft selected: ' .. comboList_aircraft:getText())
				--editBox_output:setText(comboList_aircraft:getText())
				-- hide everything here
				
				
				if comboList_aircraft:getText() == 'M-2000C' then
					log('Changing to ' .. comboList_aircraft:getText() .. ' DTC')
					aircraftSelectedChangedm2000c()
				elseif comboList_aircraft:getText() == 'AH-64D' then
					log('Changing to ' .. comboList_aircraft:getText() .. ' DTC')
					aircraftSelectedChangedah64d()	
				end
            end
        )
		
		
		comboList_terrain:addChangeCallback(
            function(self)
				log('Terrain selected: ' .. comboList_terrain:getText())
            end
        )
		
		button_clearAllData:addMouseDownCallback(clearAllData)
		
	--[[
		button_clearAllData:addMouseDownCallback(
            function(self)
                clearAllData()
            end
        )
	--]]
		button_import:addMouseDownCallback(import)
		
		button_export:addMouseDownCallback(export)
				
        -- setup window
        window:setBounds(
            config.windowPosition.x,
            config.windowPosition.y,
            config.windowSize.w,
            config.windowSize.h
        )
        handleResize(window)
	
        window:addHotKeyCallback(
            config.hotkey,
            function()
                if isHidden == true then
                    show()
                else
                    hide()
                end
            end
        )
	
		
		window:addHotKeyCallback(config.getCoordHotkey, function()
			--editBox_output:setText('hotkeypressed')
			insertCoordinates()
			end)
		
        window:addSizeCallback(handleResize)
        window:addPositionCallback(handleMove)

        window:setVisible(true)
        nextPage()
		
		window:setText(windowTitle .. "  |  Toggle with " ..  config.hotkey .. '  |  Capture with ' .. config.getCoordHotkey)
        hide()
		show()
		
		--label_area2_column02_title:setText('tst')
		
        log("DMPS window created")
    end


	
	
    local handler = {}
    function handler.onSimulationFrame()
        if config == nil then
            loadConfiguration()
        end

        if not window then
            log("Creating DMPS window hidden...")
            createDMPSWindow()
        end
    end
	
    function handler.onMissionLoadEnd()
        inMission = true
        updateCoordsMode()
    end
	
    function handler.onSimulationStop()
        inMission = false
        crosshairCheckbox:setState(false)
        hide()
    end
    DCS.setUserCallbacks(handler)

    net.log("[DMPS] Loaded ...")
end

local status, err = pcall(loadDMPS)
if not status then
    net.log("[DMPS] Load Error: " .. tostring(err))
end