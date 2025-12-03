-- ============================================================================
-- QB-MECHANIC-PRO - Employees Module (Server)
-- ============================================================================

-- Ya existe el evento updateEmployeeGrade en shops.lua, pero vamos a consolidar todo aquí

-- ----------------------------------------------------------------------------
-- Callback: Obtener información de empleado
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getEmployeeInfo', function(source, cb, citizenid)
    local query = [[
        SELECT 
            me.*,
            COUNT(DISTINCT mo.id) as completed_orders,
            SUM(mt.amount) as total_commissions
        FROM mechanic_employees me
        LEFT JOIN mechanic_orders mo ON mo.mechanic_citizenid = me.citizenid AND mo.status = 'completed'
        LEFT JOIN mechanic_transactions mt ON mt.employee_citizenid = me.citizenid AND mt.transaction_type = 'commission'
        WHERE me.citizenid = ?
        GROUP BY me.id
    ]]
    
    local result = MySQL.single.await(query, {citizenid})
    cb(result)
end)

-- ----------------------------------------------------------------------------
-- Callback: Obtener actividad del empleado
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getEmployeeActivity', function(source, cb, citizenid, shopId)
    local recentOrders = MySQL.query.await([[
        SELECT * FROM mechanic_orders 
        WHERE mechanic_citizenid = ? AND shop_id = ?
        ORDER BY completed_at DESC 
        LIMIT 20
    ]], {citizenid, shopId})
    
    local recentTransactions = MySQL.query.await([[
        SELECT * FROM mechanic_transactions 
        WHERE employee_citizenid = ? AND shop_id = ?
        ORDER BY created_at DESC 
        LIMIT 20
    ]], {citizenid, shopId})
    
    cb({
        orders = recentOrders,
        transactions = recentTransactions
    })
end)

-- ----------------------------------------------------------------------------
-- Event: Establecer empleado del mes
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:setEmployeeOfMonth', function(shopId, citizenid)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        Notify(src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if not Config.DefaultPermissions.ManagementAccess(Player, shop) then
        Notify(src, 'Not authorized', 'error')
        return
    end
    
    -- Actualizar en database
    MySQL.update.await([[
        UPDATE mechanic_shops 
        SET config_data = JSON_SET(config_data, '$.employeeOfMonth', ?)
        WHERE id = ?
    ]], {citizenid, shopId})
    
    -- Notificar al empleado si está online
    local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if TargetPlayer then
        Notify(TargetPlayer.PlayerData.source, 'You have been selected as Employee of the Month!', 'success')
    end
    
    Notify(src, 'Employee of the Month set successfully', 'success')
end)

-- ----------------------------------------------------------------------------
-- Event: Dar bonus a empleado
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:giveEmployeeBonus', function(shopId, citizenid, amount, reason)
    local src = source
    local Player = GetPlayer(src)
    
    if not Player then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        Notify(src, 'Invalid amount', 'error')
        return
    end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        Notify(src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if not Config.DefaultPermissions.ManagementAccess(Player, shop) then
        Notify(src, 'Not authorized', 'error')
        return
    end
    
    -- Verificar fondos de la sociedad
    local shopBalance = GetShopMoney(shop.job_name)
    if shopBalance < amount then
        Notify(src, 'Insufficient shop funds', 'error')
        return
    end
    
    -- Remover de sociedad
    RemoveShopMoney(shop.job_name, amount, 'Bonus to employee')
    
    -- Dar dinero al empleado
    local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if TargetPlayer then
        TargetPlayer.Functions.AddMoney('bank', amount, 'mechanic-bonus')
        Notify(TargetPlayer.PlayerData.source, string.format('You received a bonus of $%s: %s', amount, reason or 'Performance bonus'), 'success')
    else
        -- Bonus offline
        MySQL.update.await([[
            UPDATE players 
            SET money = JSON_SET(money, '$.bank', JSON_EXTRACT(money, '$.bank') + ?) 
            WHERE citizenid = ?
        ]], {amount, citizenid})
    end
    
    -- Registrar transacción
    Database.CreateTransaction({
        shopId = shopId,
        type = 'bonus',
        amount = amount,
        description = 'Bonus: ' .. (reason or 'Performance bonus'),
        employeeCitizenid = citizenid,
        orderId = nil
    })
    
    Notify(src, 'Bonus given successfully', 'success')
end)