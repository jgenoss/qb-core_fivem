local QBCore = exports['qb-core']:GetCoreObject()

-- ================================================================
-- FUNCIÓN: VERIFICAR DISPONIBILIDAD DE ITEM EN TIENDA
-- ================================================================
local function IsItemAvailable(shopItems, itemName, quantity)
    for _, item in ipairs(shopItems) do
        if item.name:lower() == itemName:lower() then
            -- Verificar stock (-1 = ilimitado)
            if item.amount == -1 or item.amount >= quantity then
                return true, item.price
            else
                return false, 0, "Stock insuficiente"
            end
        end
    end
    return false, 0, "Item no disponible en esta tienda"
end

-- ================================================================
-- FUNCIÓN: VERIFICAR FONDOS DEL JUGADOR
-- ================================================================
local function HasSufficientFunds(Player, amount, paymentMethod)
    if paymentMethod == "cash" then
        local cash = Player.PlayerData.money.cash or 0
        return cash >= amount
    elseif paymentMethod == "bank" then
        local bank = Player.PlayerData.money.bank or 0
        return bank >= amount
    end
    return false
end

-- ================================================================
-- EVENTO: SOLICITAR APERTURA DE TIENDA
-- ================================================================
RegisterNetEvent('qb-shop-ui:server:RequestShopOpen', function(shopId)
    local src = source
    local id = tonumber(shopId)
    
    if not id then 
        print('^1[qb-shop-ui] ID inválido recibido: ' .. tostring(shopId) .. '^0')
        return 
    end

    local result = MySQL.query.await('SELECT * FROM ' .. Config.ShopsTable .. ' WHERE id = ?', {id})
    if not result or not result[1] then 
        print('^1[qb-shop-ui] Tienda no encontrada con ID: ' .. id .. '^0')
        return 
    end
    
    local shop = result[1]
    
    -- Preparar datos para enviar al cliente
    local shopData = {
        id = tonumber(shop.id),
        name = shop.name,
        type = shop.type,
        items = json.decode(shop.items) or {}
    }
    
    -- Enviar al cliente
    TriggerClientEvent('qb-shop-ui:client:OpenShop', src, shopData)
end)

-- ================================================================
-- CALLBACK: PROCESAR COMPRA
-- ================================================================
QBCore.Functions.CreateCallback('qb-shop-ui:server:ProcessPurchase', function(source, cb, data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb({success = false, message = "Jugador no encontrado"})
        return
    end
    
    -- Validaciones básicas
    if not data.shopId or not data.cart or not data.paymentMethod or not data.total then
        cb({success = false, message = "Datos incompletos"})
        return
    end
    
    -- Obtener información de la tienda
    local result = MySQL.query.await('SELECT * FROM ' .. Config.ShopsTable .. ' WHERE id = ?', {tonumber(data.shopId)})
    if not result or not result[1] then
        cb({success = false, message = "Tienda no encontrada"})
        return
    end
    
    local shop = result[1]
    local shopItems = json.decode(shop.items) or {}
    
    -- Validar cada item del carrito
    local totalPrice = 0
    local itemsToGive = {}
    
    for _, cartItem in ipairs(data.cart) do
        local available, price, errMsg = IsItemAvailable(shopItems, cartItem.name, cartItem.qty)
        
        if not available then
            cb({success = false, message = errMsg or "Item no disponible"})
            return
        end
        
        -- Verificar que el precio coincida (anti-exploit)
        if math.abs(price - cartItem.price) > 0.01 then
            cb({success = false, message = "Precio alterado detectado"})
            return
        end
        
        totalPrice = totalPrice + (price * cartItem.qty)
        table.insert(itemsToGive, {
            name = cartItem.name:lower(),
            amount = cartItem.qty
        })
    end
    
    -- Verificar que el total calculado coincida con el enviado
    if math.abs(totalPrice - data.total) > 0.01 then
        cb({success = false, message = "Total alterado detectado"})
        return
    end
    
    -- Verificar fondos
    if not HasSufficientFunds(Player, totalPrice, data.paymentMethod) then
        cb({success = false, message = "Fondos insuficientes"})
        return
    end
    
    -- Procesar pago
    if data.paymentMethod == "cash" then
        Player.Functions.RemoveMoney('cash', totalPrice, "shop-purchase")
    elseif data.paymentMethod == "bank" then
        Player.Functions.RemoveMoney('bank', totalPrice, "shop-purchase")
    end
    
    -- Entregar items
    local itemsGiven = 0
    for _, item in ipairs(itemsToGive) do
        if Player.Functions.AddItem(item.name, item.amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item.name], "add", item.amount)
            itemsGiven = itemsGiven + 1
        end
    end
    
    if itemsGiven == #itemsToGive then
        -- Log de la transacción
        print(string.format(
            "^2[SHOP] %s compró %d items en '%s' por $%d (%s)^0",
            Player.PlayerData.name,
            #itemsToGive,
            shop.name,
            totalPrice,
            data.paymentMethod
        ))
        
        cb({
            success = true, 
            message = string.format("Compra realizada: $%d", totalPrice)
        })
    else
        -- Reembolso si algo falló
        if data.paymentMethod == "cash" then
            Player.Functions.AddMoney('cash', totalPrice, "shop-refund")
        elseif data.paymentMethod == "bank" then
            Player.Functions.AddMoney('bank', totalPrice, "shop-refund")
        end
        
        cb({success = false, message = "Error al entregar items. Fondos reembolsados."})
    end
end)