-- ============================================================================
-- QB-MECHANIC-PRO - Database Module (Server)
-- Todas las operaciones de base de datos centralizadas
-- ============================================================================

Database = {}

-- ----------------------------------------------------------------------------
-- SHOPS - Operaciones de talleres
-- ----------------------------------------------------------------------------

function Database.GetAllShops()
    local result = MySQL.query.await('SELECT * FROM mechanic_shops', {})
    
    if not result then return {} end
    
    -- Parsear config_data JSON
    for _, shop in ipairs(result) do
        local success, config = pcall(json.decode, shop.config_data)
        if success then
            shop.config_data = config
        end
    end
    
    return result
end

function Database.GetShop(shopId)
    local result = MySQL.single.await('SELECT * FROM mechanic_shops WHERE id = ?', {shopId})
    
    if not result then return nil end
    
    -- Parsear config_data JSON
    local success, config = pcall(json.decode, result.config_data)
    if success then
        result.config_data = config
    end
    
    return result
end

function Database.CreateShop(shopData)
    local configJson = json.encode(shopData.config_data)
    
    local insertId = MySQL.insert.await([[
        INSERT INTO mechanic_shops 
        (id, shop_name, ownership_type, job_name, minimum_grade, boss_grade, owner_license, config_data)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        shopData.id,
        shopData.shop_name,
        shopData.ownership_type,
        shopData.job_name,
        shopData.minimum_grade,
        shopData.boss_grade,
        shopData.owner_license,
        configJson
    })
    
    return insertId > 0
end

function Database.UpdateShop(shopId, shopData)
    local configJson = json.encode(shopData.config_data)
    
    local affectedRows = MySQL.update.await([[
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
        shopId
    })
    
    return affectedRows > 0
end

function Database.DeleteShop(shopId)
    local affectedRows = MySQL.query.await('DELETE FROM mechanic_shops WHERE id = ?', {shopId})
    return affectedRows > 0
end

-- ----------------------------------------------------------------------------
-- EMPLOYEES - Gestión de empleados
-- ----------------------------------------------------------------------------

function Database.GetShopEmployees(shopId)
    return MySQL.query.await('SELECT * FROM mechanic_employees WHERE shop_id = ? ORDER BY hired_at DESC', {shopId})
end

function Database.AddEmployee(shopId, citizenid, employeeName, jobGrade)
    local insertId = MySQL.insert.await([[
        INSERT INTO mechanic_employees (shop_id, citizenid, employee_name, job_grade)
        VALUES (?, ?, ?, ?)
    ]], {
        shopId,
        citizenid,
        employeeName,
        jobGrade or 0
    })
    
    return insertId > 0
end

function Database.RemoveEmployee(shopId, citizenid)
    local affectedRows = MySQL.query.await('DELETE FROM mechanic_employees WHERE shop_id = ? AND citizenid = ?', {
        shopId, citizenid
    })
    
    return affectedRows > 0
end

function Database.IsEmployee(shopId, citizenid)
    local result = MySQL.scalar.await('SELECT id FROM mechanic_employees WHERE shop_id = ? AND citizenid = ?', {
        shopId, citizenid
    })
    
    return result ~= nil
end

function Database.UpdateEmployeeGrade(shopId, citizenid, newGrade)
    local affectedRows = MySQL.update.await([[
        UPDATE mechanic_employees 
        SET job_grade = ? 
        WHERE shop_id = ? AND citizenid = ?
    ]], {
        newGrade, shopId, citizenid
    })
    
    return affectedRows > 0
end

-- ----------------------------------------------------------------------------
-- ORDERS - Sistema de órdenes
-- ----------------------------------------------------------------------------

function Database.CreateOrder(orderData)
    local modsJson = json.encode(orderData.modifications)
    
    local insertId = MySQL.insert.await([[
        INSERT INTO mechanic_orders 
        (shop_id, customer_citizenid, customer_name, vehicle_plate, vehicle_model, modifications, total_cost, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')
    ]], {
        orderData.shopId,
        orderData.customerCitizenid,
        orderData.customerName,
        orderData.vehiclePlate,
        orderData.vehicleModel,
        modsJson,
        orderData.totalCost
    })
    
    return insertId
end

function Database.GetOrder(orderId)
    local result = MySQL.single.await('SELECT * FROM mechanic_orders WHERE id = ?', {orderId})
    
    if not result then return nil end
    
    -- Parsear modifications JSON
    local success, mods = pcall(json.decode, result.modifications)
    if success then
        result.modifications = mods
    end
    
    return result
end

function Database.GetShopOrders(shopId, status)
    local query = 'SELECT * FROM mechanic_orders WHERE shop_id = ?'
    local params = {shopId}
    
    if status then
        query = query .. ' AND status = ?'
        table.insert(params, status)
    end
    
    query = query .. ' ORDER BY created_at DESC'
    
    local result = MySQL.query.await(query, params)
    
    -- Parsear modifications JSON
    for _, order in ipairs(result) do
        local success, mods = pcall(json.decode, order.modifications)
        if success then
            order.modifications = mods
        end
    end
    
    return result
end

function Database.GetPendingOrders(shopId)
    return Database.GetShopOrders(shopId, 'pending')
end

function Database.UpdateOrderStatus(orderId, status, mechanicCitizenid, mechanicName)
    local query = 'UPDATE mechanic_orders SET status = ?'
    local params = {status}
    
    if mechanicCitizenid then
        query = query .. ', mechanic_citizenid = ?, mechanic_name = ?'
        table.insert(params, mechanicCitizenid)
        table.insert(params, mechanicName)
    end
    
    if status == 'installing' then
        query = query .. ', installed_at = NOW()'
    elseif status == 'completed' then
        query = query .. ', completed_at = NOW()'
    end
    
    query = query .. ' WHERE id = ?'
    table.insert(params, orderId)
    
    local affectedRows = MySQL.update.await(query, params)
    return affectedRows > 0
end

function Database.DeleteOrder(orderId)
    local affectedRows = MySQL.query.await('DELETE FROM mechanic_orders WHERE id = ?', {orderId})
    return affectedRows > 0
end

function Database.GetOrdersByPlate(plate)
    local result = MySQL.query.await('SELECT * FROM mechanic_orders WHERE vehicle_plate = ? ORDER BY created_at DESC', {plate})
    
    -- Parsear modifications JSON
    for _, order in ipairs(result) do
        local success, mods = pcall(json.decode, order.modifications)
        if success then
            order.modifications = mods
        end
    end
    
    return result
end

-- ----------------------------------------------------------------------------
-- TRANSACTIONS - Historial financiero
-- ----------------------------------------------------------------------------

function Database.CreateTransaction(transactionData)
    local insertId = MySQL.insert.await([[
        INSERT INTO mechanic_transactions 
        (shop_id, transaction_type, amount, description, employee_citizenid, order_id)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        transactionData.shopId,
        transactionData.type,
        transactionData.amount,
        transactionData.description,
        transactionData.employeeCitizenid,
        transactionData.orderId
    })
    
    return insertId > 0
end

function Database.GetShopTransactions(shopId, limit)
    local query = 'SELECT * FROM mechanic_transactions WHERE shop_id = ? ORDER BY created_at DESC'
    
    if limit then
        query = query .. ' LIMIT ' .. limit
    end
    
    return MySQL.query.await(query, {shopId})
end

function Database.GetShopRevenue(shopId)
    local result = MySQL.single.await([[
        SELECT 
            SUM(CASE WHEN transaction_type = 'order_payment' THEN amount ELSE 0 END) as total_revenue,
            SUM(CASE WHEN transaction_type = 'commission' THEN amount ELSE 0 END) as total_commissions,
            SUM(CASE WHEN transaction_type = 'expense' THEN amount ELSE 0 END) as total_expenses
        FROM mechanic_transactions 
        WHERE shop_id = ?
    ]], {shopId})
    
    return result
end

-- ----------------------------------------------------------------------------
-- STATISTICS - Estadísticas agregadas
-- ----------------------------------------------------------------------------

function Database.GetShopStats(shopId)
    local stats = {}
    
    -- Total de órdenes
    stats.totalOrders = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_orders WHERE shop_id = ?', {shopId})
    
    -- Órdenes completadas
    stats.completedOrders = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_orders WHERE shop_id = ? AND status = "completed"', {shopId})
    
    -- Total de empleados
    stats.totalEmployees = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_employees WHERE shop_id = ?', {shopId})
    
    -- Revenue
    local revenue = Database.GetShopRevenue(shopId)
    stats.totalRevenue = revenue.total_revenue or 0
    stats.totalCommissions = revenue.total_commissions or 0
    stats.totalExpenses = revenue.total_expenses or 0
    
    return stats
end

function Database.GetGlobalStats()
    local stats = {}
    
    -- Total de talleres
    stats.totalShops = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_shops', {})
    
    -- Total de órdenes
    stats.totalOrders = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_orders', {})
    
    -- Total de empleados
    stats.totalEmployees = MySQL.scalar.await('SELECT COUNT(*) FROM mechanic_employees', {})
    
    -- Top talleres por órdenes
    stats.topShops = MySQL.query.await([[
        SELECT m.shop_name, COUNT(o.id) as order_count
        FROM mechanic_shops m
        LEFT JOIN mechanic_orders o ON m.id = o.shop_id
        GROUP BY m.id
        ORDER BY order_count DESC
        LIMIT 10
    ]], {})
    
    return stats
end

-- ----------------------------------------------------------------------------
-- VEHICLE TRACKING - Seguimiento de vehículos (opcional)
-- ----------------------------------------------------------------------------

function Database.AddVehicleService(serviceData)
    local insertId = MySQL.insert.await([[
        INSERT INTO mechanic_vehicle_tracking 
        (vehicle_plate, shop_id, service_type, cost, mechanic_citizenid, notes)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], {
        serviceData.vehiclePlate,
        serviceData.shopId,
        serviceData.serviceType,
        serviceData.cost,
        serviceData.mechanicCitizenid,
        serviceData.notes
    })
    
    return insertId > 0
end

function Database.GetVehicleHistory(plate)
    return MySQL.query.await('SELECT * FROM mechanic_vehicle_tracking WHERE vehicle_plate = ? ORDER BY created_at DESC', {plate})
end

-- ----------------------------------------------------------------------------
-- Export del módulo
-- ----------------------------------------------------------------------------
return Database
