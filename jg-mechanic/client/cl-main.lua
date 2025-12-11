local setVehicleStatebag
local function setVehicleState(entity, statebagKey, value1, value2, value3)
local netId = VehToNet(entity) -- Convert entity to network ID
return lib.callback.await("jg-mechanic:server:set-vehicle-statebag", false, netId, statebagKey, value1, value2, value3)
end
setVehicleStatebag = setVehicleState
local setVehicleStatebags
local function setVehicleStates(entity, statebagKey, value1, value2)
local netId = VehToNet(entity) -- Convert entity to network ID
return lib.callback.await("jg-mechanic:server:set-vehicle-statebags", false, netId, statebagKey, value1, value2)
end
setVehicleStatebags = setVehicleStates
local function playAnimation(entity, animDict, animName, loop)
CreateThread(function()
lib.requestAnimDict(animDict)
if not IsEntityPlayingAnim(entity, animDict, animName, 3) then
local flag = 49
if loop then
flag = 33
end
TaskPlayAnim(entity, animDict, animName, 3.0, 3.0, -1, flag, 0, false, false, false)
end
end)
end
local function stopAnimation(ped)
ClearPedTasks(ped)
end
local playTabletAnim
local function playTabletAnimation()
local animDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local animName = "base"
local propModelHash = -1585232418
local boneId = 60309
local propOffset = vector3(0.03, 0.002, 0)
local rotationOffset = vector3(10.0, 160.0, 0.0)
CreateThread(function()
lib.requestAnimDict(animDict)
lib.requestModel(propModelHash, 3000)
local playerPed = cache.ped
Globals.HoldingTablet = CreateObject(propModelHash, 0.0, 0.0, 0.0, true, true, false)
local boneIndex = GetPedBoneIndex(playerPed, boneId)
SetCurrentPedWeapon(playerPed, -1569615261, true)
AttachEntityToEntity(Globals.HoldingTablet, playerPed, boneIndex, propOffset.x, propOffset.y, propOffset.z, rotationOffset.x, rotationOffset.y, rotationOffset.z, true, false, false, false, 2, true)
SetModelAsNoLongerNeeded(propModelHash)
if not IsEntityPlayingAnim(playerPed, animDict, animName, 3) then
TaskPlayAnim(playerPed, animDict, animName, 3.0, 3.0, -1, 49, 0, false, false, false)
end
end)
end
playTabletAnim = playTabletAnimation
local stopTabletAnim
local function stopTabletAnimation()
if not Globals.HoldingTablet then
return
end
ClearPedTasks(cache.ped)
DetachEntity(Globals.HoldingTablet, true, false)
DeleteEntity(Globals.HoldingTablet)
Globals.HoldingTablet = nil
end
stopTabletAnim = stopTabletAnimation
local function createPedForTarget(modelName, coords)
lib.requestModel(modelName)
local ped = CreatePed(0, joaat(modelName), coords.x, coords.y, coords.z, coords.w or 0, false, false)
lib.waitFor(function()
return DoesEntityExist(ped)
end)
SetEntityInvincible(ped, true)
SetBlockingOfNonTemporaryEvents(ped, true)
SetPedFleeAttributes(ped, 0, false)
SetPedCombatAttributes(ped, 17, true)
FreezeEntityPosition(ped, true)
SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, true, true, false)
SetPedCanRagdoll(ped, false)
SetEntityProofs(ped, true, true, true, true, true, true, true, true)
SetModelAsNoLongerNeeded(modelName)
return ped
end
createPedForTarget = createPedForTarget
RegisterNUICallback = RegisterNUICallback
RegisterNUICallback("has-item", function(data, cb)
local itemName = data.itemName
local quantity = data.qty
local callback = cb
lib.callback.await("jg-mechanic:server:has-item", false, itemName, quantity)
:then(function(result)
callback(result)
end)
end)
RegisterNUICallback("nearby-players", function(data, cb)
local playerCoords = GetEntityCoords(cache.ped)
local radius = 10.0
local callback = cb
local includePlayer = data and data.includePlayer or false -- Check if data exists
lib.callback.await("jg-mechanic:server:nearby-players", false, playerCoords, radius, includePlayer)
:then(function(result)
callback(result)
end)
end)
RegisterNUICallback("get-player-balances", function(data, cb)
local callback = cb
local balances = {}
balances.bank = Framework.Client.GetBalance("bank")
balances.cash = Framework.Client.GetBalance("cash")
callback(balances)
end)
RegisterNUICallback("close", function(data, cb)
exitCamera()
stopTabletAnimation()
SetNuiFocus(false, false)
-- Fixes bug where player cannot move after closing ui
local playerState = LocalPlayer.state
playerState:set("isBusy", false, true)
if not Globals.HoldingTablet then
Framework.Client.ToggleHud(true)
end
cb(true)
end)
CreateThread(function()
while true do
local vehicle = cache.vehicle
if vehicle then
local vehicleEntity = Entity(vehicle)
if vehicleEntity and vehicleEntity.state and vehicleEntity.state.unpaidModifications then
local speed = GetEntitySpeed(cache.vehicle)
if speed > 1.0 then
Framework.Client.Notify("This vehicle appears to have unpaid for modifications. It has been repossessed.")
DeleteEntity(cache.vehicle)
end
end
end
Wait(10000)
end
end)