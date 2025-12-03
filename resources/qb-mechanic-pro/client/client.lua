-- ============================================================================
-- QB-MECHANIC-PRO - Client Main Entry Point (Multi-Framework)
-- ============================================================================

local QBCore = nil
local ESX = nil
local PlayerData = {}
local loadedShops = {}
local isOnDuty = false

-- ----------------------------------------------------------------------------
-- 1. INICIALIZACIÓN DEL FRAMEWORK
-- ----------------------------------------------------------------------------
if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'qbox' then
    QBCore = exports.qbx_core:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- ----------------------------------------------------------------------------
-- 2. FUNCIONES NUCLEO (WRAPPERS MULTI-FRAMEWORK)
-- ----------------------------------------------------------------------------

-- Notificaciones Unificadas
local function Notify(msg, type, length)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        QBCore.Functions.Notify(msg, type, length)
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(msg)
    else
        -- Fallback a ox_lib si está disponible
        lib.notify({ title = 'Mechanic', description = msg, type = type })
    end
end

-- Obtener datos del jugador actualizados
local function GetPlayerData()
    if Config.Framework == 'esx' then
        return ESX.GetPlayerData()
    else
        return QBCore.Functions.GetPlayerData()
    end
end

-- Obtener vehículo más cercano (CRÍTICO para módulos)
local function GetClosestVehicle()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    if Config.Framework == 'esx' then
        local vehicle, distance = ESX.Game.GetClosestVehicle(coords)
        if vehicle ~= -1 and distance <= 5.0 then
            return vehicle
        end
    else
        local vehicle, distance = QBCore.Functions.GetClosestVehicle(coords)
        if vehicle ~= -1 and distance <= 5.0 then
            return vehicle
        end
    end
    return nil
end

-- Obtener propiedades del vehículo (Mods)
local function GetVehicleProperties(vehicle)
    if Config.Framework == 'esx' then
        return ESX.Game.GetVehicleProperties(vehicle)
    else
        return QBCore.Functions.GetVehicleProperties(vehicle)
    end
end

-- Establecer propiedades del vehículo
local function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'esx' then
        ESX.Game.SetVehicleProperties(vehicle, props)
    else
        QBCore.Functions.SetVehicleProperties(vehicle, props)
    end
end

-- Traducciones simples
local function L(key, ...)
    -- Aquí conectarías con tu sistema de locales.
    -- Por defecto devolvemos la key si no hay traducción.
    return key
end

-- ----------------------------------------------------------------------------
-- 3. GESTIÓN DE EVENTOS DE FRAMEWORK (Login/Job Update)
-- ----------------------------------------------------------------------------

if Config.Framework == 'esx' then
    RegisterNetEvent('esx:playerLoaded', function(xPlayer)
        PlayerData = xPlayer
        TriggerEvent('qb-mechanic:client:initialize')
    end)

    RegisterNetEvent('esx:setJob', function(job)
        PlayerData.job = job
        isOnDuty = false -- Reset duty on job change
        TriggerEvent('qb-mechanic:client:jobUpdated', job)
    end)
else
    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        PlayerData = QBCore.Functions.GetPlayerData()
        TriggerEvent('qb-mechanic:client:initialize')
    end)

    RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
        PlayerData.job = JobInfo
        TriggerEvent('qb-mechanic:client:jobUpdated', JobInfo)
    end)

    RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
        PlayerData = val
    end)
end

-- ----------------------------------------------------------------------------
-- 4. LÓGICA DE TALLERES
-- ----------------------------------------------------------------------------

RegisterNetEvent('qb-mechanic:client:initialize', function()
    if Config.Debug then print('^2[QB-MECHANIC-PRO]^0 Client initialized') end
    TriggerServerEvent('qb-mechanic:server:requestShops')
end)

RegisterNetEvent('qb-mechanic:client:receiveShops', function(shops)
    loadedShops = shops
    if Config.Debug then print('^2[QB-MECHANIC-PRO]^0 Loaded ' .. #shops .. ' shops') end
    
    -- Recargar blips y zonas
    for _, shop in pairs(shops) do
        CreateShopBlip(shop)
        CreateShopZones(shop)
    end
end)

-- ----------------------------------------------------------------------------
-- 5. CREACIÓN DE ZONAS (OX_TARGET / TEXTUI / BLIPS)
-- ----------------------------------------------------------------------------

function CreateShopBlip(shop)
    if not shop.config_data.blip or not shop.config_data.blip.enabled then return end
    local blipCfg = shop.config_data.blip
    local coords = shop.config_data.locations.duty
    if not coords then return end

    local mapBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(mapBlip, blipCfg.sprite or 446)
    SetBlipDisplay(mapBlip, 4)
    SetBlipScale(mapBlip, blipCfg.scale or 0.8)
    SetBlipColour(mapBlip, blipCfg.color or 5)
    SetBlipAsShortRange(mapBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipCfg.label or shop.shop_name)
    EndTextCommandSetBlipName(mapBlip)
end

-- Helper para verificar permisos
function IsPlayerAuthorized(shop)
    if not PlayerData.job then return false end
    if shop.ownership_type == 'public' then return true end
    if shop.job_name and PlayerData.job.name == shop.job_name then
        -- Compatibilidad de grados ESX vs QBCore
        local grade = 0
        if type(PlayerData.job.grade) == 'table' then
            grade = PlayerData.job.grade.level -- QBCore
        else
            grade = PlayerData.job.grade -- ESX
        end
        return grade >= (shop.minimum_grade or 0)
    end
    return false
end

function IsPlayerBoss(shop)
    if not PlayerData.job then return false end
    if shop.job_name and PlayerData.job.name == shop.job_name then
        local grade = 0
        if type(PlayerData.job.grade) == 'table' then
            grade = PlayerData.job.grade.level
        else
            grade = PlayerData.job.grade
        end
        return grade >= (shop.boss_grade or 3)
    end
    return false
end

-- Helper para crear interacción (Target o TextUI)
function CreateInteractionZone(id, coords, options)
    if Config.UseTarget then
        -- Usar ox_target o qb-target
        local targetRes = Config.Interact or 'ox_target'
        exports[targetRes]:AddBoxZone(id, vector3(coords.x, coords.y, coords.z), 1.5, 1.5, {
            name = id,
            heading = coords.heading or 0,
            debugPoly = Config.Debug,
            minZ = coords.z - 1,
            maxZ = coords.z + 2,
        }, {
            options = {
                {
                    type = "client",
                    event = "qb-mechanic:client:interact_handler", -- Evento puente
                    icon = options.icon,
                    label = options.label,
                    -- Pasamos la función callback como argumento para manejarla luego si es posible
                    -- Nota: Los targets suelen requerir eventos registrados, usaremos un handler genérico
                    action = options.onSelect, 
                    canInteract = options.canInteract
                }
            },
            distance = 2.5
        })
    else
        -- Usar ox_lib textui
        local point = lib.points.new({
            coords = vector3(coords.x, coords.y, coords.z),
            distance = 2.5,
            id = id
        })
        function point:onEnter()
            if not options.canInteract or options.canInteract() then
                lib.showTextUI(options.label .. ' [E]')
            end
        end
        function point:onExit() lib.hideTextUI() end
        function point:nearby()
            if self.currentDistance < 1.5 and IsControlJustReleased(0, 38) then
                if not options.canInteract or options.canInteract() then
                    options.onSelect()
                end
            end
        end
    end
end

function CreateShopZones(shop)
    local locs = shop.config_data.locations
    
    -- 1. Zona Duty
    if locs.duty then
        CreateInteractionZone(shop.id..'_duty', locs.duty, {
            label = 'Entrar/Salir Servicio',
            icon = 'fa-solid fa-clock',
            onSelect = function() TriggerServerEvent('qb-mechanic:server:toggleDuty', shop.id) end,
            canInteract = function() return IsPlayerAuthorized(shop) end
        })
    end

    -- 2. Zona Stash
    if locs.stash and shop.config_data.features.enable_stash then
        CreateInteractionZone(shop.id..'_stash', locs.stash, {
            label = 'Abrir Almacén',
            icon = 'fa-solid fa-box',
            onSelect = function() TriggerEvent('qb-mechanic:client:openStash', shop.id) end,
            canInteract = function() return IsPlayerAuthorized(shop) and isOnDuty end
        })
    end

    -- 3. Zona Boss Menu
    if locs.bossmenu then
        CreateInteractionZone(shop.id..'_boss', locs.bossmenu, {
            label = 'Gestión de Taller',
            icon = 'fa-solid fa-briefcase',
            onSelect = function() TriggerEvent('qb-mechanic:client:openTablet', shop.id, 'management') end,
            canInteract = function() return IsPlayerBoss(shop) and isOnDuty end
        })
    end

    -- 4. Tuner & Carlift (Arrays)
    if locs.tuneshop and shop.config_data.features.enable_tuneshop then
        for i, loc in ipairs(locs.tuneshop) do
            CreateInteractionZone(shop.id..'_tune_'..i, loc, {
                label = 'Modificar Vehículo',
                icon = 'fa-solid fa-wrench',
                onSelect = function() TriggerEvent('qb-mechanic:client:openTuneshop', shop.id) end,
                canInteract = function() return IsPlayerAuthorized(shop) and isOnDuty end
            })
        end
    end

    if locs.carlift and shop.config_data.features.enable_carlift then
        for i, loc in ipairs(locs.carlift) do
            CreateInteractionZone(shop.id..'_lift_'..i, loc, {
                label = 'Usar Elevador',
                icon = 'fa-solid fa-arrow-up',
                onSelect = function() TriggerEvent('qb-mechanic:client:useCarlift', shop.id, loc) end,
                canInteract = function() return IsPlayerAuthorized(shop) and isOnDuty end
            })
        end
    end
end

-- ----------------------------------------------------------------------------
-- 6. EVENTOS DE UTILIDAD Y NUI
-- ----------------------------------------------------------------------------

RegisterNetEvent('qb-mechanic:client:dutyChanged', function(state)
    isOnDuty = state
    if state then Notify('Entraste en servicio', 'success') else Notify('Saliste de servicio', 'error') end
end)

RegisterNetEvent('qb-mechanic:client:openStash', function(shopId)
    local shop = loadedShops[shopId]
    if not shop then return end
    
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', 'mechanic_' .. shopId)
    elseif Config.Inventory == 'qb-inventory' then
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'mechanic_' .. shopId, {
            maxweight = 4000000, slots = 50,
        })
        TriggerEvent('inventory:client:SetCurrentStash', 'mechanic_' .. shopId)
    elseif Config.Inventory == 'qs-inventory' then
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'mechanic_' .. shopId)
    elseif Config.Framework == 'esx' then
         -- Implementación genérica para ESX stashes si es necesario
         TriggerServerEvent('qb-mechanic:server:openEsxStash', 'mechanic_' .. shopId)
    end
end)

-- Comandos Admin
RegisterCommand('mechanic_creator', function()
    TriggerServerEvent('qb-mechanic:server:checkCreatorAccess')
end)

RegisterNetEvent('qb-mechanic:client:openCreator', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openCreator', shops = loadedShops })
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('saveShop', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:saveShop', data)
    cb('ok')
end)

RegisterNUICallback('deleteShop', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:deleteShop', data.shopId)
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- 7. EXPORTS CRÍTICOS (API PARA MÓDULOS)
-- Estos exports permiten que carlift.lua, engine-swap.lua, etc. funcionen
-- ----------------------------------------------------------------------------

exports('Notify', Notify)
exports('GetClosestVehicle', GetClosestVehicle)
exports('GetVehicleProperties', GetVehicleProperties)
exports('SetVehicleProperties', SetVehicleProperties)
exports('GetPlayerData', GetPlayerData)
exports('IsOnDuty', function() return isOnDuty end)
exports('GetAllShops', function() return loadedShops end)

-- Inicialización inicial por si el script se reinicia
CreateThread(function()
    Wait(500)
    if Config.Framework == 'esx' then
        if ESX.IsPlayerLoaded() then
            PlayerData = ESX.GetPlayerData()
            TriggerEvent('qb-mechanic:client:initialize')
        end
    else
        if LocalPlayer.state.isLoggedIn then
            PlayerData = QBCore.Functions.GetPlayerData()
            TriggerEvent('qb-mechanic:client:initialize')
        end
    end
end)