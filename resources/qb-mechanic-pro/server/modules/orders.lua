-- server/modules/orders.lua

-- Evento: Cancelar Orden
RegisterNetEvent('qb-mechanic:server:cancelOrder', function(orderId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local order = Database.GetOrder(orderId)
    if not order then return end
    
    -- Verificar permisos (Solo el creador, un empleado del taller o un admin pueden cancelar)
    local isEmployee = Database.IsEmployee(order.shop_id, Player.PlayerData.citizenid)
    local isCustomer = order.customer_citizenid == Player.PlayerData.citizenid
    
    if not isEmployee and not isCustomer then
        TriggerClientEvent('QBCore:Notify', src, 'No autorizado para cancelar esta orden', 'error')
        return
    end

    -- Reembolso si aplica (Configurable)
    if order.status == 'pending' then
        -- Devolver dinero al cliente (si está online o offline handling)
        -- Implementación simple de reembolso al cliente online:
        local Customer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
        if Customer then
            Customer.Functions.AddMoney('bank', order.total_cost, 'mechanic-refund')
            TriggerClientEvent('QBCore:Notify', Customer.PlayerData.source, 'Orden #'..orderId..' cancelada. Reembolso recibido.', 'success')
        else
            -- TODO: Implementar reembolso offline si es necesario
        end
        
        Database.UpdateOrderStatus(orderId, 'cancelled')
        TriggerClientEvent('QBCore:Notify', src, 'Orden cancelada', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'No se puede cancelar una orden en proceso o finalizada', 'error')
    end
end)

-- Tarea periódica: Limpiar órdenes viejas (Garbage Collector)
CreateThread(function()
    while true do
        Wait(60 * 60 * 1000) -- Cada 1 hora
        
        -- Borrar órdenes pendientes con más de 3 días de antigüedad
        MySQL.query('DELETE FROM mechanic_orders WHERE status = ? AND created_at < NOW() - INTERVAL 3 DAY', {'pending'})
        
        if Config.Debug then print('^2[QB-MECHANIC-PRO]^0 Cleaned old pending orders') end
    end
end)