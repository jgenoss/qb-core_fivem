local dynoRunning = false -- Flag to indicate if the dyno is running
local function adjustWheelRotationSpeed(vehicle, speed)
local driveBiasFront = getVehicleHandlingValue(vehicle, "CHandlingData", "fDriveBiasFront") -- Get the front drive bias
if driveBiasFront >= 0.5 then -- If front-wheel drive or equal bias
SetVehicleWheelRotationSpeed(vehicle, 0, speed) -- Set left front wheel speed
SetVehicleWheelRotationSpeed(vehicle, 1, speed) -- Set right front wheel speed
end
if driveBiasFront <= 0.5 then -- If rear-wheel drive or equal bias
SetVehicleWheelRotationSpeed(vehicle, 2, speed) -- Set left rear wheel speed
SetVehicleWheelRotationSpeed(vehicle, 3, speed) -- Set right rear wheel speed
end
end
local function startDynoTest(vehicle)
local dynoThread = CreateThread(function()
local timeout = 0
dynoRunning = true -- Set the dyno running flag
SetVehicleGravity(vehicle, false) -- Disable gravity for the vehicle
while true do
if not (timeout < 33500) then -- Check if timeout exceeds maximum value
break
end
if not dynoRunning then -- Check if dyno test should stop
break
end
local startTime = GetGameTimer()
local entity = Entity(vehicle)
local vehicleState = entity.state
local dynoData = {}
dynoData.rpm = math.min(1.0, (timeout + 7500) / 33500 + 0.0) -- Calculate RPM value
dynoData.wheelSpeed = timeout / 200 + 0.0 -- Calculate wheel speed value
vehicleState.set(vehicleState, "vehicleDyno", dynoData, true) -- Set vehicle dyno state
Wait(50)
local elapsedTime = GetGameTimer() - startTime
timeout = timeout + elapsedTime
end
local entity = Entity(vehicle)
local vehicleState = entity.state
vehicleState.set(vehicleState, "vehicleDyno", false, true) -- Reset vehicle dyno state
SetVehicleGravity(vehicle, true) -- Enable gravity for the vehicle
end)
end
local addStateBagChangeHandler = AddStateBagChangeHandler
local vehicleDynoState = "vehicleDyno"
local emptyString = ""
local function onVehicleDynoChange(bagName, key, value)
local entity = GetEntityFromStateBagName(bagName) -- Get the entity from the state bag name
if not (entity and DoesEntityExist(entity)) then -- Check if the entity exists
return
end
if not value then -- If dyno data is not available
adjustWheelRotationSpeed(entity, 0) -- Stop wheel rotation
return
end
local rpm = value.rpm
local wheelSpeed = value.wheelSpeed
SetVehicleCurrentRpm(entity, rpm) -- Set the vehicle RPM
adjustWheelRotationSpeed(entity, wheelSpeed) -- Set the wheel rotation speed
end
addStateBagChangeHandler(vehicleDynoState, emptyString, onVehicleDynoChange)
local registerNUICallback = RegisterNUICallback
local function startDynoCallback(data, cb)
local playerPed = cache.ped
local connectedVehicle = LocalPlayer.state.tabletConnectedVehicle
if connectedVehicle then
connectedVehicle = connectedVehicle.vehicleEntity
end
if not (connectedVehicle and DoesEntityExist(connectedVehicle)) then -- Check if the connected vehicle exists
return cb(false)
end
CreateThread(function()
SetNuiFocus(false, false) -- Disable NUI focus
local driver = GetPedInVehicleSeat(connectedVehicle, -1) -- Get the driver of the vehicle
if driver ~= playerPed then -- If the player is not the driver
hideTabletToShowInteractionPrompt(Locale.enterVehicleToStartDynoMsg) -- Show message to enter the vehicle
while GetPedInVehicleSeat(connectedVehicle, -1) ~= playerPed do -- Wait until the player is the driver
Wait(100)
end
end
hideTabletToShowInteractionPrompt(Locale.startDynoMsg) -- Show the message to start the dyno
while not IsControlJustPressed(0, 201) do -- Wait for the player to press the interaction key
Wait(0)
end
SetNuiFocus(true, true) -- Enable NUI focus
showTabletAfterInteractionPrompt()
local dynoParameters = {}
dynoParameters.maxSpeed = getVehicleHandlingValue(connectedVehicle, "CHandlingData", "fInitialDriveMaxFlatVel") -- Get max speed
dynoParameters.fDriveInertia = getVehicleHandlingValue(connectedVehicle, "CHandlingData", "fDriveInertia") -- Get drive inertia
dynoParameters.fInitialDriveForce = getVehicleHandlingValue(connectedVehicle, "CHandlingData", "fInitialDriveForce") -- Get initial drive force
cb(dynoParameters)
startDynoTest(connectedVehicle) -- Start the dyno test
end)
end
registerNUICallback("start-dyno", startDynoCallback)
local function stopDynoCallback(data, cb)
dynoRunning = false -- Set dyno running flag to false
cb(true)
end
registerNUICallback("stop-dyno", stopDynoCallback)
local function shareDynoResultsCallback(data, cb)
local targetPlayer = data.player
local dynoResults = data.results
if not targetPlayer or not dynoResults then -- Check if player and results are valid
return cb(false)
end
local success = lib.callback.await("jg-mechanic:server:dyno-share-with-player", false, targetPlayer, dynoResults) -- Await server callback
cb(success)
end
registerNUICallback("dyno-share-with-player", shareDynoResultsCallback)
local function showDynoResultsSheet(results)
SetNuiFocus(true, true) -- Enable NUI focus
SendNUIMessage({ -- Send message to NUI
type = "show-dyno-share-sheet",
results = results,
locale = Locale,
config = Config
})
end
RegisterNetEvent("jg-mechanic:client:dyno-show-results-sheet", showDynoResultsSheet)