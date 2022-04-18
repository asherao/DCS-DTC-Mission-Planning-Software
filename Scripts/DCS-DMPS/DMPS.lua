--Version 2
--Thank you DCSTheWay! Check em out for automated waypoint entry.
local tcpServer = nil
local udpSpeaker = nil
package.path  = package.path..";"..lfs.currentdir().."/LuaSocket/?.lua"
package.cpath = package.cpath..";"..lfs.currentdir().."/LuaSocket/?.dll"
package.path  = package.path..";"..lfs.currentdir().."/Scripts/?.lua"
local socket = require("socket")

local upstreamLuaExportStart = LuaExportStart
local upstreamLuaExportAfterNextFrame = LuaExportAfterNextFrame
local upstreamLuaExportBeforeNextFrame = LuaExportBeforeNextFrame

function LuaExportStart()
    if upstreamLuaExportStart ~= nil then
        successful, err = pcall(upstreamLuaExportStart)
        if not successful then
            log.write("DMPS", log.ERROR, "Error in upstream LuaExportStart function"..tostring(err))
        end
    end
    
	udpSpeaker = socket.udp()
	udpSpeaker:settimeout(0)
	tcpServer = socket.tcp()
    tcpServer:bind("127.0.0.1", 42081)
    tcpServer:listen(1)
    tcpServer:settimeout(0)
end

function LuaExportAfterNextFrame()
    if upstreamLuaExportAfterNextFrame ~= nil then
        successful, err = pcall(upstreamLuaExportAfterNextFrame)
        if not successful then
            log.write("DMPS", log.ERROR, "Error in upstream LuaExportAfterNextFrame function"..tostring(err))
        end
    end

  local camPos = LoGetCameraPosition()
	local loX = camPos['p']['x']
	local loZ = camPos['p']['z']
	local elevation = LoGetAltitude(loX, loZ)
	local coords = LoLoCoordinatesToGeoCoordinates(loX, loZ)
	local model = LoGetSelfData()["Name"];
	
	local toSend = "{ ".."\"model\": ".."\""..model.."\""..", ".."\"coords\": ".. "{ ".."\"lat\": ".."\"".. string.format("%.4f", coords.latitude) .."\""..", ".."\"lon\": ".."\"".. string.format("%.4f", coords.longitude) .."\"".."} "..", ".."\"elev\": ".."\"".. string.format("%.2f", elevation) .."\"".."}"

	if pcall(function()
		socket.try(udpSpeaker:sendto(toSend, "127.0.0.1", 42080)) 
	end) then
	else
		log.write("DMPS", log.ERROR, "Unable to send data")
	end
end