local MAX_DISTANCE = 3000
local INTERACTION_KEY = 201
local CANCEL_KEY = 202
function isPlayerNearBone(entity, boneNames)
local playerPed = cache.ped
local playerCoords = GetEntityCoords(playerPed)
for _, boneName in ipairs(boneNames) do
local boneIndex = GetEntityBoneIndexByName(entity, boneName)
if boneIndex == -1 then
return true -- Bone name does not exist on the entity
else
local boneWorldPosition = GetWorldPositionOfEntityBone(entity, boneIndex)
local distance = #(playerCoords - boneWorldPosition) -- Calculate distance
if distance <= 3.0 then
return true -- Player is near the bone
end
end
end
return false -- Player is not near any of the bones
end
function playAnimationBasedOnSituation(entity, animationType, targetEntity)
if not entity or not targetEntity then
return
end
local targetCoords = GetEntityCoords(targetEntity)
local entityCoords = GetEntityCoords(entity)
local zDifference = targetCoords.z - entityCoords.z
if zDifference > 1.0 then
playAnimation(entity, "missheist_agency2aig_3", "chat_a_worker2")
elseif animationType == "engine" then
playAnimation(entity, "mini@repair", "fixing_a_ped")
elseif animationType == "kneeling" then
playAnimation(entity, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", true)
end
end
function createEngineHoist(coords)
local engineHoistModelHash = 232216084 -- Engine hoist model hash
local propModelHash = 1450715350 -- Prop model hash
lib.requestModel(engineHoistModelHash, MAX_DISTANCE) -- Request the model
lib.requestModel(propModelHash, MAX_DISTANCE) -- Request the model
-- Create the prop object
local propObject = CreateObject(
propModelHash,
coords.x,
coords.y,
coords.z,
true,
true,
false
)
NetworkSetObjectForceStaticBlend(propObject, true) -- Make the object static
-- Wait for collision to load
while true do
if HasCollisionLoadedAroundEntity(propObject) then
break
end
Wait(1)
end
PlaceObjectOnGroundProperly(propObject)
-- Create the engine hoist object
local engineHoistObject = CreateObject(
engineHoistModelHash,
coords.x,
coords.y,
coords.z,
true,
true,
false
)
NetworkSetObjectForceStaticBlend(engineHoistObject, true) -- Make the object static
-- Wait for collision to load
while true do
if HasCollisionLoadedAroundEntity(engineHoistObject) then
break
end
Wait(1)
end
-- Attach the engine hoist to the prop
AttachEntityToEntity(
engineHoistObject,
propObject,
0,
0.0,
-1.1,
1.25,
0.0,
0.0,
0.0,
false,
false,
true,
false,
2,
true
)
SetEntityCollision(propObject, false, false) -- Disable collision for the prop
SetEntityCanBeDamaged(propObject, false) -- Make the prop undamageable
SetEntityCollision(engineHoistObject, false, true) -- Enable collision for the engine hoist
return propObject, engineHoistObject -- Return both objects
end
function deleteEntities(entity1, entity2)
if entity1 then
DeleteEntity(entity1)
end
if entity2 then
DeleteEntity(entity2)
end
end
swapEngineMinigame = function(vehicle, enginePosition, callback)
local playerPed = cache.ped
local playerCoords = GetEntityCoords(playerPed)
local offset = vector3(1.5, 0.0, 0.0)
TaskLeaveVehicle(playerPed, vehicle, 16) -- Make the player leave the vehicle
-- Set vehicleBonnetDeleted state bag to true
local vehicleEntity = Entity(vehicle)
vehicleEntity.state.set(vehicleEntity, "vehicleBonnetDeleted", true, true)
local propObject, engineHoistObject = createEngineHoist(playerCoords) -- Create the engine hoist and prop
PlaySoundFrontend(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
SetNuiFocus(false, false) -- Disable NUI focus
hideTabletToShowInteractionPrompt(Locale.takeEngineHoistToVehicle) -- Show interaction prompt
CreateThread(function()
while true do
-- Check for cancel key press
if IsControlJustPressed(0, INTERACTION_KEY) then
break
end
if IsControlJustReleased(0, CANCEL_KEY) then
break
end
-- Position the engine hoist in front of the player
local playerCoords = GetEntityCoords(playerPed)
local forwardVector = GetEntityForwardVector(playerPed)
local rightVector = vector3(forwardVector.y, -forwardVector.x, forwardVector.z)
local targetPosition = playerCoords + forwardVector * propObject.x + rightVector * propObject.y
local groundZ = GetGroundZFor_3dCoord(targetPosition.x, targetPosition.y, targetPosition.z, true)
SetEntityCoords(
engineHoistObject,
targetPosition.x,
targetPosition.y,
groundZ,
true,
true,
true,
false
)
-- Rotate the engine hoist to face the player
local angle = math.deg(math.atan((targetPosition.y - playerCoords.y) / (targetPosition.x - playerCoords.x)))
angle = angle - 270.0
if targetPosition.x < playerCoords.x then
angle = angle - 180.0
end
SetEntityRotation(engineHoistObject, 0.0, 0.0, angle, 2, true)
Wait(0)
end
if IsControlJustReleased(0, CANCEL_KEY) then
showTabletAfterInteractionPrompt() -- Show tablet after interaction
stopAnimation(playerPed) -- Stop animation
deleteEntities(engineHoistObject, propObject) -- Delete the entities
local vehicleEntity = Entity(vehicle)
vehicleEntity.state.set(vehicleEntity, "vehicleBonnetDeleted", false, true) -- Reset vehicle state
return callback(false) -- Execute callback with false
end
hideTabletToShowInteractionPrompt(Locale.goToEngineToInstall) -- Show interaction prompt
Wait(100)
PlaySoundFrontend(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
-- Wait for interaction key press near the engine
while true do
if IsControlJustPressed(0, INTERACTION_KEY) then
-- Check if player is near the engine
if isPlayerNearBone(vehicle, { "engine" }) then
break
end
end
if IsControlJustPressed(0, INTERACTION_KEY) then
Framework.Client.Notify(Locale.notNearbyToEngine, "error")
Wait(100)
end
Wait(0)
end
playAnimationBasedOnSituation(playerPed, "engine", vehicle) -- Play animation on the player
Framework.Client.PlaySound("repair", vehicle) -- Play sound
Framework.Client.SkillCheck(
function() -- Success callback
showTabletAfterInteractionPrompt() -- Show tablet after interaction
stopAnimation(playerPed) -- Stop animation
Framework.Client.StopSound(propObject) -- Stop the sound
deleteEntities(engineHoistObject, propObject) -- Delete the entities
local vehicleEntity = Entity(vehicle)
vehicleEntity.state.set(vehicleEntity, "vehicleBonnetDeleted", false, true) -- Reset vehicle state
callback(true) -- Execute callback with true
end,
function() -- Fail callback
showTabletAfterInteractionPrompt() -- Show tablet after interaction
stopAnimation(playerPed) -- Stop animation
Framework.Client.StopSound(propObject) -- Stop the sound
deleteEntities(engineHoistObject, propObject) -- Delete the entities
local vehicleEntity = Entity(vehicle)
vehicleEntity.state.set(vehicleEntity, "vehicleBonnetDeleted", false, true) -- Reset vehicle state
Framework.Client.Notify(Locale.installationFailed, "error") -- Notify failure
callback(false) -- Execute callback with false
end
)
end)
end
local vehicleBonnetDeleted = "vehicleBonnetDeleted"
local emptyString = ""
function onVehicleBonnetDeletedChange(stateBagName, _, deleted)
local entity = GetEntityFromStateBagName(stateBagName)
if entity ~= 0 then
if DoesEntityExist(entity) then
if deleted then
SetVehicleDoorBroken(entity, 4, true) -- Break the hood
else
SetVehicleFixed(entity) -- Fix the vehicle
end
end
end
end
AddStateBagChangeHandler(vehicleBonnetDeleted, emptyString, onVehicleBonnetDeletedChange)
function createObjectFromModel(model, coords)
local modelHash = GetHashKey(model)
lib.requestModel(modelHash, MAX_DISTANCE)
local object = CreateObject(
modelHash,
coords.x,
coords.y,
coords.z,
true,
true,
false
)
NetworkSetObjectForceStaticBlend(object, true)
while true do
if HasCollisionLoadedAroundEntity(object) then
break
end
Wait(1)
end
return object
end
function handleRepairAction(vehicle, interaction, callback)
local repairProp = interaction.prop
if not repairProp then
return callback(false)
end
local playerPed = cache.ped
local playerCoords = GetEntityCoords(playerPed)
TaskLeaveVehicle(playerPed, vehicle, 16)
local interactionBones = {}
local errorLocaleKey = "ERROR"
local animationType = "kneeling"
if repairProp == "wheel" then
interactionBones = { "wheel_lf", "wheel_rf", "wheel_lr", "wheel_rr" }
errorLocaleKey = Locale.notNearWheel
animationType = "kneeling"
local wheelObject = createObjectFromModel("prop_wheel_01", playerCoords)
local boneIndex = 62
AttachEntityToEntity(
wheelObject,
playerPed,
boneIndex,
0.075443142898393,
0.093685241510963,
0.28141744731019,
-172.34215070538,
0,
0,
false,
false,
true,
false,
2,
true
)
Framework.Client.SkillCheck(
function()
DeleteEntity(wheelObject)
callback(true)
end,
function()
DeleteEntity(wheelObject)
Framework.Client.Notify(Locale.installationFailed, "error")
callback(false)
end
)
end
end
LUA
local isTabletShowing = false -- Flag to track tablet visibility
local function swapEngineMinigame(vehicle, interactionZone, callback)
local playerPed = cache.ped -- Get the player's ped
-- Helper function to attach an entity to the player
local function attachEntityToPlayer(entity, boneId, xOffset, yOffset, zOffset, xRotation, yRotation, zRotation)
AttachEntityToEntity(entity, playerPed, boneId, xOffset, yOffset, zOffset, xRotation, yRotation, zRotation, true, true, false, true, 1, true)
end
-- Detach the player from vehicle
TaskLeaveVehicle(playerPed, vehicle, 16)
-- Thread for handling the engine swap minigame logic
CreateThread(function()
local validTargets = {}
validTargets[1] = "engine" -- Only allow interaction with the engine
local notNearbyToEngine = Locale.notNearbyToEngine -- Get locale for the not nearby message
local engineProp = createUsableProp("prop_gascyl_01a", interactionZone) -- Create usable prop for engine
-- Attach the engine prop to the player
attachEntityToPlayer(engineProp, 62, 0.03949541175723, 0.11786201460733, 0.12430043235594, -157.12101467039, 7.9513867036588E-16, 37.736651343458)
-- Play animation for carrying the engine
playAnimation(playerPed, "anim@heists@box_carry@", "idle")
SetVehicleDoorOpen(vehicle, 4, false, false) -- Open vehicle door
-- Display message to take the canister to the engine
hideTabletToShowInteractionPrompt(Locale.takeCanisterToEngine)
-- If the engine prop could not be created
if engineProp == 0 then
showTabletAfterInteractionPrompt() -- Show the tablet
return callback(false) -- Execute callback with fail
end
CreateThread(function()
SetNuiFocus(false, false) -- Disable nui focus
Wait(200)
PlaySoundFrontend(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
-- Wait until the user presses a key
while true do
if IsControlJustPressed(0, selectButton) then
break
end
if IsControlJustReleased(0, cancelButton) then
break
end
Wait(0)
end
-- Loop to install the engine
while true do
if IsControlJustReleased(0, cancelButton) then
break -- Break if the cancel button is pressed
end
-- check if the use pressed select
if IsControlJustPressed(0, selectButton) then
-- Check if the user is close to the engine
if canDoActionOn(vehicle, validTargets) then
break
end
end
-- If the select button is pressed but you can't install due to being too far away
if IsControlJustPressed(0, selectButton) then
Framework.Client.Notify(notNearbyToEngine, "error") -- Notify the user that they aren't close enough
Wait(100)
end
Wait(0)
end
DeleteEntity(engineProp) -- Delete the engine prop
stopAnimation(playerPed) -- Stop animation
-- Check if the user canceled
if IsControlJustReleased(0, cancelButton) then
SetVehicleDoorsShut(vehicle, false) -- Shut the vehicle doors
showTabletAfterInteractionPrompt() -- Show the tablet again
return callback(false) -- Return the fail callback
end
Wait(200)
handleEngineInstall(playerPed, "engine", vehicle) -- handles install engine
Framework.Client.PlaySound("repair", interactionZone) -- plays repair sounds
Framework.Client.SkillCheck(
function() -- Success callback
showTabletAfterInteractionPrompt() -- Show tablet
stopAnimation(playerPed) -- Stop the animation
DeleteEntity(engineProp) -- Delete the engine prop
SetVehicleDoorsShut(vehicle, false) -- Close the doors
Framework.Client.StopSound(installSound) -- Stop the sound
callback(true) -- Success callback
end,
function() -- Fail callback
showTabletAfterInteractionPrompt() -- Show tablet
stopAnimation(playerPed) -- Stop the animation
DeleteEntity(engineProp) -- Delete the engine prop
SetVehicleDoorsShut(vehicle, false) -- Close the doors
Framework.Client.StopSound(installSound) -- stop the install sound
Framework.Client.Notify(Locale.installationFailed, "error") -- Failed skillcheck
callback(false) -- Fail callback
end
)
end)
end)
end
local function paintSprayMinigame(vehicle, interactionZone, callback)
local playerPed = cache.ped -- Get the player's ped
local playerPosition = GetEntityCoords(playerPed) -- Get player position
-- Detach player from the vehicle
TaskLeaveVehicle(playerPed, vehicle, 16)
-- Thread to handle the paint spray
CreateThread(function()
local animationDictionary = "switch@franklin@cleaning_car" -- Switch animation
local animationName = "001946_01_gc_fras_v2_ig_5_base"
local sprayPropModel = "prop_paint_spray01b" -- Spray prop model
local ptfxAsset = "core" -- ptfx asset
local ptfxName = "ent_sht_steam" -- ptfx name
local animationHash = GetHashKey(animationName) -- animation hash
lib.requestAnimDict(animationDictionary) -- Request the cleaning car animation
lib.requestModel(sprayPropModel, isTabletShowing) -- Request the prop model
lib.requestNamedPtfxAsset(ptfxAsset) -- request the ptfx asset
local sprayProp = CreateObject(
GetHashKey(sprayPropModel),
playerPosition.x,
playerPosition.y,
playerPosition.z,
true,
true,
true
)
-- Attach the spray prop to the player
AttachEntityToEntity(
sprayProp,
playerPed,
71,
0.05,
0.0,
-0.02,
0.0,
90.0,
90.0,
true,
true,
false,
true,
1,
true
)
SetNuiFocus(false, false) -- Disable nui focus
hideTabletToShowInteractionPrompt(Locale.pressToRespray) -- show use key bind
Wait(200)
PlaySoundFrontend(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
-- Wait until the user presses a key
while true do
if IsControlJustPressed(0, selectButton) then
break
end
if IsControlJustReleased(0, cancelButton) then
break
end
Wait(0)
end
-- Wait for the interaction to finish
while true do
if IsControlJustReleased(0, cancelButton) then
break -- Break if user cancels
end
-- check is the user presses select
if IsControlJustPressed(0, selectButton) then
local pedPosition = GetEntityCoords(playerPed) -- the the ped coords
local vehiclePosition = GetEntityCoords(vehicle) -- get the vehicle coords
local distance = pedPosition - vehiclePosition -- sub the two
distance = #distance -- get the length of it to see the distance
if not (distance > 4.0) then -- Makes sure that the player is close enough
break
end
end
-- If the select button is pressed but the distance is too great
if IsControlJustPressed(0, selectButton) then
Framework.Client.Notify(Locale.tooFarFromVehicle, "error") -- Tell the user that they are too far away
Wait(100)
end
Wait(0)
end
if IsControlJustReleased(0, cancelButton) then
DeleteObject(sprayProp) -- delete the prop
ClearPedTasksImmediately(playerPed) -- Stop the animation
showTabletAfterInteractionPrompt() -- show the tablet again
return callback(false) -- fail callback
end
Wait(200)
hideTabletToShowInteractionPrompt(Locale.paintEvenlyMsg) -- show prompt to respray
TaskPlayAnim(
playerPed,
animationDictionary,
animationName,
8.0,
-8,
-1,
49,
0,
false,
false,
false
)
CreateThread(function()
for i = 0, 2, 1 do
UseParticleFxAssetNextCall(ptfxAsset)
local ptfx = StartParticleFxLoopedOnEntity(
ptfxName,
sprayProp,
0.0,
0.0,
0.15,
0.0,
0.0,
0.0,
1.0,
false,
false,
false
)
Citizen.Wait(5000)
StopParticleFxLooped(ptfx, false)
end
end)
Framework.Client.ProgressBar(
Locale.resprayingVehicleProgress,
15000,
false,
false,
function() -- Success callback
showTabletAfterInteractionPrompt() -- Show the tablet
DeleteObject(sprayProp) -- delete the prop
ClearPedTasksImmediately(playerPed) -- Stop the animation
callback(true) -- success callback
end,
function() -- Cancel callback
showTabletAfterInteractionPrompt() -- Show the tablet
DeleteObject(sprayProp) -- delete the prop
ClearPedTasksImmediately(playerPed) -- Stop the animation
callback(false) -- fail callback
end
)
end)
end
local function propBasedMinigame(vehicle, interactionZone, callback)
local playerPed = cache.ped -- Get the player's ped
local playerPosition = GetEntityCoords(playerPed) -- Get player position
TaskLeaveVehicle(playerPed, vehicle, 16) -- Leave the car
CreateThread(function()
local animationDictionary = "switch@franklin@cleaning_car" -- cleaning car anim
local animationName = "001946_01_gc_fras_v2_ig_5_base"
local sprayPropModel = "prop_paint_spray01b" -- spray bottle prop
local ptfxAsset = "core"
local ptfxName = "ent_sht_steam"
lib.requestAnimDict(animationDictionary) -- Request the cleaning car animation
lib.requestModel(sprayPropModel, isTabletShowing) -- Request the prop model
lib.requestNamedPtfxAsset(ptfxAsset) -- request the ptfx asset
local sprayProp = CreateObject(
GetHashKey(sprayPropModel),
playerPosition.x,
playerPosition.y,
playerPosition.z,
true,
true,
true
)
AttachEntityToEntity(
sprayProp,
playerPed,
71,
0.05,
0.0,
-0.02,
0.0,
90.0,
90.0,
true,
true,
false,
true,
1,
true
)
SetNuiFocus(false, false) -- Disable nui focus
hideTabletToShowInteractionPrompt(Locale.pressToRespray) -- show use key bind
Wait(200)
PlaySoundFrontend(-1, "CONTINUE", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
-- Wait until the user presses a key
while true do
if IsControlJustPressed(0, selectButton) then
break
end
if IsControlJustReleased(0, cancelButton) then
break
end
Wait(0)
end
-- Wait for the interaction to finish
while true do
if IsControlJustReleased(0, cancelButton) then
break -- Break if user cancels
end
-- check is the user presses select
if IsControlJustPressed(0, selectButton) then
local pedPosition = GetEntityCoords(playerPed) -- the the ped coords
local vehiclePosition = GetEntityCoords(vehicle) -- get the vehicle coords
local distance = pedPosition - vehiclePosition -- sub the two
distance = #distance -- get the length of it to see the distance
if not (distance > 4.0) then -- Makes sure that the player is close enough
break
end
end
-- If the select button is pressed but the distance is too great
if IsControlJustPressed(0, selectButton) then
Framework.Client.Notify(Locale.tooFarFromVehicle, "error") -- Tell the user that they are too far away
Wait(100)
end
Wait(0)
end
if IsControlJustReleased(0, cancelButton) then
DeleteObject(sprayProp) -- delete the prop
ClearPedTasksImmediately(playerPed) -- Stop the animation
showTabletAfterInteractionPrompt() -- show the tablet again
return callback(false) -- fail callback
end
Wait(200)
hideTabletToShowInteractionPrompt(Locale.paintEvenlyMsg) -- show prompt to respray
TaskPlayAnim(
playerPed,
animationDictionary,
animationName,
8.0,
-8,
-1,
49,
0,
false,
false,
false
)
CreateThread(function()
for i = 0, 2, 1 do
UseParticleFxAssetNextCall(ptfxAsset)
local ptfx = StartParticleFxLoopedOnEntity(
ptfxName,
sprayProp,
0.0,
0.0,
0.15,
0.0,
0.0,
0.0,
1.0,
false,
false,
false
)
Citizen.Wait(5000)
StopParticleFxLooped(ptfx, false)
end
end)
Framework.Client.ProgressBar(
Locale.resprayingVehicleProgress,
15000,
false,
false,
function() -- Success callback
showTabletAfterInteractionPrompt() -- Show the tablet
DeleteObject(sprayProp) -- delete the prop
ClearPedTasksImmediately(playerPed) -- Stop the animation
callback(true) -- success callback
end,
function() -- Cancel callback
showTabletAfterInteractionPrompt() -- Show the tablet
DeleteObject(sprayProp) -- delete the prop
ClearPedTasksImmediately(playerPed) -- Stop the animation
callback(false) -- fail callback
end
)
end)
end
local function playMinigame(vehicle, miniGameId, interactionZone, callback)
if not vehicle or vehicle == 0 then
return callback(false) -- exit if the vehicle id is null
end
local miniGameFunction = propBasedMinigame -- set the default function
if miniGameId == "respray" then
miniGameFunction = paintSprayMinigame -- Respray mini game
end
if miniGameId == "engineSwap" then
miniGameFunction = swapEngineMinigame -- the engine swap mini game
end
miniGameFunction(vehicle, interactionZone, callback) -- Run the interaction
end