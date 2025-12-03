-- ============================================================================
-- QB-MECHANIC-PRO - Server Main Entry Point COMPLETO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Variables globales
-- ----------------------------------------------------------------------------
local QBCore = nil
local ESX = nil
local loadedShops = {}
local onDutyPlayers = {}

-- ----------------------------------------------------------------------------
-- Inicialización del Framework
-- ----------------------------------------------------------------------------
if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- ----------------------------------------------------------------------------
-- Función de traducción
-- ----------------------------------------------------------------------------
local function L(key, ...)
    local locale = Config.Locale or 'en'
    if Locale and Locale[locale] and Locale[locale][key] then
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
-- Función: Obtener objeto Player
-- ----------------------------------------------------------------------------
function GetPlayer(source)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == 'esx' then
        return ESX.GetPlayerFromId(source)
    end
end

-- ----------------------------------------------------------------------------
-- Exports globales
-- ----------------------------------------------------------------------------
exports('GetPlayer', GetPlayer)
exports('Notify', Notify)

-- ----------------------------------------------------------------------------
-- Función: Cargar talleres desde base de datos
-- ----------------------------------------------------------------------------
function LoadShopsFromDatabase()
    loadedShops = {}
    local shops = Database.GetAllShops()
    
    for _, shop in pairs(shops) do
        loadedShops[shop.id] = shop
        
        -- Crear stash si está habilitado
        if shop.config_data.features and shop.config_data.features.enable_stash then
            CreateMechanicStash(shop.id)
        end
    end
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Loaded %d shops from database', #shops))
    end
end

-- ----------------------------------------------------------------------------
-- Función: Inicializar stashes
-- ----------------------------------------------------------------------------
function InitializeStashes()
    for _, shop in pairs(loadedShops) do
        if shop.config_data.features and shop.config_data.features.enable_stash then
            CreateMechanicStash(shop.id)
        end
    end
    
    if Config.Debug then
        print('^2[QB-MECHANIC-PRO]^0 Stashes initialized')
    end
end

-- ----------------------------------------------------------------------------
-- Event: Solicitar lista de talleres
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
    if IsPlayerAceAllowed(src, 'mechanic.creator') then
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
    if not IsPlayerAceAllowed(src, 'mechanic.creator') then
        Notify(src, L('error_not_authorized'), 'error')
        return
    end
    
    -- Validar datos
    if not shopData.id or not shopData.shop_name then
        Notify(src, 'Invalid shop data', 'error')
        return
    end
    
    -- Verificar si el taller existe
    local exists = MySQL.scalar.await('SELECT id FROM mechanic_shops WHERE id = ?', {shopData.id})
    
    if exists then
        -- Actualizar taller existente
        local success = Database.UpdateShop(shopData.id, shopData)
        if success then
            Notify(src, L('success_shop_updated'), 'success')
        else
            Notify(src, 'Failed to update shop', 'error')
        end
    else
        -- Crear nuevo taller
        if not shopData.owner_license then
            shopData.owner_license = Player.PlayerData.license or Player.identifier
        end
        
        local success = Database.CreateShop(shopData)
        if success then
            Notify(src, L('success_shop_created'), 'success')
            
            -- Crear stash si está habilitado
            if shopData.config_data.features and shopData.config_data.features.enable_stash then
                CreateMechanicStash(shopData.id)
            end
        else
            Notify(src, 'Failed to create shop', 'error')
        end
    end
    
    -- Recargar talleres
    LoadShopsFromDatabase()
    
    -- Notificar a todos los clientes
    TriggerClientEvent('qb-mechanic:client:receiveShops', -1, loadedShops)
end)

-- ----------------------------------------------------------------------------
-- Event: Borrar taller
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:deleteShop', function(shopId)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar permisos
    if not IsPlayerAceAllowed(src, 'mechanic.creator') then
        Notify(src, L('error_not_authorized'), 'error')
        return
    end
    
    -- Borrar taller
    local success = Database.DeleteShop(shopId)
    
    if not success then
        Notify(src, 'Failed to delete shop', 'error')
        return
    end
    
    -- Eliminar de cache
    loadedShops[shopId] = nil
    
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
        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            if Player.PlayerData.job.name ~= shop.job_name then
                Notify(src, L('error_not_authorized'), 'error')
                return
            end
        elseif Config.Framework == 'esx' then
            if Player.job.name ~= shop.job_name then
                Notify(src, L('error_not_authorized'), 'error')
                return
            end
        end
    end
    
    -- Toggle duty
    local isOnDuty = onDutyPlayers[src]
    
    if isOnDuty then
        onDutyPlayers[src] = nil
        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            Player.Functions.SetJobDuty(false)
        elseif Config.Framework == 'esx' then
            -- ESX no tiene sistema de duty nativo
        end
        TriggerClientEvent('qb-mechanic:client:dutyChanged', src, false)
        Notify(src, 'You are now off duty', 'error')
    else
        onDutyPlayers[src] = shopId
        if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
            Player.Functions.SetJobDuty(true)
        elseif Config.Framework == 'esx' then
            -- ESX no tiene sistema de duty nativo
        end
        TriggerClientEvent('qb-mechanic:client:dutyChanged', src, true)
        Notify(src, 'You are now on duty', 'success')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Abrir stash
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:openStash', function(shopId)
    local src = source
    OpenMechanicStash(src, shopId)
end)

-- ----------------------------------------------------------------------------
-- Event: Teletransportar a taller
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:teleportToShop', function(shopId)
    local src = source
    local shop = Database.GetShop(shopId)
    
    if shop and shop.config_data and shop.config_data.locations and shop.config_data.locations.duty then
        local loc = shop.config_data.locations.duty
        TriggerClientEvent('qb-mechanic:client:teleport', src, loc.x, loc.y, loc.z)
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Inicialización del servidor
-- ----------------------------------------------------------------------------
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    Wait(1000) -- Esperar a que la base de datos esté lista
    
    if Config.Debug then
        print('^2========================================^0')
        print('^2[QB-MECHANIC-PRO] Server Starting^0')
        print('^3Framework:^0 ' .. Config.Framework)
        print('^3Inventory:^0 ' .. Config.Inventory)
        print('^3Society System:^0 ' .. Config.SocietySystem)
        print('^2========================================^0')
    end
    
    -- Cargar talleres desde la base de datos
    LoadShopsFromDatabase()
    
    -- Inicializar stashes
    InitializeStashes()
    
    if Config.Debug then
        print('^2[QB-MECHANIC-PRO]^0 Server initialized successfully')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Jugador desconectado (limpiar duty)
-- ----------------------------------------------------------------------------
AddEventHandler('playerDropped', function(reason)
    local src = source
    if onDutyPlayers[src] then
        onDutyPlayers[src] = nil
    end
end)

-- ----------------------------------------------------------------------------
-- Comando: Recargar talleres
-- ----------------------------------------------------------------------------
RegisterCommand('mechanic:reload', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'mechanic.admin') then
        LoadShopsFromDatabase()
        TriggerClientEvent('qb-mechanic:client:receiveShops', -1, loadedShops)
        
        if source > 0 then
            Notify(source, 'Shops reloaded successfully', 'success')
        else
            print('^2[QB-MECHANIC-PRO]^0 Shops reloaded successfully')
        end
    end
end, false)

-- ----------------------------------------------------------------------------
-- Comando: Ver estado de talleres
-- ----------------------------------------------------------------------------
RegisterCommand('mechanic:status', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'mechanic.admin') then
        local shopCount = 0
        local employeeCount = 0
        local orderCount = 0
        
        for _, shop in pairs(loadedShops) do
            shopCount = shopCount + 1
            local employees = Database.GetShopEmployees(shop.id)
            employeeCount = employeeCount + #employees
            local orders = Database.GetShopOrders(shop.id)
            orderCount = orderCount + #orders
        end
        
        local message = string.format(
            'Shops: %d | Employees: %d | Orders: %d | Players on duty: %d',
            shopCount, employeeCount, orderCount, CountTable(onDutyPlayers)
        )
        
        if source > 0 then
            Notify(source, message, 'inform')
        else
            print('^2[QB-MECHANIC-PRO]^0 ' .. message)
        end
    end
end, false)

-- ----------------------------------------------------------------------------
-- Callback: Calcular precio de modificación
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getModificationPrice', function(source, cb, modType, modIndex, level)
    local price = 0
    
    -- Buscar en configuración de modificaciones
    for _, category in pairs(Config.VehicleMods.Performance) do
        if category.id == modType then
            price = category.basePrice or 1000
            if level and level > 0 then
                price = price * (level + 1)
            end
            break
        end
    end
    
    if price == 0 then
        for _, category in pairs(Config.VehicleMods.Cosmetic) do
            if category.id == modType then
                price = category.basePrice or 1000
                break
            end
        end
    end
    
    cb(price)
end)

-- ----------------------------------------------------------------------------
-- Event: Procesar compra de modificaciones
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:purchaseMods', function(data)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local totalCost = tonumber(data.totalCost)
    
    if not totalCost or totalCost <= 0 then
        Notify(src, 'Invalid purchase amount', 'error')
        return
    end
    
    -- Verificar método de pago
    local paymentMethod = data.paymentMethod or 'bank'
    
    if Player.PlayerData.money[paymentMethod] < totalCost then
        Notify(src, 'Insufficient funds', 'error')
        TriggerClientEvent('qb-mechanic:client:purchaseFailed', src)
        return
    end
    
    -- Cobrar
    Player.Functions.RemoveMoney(paymentMethod, totalCost, 'mechanic-tuneshop')
    
    -- Aplicar modificaciones al vehículo
    TriggerClientEvent('qb-mechanic:client:applyPurchasedMods', src, data.modifications)
    
    Notify(src, 'Purchase successful', 'success')
end)
-- ----------------------------------------------------------------------------
-- Función auxiliar: Contar tabla
-- ----------------------------------------------------------------------------
function CountTable(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end