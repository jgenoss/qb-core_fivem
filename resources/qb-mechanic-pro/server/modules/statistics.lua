-- ============================================================================
-- QB-MECHANIC-PRO - Statistics Module (Server)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Callback: Obtener estadísticas globales del sistema
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getGlobalStats', function(source, cb)
    local stats = Database.GetGlobalStats()
    cb(stats)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener top mecánicos por comisiones
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getTopMechanics', function(source, cb, shopId, limit)
    local query = [[
        SELECT 
            me.employee_name,
            me.citizenid,
            COUNT(DISTINCT mo.id) as orders_completed,
            SUM(mt.amount) as total_commissions
        FROM mechanic_employees me
        LEFT JOIN mechanic_orders mo ON mo.mechanic_citizenid = me.citizenid AND mo.status = 'completed'
        LEFT JOIN mechanic_transactions mt ON mt.employee_citizenid = me.citizenid AND mt.transaction_type = 'commission'
        WHERE me.shop_id = ?
        GROUP BY me.citizenid
        ORDER BY total_commissions DESC
        LIMIT ?
    ]]
    
    local result = MySQL.query.await(query, {shopId, limit or 10})
    cb(result)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener estadísticas por período
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getStatsForPeriod', function(source, cb, shopId, period)
    -- period: 'day', 'week', 'month', 'year'
    local interval = 'DAY'
    if period == 'week' then interval = 'WEEK'
    elseif period == 'month' then interval = 'MONTH'
    elseif period == 'year' then interval = 'YEAR'
    end
    
    local query = string.format([[
        SELECT 
            DATE(created_at) as date,
            COUNT(*) as order_count,
            SUM(total_cost) as revenue,
            AVG(total_cost) as avg_order_value
        FROM mechanic_orders
        WHERE shop_id = ? AND created_at >= NOW() - INTERVAL 1 %s
        GROUP BY DATE(created_at)
        ORDER BY date DESC
    ]], interval)
    
    local result = MySQL.query.await(query, {shopId})
    cb(result)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener vehículos más modificados
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getPopularVehicles', function(source, cb, shopId, limit)
    local query = [[
        SELECT 
            vehicle_model,
            COUNT(*) as modification_count,
            SUM(total_cost) as total_revenue
        FROM mechanic_orders
        WHERE shop_id = ?
        GROUP BY vehicle_model
        ORDER BY modification_count DESC
        LIMIT ?
    ]]
    
    local result = MySQL.query.await(query, {shopId, limit or 10})
    cb(result)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener modificaciones más populares
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getPopularModifications', function(source, cb, shopId)
    local orders = Database.GetShopOrders(shopId, 'completed')
    local modCounts = {}
    
    for _, order in ipairs(orders) do
        if order.modifications then
            for _, mod in ipairs(order.modifications) do
                local modType = mod.type or 'unknown'
                modCounts[modType] = (modCounts[modType] or 0) + 1
            end
        end
    end
    
    -- Convertir a array ordenado
    local result = {}
    for modType, count in pairs(modCounts) do
        table.insert(result, {type = modType, count = count})
    end
    
    table.sort(result, function(a, b) return a.count > b.count end)
    
    cb(result)
end)

-- ----------------------------------------------------------------------------
-- Comando: Exportar estadísticas a JSON
-- ----------------------------------------------------------------------------
RegisterCommand('mechanic:export-stats', function(source, args, rawCommand)
    if source == 0 or IsPlayerAceAllowed(source, 'command') then
        local shopId = args[1]
        
        if not shopId then
            print('^3Usage: /mechanic:export-stats <shopId>^0')
            return
        end
        
        local shop = Database.GetShop(shopId)
        if not shop then
            print('^1Shop not found^0')
            return
        end
        
        local stats = {
            shop = shop.shop_name,
            generated = os.date('%Y-%m-%d %H:%M:%S'),
            overview = Database.GetShopStats(shopId),
            orders = Database.GetShopOrders(shopId),
            employees = Database.GetShopEmployees(shopId),
            transactions = Database.GetShopTransactions(shopId, 100),
        }
        
        local filename = 'stats_' .. shopId .. '_' .. os.date('%Y%m%d_%H%M%S') .. '.json'
        SaveResourceFile(GetCurrentResourceName(), filename, json.encode(stats, {indent = true}))
        
        print('^2Stats exported to: ' .. filename .. '^0')
        
        if source > 0 then
            TriggerClientEvent('QBCore:Notify', source, 'Stats exported: ' .. filename, 'success')
        end
    end
end, false)