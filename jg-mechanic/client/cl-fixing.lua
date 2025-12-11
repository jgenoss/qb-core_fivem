local RegisterNetEvent = RegisterNetEvent
RegisterNetEvent("jg-mechanic:client:fix-vehicle-admin", function()
-- Check if the player is an admin
local isAdmin = lib.callback.await("jg-mechanic:server:is-admin", false)
if not isAdmin then
return
end
-- Check if the player is in a vehicle
local vehicle = cache.vehicle
if not vehicle then
Framework.Client.Notify(Locale.notInsideVehicle, "error")
return
end
-- Repair the vehicle
Framework.Client.RepairVehicle(cache.vehicle)
end)
RegisterNetEvent("jg-mechanic:client:clean-vehicle", function()
-- Check if the player has a cleaning kit
local hasCleaningKit = lib.callback.await("jg-mechanic:server:has-item", 250, "cleaning_kit")
if not hasCleaningKit then
return
end
local playerPed = cache.ped
local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)
-- Check if there is a vehicle nearby
if not closestVehicle then
Framework.Client.Notify(Locale.noVehicleNearby, "error")
return
end
-- Make the player leave the vehicle if they are in it
if IsPedInVehicle(playerPed, closestVehicle, true) then
TaskLeaveVehicle(playerPed, closestVehicle, 16)
end
-- Configure the cleaning animation and prop
local animation = {}
animation.dict = "amb@world_human_maid_clean@"
animation.name = "base"
local prop = {}
prop.model = "prop_sponge_01"
prop.bone = 28422
prop.coords = vector3(0.0, 0.0, -0.01)
prop.rotation = vector3(90.0, 0.0, 0.0)
-- Start the progress bar and animation
Framework.Client.ProgressBar(Locale.cleaningVehicle, 3500, animation, prop, function()
-- Called when the progress bar is complete
-- Clean the vehicle
SetVehicleDirtLevel(closestVehicle, 0.0)
WashDecalsFromVehicle(closestVehicle, 1.0)
Framework.Client.Notify(Locale.vehicleCleaned, "success")
-- Remove the cleaning kit
TriggerServerEvent("jg-mechanic:server:remove-item", "cleaning_kit")
end, function()
-- Called if the progress bar is cancelled
end)
end)
RegisterNetEvent("jg-mechanic:client:repair-vehicle", function()
-- Check if the player has a repair kit
local hasRepairKit = lib.callback.await("jg-mechanic:server:has-item", 250, "repair_kit")
if not hasRepairKit then
return
end
local playerPed = cache.ped
local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)
-- Check if there is a vehicle nearby
if not closestVehicle then
Framework.Client.Notify(Locale.noVehicleNearby, "error")
return
end
-- Check if the player is already in a vehicle
if cache.vehicle then
Framework.Client.Notify(Locale.leaveVehicleFirst, "error")
return
end
-- Start the repair minigame
playMinigame(closestVehicle, "prop", { prop = "spanner" }, function(success)
-- Called when the minigame is complete
if not success then
return
end
-- Check if the player still has a repair kit
local hasRepairKit = lib.callback.await("jg-mechanic:server:has-item", false, "repair_kit")
if not hasRepairKit then
return
end
-- Repair the vehicle
Framework.Client.RepairVehicle(closestVehicle)
Framework.Client.Notify(Locale.vehicleRepaired, "success")
-- Remove the repair kit
TriggerServerEvent("jg-mechanic:server:remove-item", "repair_kit")
end)
end)
RegisterNetEvent("jg-mechanic:client:use-duct-tape", function()
-- Check if the player has duct tape
local hasDuctTape = lib.callback.await("jg-mechanic:server:has-item", 250, "duct_tape")
if not hasDuctTape then
return
end
local playerPed = cache.ped
local closestVehicle = lib.getClosestVehicle(GetEntityCoords(playerPed), 3.0, true)
-- Check if there is a vehicle nearby
if not closestVehicle then
Framework.Client.Notify(Locale.noVehicleNearby, "error")
return
end
-- Check the vehicle engine health
local engineHealth = GetVehicleEngineHealth(closestVehicle)
if engineHealth > Config.DuctTapeMinimumEngineHealth then
Framework.Client.Notify(Locale.ductTapeEngineHealthTooHigh, "error")
return
end
-- Start the minigame
playMinigame(closestVehicle, "prop", { prop = "spanner" }, function(success)
-- Called when the minigame is complete
if not success then
return
end
-- Check if the player still has duct tape
local hasDuctTape = lib.callback.await("jg-mechanic:server:has-item", false, "duct_tape")
if not hasDuctTape then
return
end
-- Apply the duct tape
SetVehicleUndriveable(closestVehicle, false) -- Make sure the vehicle is driveable
SetVehicleEngineHealth(closestVehicle, engineHealth + Config.DuctTapeEngineHealthIncrease)
Framework.Client.Notify(Locale.ductTapeUsed, "success")
-- Remove the duct tape
TriggerServerEvent("jg-mechanic:server:remove-item", "duct_tape")
end)
end)