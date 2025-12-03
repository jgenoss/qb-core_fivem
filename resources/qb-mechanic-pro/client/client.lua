-- ============================================================================
-- QB-MECHANIC-PRO - Client Main Entry Point COMPLETO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Variables Globales
-- ----------------------------------------------------------------------------
local QBCore = nil
local ESX = nil
local loadedShops = {}
local playerJob = nil
local playerGrade = 0

-- ----------------------------------------------------------------------------
-- Inicialización del Framework
-- ----------------------------------------------------------------------------
if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- ----------------------------------------------------------------------------
-- 1. FUNCIONES AUXILIARES GLOBALES
-- ----------------------------------------------------------------------------

-- Función: Notificación
function Notify(message, type, duration)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        QBCore.Functions.Notify(message, type, duration or 5000)
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(message)
    else
        exports['ox_lib']:notify({
            title = 'Mechanic',
            description = message,
            type = type or 'info'
        })
    end
end

-- Función: Obtener vehículo más cercano
function GetClosestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicles = GetGamePool('CVehicle')
    local closestVehicle = nil
    local closestDistance = 10.0
    
    for _, vehicle in pairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        if distance < closestDistance then
            closestDistance = distance
            closestVehicle = vehicle
        end
    end
    
    return closestVehicle, closestDistance
end

-- Función: Obtener propiedades del vehículo
function GetVehicleProperties(vehicle)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'esx' then
        return ESX.Game.GetVehicleProperties(vehicle)
    end
end

-- Función: Aplicar propiedades al vehículo
function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return QBCore.Functions.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'esx' then
        return ESX.Game.SetVehicleProperties(vehicle, props)
    end
end

-- Función: Obtener job del jugador
function GetPlayerJob()
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        local PlayerData = QBCore.Functions.GetPlayerData()
        return PlayerData.job.name, PlayerData.job.grade.level
    elseif Config.Framework == 'esx' then
        local PlayerData = ESX.GetPlayerData()
        return PlayerData.job.name, PlayerData.job.grade
    end
end

-- ----------------------------------------------------------------------------
-- 2. EXPORTS GLOBALES
-- ----------------------------------------------------------------------------
exports('Notify', Notify)
exports('GetClosestVehicle', GetClosestVehicle)
exports('GetVehicleProperties', GetVehicleProperties)
exports('SetVehicleProperties', SetVehicleProperties)
exports('GetPlayerJob', GetPlayerJob)
exports('GetAllShops', function() return loadedShops end)

-- ----------------------------------------------------------------------------
-- 3. ACTUALIZACIÓN DE JOB
-- ----------------------------------------------------------------------------
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerJob, playerGrade = GetPlayerJob()
    TriggerServerEvent('qb-mechanic:server:requestShops')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    playerJob = JobInfo.name
    playerGrade = JobInfo.grade.level
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    playerJob = xPlayer.job.name
    playerGrade = xPlayer.job.grade
    TriggerServerEvent('qb-mechanic:server:requestShops')
end)

RegisterNetEvent('esx:setJob', function(job)
    playerJob = job.name
    playerGrade = job.grade
end)

-- ----------------------------------------------------------------------------
-- 4. FUNCIONES DE BLIPS
-- ----------------------------------------------------------------------------
function CreateShopBlip(shop)
    if not shop.config_data or not shop.config_data.blip then return end
    
    local blipConfig = shop.config_data.blip
    if not blipConfig.enabled then return end
    
    -- Usar ubicación de duty como referencia
    local coords = shop.config_data.locations.duty
    if not coords or not coords[1] then return end
    
    local location = coords[1]
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, blipConfig.sprite or 446)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipConfig.scale or 0.8)
    SetBlipColour(blip, blipConfig.color or 5)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipConfig.label or shop.shop_name)
    EndTextCommandSetBlipName(blip)
end

-- ----------------------------------------------------------------------------
-- 5. RECIBIR TALLERES DEL SERVIDOR
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:receiveShops', function(shops)
    loadedShops = shops
    
    if Config.Debug then 
        print('^2[QB-MECHANIC-PRO]^0 Client loaded ' .. #shops .. ' shops') 
    end
    
    -- Crear blips
    for _, shop in pairs(shops) do
        CreateShopBlip(shop)
    end
    
    -- Crear zonas de interacción
    TriggerEvent('qb-mechanic:client:createShopZones', shops)
end)

-- ----------------------------------------------------------------------------
-- 6. COMANDOS DE ADMINISTRADOR
-- ----------------------------------------------------------------------------
RegisterCommand('mechanic:creator', function()
    TriggerEvent('qb-mechanic:client:openCreator')
end, false)

RegisterCommand('mechanic:debug', function()
    local vehicle, distance = GetClosestVehicle()
    if vehicle then
        local plate = GetVehicleNumberPlateText(vehicle)
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        print(string.format('^2[DEBUG]^0 Vehicle: %s | Plate: %s | Distance: %.2f', model, plate, distance))
    else
        print('^1[DEBUG]^0 No vehicle nearby')
    end
end, false)

-- ----------------------------------------------------------------------------
-- 7. EVENT: TELETRANSPORTAR JUGADOR
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:teleport', function(x, y, z)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    Notify('Teleported to shop', 'success')
end)

-- ----------------------------------------------------------------------------
-- 8. INICIALIZACIÓN
-- ----------------------------------------------------------------------------
CreateThread(function()
    Wait(1000)
    TriggerServerEvent('qb-mechanic:server:requestShops')
end)

-- ----------------------------------------------------------------------------
-- 9. LIMPIEZA AL DESCARGAR RESOURCE
-- ----------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Cerrar todas las UIs abiertas
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeAll' })
end)