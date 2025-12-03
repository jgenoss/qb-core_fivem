local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================================
-- FUNCIÓN DE VERIFICACIÓN DE PERMISOS
-- ================================================================
local function HasPermission(source)
    return IsPlayerAceAllowed(source, "command")
end

-- ================================================================
-- INICIALIZACIÓN DE BASE DE DATOS
-- ================================================================
CreateThread(function()
    local success = MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `server_shops_v3` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `name` VARCHAR(100) NOT NULL,
            `type` VARCHAR(50) DEFAULT 'general',
            `pedModel` VARCHAR(50) DEFAULT 'mp_m_shopkeep_01',
            `coords` TEXT NOT NULL,
            `items` LONGTEXT NOT NULL,
            `blip` TEXT NULL,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`),
            KEY `idx_type` (`type`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]])
    
    if success then
        print("^2[QB-ShopCreator] Tabla 'server_shops_v3' verificada correctamente")
    else
        print("^1[ERROR] No se pudo crear/verificar la tabla de tiendas")
    end
end)

-- ================================================================
-- COMANDO ADMIN
-- ================================================================
QBCore.Commands.Add('adminshops', 'Panel de Tiendas (Admin)', {}, false, function(source)
    if IsPlayerAceAllowed(source, "command") then
        TriggerClientEvent('shopcreator:client:OpenDashboard', source)
    else
        TriggerClientEvent('QBCore:Notify', source, 'Acceso denegado', 'error')
    end
end)

-- ================================================================
-- CALLBACKS
-- ================================================================

-- Obtener todas las tiendas
QBCore.Functions.CreateCallback('shopcreator:server:GetAllShops', function(source, cb)
    MySQL.query('SELECT * FROM server_shops_v3 ORDER BY id DESC', {}, function(result)
        if not result then cb({}) return end
        
        for k, shop in pairs(result) do
            -- 🔥 FIX: Forzar conversión de ID a número
            shop.id = tonumber(shop.id)
            shop.coords = json.decode(shop.coords) or {x=0,y=0,z=0,h=0}
            shop.items = json.decode(shop.items) or {}
            shop.blip = json.decode(shop.blip or '{"enable":false}')
            result[k] = shop
        end
        cb(result)
    end)
end)

QBCore.Functions.CreateCallback('shopcreator:server:GetItems', function(source, cb)
    local items = {}
    for k, v in pairs(QBCore.Shared.Items) do
        table.insert(items, {
            name = k,
            label = v.label,
            image = v.image or (k..".png")
        })
    end
    table.sort(items, function(a, b) return a.label < b.label end)
    cb(items)
end)

function SyncShops()
    local result = MySQL.query.await('SELECT * FROM server_shops_v3')
    if result then
        for k, shop in pairs(result) do
            -- 🔥 FIX: Asegurar que el ID sea número limpio
            shop.id = tonumber(shop.id)
            shop.coords = json.decode(shop.coords)
            shop.items = json.decode(shop.items)
            shop.blip = json.decode(shop.blip or '{"enable":false}')
            result[k] = shop
        end
        TriggerClientEvent('shopcreator:client:Sync', -1, result)
        print('^2[SYNC] ' .. #result .. ' tiendas sincronizadas con todos los clientes^0')
    end
end

-- ================================================================
-- EVENTOS DE GESTIÓN (CREAR / BORRAR)
-- ================================================================

RegisterNetEvent('shopcreator:server:CreateShop', function(data)
    local src = source
    if not HasPermission(src) then return end
    
    MySQL.insert('INSERT INTO server_shops_v3 (name, type, pedModel, coords, items, blip) VALUES (?, ?, ?, ?, ?, ?)', {
        data.name, 
        data.type, 
        data.pedModel, 
        json.encode(data.coords), 
        json.encode(data.items), 
        json.encode(data.blip)
    }, function(id)
        if id then
            TriggerClientEvent('QBCore:Notify', src, 'Tienda creada #'..id, 'success')
            SyncShops()
        end
    end)
end)

RegisterNetEvent('shopcreator:server:DeleteShop', function(data)
    local src = source
    if not HasPermission(src) then return end
    
    -- 🔥 FIX: Extraer ID correctamente del objeto data
    local shopId = nil
    if type(data) == 'table' then
        shopId = tonumber(data.id)
    else
        shopId = tonumber(data)
    end
    
    if not shopId then 
        print('^1[ERROR] shopcreator:server:DeleteShop - ID inválido recibido: ' .. tostring(data) .. '^0')
        return 
    end

    MySQL.update('DELETE FROM server_shops_v3 WHERE id = ?', {shopId}, function(affected)
        if affected > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Tienda eliminada correctamente', 'success')
            SyncShops()
        else
            TriggerClientEvent('QBCore:Notify', src, 'No se encontró la tienda', 'error')
        end
    end)
end)

-- ================================================================
-- 📝 EDICIÓN DE TIENDA (NUEVO - AÑADIR DESPUÉS DE DeleteShop)
-- ================================================================

RegisterNetEvent('shopcreator:server:UpdateShop', function(data)
    local src = source
    if not HasPermission(src) then return end
    
    local shopId = tonumber(data.id)
    if not shopId then 
        print('^1[ERROR] shopcreator:server:UpdateShop - ID inválido recibido^0')
        return 
    end

    -- Verificar que la tienda existe antes de actualizar
    local exists = MySQL.scalar.await('SELECT id FROM server_shops_v3 WHERE id = ?', {shopId})
    if not exists then
        TriggerClientEvent('QBCore:Notify', src, 'Tienda no encontrada', 'error')
        return
    end

    -- Actualizar en la base de datos
    MySQL.update([[
        UPDATE server_shops_v3 
        SET name = ?, type = ?, pedModel = ?, coords = ?, items = ?, blip = ? 
        WHERE id = ?
    ]], {
        data.name, 
        data.type, 
        data.pedModel, 
        json.encode(data.coords), 
        json.encode(data.items), 
        json.encode(data.blip),
        shopId
    }, function(affected)
        if affected > 0 then
            TriggerClientEvent('QBCore:Notify', src, 'Tienda actualizada correctamente', 'success')
            SyncShops() -- Sincronizar con todos los clientes
        else
            TriggerClientEvent('QBCore:Notify', src, 'Error al actualizar tienda', 'error')
        end
    end)
end)

-- ================================================================
-- 📊 CALLBACK PARA OBTENER UNA TIENDA INDIVIDUAL (PARA EDICIÓN)
-- ================================================================

QBCore.Functions.CreateCallback('shopcreator:server:GetShop', function(source, cb, shopId)
    local id = tonumber(shopId)
    if not id then cb(nil) return end
    
    MySQL.query('SELECT * FROM server_shops_v3 WHERE id = ?', {id}, function(result)
        if not result or not result[1] then 
            cb(nil) 
            return 
        end
        
        local shop = result[1]
        shop.id = tonumber(shop.id)
        shop.coords = json.decode(shop.coords) or {x=0,y=0,z=0,h=0}
        shop.items = json.decode(shop.items) or {}
        shop.blip = json.decode(shop.blip or '{"enable":false}')
        
        cb(shop)
    end)
end)

-- ================================================================
-- APERTURA DE TIENDA (FIXED & SECURE) ⚠️ CORRECCIÓN CRÍTICA
-- ================================================================
-- RegisterNetEvent('shopcreator:server:OpenShop', function(shopId)
--     local src = source
    
--     -- 🔥 FIX: Forzar conversión a número, independientemente del tipo recibido
--     local id = tonumber(shopId)
--     if not id then 
--         print('^1[ERROR] shopcreator:server:OpenShop - ID inválido recibido: ' .. tostring(shopId) .. '^0')
--         return 
--     end

--     -- Ahora consultar con el ID numérico limpio
--     local result = MySQL.query.await('SELECT * FROM server_shops_v3 WHERE id = ?', {id})
--     if not result or not result[1] then 
--         print('^1[ERROR] Tienda no encontrada con ID: ' .. id .. '^0')
--         return 
--     end
    
--     local shop = result[1]
--     local dbItems = json.decode(shop.items) or {}
--     local finalItems = {}
--     local slot = 1

--     for _, v in pairs(dbItems) do
--         if v.name and QBCore.Shared.Items[v.name:lower()] then
--             table.insert(finalItems, {
--                 name = v.name:lower(),
--                 price = tonumber(v.price) or 0,
--                 amount = tonumber(v.amount) or 100,
--                 info = {},
--                 type = 'item',
--                 slot = slot
--             })
--             slot = slot + 1
--         end
--     end

--     local coords = json.decode(shop.coords)
--     local shopName = 'shop_dynamic_'..id

--     exports['qb-inventory']:CreateShop({
--         name = shopName,
--         label = shop.name,
--         coords = vector4(coords.x, coords.y, coords.z, coords.h),
--         slots = #finalItems + 2,
--         items = finalItems
--     })

--     exports['qb-inventory']:OpenShop(src, shopName)
-- end)