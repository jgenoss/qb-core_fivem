local MIN_HEIGHT = -1.025 -- Minimum car lift height
local MAX_HEIGHT = 0.85  -- Maximum car lift height
local HEIGHT_INCREMENT = 0.01 -- Height increment for each step
local carLiftData = nil -- Stores car lift data (platform, stand, coords)
local isGoingUp = false   -- Flag indicating if the car lift is going up
local isGoingDown = false -- Flag indicating if the car lift is going down
local hydraulicSound = nil -- Stores the hydraulic sound object
local registerNUICallback = RegisterNUICallback
registerNUICallback("carlift-up", function(data, callback)
-- If car lift is already going up, do nothing
if carLiftData then
if not isGoingUp then
goto continueUp
end
end
callback(false)
return
::continueUp::
-- Get coordinates of the platform
local platformProp = carLiftData.platformProp
local platformCoords = GetEntityCoords(platformProp)
local platformZ = platformCoords.z
local initialZ = carLiftData.coords.z
local heightDifference = platformZ - initialZ
carLiftData.height = heightDifference
-- Set flags and get closest vehicle
isGoingUp = true
local closestVehicleCoords = platformCoords
local maxDistance = 3.0
local includeOccupied = true
local closestVehicle, closestVehicleCoords = lib.getClosestVehicle(closestVehicleCoords, maxDistance, includeOccupied)
-- Play hydraulic sound effect
hydraulicSound = Framework.Client.PlaySound("hydraulic", vector3(carLiftData.coords.x, carLiftData.coords.y, carLiftData.coords.z))
-- Create thread to animate the car lift going up
CreateThread(function()
while true do
-- Stop if lift is no longer going up or if the car lift data is gone
if not isGoingUp then
break
end
if not carLiftData then
break
end
-- Stop if lift is at or above max height
if not (carLiftData.height < MAX_HEIGHT) then
break
end
-- Increment lift height
local newHeight = carLiftData.height + HEIGHT_INCREMENT
carLiftData.height = newHeight
-- Set car lift platform coords
local newZ = carLiftData.coords.z + carLiftData.height
SetEntityCoords(platformProp, carLiftData.coords.x, carLiftData.coords.y, newZ, false, false, false, false)
-- If a vehicle is attached, move it with the platform
if data.vAttach then
if closestVehicle then
if DoesEntityExist(closestVehicle) then
SetEntityCoords(closestVehicle, closestVehicleCoords.x, closestVehicleCoords.y, newZ, false, false, false, false)
end
end
end
Wait(25)
end
-- Stop sound if lift has reached max height
if carLiftData then
if not (carLiftData.height >= MAX_HEIGHT) then
goto skipSoundStop
end
end
if hydraulicSound then
Framework.Client.StopSound(hydraulicSound)
end
::skipSoundStop::
end)
-- Call callback when finished
callback(true)
end)
registerNUICallback("carlift-down", function(data, callback)
-- If car lift is already going down, do nothing
if carLiftData then
if not isGoingDown then
goto continueDown
end
end
callback(false)
return
::continueDown::
-- Get coordinates of the platform
local platformProp = carLiftData.platformProp
local platformCoords = GetEntityCoords(platformProp)
local platformZ = platformCoords.z
local initialZ = carLiftData.coords.z
local heightDifference = platformZ - initialZ
carLiftData.height = heightDifference
-- Set flags and get closest vehicle
isGoingDown = true
local closestVehicleCoords = platformCoords
local maxDistance = 3.0
local includeOccupied = true
local closestVehicle, closestVehicleCoords = lib.getClosestVehicle(closestVehicleCoords, maxDistance, includeOccupied)
-- Play hydraulic sound effect
hydraulicSound = Framework.Client.PlaySound("hydraulic", vector3(carLiftData.coords.x, carLiftData.coords.y, carLiftData.coords.z))
-- Create thread to animate the car lift going down
CreateThread(function()
while true do
-- Stop if lift is no longer going down or if the car lift data is gone
if not isGoingDown then
break
end
if not carLiftData then
break
end
-- Stop if lift is at or below min height
if not (carLiftData.height > MIN_HEIGHT) then
break
end
-- Decrement lift height
local newHeight = carLiftData.height - HEIGHT_INCREMENT
carLiftData.height = newHeight
-- Set car lift platform coords
local newZ = carLiftData.coords.z + carLiftData.height
SetEntityCoords(platformProp, carLiftData.coords.x, carLiftData.coords.y, newZ, false, false, false, false)
-- If a vehicle is attached, move it with the platform
if data.vAttach then
if closestVehicle then
if DoesEntityExist(closestVehicle) then
SetEntityCoords(closestVehicle, closestVehicleCoords.x, closestVehicleCoords.y, newZ, false, false, false, false)
end
end
end
Wait(25)
end
-- Stop sound if lift has reached min height
if carLiftData then
if not (carLiftData.height <= MIN_HEIGHT) then
goto skipDownSoundStop
end
end
if hydraulicSound then
Framework.Client.StopSound(hydraulicSound)
end
::skipDownSoundStop::
end)
-- Call callback when finished
callback(true)
end)
registerNUICallback("carlift-stop", function(data, callback)
-- If sound is already stopped, do nothing
if carLiftData then
if hydraulicSound then
goto continueStop
end
end
callback(false)
return
::continueStop::
Framework.Client.StopSound(hydraulicSound)
isGoingDown = false
isGoingUp = false
callback(true)
end)
registerNUICallback("hide-carlift-controls", function(data, callback)
SendNUIMessage({ showCarLift = false })
SetNuiFocus(false, false)
callback(true)
end)
local showCarLiftControls = function()
SetNuiFocus(true, true)
SendNUIMessage({
showCarLift = true,
locale = Locale,
})
end
local onEnterCarliftZone = function(zoneData)
if not zoneData then
return
end
-- Get entity handles from network IDs
local platformEntity = NetworkGetEntityFromNetworkId(zoneData.platform)
local standEntity = NetworkGetEntityFromNetworkId(zoneData.stand)
-- Show use prompt
Framework.Client.ShowTextUI(Config.UseCarLiftPrompt)
-- Store car lift data
carLiftData = {
platformProp = platformEntity,
standProp = standEntity,
coords = zoneData.coords,
height = 0,
}
-- Create thread to check for activation key press
CreateThread(function()
while true do
if not carLiftData then
break
end
-- Check for activation key press
if IsControlJustPressed(0, Config.UseCarLiftKey) then
showCarLiftControls()
end
Wait(0)
end
end)
end
onEnterCarliftZone = onEnterCarliftZone
local onExitCarliftZone = function()
carLiftData = nil
Framework.Client.HideTextUI()
SetNuiFocus(false, false)
SendNUIMessage({ showCarLift = false })
end
onExitCarliftZone = onExitCarliftZone