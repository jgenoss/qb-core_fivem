local currentVehicle = nil
local isFrozen = false
local tempVehicle = nil
local vehicleProperties = {}
local notificationTitle = ""
local propertiesApplied = false
local inProgress = false
local tyresCanBurst = true
local freezePosition = false
local applyMods = false
local modData = {}
local repairModData = {}
modData.repair = repairModData
local performanceModData = {}
modData.performance = performanceModData
local cosmeticsModData = {}
modData.cosmetics = cosmeticsModData
local stanceModData = {}
modData.stance = stanceModData
local resprayModData = {}
modData.respray = resprayModData
local wheelsModData = {}
modData.wheels = wheelsModData
local neonLightsModData = {}
modData.neonLights = neonLightsModData
local headlightsModData = {}
modData.headlights = headlightsModData
local tyreSmokeModData = {}
modData.tyreSmoke = tyreSmokeModData
local bulletproofTyresModData = {}
modData.bulletproofTyres = bulletproofTyresModData
local extrasModData = {}
modData.extras = extrasModData
local function setVehicleState(vehicle, freeze)
if not vehicle then
return
end
SetVehicleEngineOn(vehicle, not freeze, true, true) -- Turn engine off or on
FreezeEntityPosition(vehicle, freeze) -- Freeze or unfreeze position
SetEntityCollision(vehicle, not freeze, not freeze) -- Enable or disable collision
end
local function resetVehicle()
if not currentVehicle then
return
end
ClearPedTasks(cache.ped) -- Clear ped tasks
SetVehicleTyresCanBurst(currentVehicle, tyresCanBurst) -- Reset tyre burst state
SetVehicleCurrentRpm(currentVehicle, 0) -- Reset RPM
FreezeEntityPosition(currentVehicle, true) -- Freeze the vehicle
SetEntityCollision(currentVehicle, false, false) -- Disable vehicle collision
SetVehicleEngineOn(currentVehicle, false, true, true) -- Turn engine off
inProgress = false
end
local function applyVehicleMods()
if not currentVehicle then
return
end
if propertiesApplied then
return
end
setVehicleProperties(currentVehicle, vehicleProperties, true)
end
local function getModSlotLocalizedName(vehicle, modSlot)
local modType = type(modSlot)
if "string" == modType then
return false -- Return false if modSlot is a string
end
local label = GetLabelText(GetModSlotName(vehicle, modSlot)) -- Get the label text for the mod slot
if "NULL" ~= label then
return label -- Return the label if it's not null
end
local modSlotName = GetModSlotName(vehicle, modSlot) -- Get the mod slot name
if modSlotName and "" ~= modSlotName then
return modSlotName -- Return the mod slot name if it exists and is not empty
end
return false -- Return false if no name is found
end
local function getModLocalizedText(vehicle, modType, defaultName, modIndex)
if "LIVERY" == modType then -- Check if the modification type is "LIVERY"
local liveryName = GetLabelText(GetLiveryName(vehicle, modIndex)) -- Get the localized name for the livery
if "NULL" ~= liveryName then
return liveryName -- Return the localized name if it's not "NULL"
end
end
local modTypeType = type(modType)
if "string" == modTypeType then
return "ERROR" -- Return "ERROR" if modType is a string
end
local modTextLabel = GetLabelText(GetModTextLabel(vehicle, modType, modIndex)) -- Get the localized text label for the modification
if "NULL" ~= modTextLabel then
return modTextLabel -- Return the localized text label if it's not "NULL"
end
local modText = GetModTextLabel(vehicle, modType, modIndex) -- Get the modification text label
if modText and "" ~= modText then
return modText -- Return the modification text label if it exists and is not empty
end
defaultName = defaultName or defaultName -- Keep or initialize defaultName
if not defaultName then
defaultName = ""
end
local localizedText = " "
local newIndex = modIndex + 1
defaultName = defaultName .. localizedText .. newIndex -- Append the index to the name
return defaultName -- Return the default name with the appended index
end
local function stringExistsInTable(tableToCheck, vehicle, stringToCheck)
for index, value in ipairs(tableToCheck) do
if stringToCheck == value then
return true -- String exists in the table
else
local valueType = type(value)
if "string" == valueType then
local stringToCheckType = type(stringToCheck)
if "number" == stringToCheckType then
local modSlotName = GetModSlotName(vehicle, stringToCheck)
if modSlotName == value then
return true
end
end
end
end
end
return false -- String does not exist in the table
end
local function getAvailableVehicleMods(vehicle, mechanicLocationIndex)
local locationConfig = Config.MechanicLocations[mechanicLocationIndex]
local modsConfig = locationConfig.mods
if not modsConfig then
return false
end
-- Apply prices as a percentage of vehicle value if enabled
if Config.ModsPricesAsPercentageOfVehicleValue then
local vehicleValue = Framework.Client.GetVehicleValue(GetEntityArchetypeName(vehicle))
for modCategory, modDetails in pairs(modsConfig) do
local modPercent = modDetails.percentVehVal
if not modPercent then
modPercent = 0.01
end
local price = round(vehicleValue * modPercent, 0)
modDetails.price = price
end
end
local vehicleModelHash = GetEntityModel(vehicle) -- Get vehicle model hash
SetVehicleModKit(vehicle, 0) -- Set vehicle mod kit
local availableMods = {}
-- Iterate through performance mods
for _, modDetails in pairs(Config.Mods.Performance) do
local numMods = GetNumVehicleMods(vehicle, modDetails.modType)
if not (numMods > 0) then
if not modDetails.toggle then
goto continue_performance_loop
end
end
local localizedName = getModSlotLocalizedName(vehicle, modDetails.modType)
if not localizedName then
localizedName = modDetails.name
end
local modOptions = {}
modOptions[1] = {modIndex = -1, name = "Stock"}
-- Handle override options if provided
if modDetails.overrideOptions then
local overrideOptionsType = type(modDetails.overrideOptions)
if "table" == overrideOptionsType then
for _, overrideOptionDetails in pairs(modDetails.overrideOptions) do
local newOptionIndex = #modOptions + 1
local newOption = {}
newOption.modIndex = overrideOptionDetails.modIndex
newOption.name = overrideOptionDetails.name
local price = overrideOptionDetails.price
if not price then
price = round(modsConfig.performance.price * (overrideOptionDetails.modIndex > 0 and (1 + overrideOptionDetails.modIndex * (modsConfig.performance.priceMult or 0)) or 1), 0)
end
newOption.price = price
modOptions[newOptionIndex] = newOption
end
end
else
-- Add default options
for modIndex = 0, numMods - 1 do
local newOptionIndex = #modOptions + 1
local newOption = {}
newOption.modIndex = modIndex
newOption.name = getModLocalizedText(vehicle, modDetails.modType, localizedName, modIndex)
local price = round(modsConfig.performance.price * (modIndex > 0 and (1 + modIndex * (modsConfig.performance.priceMult or 0)) or 1), 0)
newOption.price = price
modOptions[newOptionIndex] = newOption
end
end
-- Add mod details to available mods
local newAvailableModIndex = #availableMods + 1
local newAvailableMod = {}
newAvailableMod.modType = modDetails.modType
newAvailableMod.name = localizedName
newAvailableMod.mods = modOptions
newAvailableMod.toggle = modDetails.toggle
newAvailableMod.price = modsConfig.performance.price
availableMods[newAvailableModIndex] = newAvailableMod
::continue_performance_loop::
end
local cosmeticsMods = {}
-- Iterate through cosmetic mods
for _, modDetails in pairs(Config.Mods.Cosmetics) do
local modName = modDetails.name
local ignorePriceMult = modDetails.ignorePriceMult
local cosmeticsModOptions = {}
local modType = modDetails.modType
if "PLATE_INDEX" == modType then
-- Handle license plate index
if IsThisModelACar(vehicleModelHash) or IsThisModelAQuadbike(vehicleModelHash) or IsThisModelABike(vehicleModelHash) then
local startIndex = 1
local endIndex = #Config.Mods.PlateIndexes
for plateIndex = startIndex, endIndex do
if not (plateIndex < 6) then
if not (plateIndex >= 6) then
goto continue_plate_index_loop
end
if not (GetGameBuildNumber() >= 3095) then
goto continue_plate_index_loop
end
end
local newOptionIndex = #cosmeticsModOptions + 1
local newOption = Config.Mods.PlateIndexes[plateIndex]
cosmeticsModOptions[newOptionIndex] = newOption
local newCosmeticsOption = cosmeticsModOptions[plateIndex]
if ignorePriceMult then
local price = modsConfig.cosmetics.price
if price then
goto continue_plate_index_price_check
end
end
local price = round(modsConfig.cosmetics.price * (plateIndex > 0 and (1 + plateIndex * (modsConfig.cosmetics.priceMult or 0)) or 1), 0)
::continue_plate_index_price_check::
newCosmeticsOption.price = price
::continue_plate_index_loop::
end
end
elseif "WINDOW_TINT" == modType then
-- Handle window tint
if not IsThisModelABicycle(vehicleModelHash) then
local startIndex = 1
local endIndex = #Config.Mods.WindowTints
for windowTintIndex = startIndex, endIndex do
local newOptionIndex = #cosmeticsModOptions + 1
local newOption = Config.Mods.WindowTints[windowTintIndex]
cosmeticsModOptions[newOptionIndex] = newOption
local newCosmeticsOption = cosmeticsModOptions[windowTintIndex]
if ignorePriceMult then
local price = modsConfig.cosmetics.price
if price then
goto continue_window_tint_price_check
end
end
local price = round(modsConfig.cosmetics.price * (windowTintIndex > 0 and (1 + windowTintIndex * (modsConfig.cosmetics.priceMult or 0)) or 1), 0)
::continue_window_tint_price_check::
newCosmeticsOption.price = price
end
end
else
local numMods = 0
-- Get the number of mods depending on the mod type
if "LIVERY" == modType then
numMods = GetVehicleLiveryCount(vehicle)
elseif "LIVERY_ROOF" == modType then
numMods = GetVehicleRoofLiveryCount(vehicle)
else
numMods = GetNumVehicleMods(vehicle, modType)
end
if not (numMods > 0) then
if not modDetails.toggle then
goto continue_cosmetics_loop
end
end
local localizedName = getModSlotLocalizedName(vehicle, modType)
modName = localizedName or modName
if not localizedName then
modName = modDetails.name
end
if 14 == modType then
-- Handle horns
local startIndex = 1
local endIndex = #Config.Mods.Horns
for hornIndex = startIndex, endIndex do
local newOptionIndex = #cosmeticsModOptions + 1
local newOption = Config.Mods.Horns[hornIndex]
cosmeticsModOptions[newOptionIndex] = newOption
local newCosmeticsOption = cosmeticsModOptions[hornIndex]
if ignorePriceMult then
local price = modsConfig.cosmetics.price
if price then
goto continue_horn_index_price_check
end
end
local price = round(modsConfig.cosmetics.price * (hornIndex > 0 and (1 + hornIndex * (modsConfig.cosmetics.priceMult or 0)) or 1), 0)
::continue_horn_index_price_check::
newCosmeticsOption.price = price
end
goto continue_cosmetics_add_to_main_table
else
-- Default mods
for modIndex = -1, numMods - 1 do
local newOptionIndex = #cosmeticsModOptions + 1
local newOption = {}
newOption.modIndex = modIndex
if modIndex == -1 then
newOption.name = "Stock"
else
newOption.name = getModLocalizedText(vehicle, modType, modName, modIndex)
end
if ignorePriceMult then
local price = modsConfig.cosmetics.price
if price then
goto continue_index_price_check
end
end
local price = round(modsConfig.cosmetics.price * (modIndex > 0 and (1 + modIndex * (modsConfig.cosmetics.priceMult or 0)) or 1), 0)
::continue_index_price_check::
newOption.price = price
cosmeticsModOptions[newOptionIndex] = newOption
end
end
end
::continue_cosmetics_add_to_main_table::
local newCosmeticsModIndex = #cosmeticsMods + 1
local newCosmeticsMod = {}
newCosmeticsMod.modType = modType
newCosmeticsMod.name = modName
newCosmeticsMod.options = cosmeticsModOptions
cosmeticsMods[newCosmeticsModIndex] = newCosmeticsMod
::continue_cosmetics_loop::
end
-- Populate stance options
local stanceModOptions = {}
local newStanceModIndex = #stanceModOptions + 1
stanceModOptions[newStanceModIndex] = {name = "Default", value = {1.0, 1.0, 1.0, 1.0}}
local newStanceModIndex = #stanceModOptions + 1
stanceModOptions[newStanceModIndex] = {name = "Max Low", value = {0.75, 0.75, 0.75, 0.75}}
local newStanceModIndex = #stanceModOptions + 1
stanceModOptions[newStanceModIndex] = {name = "Low", value = {0.85, 0.85, 0.85, 0.85}}
local newStanceModIndex = #stanceModOptions + 1
stanceModOptions[newStanceModIndex] = {name = "Medium Low", value = {0.925, 0.925, 0.925, 0.925}}
-- Populate repair option
local repairMods = {}
local newRepairModIndex = #repairMods + 1
repairMods[newRepairModIndex] = {name = "Repair", price = modsConfig.repair.price}
-- Populate extras option
local extrasMods = {}
local extraCount = GetVehicleNumberOfExtras(vehicle)
for extraId = 1, extraCount do
local newExtraModIndex = #extrasMods + 1
extrasMods[newExtraModIndex] = {id = extraId}
end
local colors = {}
colors[1] = {name = "Primary", type = 0}
colors[2] = {name = "Secondary", type = 1}
colors[3] = {name = "Pearl", type = 2}
colors[4] = {name = "Wheel", type = 3}
local neonColors = {}
neonColors[1] = {name = "Red", color = {255, 0, 0}}
neonColors[2] = {name = "Blue", color = {0, 0, 255}}
neonColors[3] = {name = "Green", color = {0, 255, 0}}
neonColors[4] = {name = "Yellow", color = {255, 255, 0}}
neonColors[5] = {name = "Purple", color = {255, 0, 255}}
neonColors[6] = {name = "Cyan", color = {0, 255, 255}}
neonColors[7] = {name = "White", color = {255, 255, 255}}
neonColors[8] = {name = "Off", color = {0, 0, 0}}
local headlightColors = {}
headlightColors[1] = {name = "Stock", color = {255, 255, 255}}
headlightColors[2] = {name = "Xenon", color = {190, 212, 255}}
headlightColors[3] = {name = "Blue", color = {0, 0, 255}}
headlightColors[4] = {name = "Red", color = {255, 0, 0}}
local tyreSmokeColors = {}
tyreSmokeColors[1] = {name = "Red", color = {255, 0, 0}}
tyreSmokeColors[2] = {name = "Blue", color = {0, 0, 255}}
tyreSmokeColors[3] = {name = "Green", color = {0, 255, 0}}
tyreSmokeColors[4] = {name = "Yellow", color = {255, 255, 0}}
tyreSmokeColors[5] = {name = "Purple", color = {255, 0, 255}}
tyreSmokeColors[6] = {name = "Cyan", color = {0, 255, 255}}
tyreSmokeColors[7] = {name = "White", color = {255, 255, 255}}
tyreSmokeColors[8] = {name = "Black", color = {0, 0, 0}}
return {
performance = availableMods,
cosmetics = cosmeticsMods,
stance = stanceModOptions,
repair = repairMods,
colors = colors,
neonColors = neonColors,
headlightColors = headlightColors,
tyreSmokeColors = tyreSmokeColors,
extras = extrasMods,
}
end
local function GetVehicleModifications(vehicle, vehicleProperties, mechanicLocation)
local modifications = {} -- Table to store all available modifications.
local vehicleModelHash = GetEntityModel(vehicle)
local vehicleClass = GetVehicleClass(vehicle)
local vehicleHandlingDataId = GetVehicleHandlingId(vehicle)
local vehicleConfig = Config.Vehicles[vehicleModelHash] -- Specific config for the vehicle model.
if not vehicleConfig then
vehicleConfig = Config.Classes[vehicleClass] -- Fallback to class config if model specific config is missing.
if not vehicleConfig then
vehicleConfig = Config.Default -- Fallback to default if class config is missing.
end
end
local modCategories = vehicleConfig.Mods -- Get modification categories from the config.
-- Loop through each modification category.
for _, modCategory in ipairs(modCategories) do
local modType = modCategory.modType
local modName = modCategory.name
-- Get localized name
if Config.UseCustomNamesInTuningMenu and modCategory.name then
modName = modCategory.name
else
modName = GetVehicleModName(vehicle, modType, modName, -1) -- Get localized name of modification.
end
local modsList = {} -- Table to store individual mods within the category.
local numberOfMods = GetNumVehicleMods(vehicle, modType) -- Get the number of mods available for this type.
-- Add Stock option.
local stockMod = {}
stockMod.modIndex = -1
stockMod.name = "Stock"
modsList[1] = stockMod
-- Loop through the available mods for the current category.
for modIndex = 0, numberOfMods - 1 do
local mod = {}
mod.modIndex = modIndex
if Config.UseCustomNamesInTuningMenu and modCategory.name then
modName = modCategory.name
else
modName = GetVehicleModName(vehicle, modType, modName, modIndex) -- Get mod name for this index.
end
mod.name = modName
-- Calculate price for each mod.
local modPrice = vehicleConfig.cosmetics.price
if modIndex > 0 then
local priceMultiplier = vehicleConfig.cosmetics.priceMult or 0
modPrice = modPrice * (1 + (modIndex * priceMultiplier))
end
mod.price = round(modPrice, 0)
-- Add the mod to the list.
modsList[#modsList + 1] = mod
end
-- If there are any mods in the category, add it to the overall modification list.
if #modsList > 0 then
local category = {}
category.modType = modType
category.name = modName
category.mods = modsList
category.toggle = modCategory.toggle -- Does the mod require a toggle
category.price = vehicleConfig.cosmetics.price
modifications[#modifications + 1] = category
end
end
local wheelTypes = {}
local isCar = IsThisModelACar(vehicleModelHash)
local isQuadbike = IsThisModelAQuadbike(vehicleModelHash)
local isBike = IsThisModelABike(vehicleModelHash)
-- Wheel types
if isCar or isQuadbike or isBike then
for _, wheelType in ipairs(Config.Mods.WheelTypes) do
local isValidWheelType = true
-- Check if the wheel type applies to the vehicle type
if isBike and wheelType.modIndex ~= 6 then
isValidWheelType = false
end
if isValidWheelType then
-- Apply current wheel type
SetVehicleWheelType(vehicle, wheelType.modIndex)
local wheelMods = {}
local numberOfWheelMods = GetNumVehicleMods(vehicle, 23) -- Wheel mods are type 23.
-- Add stock wheels
local stockWheel = {}
stockWheel.modIndex = -1
stockWheel.name = "Stock"
wheelMods[1] = stockWheel
-- Loop through the available wheel mods
for modIndex = 0, numberOfWheelMods - 1 do
local wheelMod = {}
wheelMod.modIndex = modIndex
wheelMod.name = GetVehicleModName(vehicle, 23, wheelType.name, modIndex)
local wheelPrice = vehicleConfig.wheels.price
if modIndex > 0 then
local priceMultiplier = vehicleConfig.wheels.priceMult or 0
wheelPrice = wheelPrice * (1 + (modIndex * priceMultiplier))
end
wheelMod.price = round(wheelPrice, 0)
wheelMods[#wheelMods + 1] = wheelMod
end
-- Add to wheel types list
local wheelCategory = {}
wheelCategory.modType = wheelType.modIndex
wheelCategory.name = wheelType.name
wheelCategory.mods = wheelMods
wheelTypes[#wheelTypes + 1] = wheelCategory
end
end
end
-- Restore original wheel type
SetVehicleWheelType(vehicle, vehicleProperties.wheels)
-- Apply front wheel mod
if vehicleProperties.modFrontWheels then
SetVehicleMod(vehicle, 23, vehicleProperties.modFrontWheels, vehicleProperties.modCustomTiresF)
end
-- Apply rear wheel mod
if vehicleProperties.modBackWheels then
SetVehicleMod(vehicle, 24, vehicleProperties.modBackWheels, vehicleProperties.modCustomTiresR)
end
-- Construct data to be sent to the client
local clientData = {}
clientData.repair = vehicleConfig.repair.enabled and vehicleConfig.repair or nil
clientData.performance = vehicleConfig.performance.enabled and modifications or nil
clientData.cosmetics = vehicleConfig.cosmetics.enabled and modifications or nil
clientData.stance = isCar and vehicleConfig.stance.enabled and vehicleConfig.stance or nil
-- Respray options
clientData.respray = vehicleConfig.respray.enabled and (#Config.Mods.Colours > 0 and { price = vehicleConfig.respray.price, colours = Config.Mods.Colours } or nil) or nil
-- Wheels options
clientData.wheels = vehicleConfig.wheels.enabled and wheelTypes or nil
-- Neon light options
clientData.neonLights = (isCar or isQuadbike) and vehicleConfig.neonLights.enabled and vehicleConfig.neonLights or nil
-- Headlight options (Bicycle)
clientData.headlights = IsThisModelABicycle(vehicleModelHash) and vehicleConfig.headlights.enabled or nil
-- Tyre smoke
clientData.tyreSmoke = (isCar or isBike or isQuadbike) and vehicleConfig.tyreSmoke.enabled and vehicleConfig.tyreSmoke or nil
-- Bulletproof tyres
clientData.bulletproofTyres = (isCar or isBike or isQuadbike) and vehicleConfig.bulletproofTyres.enabled and vehicleConfig.bulletproofTyres or nil
-- Extras
clientData.extras = vehicleConfig.extras.enabled and next(vehicleProperties.extras) ~= nil
return clientData
end
function CloseMechanicMenu()
if currentlySelectedVehicle then
-- Restore client data
Client.RestoreModifications(currentlySelectedVehicle, false)
RestoreVehicleCamera(currentlySelectedVehicle)
Framework.Client.ToggleHud(true)
local vehicleEntity = Entity(currentlySelectedVehicle)
vehicleEntity.state.set(vehicleEntity, "unpaidModifications", false, true)
end
SetNuiFocusKeepInput(false)
Framework.Client.ToggleHud(true)
LocalPlayer.state.set(LocalPlayer, "isBusy", false, true)
-- Reset UI data
repairOptions = {}
performanceOptions = {}
cosmeticOptions = {}
stanceOptions = {}
resprayOptions = {}
wheelOptions = {}
neonLightOptions = {}
headlightOptions = {}
tyreSmokeOptions = {}
bulletproofTyreOptions = {}
extraOptions = {}
isMechanicEmployee = false
selectedLocation = nil
vehicleProps = nil
vehiclePlate = nil
bulletProofTyres = false
end
function OpenMechanicMenu(mechanicLocation, mechanicData)
local locationConfig = Config.MechanicLocations[mechanicLocation]
if not locationConfig then
return false
end
selectedLocation = mechanicLocation
-- Check if vehicle exists
if not cache.vehicle then
return false
end
local vehicle = cache.vehicle
currentlySelectedVehicle = vehicle
-- Check if the player is in the driver's seat.
local driverPed = GetPedInVehicleSeat(vehicle, -1)
if driverPed ~= cache.ped then
Framework.Client.Notify(Locale.notInDriversSeat, "error")
currentlySelectedVehicle = nil
return false
end
-- Store current vehicle data for repair purposes
local vehicleData = {}
vehicleData[1] = GetVehicleBodyHealth(vehicle)
local engineHealth, a, b, c, d, e, f, g, h = GetVehicleEngineHealth(vehicle)
vehicleData[2] = engineHealth
vehicleData[3] = a
vehicleData[4] = b
vehicleData[5] = c
vehicleData[6] = d
vehicleData[7] = e
vehicleData[8] = f
vehicleData[9] = g
vehicleData[10] = h
-- Retrieve current vehicle properties for mod reset
vehicleProps = getVehicleProperties(vehicle, true)
if not vehicleProps then
error("Could not get the vehicle's props")
end
vehiclePlate = Framework.Client.GetPlate(vehicle)
if not vehiclePlate then
error("Could not get the vehicle's plate")
end
bulletProofTyres = not vehicleProps.bulletProofTyres
vehicleProps.windowTint = math.max(vehicleProps.windowTint, 0)
-- Get available modifications.
local availableMods = GetVehicleModifications(vehicle, vehicleProps, mechanicLocation)
-- Check if passengers are in the vehicle.
for seatIndex = 0, 5 do
local passengerPed = GetPedInVehicleSeat(vehicle, seatIndex)
if passengerPed ~= 0 then
Framework.Client.Notify(Locale.passengersMustLeaveVehicleFirst, "error")
return false
end
end
-- Make the car invulnerable.
Client.SetVehicleInvulnerable(vehicle, true)
SetVehicleModKit(vehicle, 0)
-- Setup camera.
setupVehicleCamera(vehicle)
-- Open the UI
if Config.ChangePlateDuringPreview then
local serverData = VehToNet(vehicle)
lib.callback.await("jg-mechanic:server:open-mods-menu", false, serverData)
end
isMechanicEmployee = lib.callback.await("jg-mechanic:server:is-mechanic-employee", false, mechanicLocation)
if isMechanicEmployee then
local MechanicItems = Config.MechanicItems
lib.register.openMenu("mechanic_menu", mechanicData, MechanicItems, mechanicLocation, availableMods, vehicleProps, vehiclePlate, bulletProofTyres, vehicleData)
else
local CitizenItems = Config.CitizenItems
lib.register.openMenu("mechanic_menu", mechanicData, CitizenItems, mechanicLocation, availableMods, vehicleProps, vehiclePlate, bulletProofTyres, vehicleData)
end
LocalPlayer.state.set(LocalPlayer, "isBusy", true, true)
return true
end
local VehicleEntity = nil -- Cache the vehicle entity
local VehicleNetworkId = nil -- Cache the vehicle network ID
local CurrentMechanicLocation = nil -- Cache current mechanic location ID
local CurrentVehicleProps = nil -- Cache the current vehicle props
local function openCustomizationMenu(mechanicLocationId, mechanicName)
if not cache.vehicle then
return false -- Exit if no vehicle is cached
end
CreateThread(function()
local showTextUI = true -- Flag to control the display of the text UI
local menuOpen = false
while true do
Wait(0)
if not showTextUI then
break -- Exit the loop if showTextUI is false
end
if not menuOpen then
Framework.Client.ShowTextUI(Config.CustomiseVehiclePrompt) -- Display prompt if menu is not open
showTextUI = true
end
if IsControlJustPressed(0, Config.CustomiseVehicleKey) then
if not menuOpen then
local success = openCustomizationMenu(mechanicLocationId, mechanicName) -- Try opening the menu
if success then
showTextUI = false -- Hide the text UI
menuOpen = true
Framework.Client.HideTextUI()
end
end
end
end
end)
end
RegisterNetEvent("jg-mechanic:client:open-customisation-menu", openCustomizationMenu)
local function onEnterModsZone(mechanicLocationId, vehicleNetworkId)
local vehicle = cache.vehicle
if not vehicle then
return false
end
VehicleNetworkId = vehicleNetworkId
CurrentMechanicLocation = mechanicLocationId
CreateThread(function()
local showTextUI = true -- Flag to control the display of the text UI
local menuOpen = false
while true do
Wait(0)
if not showTextUI then
break -- Exit the loop if showTextUI is false
end
if not menuOpen then
Framework.Client.ShowTextUI(Config.CustomiseVehiclePrompt) -- Display prompt if menu is not open
showTextUI = true
end
if IsControlJustPressed(0, Config.CustomiseVehicleKey) then
if not menuOpen then
local success = openCustomizationMenu(mechanicLocationId, vehicleNetworkId) -- Try opening the menu
if success then
showTextUI = false -- Hide the text UI
menuOpen = true
Framework.Client.HideTextUI()
end
end
end
end
end)
end
local function onExitModsZone()
CurrentMechanicLocation = nil -- Reset the mechanic location
hideCamera()
SetTimeout(1, function()
Framework.Client.HideTextUI()
end)
end
local function purchaseMods(data, callback)
-- Check if essential variables are set.
if not (VehicleNetworkId and VehicleEntity and CurrentVehicleProps and VehicleEntity) then
callback({error = true})
return
end
local cart = data.cart
local paymentMethod = data.paymentMethod
-- Validate the cart.
if not (cart and type(cart) == "table") then
callback({error = true})
return
end
-- Fetch mechanic location config.
local mechanicLocation = Config.MechanicLocations[CurrentMechanicLocation]
if not mechanicLocation then
callback({error = false})
return
end
-- Get vehicle properties.
local vehicleProperties = getVehicleProperties(VehicleEntity, true)
vehicleProperties.plate = VehicleNetworkId
if not vehicleProperties then
callback({error = false})
return
end
-- Get vehicle value.
local vehicleValue = Framework.Client.GetVehicleValue(GetEntityArchetypeName(VehicleEntity))
-- Purchase mods from server.
local purchaseResult = lib.callback.await("jg-mechanic:server:purchase-mods", false, CurrentMechanicLocation, vehicleValue, cart, paymentMethod)
if purchaseResult == false then
callback({error = true})
return
end
-- Check if the player is a mechanic employee.
local isMechanicEmployee = lib.callback.await("jg-mechanic:server:is-mechanic-employee", false, CurrentMechanicLocation)
-- Handle self-service mods.
if mechanicLocation.type ~= "self-service" or not (Config.MechanicEmployeesCanSelfServiceMods and isMechanicEmployee) then
-- Place order on server
local placeOrderSuccessful = lib.callback.await("jg-mechanic:server:place-order", false, CurrentMechanicLocation, VehicleNetworkId, cart, purchaseResult, PropStateBags, paymentMethod)
if not placeOrderSuccessful then
callback({error = true})
return
end
else
-- Apply self service mods.
applySkin(VehicleEntity, false)
local appliedProps = {}
for k, v in pairs(PropStateBags) do
appliedProps = table.concat(appliedProps, v)
end
setStatebagsFromProps(VehicleEntity, appliedProps, VehicleNetworkId)
lib.callback.await("jg-mechanic:server:save-veh-statebag-data-to-db", false, VehicleNetworkId)
local modsApplied = true -- Flag if mods are applied
lib.callback.await("jg-mechanic:server:self-service-mods-applied", false, CurrentMechanicLocation, VehToNet(VehicleEntity), VehicleNetworkId, cart, purchaseResult, paymentMethod)
-- Save vehicle props.
if Config.UpdatePropsOnChange then
lib.callback.await("jg-mechanic:server:save-vehicle-props", false, VehicleNetworkId, vehicleProperties)
end
-- Update local props if available.
if CurrentVehicleProps and vehicleProperties then
CurrentVehicleProps.wheels = vehicleProperties.wheels
CurrentVehicleProps.modFrontWheels = vehicleProperties.modFrontWheels
CurrentVehicleProps.modBackWheels = vehicleProperties.modBackWheels
end
end
callback(true)
end
RegisterNUICallback("purchase-mods", purchaseMods)
local function exitMods(data, callback)
hideCamera() -- Hide the camera
callback(true)
end
RegisterNUICallback("exit-mods", exitMods)
local function switchCamera(data, callback)
-- Validate if the vehicle entity exists.
if not VehicleEntity then
callback(false)
return
end
local modId = data and data.modId
CreateThread(function()
-- Close any open doors before switching camera
SetVehicleDoorsShut(VehicleEntity, true)
if IsVehicleDoorDamaged(VehicleEntity, 4) then
SetVehicleFixed(VehicleEntity)
end
hideCamera()
-- Define the camera positions and their corresponding mod categories
local cameraPositions = {
{
categories = {"TOP_HL_CV", "TOP_HLT", "TOP_SUNST", "HEADLIGHTS", "TOP_SPLIT"},
camera = "frontCamera"
},
{
categories = {"TOP_TRUNK", "TOP_BOOT", "TOP_TGATE", "TOP_RPNL", "TOP_WINP", "TOP_WBAR", "TOP_COVER", "TOP_LOUV"},
camera = "backCamera"
},
{
categories = {"TOP_CAGE"},
camera = "interior"
},
{
categories = {"TOP_ROOFSC", "TOP_ROOFFIN"},
camera = "roof"
},
{
categories = {"TOP_VALHD", "TOP_ENGHD"},
camera = "backCamera",
openDoor = true
},
{
categories = {"TOP_SIDE_PAN", "TOP_MIR"},
camera = "sideCamera"
},
{
categories = {"TOP_CATCH"},
camera = "engineBay"
},
{
categories = {"TOP_ENGINE", "TOP_BRACE", "TOP_ENGD"},
camera = "engineBay",
repairDoor = true,
openDoor = true
},
{
categories = {1, 6, 26, 42, 43},
camera = "frontCamera"
},
{
categories = {37},
camera = "backCamera",
openDoor = 5
},
}
-- Find the correct camera position based on the current mod and then transition to that camera.
for _, pos in ipairs(cameraPositions) do
if doesVehicleHaveAssociatedTop(pos.categories, VehicleEntity, modId) then
transitionCamera(pos.camera)
if pos.openDoor then
SetVehicleDoorOpen(VehicleEntity, pos.openDoor, false, true)
end
if pos.repairDoor then
local modelName = GetEntityArchetypeName(VehicleEntity)
if "z190" == modelName then
SetVehicleDoorBroken(VehicleEntity, 4, true)
end
SetVehicleDoorOpen(VehicleEntity, 4, false, true)
end
return
end
end
end)
callback(true)
end
RegisterNUICallback("switch-camera", switchCamera)
RegisterNUICallback = RegisterNUICallback
local toggleFreecamEvent = "toggle-freecam"
function ToggleFreecam(eventData, callback)
local enable = eventData.enable
if enable then
-- Enable freecam
isFreecamEnabled = true
ToggleCamTemporarily(false) -- Disable temporary camera
else
-- Disable freecam
ToggleCamTemporarily(true) -- Enable temporary camera
isFreecamEnabled = false
end
callback(true) -- Acknowledge the callback
end
RegisterNUICallback(toggleFreecamEvent, ToggleFreecam)
local moveFreecamEvent = "move-freecam"
function MoveFreecam(eventData, callback)
if not isFreecamEnabled then
-- Freecam is not enabled, so return.
callback(false)
return
end
-- Set focus to NUI, allowing input.
SetNuiFocus(true, false)
SetNuiFocusKeepInput(true)
-- Create a thread to handle control actions while in freecam.
CreateThread(function()
while true do
if not isFreecamEnabled then
break -- Exit loop if freecam is disabled.
end
-- Disable default control actions.
DisableAllControlActions(0)
-- Re-enable necessary controls.
EnableControlAction(0, 0, false) -- INPUT_LOOK_LR
EnableControlAction(0, 1, true)  -- INPUT_LOOK_UD
EnableControlAction(0, 2, true)  -- INPUT_SELECT_WEAPON
EnableControlAction(0, 59, true) -- INPUT_WHEEL_MOD_MENU
Wait(0)
end
end)
callback(true) -- Acknowledge the callback.
end
RegisterNUICallback(moveFreecamEvent, MoveFreecam)
local stopMoveFreecamEvent = "stop-moving-freecam"
function StopMovingFreecam(eventData, callback)
-- Restore NUI focus.
SetNuiFocus(true, true)
SetNuiFocusKeepInput(false)
callback(true) -- Acknowledge the callback.
end
RegisterNUICallback(stopMoveFreecamEvent, StopMovingFreecam)
local repairVehicleEvent = "repair-vehicle"
function RepairVehicle(eventData, callback)
local vehicle = selectedVehicle
if not vehicle then
callback(false)
return
end
-- Get vehicle value from the server.
local vehicleModel = GetEntityArchetypeName(vehicle)
local vehicleValue = Framework.Client.GetVehicleValue(vehicleModel)
-- Await server response.
local success = lib.callback.await("jg-mechanic:server:self-service-repair-vehicle", false, Framework.Config, vehicleValue, eventData and eventData.paymentMethod)
if success then
-- Repair the vehicle.
Framework.Client.RepairVehicle(vehicle)
-- Reset vehicle health and appearance data.
if vehicleData then
vehicleData.dirtLevel = 0.0
vehicleData.engineHealth = 1000.0
vehicleData.bodyHealth = 1000.0
vehicleData.tankHealth = 1000.0
vehicleData.windowStatus = nil
vehicleData.doorStatus = nil
vehicleData.tireHealth = nil
vehicleData.tireBurstState = nil
vehicleData.tireBurstCompletely = nil
vehicleData.windowsBroken = nil
vehicleData.doorsBroken = nil
vehicleData.tyreBurst = nil
end
end
callback(true) -- Acknowledge the callback.
end
RegisterNUICallback(repairVehicleEvent, RepairVehicle)
local previewPerformanceModEvent = "preview-performance-mod"
function PreviewPerformanceMod(eventData, callback)
local vehicle = selectedVehicle
if not vehicle then
callback(false)
return
end
-- Set the "unpaidModifications" state on the vehicle.
local entityState = Entity(vehicle).state
entityState.set(entityState, "unpaidModifications", true, true)
local propKey = eventData.propKey
local modType = eventData.modType
local modIndex = eventData.modIndex
local toggleMod = eventData.toggleMod
SetVehicleModKit(vehicle, 0)
if toggleMod then
-- Toggle the vehicle modification.
ToggleVehicleMod(vehicle, modType, modIndex)
vehicleModData.performance[propKey] = modIndex
else
-- Apply vehicle modification based on type.
if type(modType) == "number" then
SetVehicleMod(vehicle, modType, modIndex, false)
vehicleModData.performance[propKey] = modIndex
end
end
callback(true) -- Acknowledge the callback.
end
RegisterNUICallback(previewPerformanceModEvent, PreviewPerformanceMod)
local previewCosmeticModEvent = "preview-cosmetic-mod"
function PreviewCosmeticMod(eventData, callback)
local vehicle = selectedVehicle
if not vehicle then
callback(false)
return
end
-- Set the "unpaidModifications" state on the vehicle.
local entityState = Entity(vehicle).state
entityState.set(entityState, "unpaidModifications", true, true)
local propKey = eventData.propKey
local modType = eventData.modType
local modIndex = eventData.modIndex
local toggleMod = eventData.toggleMod
SetVehicleModKit(vehicle, 0)
if modType == "LIVERY" then
-- Apply the vehicle livery.
SetVehicleLivery(vehicle, modIndex)
elseif modType == "LIVERY_ROOF" then
-- Apply the roof livery.
SetVehicleRoofLivery(vehicle, modIndex)
elseif modType == "PLATE_INDEX" then
-- Apply the number plate.
SetVehicleNumberPlateTextIndex(vehicle, modIndex)
elseif modType == "WINDOW_TINT" then
-- Apply the window tint.
SetVehicleWindowTint(vehicle, modIndex)
elseif modType == 14 then
-- Apply the horn.
SetVehicleMod(vehicle, 14, modIndex, false)
-- Create a thread to play the horn sound.
Citizen.CreateThreadNow(function()
if isHornPlaying then
isHornPlaying = false
Wait(10)
end
isHornPlaying = true
local hornType = Config.Mods.Horns[modIndex + 2].musical
local hornDuration = 750
if hornType then
hornDuration = 750
else
hornDuration = 100
end
while hornDuration > 1 do
if not isHornPlaying then
break
end
SetControlNormal(0, 86, 1.0)
Wait(1)
hornDuration = hornDuration - 1
end
end)
elseif toggleMod then
-- Toggle the vehicle modification.
ToggleVehicleMod(vehicle, modType, modIndex)
else
-- Apply vehicle modification based on type.
if type(modType) == "number" then
SetVehicleMod(vehicle, modType, modIndex, false)
end
end
vehicleModData.cosmetics[propKey] = modIndex
callback(true) -- Acknowledge the callback.
end
RegisterNUICallback(previewCosmeticModEvent, PreviewCosmeticMod)
local previewWheelsEvent = "preview-wheels"
function PreviewWheels(eventData, callback)
local vehicle = selectedVehicle
if not vehicle then
callback(false)
return
end
-- Set the "unpaidModifications" state on the vehicle.
local entityState = Entity(vehicle).state
entityState.set(entityState, "unpaidModifications", true, true)
SetVehicleModKit(vehicle, 0)
SetVehicleWheelType(vehicle, eventData.modType)
vehicleModData.wheels.wheels = eventData.modType
SetVehicleMod(vehicle, 23, eventData.modIndex, false)
vehicleModData.wheels.modFrontWheels = eventData.modIndex
local vehicleModel = GetEntityModel(vehicle)
if IsThisModelABike(vehicleModel) then
SetVehicleMod(vehicle, 24, eventData.modIndex, false)
vehicleModData.wheels.modBackWheels = eventData.modIndex
end
vehicleModData.wheels.wheelWidth = GetVehicleWheelWidth(vehicle)
vehicleModData.wheels.wheelSize = GetVehicleWheelSize(vehicle)
callback(true) -- Acknowledge the callback.
end
RegisterNUICallback(previewWheelsEvent, PreviewWheels)
local previewColorsEvent = "preview-pri-sec-colours"
function PreviewColors(eventData, callback)
local vehicle = selectedVehicle
if not vehicle then
callback(false)
return
end
function PreviewPrimaryPaint(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
SetVehicleModKit(CurrentVehicle, 0)
-- Sync primary and secondary colors if needed
local primarySecondarySync = data.primarySecondarySync
Entity(CurrentVehicle).state.set(Entity(CurrentVehicle).state, "primarySecondarySync", primarySecondarySync)
VehicleData.respray.primarySecondarySync = primarySecondarySync
local paintTypeKey = data.paintTypeKey
if "paintType1" == paintTypeKey then
-- Handle RGB paint
if data.enableRgb then
SetVehicleModColor_1(CurrentVehicle, data.paint, 0, 0)
local rgbColor = data.rgbColour
SetVehicleCustomPrimaryColour(CurrentVehicle, rgbColor[1], rgbColor[2], rgbColor[3])
VehicleData.respray.color1 = rgbColor
else
-- Handle standard colors
local primaryColor, secondaryColor = GetVehicleColours(CurrentVehicle)
SetVehicleColours(CurrentVehicle, data.colourId, secondaryColor)
ClearVehicleCustomPrimaryColour(CurrentVehicle)
VehicleData.respray.color1 = data.colourId
end
VehicleData.respray.paintType1 = data.paint
end
-- Apply secondary color if not syncing primary and secondary
if "paintType2" ~= paintTypeKey then
if not primarySecondarySync then
goto lbl_118
end
end
-- Handle secondary paint
if data.enableRgb then
local rgbColor = data.rgbColour
SetVehicleModColor_2(CurrentVehicle, data.paint, 0)
SetVehicleCustomSecondaryColour(CurrentVehicle, rgbColor[1], rgbColor[2], rgbColor[3])
VehicleData.respray.color2 = rgbColor
else
local primaryColor, secondaryColor = GetVehicleColours(CurrentVehicle)
SetVehicleColours(CurrentVehicle, primaryColor, data.colourId)
ClearVehicleCustomSecondaryColour(CurrentVehicle)
VehicleData.respray.color2 = data.colourId
end
VehicleData.respray.paintType2 = data.paint
::lbl_118::
callback(true)
end
RegisterNUICallback("preview-primary-colours", PreviewPrimaryPaint)
RegisterNUICallback("preview-other-colours", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
SetVehicleModKit(CurrentVehicle, 0)
local colourIdKey = data.colourIdKey
if "dashboardColor" == colourIdKey then
SetVehicleDashboardColor(CurrentVehicle, data.colourId)
elseif "interiorColor" == colourIdKey then
SetVehicleInteriorColor(CurrentVehicle, data.colourId)
else
local extraColor1, extraColor2 = GetVehicleExtraColours(CurrentVehicle)
if "pearlescentColor" == colourIdKey then
SetVehicleExtraColours(CurrentVehicle, data.colourId, extraColor2)
Entity(CurrentVehicle).state.set(Entity(CurrentVehicle).state, "disablePearl", not data.disablePearl or false)
VehicleData.respray.disablePearl = not data.disablePearl or false
end
if "wheelColor" == colourIdKey then
SetVehicleExtraColours(CurrentVehicle, extraColor1, data.colourId)
end
end
VehicleData.respray[data.colourIdKey] = data.colourId
callback(true)
end)
RegisterNUICallback("preview-xenons", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
SetVehicleModKit(CurrentVehicle, 0)
ToggleVehicleMod(CurrentVehicle, 22, data.enableXenons)
SetVehicleLights(CurrentVehicle, 2)
SetVehicleXenonLightsColor(CurrentVehicle, data.xenonColor)
VehicleData.headlights.modXenon = true
VehicleData.headlights.xenonColor = data.xenonColor
callback(true)
end)
RegisterNUICallback("preview-neons", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
SetVehicleModKit(CurrentVehicle, 0)
for i = 0, 3, 1 do
SetVehicleNeonLightEnabled(CurrentVehicle, i, data.enableNeons[i + 1])
end
local neonColor = data.neonColor
SetVehicleNeonLightsColour(CurrentVehicle, neonColor[1], neonColor[2], neonColor[3])
VehicleData.neonLights.neonEnabled = data.enableNeons
VehicleData.neonLights.neonColor = data.neonColor
callback(true)
end)
RegisterNUICallback("preview-tyre-smoke", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
if TyreSmokeExploitFix then
if not data.enableTyreSmoke then
DisableTyreSmokeExploit()
end
end
if not TyreSmokeExploitFix then
if data.enableTyreSmoke then
CreateThread(function()
local infiniteBurnout = true
TyreSmokeExploitFix = infiniteBurnout
if BurstTiresExploit then
SetVehicleTyresCanBurst(CurrentVehicle, false)
end
SetVehicleEngineOn(CurrentVehicle, true, true, true)
SetEntityCollision(CurrentVehicle, true, true)
FreezeEntityPosition(CurrentVehicle, false)
TaskVehicleTempAction(Cache.ped, CurrentVehicle, 30, 999999)
end)
end
end
SetVehicleModKit(CurrentVehicle, 0)
ToggleVehicleMod(CurrentVehicle, 20, data.enableTyreSmoke)
local tyreSmokeColor = data.tyreSmokeColor
SetVehicleTyreSmokeColor(CurrentVehicle, tyreSmokeColor[1], tyreSmokeColor[2], tyreSmokeColor[3])
VehicleData.tyreSmoke.modSmokeEnabled = data.enableTyreSmoke
VehicleData.tyreSmoke.tyreSmokeColor = data.tyreSmokeColor
callback(true)
end)
RegisterNUICallback("preview-bulletproof-tyres", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
local bulletproofTyresEnabled = not data.enableBulletproofTyres
SetVehicleTyresCanBurst(CurrentVehicle, bulletproofTyresEnabled)
BurstTiresExploit = bulletproofTyresEnabled
VehicleData.bulletproofTyres.bulletProofTyres = data.enableBulletproofTyres
callback(true)
end)
RegisterNUICallback("preview-extras", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
for extraId, enabled in pairs(data.extras) do
SetVehicleExtra(CurrentVehicle, tonumber(extraId), not enabled)
end
VehicleData.extras.extras = data.extras
callback(true)
end)
RegisterNUICallback("preview-stance", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
previewVehicleStance(CurrentVehicle, data.enableStance, data.defaultStance, data.stance)
PreviewingNewStance = true
callback(true)
end)
RegisterNUICallback("save-previewed-stance", function(data, callback)
if not CurrentVehicle then
callback(false)
return
end
-- Mark modifications as unpaid
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", true, true)
setStanceState(CurrentVehicle, data.enableStance, data.wheelsAdjIndv, data.defaultStance, data.stance)
PreviewingNewStance = false
VehicleData.stance.enableStance = data.enableStance
VehicleData.stance.wheelsAdjIndv = data.wheelsAdjIndv
VehicleData.stance.defaultStance = data.defaultStance
VehicleData.stance.stance = data.stance
callback(true)
end)
AddEventHandler("onResourceStop", function(resourceName)
if GetCurrentResourceName() == resourceName then
if CurrentVehicle then
restoreOriginalHandling()
local vehicleEntity = Entity(CurrentVehicle)
local vehicleState = vehicleEntity.state
vehicleState.set(vehicleState, "unpaidModifications", false, true)
SetVehicleEngineOn(CurrentVehicle, false)
end
end
end)