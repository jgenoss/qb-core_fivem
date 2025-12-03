local QBCore = exports['qb-core']:GetCoreObject()

-- =====================================================
-- VARIABLES GLOBALES
-- =====================================================
local PlayerData = QBCore.Functions.GetPlayerData()
local menuOpen = false
local currentVehicle = nil
local isTransitioning = false
local disableControlThread = nil
local rotatingCamera = false 

-- =====================================================
-- FUNCIONES AUXILIARES Y VALIDACIÓN
-- =====================================================

function GetVehicleTypeRaw(veh)
    local model = GetEntityModel(veh)
    if IsThisModelABike(model) or IsThisModelAQuadbike(model) then return 'motorcycle' end
    if GetVehicleNumberOfWheels(veh) == 3 then return 'trike' end
    return 'car'
end

function GetDoorName(index)
    local names = {[0]="Izquierda",[1]="Derecha",[2]="Tras. Izq",[3]="Tras. Der",[4]="Capó",[5]="Maletero"}
    return names[index] or "P-"..index
end

function GetWindowName(index)
    local names = {[0]="Izquierda",[1]="Derecha",[2]="Tras. Izq",[3]="Tras. Der"}
    return names[index] or "V-"..index
end

local function CanOpenMenu()
    local ped = PlayerPedId()
    if IsPauseMenuActive() then return false end
    if PlayerData.metadata and PlayerData.metadata['ishandcuffed'] then return false end
    if PlayerData.metadata and PlayerData.metadata['isdead'] then return false end
    if not IsPedInAnyVehicle(ped, false) then return false end
    
    local vehicle = GetVehiclePedIsIn(ped, false)
    local driver = GetPedInVehicleSeat(vehicle, -1)
    
    if driver ~= ped then return false end
    if IsVehicleExcluded(GetEntityModel(vehicle)) then return false end
    
    return true
end

-- =====================================================
-- OBTENER INFORMACIÓN DEL VEHÍCULO
-- =====================================================

function GetVehicleInfo()
    if not currentVehicle or not DoesEntityExist(currentVehicle) then return {} end
    
    local doors = {}
    local windows = {}
    
    -- Detectar puertas reales
    for i = 0, 5 do
        if DoesVehicleHaveDoor(currentVehicle, i) then
            -- Usamos > 0.0 para detectar si está abierta.
            -- NOTA: Durante la animación de apertura, esto pasa de 0.0 a 1.0 gradualmente.
            table.insert(doors, {
                index = i,
                name = GetDoorName(i),
                isOpen = GetVehicleDoorAngleRatio(currentVehicle, i) > 0.05 -- Margen pequeño para evitar falsos positivos
            })
        end
    end
    
    -- Detectar ventanas (solo si existe la puerta asociada)
    for i = 0, 3 do
        if DoesVehicleHaveDoor(currentVehicle, i) then
            table.insert(windows, {
                index = i,
                name = GetWindowName(i),
                isRolledDown = not IsVehicleWindowIntact(currentVehicle, i)
            })
        end
    end
    
    -- LECTURA DE ESTADO REAL DE LUCES
    local indicatorState = GetVehicleIndicatorLights(currentVehicle)
    
    local data = {
        model = GetDisplayNameFromVehicleModel(GetEntityModel(currentVehicle)),
        plate = GetVehicleNumberPlateText(currentVehicle),
        doors = doors,
        windows = windows,
        engineOn = GetIsVehicleEngineRunning(currentVehicle), 
        locked = GetVehicleDoorLockStatus(currentVehicle) > 1,
        vehicleType = GetVehicleTypeRaw(currentVehicle),
        lights = {
            left = (indicatorState == 1 or indicatorState == 3),
            right = (indicatorState == 2 or indicatorState == 3),
            hazard = (indicatorState == 3),
            interior = IsVehicleInteriorLightOn(currentVehicle)
        }
    }
    
    return data
end

-- =====================================================
-- GESTIÓN DEL MENÚ
-- =====================================================

local function SetMenuState(bool)
    if isTransitioning then return end
    if bool == menuOpen then return end
    
    isTransitioning = true
    menuOpen = bool
    
    if bool then
        local ped = PlayerPedId()
        currentVehicle = GetVehiclePedIsIn(ped, false)
        
        if not currentVehicle or currentVehicle == 0 then
            isTransitioning = false
            menuOpen = false
            return
        end
        
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        rotatingCamera = false
        
        if disableControlThread then disableControlThread = nil end
        disableControlThread = CreateThread(function()
            while menuOpen do
                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 263, true) -- Melee Attack 1
                DisableControlAction(0, 71, true) -- Accelerate
                DisableControlAction(0, 72, true) -- Brake
                DisableControlAction(0, 59, true) -- Veh Control LR
                DisableControlAction(0, 75, true) -- Exit Vehicle

                if not rotatingCamera then
                    DisableControlAction(0, 1, true) -- LookLeftRight
                    DisableControlAction(0, 2, true) -- LookUpDown
                end
                Wait(0)
            end
        end)
        
        SendNUIMessage({ action = "openMenu", vehicleData = GetVehicleInfo() })
    else
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "closeMenu" })
        disableControlThread = nil
    end

    SetTimeout(200, function() isTransitioning = false end)
end

-- =====================================================
-- COMANDOS
-- =====================================================

RegisterCommand('+vehicleMenu', function() if not menuOpen and CanOpenMenu() then SetMenuState(true) end end)
RegisterCommand('-vehicleMenu', function() if not Config.Toggle and menuOpen then SetMenuState(false) end end)

if Config.Toggle then
    RegisterKeyMapping('vehiclecontrol_toggle', 'Abrir menú vehicular', 'keyboard', Config.OpenKey)
    RegisterCommand('vehiclecontrol_toggle', function()
        if not menuOpen then if CanOpenMenu() then SetMenuState(true) end else SetMenuState(false) end
    end)
else
    RegisterKeyMapping('+vehicleMenu', 'Abrir menú vehicular (Mantener)', 'keyboard', Config.OpenKey)
end

-- =====================================================
-- CALLBACKS NUI (FIXED)
-- =====================================================

RegisterNUICallback('cameraControl', function(data, cb)
    if data.state == "moving" then
        rotatingCamera = true
        SetNuiFocus(true, false)
    else
        rotatingCamera = false
        SetNuiFocus(true, true)
    end
    cb('ok')
end)

-- CALLBACK CORREGIDO: PUERTAS
RegisterNUICallback('toggleDoor', function(data, cb)
    if currentVehicle and Config.Permissions.doors then
        local doorIndex = tonumber(data.doorIndex)
        local isOpen = GetVehicleDoorAngleRatio(currentVehicle, doorIndex) > 0.0
        
        if isOpen then
            SetVehicleDoorShut(currentVehicle, doorIndex, false)
        else
            SetVehicleDoorOpen(currentVehicle, doorIndex, false, false)
        end
        
        -- FIX: Actualización progresiva para capturar la animación
        -- Enviamos actualizaciones en varios momentos para que el botón cambie de color
        -- cuando la puerta realmente empiece a abrirse.
        CreateThread(function()
            -- Actualización inmediata (reacción visual rápida)
            SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
            
            Wait(250) -- Esperamos un poco a que la puerta se mueva físicamente
            SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
            
            Wait(350) -- Confirmación final
            SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
        end)
    end
    cb('ok')
end)

RegisterNUICallback('toggleWindow', function(data, cb)
    if currentVehicle and Config.Permissions.windows then
        local windowIndex = tonumber(data.windowIndex)
        if IsVehicleWindowIntact(currentVehicle, windowIndex) then
            RollDownWindow(currentVehicle, windowIndex)
        else
            RollUpWindow(currentVehicle, windowIndex)
        end
        Wait(100)
        SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
    end
    cb('ok')
end)

RegisterNUICallback('toggleIndicator', function(data, cb)
    if currentVehicle and Config.Permissions.lights then
        local side = data.side
        local current = GetVehicleIndicatorLights(currentVehicle)
        
        if side == "left" then
            local newState = not (current == 1 or current == 3)
            SetVehicleIndicatorLights(currentVehicle, 1, newState)
            SetVehicleIndicatorLights(currentVehicle, 0, false)
        elseif side == "right" then
            local newState = not (current == 2 or current == 3)
            SetVehicleIndicatorLights(currentVehicle, 0, newState)
            SetVehicleIndicatorLights(currentVehicle, 1, false)
        elseif side == "hazard" then
            local newState = not (current == 3)
            SetVehicleIndicatorLights(currentVehicle, 1, newState)
            SetVehicleIndicatorLights(currentVehicle, 0, newState)
        end
        
        Wait(50)
        SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
    end
    cb('ok')
end)

RegisterNUICallback('toggleInteriorLight', function(data, cb)
    if currentVehicle and Config.Permissions.lights then
        local state = IsVehicleInteriorLightOn(currentVehicle)
        SetVehicleInteriorlight(currentVehicle, not state)
        Wait(50)
        SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
    end
    cb('ok')
end)

RegisterNUICallback('toggleEngine', function(data, cb)
    if currentVehicle and Config.Permissions.engine then
        local engineOn = GetIsVehicleEngineRunning(currentVehicle)
        SetVehicleEngineOn(currentVehicle, not engineOn, false, true)
        
        Wait(100)
        SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
        Wait(500)
        SendNUIMessage({ action = "updateVehicleData", vehicleData = GetVehicleInfo() })
    end
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(data, cb)
    SetMenuState(false)
    cb('ok')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() PlayerData = QBCore.Functions.GetPlayerData() end)
RegisterNetEvent('QBCore:Client:OnPlayerUnload', function() PlayerData = {} end)
RegisterNetEvent('QBCore:Player:SetPlayerData', function(data) PlayerData = data end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName and menuOpen then
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
    end
end)