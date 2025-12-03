-- ============================================================================
-- QB-MECHANIC-PRO - Server Main Entry Point
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Variables globales
-- ----------------------------------------------------------------------------
local QBCore = nil
local loadedShops = {}
local onDutyPlayers = {}

-- ----------------------------------------------------------------------------
-- Inicialización del Framework
-- ----------------------------------------------------------------------------
if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
elseif Config.Framework == 'qbox' then
    QBCore = exports.qbx_core:GetCoreObject()
end

-- ----------------------------------------------------------------------------
-- Función de traducción
-- ----------------------------------------------------------------------------
local function L(key, ...)
    local locale = Config.Locale or 'en'
    if Locale[locale] and Locale[locale][key] then
        return string.format(Locale[locale][key], ...)
    end
    return key
end

-- ----------------------------------------------------------------------------
-- Función de notificación
-- ----------------------------------------------------------------------------
local function Notify(source, message, type, duration)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        TriggerClientEvent('QBCore:Notify', source, message, type, duration or 5000)
    elseif Config.Framework == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Mechanic',
            description = message,
            type = type or 'info'
        })
    end
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('GetShopData', function(shopId)
    return loadedShops[shopId]
end)

exports('GetAllShops', function()
    return loadedShops
end)

exports('IsPlayerOnDuty', function(source)
    return onDutyPlayers[source] ~= nil
end)

-- ----------------------------------------------------------------------------
-- Event: Inicialización del servidor
-- ----------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if Config.Debug then
        print('^2========================================^0')
        print('^2[QB-MECHANIC-PRO] Server Starting^0')
        print('^3Framework:^0 ' .. Config.Framework)
        print('^3Society System:^0 ' .. Config.SocietySystem)
        print('^2========================================^0')
    end
    
    -- Cargar talleres desde la base de datos
    LoadShopsFromDatabase()
    
    -- Inicializar stashes si es necesario
    InitializeStashes()
end)

-- ----------------------------------------------------------------------------
-- Función: Cargar talleres desde base de datos
-- ----------------------------------------------------------------------------
function LoadShopsFromDatabase()
    local result = MySQL.query.await('SELECT * FROM mechanic_shops', {})
    
    if not result then
        print('^1[QB-MECHANIC-PRO] Error loading shops from database^0')
        return
    end
    
    loadedShops = {}
    
    for _, shop in ipairs(result) do
        -- Parsear config_data JSON
        local success, config = pcall(json.decode, shop.config_data)
        
        if success then
            shop.config_data = config
            loadedShops[shop.id] = shop
        else
            print('^1[QB-MECHANIC-PRO] Error parsing config for shop: ' .. shop.id .. '^0')
        end
    end
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Loaded %d shops', #result))
    end
end

-- ----------------------------------------------------------------------------
-- Función: Inicializar stashes
-- ----------------------------------------------------------------------------
function InitializeStashes()
    if Config.Inventory == 'ox_inventory' then
        for shopId, shop in pairs(loadedShops) do
            if shop.config_data.features and shop.config_data.features.enable_stash then
                exports.ox_inventory:RegisterStash('mechanic_' .. shopId, 'Mechanic Stash', 50, 100000, false)
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Event: Cliente solicita talleres
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:requestShops', function()
    local src = source
    TriggerClientEvent('qb-mechanic:client:receiveShops', src, loadedShops)
end)

-- ----------------------------------------------------------------------------
-- Event: Verificar acceso al creator
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:checkCreatorAccess', function()
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar permisos de admin
    if IsPlayerAceAllowed(src, Config.DefaultPermissions.CreatorAccess.ace) then
        TriggerClientEvent('qb-mechanic:client:openCreator', src)
    else
        Notify(src, L('error_not_authorized'), 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Guardar taller
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:saveShop', function(shopData)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar permisos
    if not IsPlayerAceAllowed(src, Config.DefaultPermissions.CreatorAccess.ace) then
        Notify(src, L('error_not_authorized'), 'error')
        return
    end
    
    -- Validar datos
    if not shopData.id or not shopData.shop_name then
        Notify(src, 'Invalid shop data', 'error')
        return
    end
    
    -- Preparar config_data para guardar
    local configJson = json.encode(shopData.config_data)
    
    -- Verificar si el taller existe
    local exists = MySQL.scalar.await('SELECT id FROM mechanic_shops WHERE id = ?', {shopData.id})
    
    if exists then
        -- Actualizar taller existente
        MySQL.update.await([[
            UPDATE mechanic_shops 
            SET shop_name = ?, ownership_type = ?, job_name = ?, 
                minimum_grade = ?, boss_grade = ?, config_data = ?
            WHERE id = ?
        ]], {
            shopData.shop_name,
            shopData.ownership_type,
            shopData.job_name,
            shopData.minimum_grade,
            shopData.boss_grade,
            configJson,
            shopData.id
        })
        
        Notify(src, L('success_shop_updated'), 'success')
    else
        -- Crear nuevo taller
        MySQL.insert.await([[
            INSERT INTO mechanic_shops (id, shop_name, ownership_type, job_name, minimum_grade, boss_grade, owner_license, config_data)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ]], {
            shopData.id,
            shopData.shop_name,
            shopData.ownership_type,
            shopData.job_name,
            shopData.minimum_grade,
            shopData.boss_grade,
            Player.PlayerData.license,
            configJson
        })
        
        Notify(src, L('success_shop_created'), 'success')
    end
    
    -- Recargar talleres
    LoadShopsFromDatabase()
    
    -- Notificar a todos los clientes
    TriggerClientEvent('qb-mechanic:client:receiveShops', -1, loadedShops)
end)

-- ----------------------------------------------------------------------------
-- Event: Eliminar taller
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:deleteShop', function(shopId)
    local src = source
    
    -- Verificar permisos
    if not IsPlayerAceAllowed(src, Config.DefaultPermissions.CreatorAccess.ace) then
        Notify(src, L('error_not_authorized'), 'error')
        return
    end
    
    -- Eliminar de base de datos (CASCADE eliminará empleados, órdenes, etc)
    MySQL.query.await('DELETE FROM mechanic_shops WHERE id = ?', {shopId})
    
    -- Recargar talleres
    LoadShopsFromDatabase()
    
    -- Notificar a todos los clientes
    TriggerClientEvent('qb-mechanic:client:receiveShops', -1, loadedShops)
    
    Notify(src, L('success_shop_deleted'), 'success')
end)

-- ----------------------------------------------------------------------------
-- Event: Toggle duty
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:toggleDuty', function(shopId)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local shop = loadedShops[shopId]
    if not shop then return end
    
    -- Verificar autorización
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            Notify(src, L('error_not_authorized'), 'error')
            return
        end
    end
    
    -- Toggle duty
    local isOnDuty = onDutyPlayers[src]
    
    if isOnDuty then
        onDutyPlayers[src] = nil
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('qb-mechanic:client:dutyChanged', src, false)
    else
        onDutyPlayers[src] = shopId
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('qb-mechanic:client:dutyChanged', src, true)
    end
end)

RegisterNetEvent('qb-mechanic:server:teleportToShop', function(shopId)
    local src = source
    local shop = Database.GetShop(shopId) -- Usando tu módulo database
    if shop then
        -- Decodificar JSON si es necesario
        local loc = shop.config_data.locations.duty
        if loc then
            local ped = GetPlayerPed(src)
            SetEntityCoords(ped, loc.x, loc.y, loc.z, false, false, false, false)
        end
    end
end)
-- ----------------------------------------------------------------------------
-- Event: Jugador desconectado
-- ----------------------------------------------------------------------------
AddEventHandler('playerDropped', function()
    local src = source
    onDutyPlayers[src] = nil
end)

-- ----------------------------------------------------------------------------
-- Función: Obtener objeto del jugador
-- ----------------------------------------------------------------------------
function GetPlayer(source)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    end
end

-- ----------------------------------------------------------------------------
-- Función: Obtener citizenid del jugador
-- ----------------------------------------------------------------------------
function GetPlayerIdentifier(source)
    local Player = GetPlayer(source)
    if not Player then return nil end
    
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return Player.PlayerData.citizenid
    elseif Config.Framework == 'esx' then
        return Player.identifier
    end
end

-- ----------------------------------------------------------------------------
-- Función: Obtener nombre del jugador
-- ----------------------------------------------------------------------------
function GetPlayerName(source)
    local Player = GetPlayer(source)
    if not Player then return 'Unknown' end
    
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    elseif Config.Framework == 'esx' then
        return Player.getName()
    end
end

-- ----------------------------------------------------------------------------
-- Commands: Admin commands
-- ----------------------------------------------------------------------------
RegisterCommand('mechanic_reload', function(source, args)
    if source == 0 or IsPlayerAceAllowed(source, 'command.mechanic_reload') then
        LoadShopsFromDatabase()
        TriggerClientEvent('qb-mechanic:client:receiveShops', -1, loadedShops)
        
        if source > 0 then
            Notify(source, 'Shops reloaded successfully', 'success')
        else
            print('^2[QB-MECHANIC-PRO]^0 Shops reloaded successfully')
        end
    end
end, true)


-- ----------------------------------------------------------------------------
-- Debug: Mostrar información del servidor
-- ----------------------------------------------------------------------------
if Config.Debug then
    RegisterCommand('mechanic_info', function(source)
        if source == 0 or IsPlayerAceAllowed(source, 'command.mechanic_info') then
            print('^2========== SERVER INFO ==========^0')
            print('^3Total Shops:^0 ' .. #loadedShops)
            print('^3Players on Duty:^0 ' .. #onDutyPlayers)
            print('^2================================^0')
        end
    end, true)
end
