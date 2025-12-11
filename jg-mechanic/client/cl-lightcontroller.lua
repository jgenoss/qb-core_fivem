local cycleValue = 0
local flashState = false
local controllerActive = true
local isPedInVehicle = false
local controllerInstalled = false
local currentVehicle = nil
function HSVToRGB(hue, saturation, value)
local i = math.floor(hue * 6)
local f = hue * 6 - i
local p = value * (1 - saturation)
local q = value * (1 - saturation * f)
local t = value * (1 - saturation * (1 - f))
local r, g, b
if i % 6 == 0 then
r, g, b = value, t, p
elseif i % 6 == 1 then
r, g, b = q, value, p
elseif i % 6 == 2 then
r, g, b = p, value, t
elseif i % 6 == 3 then
r, g, b = p, q, value
elseif i % 6 == 4 then
r, g, b = t, p, value
else
r, g, b = value, p, q
end
return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end
RegisterNUICallback("install-light-controller", function(data, callback)
if controllerInstalled and currentVehicle then
return -- Avoid installing if already installed
end
-- Simulate an installation process with a progress bar
Framework.Client.ProgressBar(Locale.installingLightingController, 2000, false, false,
function() -- Success callback
setVehicleStatebag(currentVehicle, "lightingControllerInstalled", true, true)
callback(true) -- Indicate success
end,
function() -- Failure callback
callback(false) -- Indicate failure
end
)
end)
RegisterNUICallback("update-light-controller", function(data, callback)
if not controllerInstalled or not currentVehicle then
return callback(false)
end
local vehicleEntity = Entity(currentVehicle)
if not vehicleEntity.state.lightingControllerInstalled then
return callback(false) -- controller not installed
end
SetVehicleModKit(currentVehicle, 0) -- Reset vehicle mods
-- Xenon lights
if data.xenons then
ToggleVehicleMod(currentVehicle, 22, true) -- Enable xenon mod
local lightSetting = data.xenons.enabled and 2 or 0 -- Set lights on if enabled
SetVehicleLights(currentVehicle, lightSetting)
-- Set custom xenon color if selected
if data.xenons.effect == "solid" then
SetVehicleXenonLightsCustomColor(currentVehicle, data.xenons.colour.r, data.xenons.colour.g, data.xenons.colour.b)
end
setVehicleStatebag(currentVehicle, "xenons", data.xenons, true)
end
-- Underglow lights
if data.underglow then
-- Disable underglow if not enabled
if not data.underglow.enabled then
for i = 0, 3 do
SetVehicleNeonLightEnabled(currentVehicle, i, false)
end
end
-- Set solid underglow color
if data.underglow.effect == "solid" then
SetVehicleNeonLightsColour(currentVehicle, data.underglow.colour.r, data.underglow.colour.g, data.underglow.colour.b)
end
-- Save underglow settings and direction to state bag
setVehicleStatebag(currentVehicle, "underglowDirections", data.underglowDirections, true)
setVehicleStatebag(currentVehicle, "underglow", data.underglow, true)
end
callback(true)
end)
RegisterNUICallback("sync-light-controller", function(data, callback)
if not controllerInstalled or not currentVehicle then
return callback(false)
end
-- Simulate synchronization with a short delay
CreateThread(function()
Wait(500)
isPedInVehicle = true
controllerActive = true
callback(true)
end)
end)
RegisterNUICallback("close-light-controller", function(data, callback)
cycleValue = 0
flashState = false
controllerActive = true -- Enable underglow lights
isPedInVehicle = false
controllerInstalled = false
currentVehicle = nil
LocalPlayer.state.set(LocalPlayer.state, "isBusy", false, true) -- Release busy state
SetNuiFocus(false, false) -- Disable NUI focus
callback(true) -- Confirm NUI is closed
end)
RegisterNetEvent("jg-mechanic:client:show-lighting-controller", function()
controllerInstalled = lib.callback.await("jg-mechanic:server:has-item", 250, "lighting_controller")
if not controllerInstalled then
return
end
if not cache.vehicle then
Framework.Client.Notify(Locale.notInsideVehicle, "error")
return
end
currentVehicle = cache.vehicle
local vehicleModel = GetEntityModel(currentVehicle)
-- Ensure the vehicle is compatible
if not IsThisModelACar(vehicleModel) and not IsThisModelAQuadbike(vehicleModel) then
Framework.Client.Notify("ERR_VEHICLE_TYPE_INCOMPATIBLE", "error")
return
end
local vehicleEntityState = Entity(currentVehicle).state
-- Set client as busy
LocalPlayer.state.set(LocalPlayer.state, "isBusy", true, true)
SetNuiFocus(true, true)
-- Send data to the NUI for rendering
SendNUIMessage({
type = "show-lighting-controller",
installed = vehicleEntityState.lightingControllerInstalled or false,
xenons = vehicleEntityState.xenons,
underglow = vehicleEntityState.underglow,
underglowDirections = vehicleEntityState.underglowDirections,
locale = Locale,
config = Config
})
end)
CreateThread(function()
while true do
-- Check if player is in a vehicle
if IsPedInAnyVehicle(cache.ped, false) then
local vehicle = GetVehiclePedIsIn(cache.ped, false)
local vehicleEntity = Entity(vehicle).state
-- Control the underglow if installed and enabled
if vehicleEntity.underglow then
while true do
-- Break if the player is no longer in the vehicle
if not IsPedInVehicle(cache.ped, vehicle, false) then
break
end
-- Break if the controller or underglow is disabled
if not vehicleEntity.lightingControllerInstalled or not vehicleEntity.underglow or not vehicleEntity.underglow.enabled or not controllerActive then
break
end
-- Update neon lights based on directions
for i = 0, 3 do
SetVehicleNeonLightEnabled(vehicle, i, vehicleEntity.underglowDirections[i + 1])
end
-- Handle the specific lighting effect
if vehicleEntity.underglow.effect == "solid" then
break -- Solid color doesn't need dynamic update
elseif vehicleEntity.underglow.effect == "rgb_cycle" then
-- Cycle through RGB colors
cycleValue = (cycleValue + 0.01) % 1
local r, g, b = HSVToRGB(cycleValue, 1, 1)
SetVehicleNeonLightsColour(vehicle, r, g, b)
local speed = vehicleEntity.underglow.speed or 1
Wait(50 / speed)
elseif vehicleEntity.underglow.effect == "flashing" then
-- Flash the underglow
if flashState then
SetVehicleNeonLightsColour(vehicle, 0, 0, 0) -- Turn off lights
flashState = false
else
SetVehicleNeonLightsColour(vehicle, vehicleEntity.underglow.colour.r, vehicleEntity.underglow.colour.g, vehicleEntity.underglow.colour.b)
flashState = true
end
local speed = vehicleEntity.underglow.speed or 1
Wait(200 / speed)
else
Wait(500)
end
vehicleEntity = Entity(vehicle).state
end
end
end
Wait(controllerActive and 500 or 2000)
end
end)
local updateThread = CreateThread
local function vehicleXenonLightsHandler()
while true do
local playerPed = cache.ped  -- Get the player's ped from the cache
local isInVehicle = IsPedInAnyVehicle(playerPed, false) -- Check if the player is in any vehicle
if isInVehicle then
local vehicle = GetVehiclePedIsIn(playerPed, false) -- Get the vehicle the player is in
local entityData = Entity(vehicle) -- Get entity data
local vehicleState = entityData.state
if vehicleState.xenons then --check if vehicle has xenon lights
while true do
local isPedInSpecificVehicle = IsPedInVehicle(playerPed, vehicle, false) --checks ped is in vehicle
if not isPedInSpecificVehicle then
break -- Exit loop if player is no longer in the vehicle
end
if not vehicleState.lightingControllerInstalled then
break --exit if lighting controller not installed
end
if not vehicleState.xenons then
break --exit if no xenon lights
end
if not vehicleState.xenons.enabled then
break -- Exit loop if xenon lights are not enabled
end
if not lightingEnabled then
break -- global check for lighting enabled
end
if vehicleState.xenons then
local xenonEffect = vehicleState.xenons.effect --xenon effect stored
if "solid" == xenonEffect then
break --exit loop solid effect
end
if "rgb_cycle" == xenonEffect then -- if rgb_cycle effect
rgbCycleValue = rgbCycleValue + 0.01 -- Increment the RGB cycle value
rgbCycleValue = rgbCycleValue % 1 -- Ensure the value stays within 0-1 range
local r, g, b = HSVToRGB(rgbCycleValue, 1, 1) -- Convert HSV to RGB
SetVehicleXenonLightsCustomColor(vehicle, r, g, b) -- Set vehicle's xenon lights to the custom color
local waitTime = vehicleState.xenons.speed --adjust the wait time according to the speed variable set
if not waitTime then
waitTime = 1
end
Wait(50 / waitTime) -- Wait before the next color change
elseif "flashing" == xenonEffect then --If flash effect
if isFlashingOn then
SetVehicleXenonLightsCustomColor(vehicle, 0, 0, 0) -- Turn off the lights
isFlashingOn = false -- Set the flag to false
else
local r = vehicleState.xenons.colour.r
local g = vehicleState.xenons.colour.g
local b = vehicleState.xenons.colour.b
SetVehicleXenonLightsCustomColor(vehicle, r, g, b) -- Turn on the lights with configured colors
isFlashingOn = true -- Set the flag to true
end
local waitTime = vehicleState.xenons.speed --same principle as above
if not waitTime then
waitTime = 1
end
Wait(200 / waitTime) -- Wait before the next flash
else
Wait(500) -- Default wait if no effect is specified
end
local entity = Entity(vehicle) -- Get entity data
vehicleState = entity.state
end
end
end
end
-- Wait before the next check (reduced waiting if enabled)
local waitTime = lightingEnabled and 1000 or 1
Wait(waitTime)
end
end
updateThread(vehicleXenonLightsHandler) -- Start the xenon lights handling thread