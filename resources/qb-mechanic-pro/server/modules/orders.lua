-- ============================================================================
-- QB-MECHANIC-PRO - Orders Module (Server) COMPLETO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Event: Iniciar instalación de orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:startInstallation', function(orderId)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local order = Database.GetOrder(orderId)
    if not order then
        Notify(src, 'Order not found', 'error')
        return
    end
    
    if order.status ~= 'pending' then
        Notify(src, 'Order is not pending', 'error')
        return
    end
    
    -- Verificar que el mecánico pertenece al taller
    local shop = Database.GetShop(order.shop_id)
    if not shop then
        Notify(src, 'Shop not found', 'error')
        return
    end
    
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            Notify(src, 'Not authorized for this shop', 'error')
            return
        end
    end
    
    -- Actualizar estado a "installing"
    local mechanicName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    Database.UpdateOrderStatus(orderId, 'installing', Player.PlayerData.citizenid, mechanicName)
    
    -- Enviar orden completa al cliente para iniciar proceso
    TriggerClientEvent('qb-mechanic:client:beginInstallation', src, order)
    
    Notify(src, 'Installation started', 'success')
end)

-- ----------------------------------------------------------------------------
-- Event: Completar orden (llamado desde cliente después de InstallModifications)
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:completeOrder', function(orderId, success)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local order = Database.GetOrder(orderId)
    if not order then return end
    
    if success then
        -- Marcar orden como completada
        Database.UpdateOrderStatus(orderId, 'completed')
        
        -- Pagar comisión al mecánico (si está habilitado)
        if Config.EnableCommissions then
            local commission = math.floor(order.total_cost * (Config.CommissionRate or 0.10))
            Player.Functions.AddMoney('bank', commission, 'mechanic-commission')
            
            -- Registrar transacción de comisión
            Database.CreateTransaction({
                shopId = order.shop_id,
                type = 'commission',
                amount = commission,
                description = 'Commission for order #' .. orderId,
                employeeCitizenid = Player.PlayerData.citizenid,
                orderId = orderId
            })
            
            Notify(src, 'Order completed! Commission: $' .. commission, 'success')
        else
            Notify(src, 'Order completed successfully', 'success')
        end
        
        -- Notificar al cliente propietario del vehículo
        local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
        if targetPlayer then
            Notify(targetPlayer.PlayerData.source, 'Your vehicle modifications have been installed!', 'success')
        end
    else
        -- Marcar orden como fallida
        Database.UpdateOrderStatus(orderId, 'failed')
        
        -- Refund al cliente
        local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
        if targetPlayer then
            targetPlayer.Functions.AddMoney('bank', order.total_cost, 'mechanic-order-refund')
            Notify(targetPlayer.PlayerData.source, 'Installation failed. Refund issued: $' .. order.total_cost, 'inform')
        end
        
        Notify(src, 'Installation failed. Customer refunded.', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Asignar orden a mecánico
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:assignOrder', function(orderId)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local order = Database.GetOrder(orderId)
    if not order then
        Notify(src, 'Order not found', 'error')
        return
    end
    
    local shop = Database.GetShop(order.shop_id)
    if not shop then return end
    
    -- Verificar que el mecánico pertenece al taller
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            Notify(src, 'Not authorized', 'error')
            return
        end
    end
    
    -- Asignar mecánico
    local mechanicName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    Database.UpdateOrderStatus(orderId, 'assigned', Player.PlayerData.citizenid, mechanicName)
    
    Notify(src, 'Order assigned to you', 'success')
end)

-- ----------------------------------------------------------------------------
-- Event: Cancelar orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:cancelOrder', function(orderId, reason)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local order = Database.GetOrder(orderId)
    if not order then
        Notify(src, 'Order not found', 'error')
        return
    end
    
    -- Solo el cliente o un boss pueden cancelar
    local shop = Database.GetShop(order.shop_id)
    local canCancel = false
    
    if Player.PlayerData.citizenid == order.customer_citizenid then
        canCancel = true
    elseif shop and shop.ownership_type == 'job' then
        if Player.PlayerData.job.name == shop.job_name and 
           Player.PlayerData.job.grade.level >= (shop.boss_grade or 4) then
            canCancel = true
        end
    end
    
    if not canCancel then
        Notify(src, 'Not authorized to cancel this order', 'error')
        return
    end
    
    -- Refund al cliente si la orden estaba pendiente
    if order.status == 'pending' then
        local targetPlayer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
        if targetPlayer then
            targetPlayer.Functions.AddMoney('bank', order.total_cost, 'mechanic-order-cancel')
            Notify(targetPlayer.PlayerData.source, 'Order cancelled. Refund: $' .. order.total_cost, 'inform')
        end
    end
    
    -- Eliminar orden
    Database.DeleteOrder(orderId)
    
    Notify(src, 'Order cancelled', 'success')
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener detalles de orden específica
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getOrderDetails', function(source, cb, orderId)
    local order = Database.GetOrder(orderId)
    cb(order)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener órdenes pendientes de un taller
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getPendingOrders', function(source, cb, shopId)
    local orders = Database.GetPendingOrders(shopId)
    cb(orders)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener historial de órdenes por placa
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getOrdersByPlate', function(source, cb, plate)
    local orders = Database.GetOrdersByPlate(plate)
    cb(orders)
end)

-- ----------------------------------------------------------------------------
-- Tarea Periódica: Limpiar órdenes antiguas
-- ----------------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(60 * 60 * 1000) -- Cada 1 hora
        
        -- Borrar órdenes pendientes con más de 7 días
        MySQL.query('DELETE FROM mechanic_orders WHERE status = ? AND created_at < NOW() - INTERVAL 7 DAY', {'pending'})
        
        -- Borrar órdenes completadas con más de 30 días
        MySQL.query('DELETE FROM mechanic_orders WHERE status = ? AND completed_at < NOW() - INTERVAL 30 DAY', {'completed'})
        
        if Config.Debug then 
            print('^2[QB-MECHANIC-PRO]^0 Cleaned old orders') 
        end
    end
end)

-- ----------------------------------------------------------------------------
-- Comando Admin: Ver órdenes de un taller
-- ----------------------------------------------------------------------------
RegisterCommand('mechanic:orders', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'mechanic.admin') then
        local shopId = args[1]
        
        if not shopId then
            print('^3Usage: /mechanic:orders <shopId>^0')
            return
        end
        
        local orders = Database.GetShopOrders(shopId)
        print('^2[QB-MECHANIC-PRO]^0 Orders for shop ' .. shopId .. ':')
        
        for _, order in ipairs(orders) do
            print(string.format('  - Order #%d | Plate: %s | Status: %s | Cost: $%d', 
                order.id, order.vehicle_plate, order.status, order.total_cost))
        end
    end
end, false)