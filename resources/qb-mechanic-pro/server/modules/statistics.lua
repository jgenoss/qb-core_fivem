-- server/modules/statistics.lua

-- Función para recalcular estadísticas de un taller
local function UpdateShopStats(shopId)
    local revenue = MySQL.scalar.await([[
        SELECT SUM(amount) FROM mechanic_transactions 
        WHERE shop_id = ? AND transaction_type = 'order_payment' 
        AND created_at > NOW() - INTERVAL 7 DAY
    ]], {shopId}) or 0
    
    local ordersCount = MySQL.scalar.await([[
        SELECT COUNT(*) FROM mechanic_orders 
        WHERE shop_id = ? AND status = 'completed'
        AND created_at > NOW() - INTERVAL 7 DAY
    ]], {shopId}) or 0

    -- Aquí podrías guardar estos datos en una tabla de cache si las consultas son muy pesadas
    return {
        weeklyRevenue = revenue,
        weeklyOrders = ordersCount
    }
end

-- Evento: Solicitar estadísticas avanzadas (para la pestaña Dashboard)
RegisterNetEvent('qb-mechanic:server:getDashboardStats', function(shopId)
    local src = source
    local stats = UpdateShopStats(shopId)
    
    -- Obtener top empleado
    local topEmployee = MySQL.single.await([[
        SELECT mechanic_name, COUNT(*) as jobs_done 
        FROM mechanic_orders 
        WHERE shop_id = ? AND status = 'completed' 
        GROUP BY mechanic_citizenid 
        ORDER BY jobs_done DESC LIMIT 1
    ]], {shopId})
    
    TriggerClientEvent('qb-mechanic:client:updateDashboard', src, {
        revenue = stats.weeklyRevenue,
        orders = stats.weeklyOrders,
        topEmployee = topEmployee
    })
end)