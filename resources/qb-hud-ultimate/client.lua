--[[
    ═══════════════════════════════════════════════════════════
    HUD ULTIMATE v13.2 - INTERFAZ DE USUARIO
    Maneja solo la UI y visualización del HUD
    ═══════════════════════════════════════════════════════════
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- ═══════════════════════════════════════════════════════════
-- 📦 VARIABLES GLOBALES DE UI
-- ═══════════════════════════════════════════════════════════

local display = true
local voiceLevel = 2
local wasInVehicle = false
local isEditMode = false
local isLoadingMap = false
local minimapScaleform = nil
local playerFullyLoaded = false
local showSeatbelt = false
local seatbeltOn = true
local cruiseOn = false

-- Datos del vehículo recibidos desde vehicle.lua
local currentVehicleData = {
    inVehicle = false,
    vehicle = 0,
    data = nil,
    speed = 0,
    rpm = 0,
    engineHealth = 0,
    engineOn = false
}

-- ═══════════════════════════════════════════════════════════
-- 🗺️ SISTEMA DE MAPA
-- ═══════════════════════════════════════════════════════════

local function HideNativeHealthArmor()
    if not minimapScaleform or not HasScaleformMovieLoaded(minimapScaleform) then
        minimapScaleform = RequestScaleformMovie("minimap")
        local timeout = GetGameTimer() + 3000
        while not HasScaleformMovieLoaded(minimapScaleform) and GetGameTimer() < timeout do 
            Wait(10) 
        end
    end
    
    if HasScaleformMovieLoaded(minimapScaleform) then
        BeginScaleformMovieMethod(minimapScaleform, "SETUP_HEALTH_ARMOUR")
        ScaleformMovieMethodAddParamInt(3) 
        EndScaleformMovieMethod()
    end
end

local function LoadMap()
    isLoadingMap = true 
    DisplayRadar(false)
    
    HideNativeHealthArmor()

    local defaultAspectRatio = 1920 / 1080 
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0
    
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end

    RequestStreamedTextureDict('squaremap', false)
    local timeout = GetGameTimer() + 3000
    while not HasStreamedTextureDictLoaded('squaremap') and GetGameTimer() < timeout do 
        Wait(50) 
    end

    SetMinimapClipType(0) 
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'squaremap', 'radarmasksm')
    AddReplaceTexture('platform:/textures/graphics', 'radarmask1g', 'squaremap', 'radarmasksm')
    
    SetMinimapComponentPosition('minimap', 'L', 'B', 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01 + minimapOffset, 0.025, 0.262, 0.300)
    
    SetBlipAlpha(GetNorthRadarBlip(), 0)
    
    SetBigmapActive(true, false)
    SetMinimapClipType(0)
    Wait(50)
    SetBigmapActive(false, false)
    
    SetRadarZoom(1000)
    HideNativeHealthArmor()
    
    isLoadingMap = false
    
    print("^2[HUD] Mapa cargado correctamente^0")
end

-- ═══════════════════════════════════════════════════════════
-- 🎨 EVENTO: RECIBIR DATOS DEL VEHÍCULO
-- ═══════════════════════════════════════════════════════════

RegisterNetEvent(VEHICLE_EVENTS.UPDATE_VEHICLE_DATA, function(data)
    currentVehicleData = data
end)

-- ═══════════════════════════════════════════════════════════
-- 🔄 THREAD: MANTENIMIENTO DEL MAPA
-- ═══════════════════════════════════════════════════════════

CreateThread(function()
    minimapScaleform = RequestScaleformMovie("minimap")
    while not HasScaleformMovieLoaded(minimapScaleform) do Wait(10) end
    
    while true do
        Wait(30000)
        SetBigmapActive(false, false)
        SetRadarZoom(1000)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 📡 EVENTOS DE CARGA
-- ═══════════════════════════════════════════════════════════

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoadingMap = true 
    playerFullyLoaded = false
    DisplayRadar(false)
    
    Wait(1500) 
    LoadMap()
    
    Wait(500)
    playerFullyLoaded = true
    print("^2[HUD] Jugador completamente cargado^0")
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    playerFullyLoaded = false
    DisplayRadar(false)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(1000)
    if LocalPlayer.state.isLoggedIn then 
        LoadMap()
        Wait(500)
        playerFullyLoaded = true
    end
end)

RegisterNetEvent('hud:client:ToggleShowSeatbelt', function()
    showSeatbelt = not showSeatbelt
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    seatbeltOn = not seatbeltOn
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function()
    cruiseOn = not cruiseOn
end)
-- ═══════════════════════════════════════════════════════════
-- 🎨 BUCLE PRINCIPAL (HUD)
-- ═══════════════════════════════════════════════════════════

CreateThread(function()
    while true do
        local waitTime = 200
        
        if IsPauseMenuActive() or isLoadingMap or not playerFullyLoaded then
            SendNUIMessage({ action = "toggleHUD", show = false })
            DisplayRadar(false)
            wasInVehicle = false 
            waitTime = 500
        else
            if LocalPlayer.state.isLoggedIn and display then
                local ped = PlayerPedId()
                if not ped or ped == 0 then goto skip end
                
                local playerId = PlayerId()
                local playerData = QBCore.Functions.GetPlayerData()
                
                if not playerData then goto skip end
                
                local inVehicle = IsPedInAnyVehicle(ped, false)
                
                if inVehicle then
                    if not wasInVehicle then
                        HideNativeHealthArmor()
                        DisplayRadar(true)
                        wasInVehicle = true
                    end
                    if IsRadarHidden() then 
                        DisplayRadar(true) 
                    end
                    waitTime = 150
                else
                    if wasInVehicle then
                        wasInVehicle = false
                        DisplayRadar(true)
                    end
                    if IsRadarHidden() then 
                        DisplayRadar(true) 
                    end
                    waitTime = 250
                end

                HideHudComponentThisFrame(3) 
                HideHudComponentThisFrame(4) 
                HideHudComponentThisFrame(6) 
                HideHudComponentThisFrame(7) 
                HideHudComponentThisFrame(8) 
                HideHudComponentThisFrame(9)

                local health = math.max(0, GetEntityHealth(ped) - 100)
                local oxygen = 100
                
                if health <= 0 then
                    oxygen = 0
                elseif IsPedSwimming(ped) then
                    oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
                end
                
                local stamina = 100 - GetPlayerSprintStaminaRemaining(playerId)

                local data = {
                    action = "updateHUD",
                    show = true,
                    inVehicle = false,
                    isBicycle = false,
                    isMotorcycle = false,
                    isEditMode = isEditMode,
                    health = health,
                    armor = GetPedArmour(ped),
                    hunger = playerData.metadata and playerData.metadata['hunger'] or 100,
                    thirst = playerData.metadata and playerData.metadata['thirst'] or 100,
                    stress = playerData.metadata and playerData.metadata['stress'] or 0,
                    oxygen = oxygen,
                    stamina = stamina,
                    voice = (voiceLevel / 3) * 100,
                    talking = NetworkIsPlayerTalking(playerId),
                    money = playerData.money and playerData.money['cash'] or 0,
                    bank = playerData.money and playerData.money['bank'] or 0,
                    id = GetPlayerServerId(playerId)
                }

                if inVehicle and currentVehicleData.inVehicle then
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    if vehicle and vehicle ~= 0 then
                        local driver = GetPedInVehicleSeat(vehicle, -1)
                        local vehClass = GetVehicleClass(vehicle)
                        
                        data.isBicycle = (vehClass == 13)
                        data.isMotorcycle = (vehClass == 8)

                        if driver == ped and not data.isBicycle then
                            local vData = currentVehicleData.data
                            if vData then
                                data.inVehicle = true
                                data.engineOn = currentVehicleData.engineOn
                                data.speed = math.floor(currentVehicleData.speed)
                                data.rpm = math.max(0, math.min(1, currentVehicleData.rpm))
                                data.gear = GetVehicleCurrentGear(vehicle)
                                data.fuel = math.max(0, GetVehicleFuelLevel(vehicle) or 0)
                                data.engine = (currentVehicleData.engineHealth / 10)
                                data.body = (GetVehicleBodyHealth(vehicle) / 10) or 0
                                data.temp = math.floor(vData.temp or 0)
                                data.oil = vData.oil or 0
                                data.coolant = vData.coolant or 0
                                data.battery = vData.battery or 0
                                data.odometer = math.floor(vData.odometer or 0)
                                data.radiatorFan = vData.radiatorFanActive or false
                                data.engineSeized = vData.engineSeized or false
                                data.onFire = vData.onFire or false
                                data.shutdownProtection = vData.shutdownProtection or false

                                data.IsEngineDamage = vData.IsEngineDamage or false
                                data.engineDamageLevel = vData.engineDamageLevel or 0
                                
                                if not currentVehicleData.engineOn or vData.engineSeized then
                                    data.pressure = 0
                                else
                                    local basePressure = (data.rpm or 0) * 5.0
                                    if currentVehicleData.engineHealth < 400 or vData.oil < 20 then 
                                        data.pressure = math.max(0, basePressure - math.random(1.0, 3.0))
                                    else
                                        data.pressure = basePressure
                                    end
                                end
                                
                                --data.seatbelt = LocalPlayer.state.seatbelt or false
                                data.seatbelt = not seatbeltOn

                                data.handbrake = GetVehicleHandbrake(vehicle)

                                data.doorOpen = false
                                for i = 0, 5 do
                                    if GetVehicleDoorAngleRatio(vehicle, i) > 0 then 
                                        data.doorOpen = true 
                                        break 
                                    end
                                end
                                
                                local _, lightOn, highBeam = GetVehicleLightsState(vehicle)
                                local indicators = GetVehicleIndicatorLights(vehicle)
                                
                                data.lights = {
                                    low = (lightOn == 1 and highBeam == 0),
                                    high = (lightOn == 1 and highBeam == 1),
                                    left = (indicators == 1 or indicators == 3),
                                    right = (indicators == 2 or indicators == 3)
                                }

                                local coords = GetEntityCoords(ped)
                                local heading = GetEntityHeading(ped)
                                local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                                data.street = GetStreetNameFromHashKey(streetHash)
                                local dirIndex = math.floor((heading + 22.5) / 45.0)
                                data.direction = CONFIG.DIRECTIONS[dirIndex] or 'N'
                            end
                        end
                    end
                end

                SendNUIMessage(data)
            else
                SendNUIMessage({ action = "toggleHUD", show = false })
                waitTime = 500
            end
        end
        
        ::skip::
        Wait(waitTime)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎤 EVENTOS DE VOZ
-- ═══════════════════════════════════════════════════════════

RegisterNetEvent('pma-voice:setTalkingMode', function(mode) 
    voiceLevel = mode or 2
end)

-- ═══════════════════════════════════════════════════════════
-- 🎨 MODO DE EDICIÓN
-- ═══════════════════════════════════════════════════════════

RegisterCommand('hudmenu', function()
    if IsPauseMenuActive() then return end
    isEditMode = not isEditMode
    SetNuiFocus(isEditMode, isEditMode)
    SendNUIMessage({ action = "toggleEditMode", status = isEditMode })
end)

RegisterNUICallback('closeEdit', function(_, cb)
    isEditMode = false
    SetNuiFocus(false, false)
    cb('ok')
end)

-- ═══════════════════════════════════════════════════════════
-- 🧠 EVENTOS DE ESTRÉS
-- ═══════════════════════════════════════════════════════════

RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    -- Evento para actualizar estrés desde servidor
end)

-- ═══════════════════════════════════════════════════════════
-- ✅ MENSAJE DE CARGA
-- ═══════════════════════════════════════════════════════════

print('^2╔═══════════════════════════════════════════╗^0')
print('^2║  HUD ULTIMATE v13.2 - UI CARGADO         ║^0')
print('^2║  🎨 Interfaz de Usuario                   ║^0')
print('^2║  📊 Lectura de datos vehiculares          ║^0')
print('^2╚═══════════════════════════════════════════╝^0')
print('^3Comandos disponibles:^0')
print('^2  /hudmenu^0 - Abrir menú de configuración')
print('^2  /vehinfo^0 - Ver información completa del vehículo')
print('^2  /vehreset^0 - Resetear vehículo')
print('^2  /vehsetoil [0-100]^0 - Testear nivel de aceite')
print('^2  /vehtoggleseize^0 - Toggle gripaje para pruebas')