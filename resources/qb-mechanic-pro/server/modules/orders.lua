-- ============================================================================
-- QB-MECHANIC-PRO - Orders Module COMPLETO (Server)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Event: Cancelar Orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:cancelOrder', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local order = Database.GetOrder(orderId)
    if not order then
        TriggerClientEvent('QBCore:Notify', src, 'Order not found', 'error')
        return
    end
    
    -- Verificar permisos
    local isEmployee = Database.IsEmployee(order.shop_id, Player.PlayerData.citizenid)
    local isCustomer = order.customer_citizenid == Player.PlayerData.citizenid
    local shop = Database.GetShop(order.shop_id)
    local isBoss = false
    
    if shop and shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name == shop.job_name then
            isBoss = Player.PlayerData.job.grade.level >= (shop.boss_grade or 3)
        end
    end
    
    if not isEmployee and not isCustomer and not isBoss then
        TriggerClientEvent('QBCore:Notify', src, 'Not authorized to cancel this order', 'error')
        return
    end

    -- Solo se puede cancelar si está pendiente
    if order.status == 'pending' then
        -- Reembolso al cliente
        local Customer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
        if Customer then
            Customer.Functions.AddMoney('bank', order.total_cost, 'mechanic-refund')
            TriggerClientEvent('QBCore:Notify', Customer.PlayerData.source, 
                'Order #'..orderId..' cancelled. Refund received.', 'success')
        else
            -- Reembolso offline
            MySQL.update.await([[
                UPDATE players 
                SET money = JSON_SET(money, '$.bank', JSON_EXTRACT(money, '$.bank') + ?) 
                WHERE citizenid = ?
            ]], {order.total_cost, order.customer_citizenid})
        end
        
        -- Remover dinero de la sociedad
        if shop.ownership_type == 'job' and shop.job_name then
            RemoveShopMoney(shop.job_name, order.total_cost, 'Order #'..orderId..' cancelled')
        end
        
        -- Registrar transacción de cancelación
        Database.CreateTransaction({
            shopId = order.shop_id,
            type = 'refund',
            amount = order.total_cost,
            description = 'Refund for cancelled order #' .. orderId,
            employeeCitizenid = nil,
            orderId = orderId
        })
        
        -- Eliminar orden
        Database.DeleteOrder(orderId)
        
        TriggerClientEvent('QBCore:Notify', src, 'Order cancelled', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Cannot cancel order in progress or completed', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Obtener órdenes por matrícula
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getOrdersByPlate', function(source, cb, plate)
    local orders = Database.GetOrdersByPlate(plate)
    cb(orders)
end)

-- ----------------------------------------------------------------------------
-- Event: Asignar mecánico a orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:assignMechanicToOrder', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local order = Database.GetOrder(orderId)
    if not order then
        TriggerClientEvent('QBCore:Notify', src, 'Order not found', 'error')
        return
    end
    
    local shop = Database.GetShop(order.shop_id)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar que el mecánico pertenece al taller
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
    end
    
    -- Asignar mecánico
    local mechanicName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    Database.UpdateOrderStatus(orderId, 'assigned', Player.PlayerData.citizenid, mechanicName)
    
    TriggerClientEvent('QBCore:Notify', src, 'Order assigned to you', 'success')
end)

-- ----------------------------------------------------------------------------
-- Tarea periódica: Limpiar órdenes antiguas
-- ----------------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(60 * 60 * 1000) -- Cada 1 hora
        
        -- Borrar órdenes pendientes con más de 7 días
        MySQL.query('DELETE FROM mechanic_orders WHERE status = ? AND created_at < NOW() - INTERVAL 7 DAY', {'pending'})
        
        -- Borrar órdenes completadas con más de 30 días
        MySQL.query('DELETE FROM mechanic_orders WHERE status = ? AND created_at < NOW() - INTERVAL 30 DAY', {'completed'})
        
        if Config.Debug then 
            print('^2[QB-MECHANIC-PRO]^0 Cleaned old orders') 
        end
    end
end)