-- ============================================================================
-- QB-MECHANIC-PRO - Shops Module COMPLETO (Server)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Event: Solicitar datos de un taller específico
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:requestShopData', function(shopId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.minimum_grade or 0) then
            TriggerClientEvent('QBCore:Notify', src, 'Insufficient grade', 'error')
            return
        end
    end
    
    -- Obtener datos adicionales
    shop.employees = Database.GetShopEmployees(shopId)
    shop.orders = Database.GetShopOrders(shopId)
    shop.stats = Database.GetShopStats(shopId)
    shop.transactions = Database.GetShopTransactions(shopId, 20)
    
    -- Obtener balance de sociedad si es job-based
    if shop.ownership_type == 'job' and shop.job_name then
        shop.balance = GetShopMoney(shop.job_name)
    else
        shop.balance = 0
    end
    
    -- Enviar al cliente
    TriggerClientEvent('qb-mechanic:client:receiveShopData', src, shop)
end)

-- ----------------------------------------------------------------------------
-- Event: Contratar empleado
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:hireEmployee', function(shopId, targetServerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local TargetPlayer = QBCore.Functions.GetPlayer(targetServerId)
    
    if not Player or not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found or not online', 'error')
        return
    end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Verificar si ya es empleado
    if Database.IsEmployee(shopId, TargetPlayer.PlayerData.citizenid) then
        TriggerClientEvent('QBCore:Notify', src, 'Player is already an employee', 'error')
        return
    end
    
    -- Añadir como empleado
    local targetName = TargetPlayer.PlayerData.charinfo.firstname .. ' ' .. TargetPlayer.PlayerData.charinfo.lastname
    local success = Database.AddEmployee(shopId, TargetPlayer.PlayerData.citizenid, targetName, 0)
    
    if success then
        -- Asignar job si el taller es job-restricted
        if shop.ownership_type == 'job' and shop.job_name then
            TargetPlayer.Functions.SetJob(shop.job_name, 0)
        end
        
        TriggerClientEvent('QBCore:Notify', src, 'Employee hired successfully', 'success')
        TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 
            'You have been hired at ' .. shop.shop_name, 'success')
        
        -- Refrescar datos del taller
        TriggerEvent('qb-mechanic:server:requestShopData', shopId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to hire employee', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Despedir empleado
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:fireEmployee', function(shopId, employeeCitizenid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- No puede despedirse a sí mismo
    if Player.PlayerData.citizenid == employeeCitizenid then
        TriggerClientEvent('QBCore:Notify', src, 'You cannot fire yourself', 'error')
        return
    end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Remover empleado
    local success = Database.RemoveEmployee(shopId, employeeCitizenid)
    
    if success then
        -- Si el jugador está online, cambiar su job
        local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(employeeCitizenid)
        if TargetPlayer and shop.ownership_type == 'job' and shop.job_name then
            TargetPlayer.Functions.SetJob('unemployed', 0)
            TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 
                'You have been fired from ' .. shop.shop_name, 'error')
        end
        
        TriggerClientEvent('QBCore:Notify', src, 'Employee fired successfully', 'success')
        
        -- Refrescar datos del taller
        TriggerEvent('qb-mechanic:server:requestShopData', shopId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to fire employee', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Actualizar grado de empleado
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:updateEmployeeGrade', function(shopId, employeeCitizenid, newGrade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Validar nuevo grado
    newGrade = tonumber(newGrade)
    if not newGrade or newGrade < 0 then
        newGrade = 0
    end
    
    -- No se puede ascender a boss
    if newGrade >= (shop.boss_grade or 3) then
        TriggerClientEvent('QBCore:Notify', src, 'Cannot promote to boss grade', 'error')
        return
    end
    
    -- Actualizar grado
    local success = Database.UpdateEmployeeGrade(shopId, employeeCitizenid, newGrade)
    
    if success then
        -- Si el jugador está online, actualizar su job
        local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(employeeCitizenid)
        if TargetPlayer and shop.ownership_type == 'job' and shop.job_name then
            TargetPlayer.Functions.SetJob(shop.job_name, newGrade)
            TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 
                'Your grade has been updated to ' .. newGrade, 'success')
        end
        
        TriggerClientEvent('QBCore:Notify', src, 'Employee grade updated', 'success')
        
        -- Refrescar datos del taller
        TriggerEvent('qb-mechanic:server:requestShopData', shopId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to update grade', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Crear orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:createOrder', function(orderData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(orderData.shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Preparar datos de orden
    local order = {
        shopId = orderData.shopId,
        customerCitizenid = Player.PlayerData.citizenid,
        customerName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        vehiclePlate = orderData.vehiclePlate,
        vehicleModel = orderData.vehicleModel,
        modifications = orderData.modifications,
        totalCost = orderData.totalCost
    }
    
    -- Verificar fondos
    if Player.PlayerData.money['bank'] < order.totalCost then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error')
        return
    end
    
    -- Cobrar al cliente
    Player.Functions.RemoveMoney('bank', order.totalCost, 'mechanic-order')
    
    -- Crear orden en base de datos
    local orderId = Database.CreateOrder(order)
    
    if orderId then
        -- Agregar dinero a la sociedad del taller
        if shop.ownership_type == 'job' and shop.job_name then
            AddShopMoney(shop.job_name, order.totalCost, 'Order #' .. orderId)
        end
        
        -- Registrar transacción
        Database.CreateTransaction({
            shopId = orderData.shopId,
            type = 'order_payment',
            amount = order.totalCost,
            description = 'Order #' .. orderId .. ' - ' .. orderData.vehiclePlate,
            employeeCitizenid = nil,
            orderId = orderId
        })
        
        TriggerClientEvent('QBCore:Notify', src, 'Order created successfully', 'success')
        
        -- Notificar a mecánicos online del taller
        NotifyShopMechanics(shop, 'New order #' .. orderId .. ' received', 'inform')
    else
        -- Refund si falla la creación
        Player.Functions.AddMoney('bank', order.totalCost, 'mechanic-order-refund')
        TriggerClientEvent('QBCore:Notify', src, 'Order creation failed', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Actualizar estado de orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:updateOrderStatus', function(orderId, status)
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
    
    -- Actualizar estado
    local mechanicName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    Database.UpdateOrderStatus(orderId, status, Player.PlayerData.citizenid, mechanicName)
end)

-- ----------------------------------------------------------------------------
-- Event: Completar orden
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:completeOrder', function(orderId, vehicleNetId, vehicleProps)
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
    
    -- Actualizar estado de orden
    local mechanicName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
    Database.UpdateOrderStatus(orderId, 'completed', Player.PlayerData.citizenid, mechanicName)
    
    -- Actualizar vehículo en base de datos (player_vehicles)
    MySQL.update.await([[
        UPDATE player_vehicles 
        SET mods = ? 
        WHERE plate = ?
    ]], {json.encode(vehicleProps), order.vehicle_plate})
    
    -- Pagar comisión al mecánico
    local commission = math.floor(order.total_cost * (Config.Orders.MechanicCommission or 0.10))
    if commission > 0 then
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
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'Order completed successfully', 'success')
    
    -- Notificar al cliente si está online
    local Customer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
    if Customer then
        TriggerClientEvent('QBCore:Notify', Customer.PlayerData.source, 
            'Your vehicle modifications have been completed', 'success')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Depositar dinero
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:depositMoney', function(shopId, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid amount', 'error')
        return
    end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Verificar fondos del jugador
    if Player.PlayerData.money['bank'] < amount then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error')
        return
    end
    
    -- Remover dinero del jugador
    Player.Functions.RemoveMoney('bank', amount, 'mechanic-deposit')
    
    -- Agregar a la sociedad
    if shop.ownership_type == 'job' and shop.job_name then
        AddShopMoney(shop.job_name, amount, 'Deposit by ' .. Player.PlayerData.charinfo.firstname)
    end
    
    -- Registrar transacción
    Database.CreateTransaction({
        shopId = shopId,
        type = 'deposit',
        amount = amount,
        description = 'Deposit by ' .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        employeeCitizenid = Player.PlayerData.citizenid,
        orderId = nil
    })
    
    TriggerClientEvent('QBCore:Notify', src, 'Money deposited successfully', 'success')
    
    -- Refrescar datos del taller
    TriggerEvent('qb-mechanic:server:requestShopData', shopId)
end)

-- ----------------------------------------------------------------------------
-- Event: Retirar dinero
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:withdrawMoney', function(shopId, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, 'Invalid amount', 'error')
        return
    end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Verificar fondos de la sociedad
    local shopBalance = GetShopMoney(shop.job_name)
    if shopBalance < amount then
        TriggerClientEvent('QBCore:Notify', src, 'Insufficient shop funds', 'error')
        return
    end
    
    -- Remover de la sociedad
    if shop.ownership_type == 'job' and shop.job_name then
        RemoveShopMoney(shop.job_name, amount, 'Withdrawal by ' .. Player.PlayerData.charinfo.firstname)
    end
    
    -- Agregar dinero al jugador
    Player.Functions.AddMoney('bank', amount, 'mechanic-withdrawal')
    
    -- Registrar transacción
    Database.CreateTransaction({
        shopId = shopId,
        type = 'withdrawal',
        amount = amount,
        description = 'Withdrawal by ' .. Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname,
        employeeCitizenid = Player.PlayerData.citizenid,
        orderId = nil
    })
    
    TriggerClientEvent('QBCore:Notify', src, 'Money withdrawn successfully', 'success')
    
    -- Refrescar datos del taller
    TriggerEvent('qb-mechanic:server:requestShopData', shopId)
end)

-- ----------------------------------------------------------------------------
-- Event: Actualizar configuración del taller
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:updateShopSettings', function(shopId, settings)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Actualizar configuración
    shop.config_data = settings
    local success = Database.UpdateShop(shopId, shop)
    
    if success then
        TriggerClientEvent('QBCore:Notify', src, 'Settings updated successfully', 'success')
        
        -- Refrescar datos del taller
        TriggerEvent('qb-mechanic:server:requestShopData', shopId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to update settings', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Event: Guardar nombre del taller
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:saveShopName', function(shopId, shopName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(shopId)
    if not shop then
        TriggerClientEvent('QBCore:Notify', src, 'Shop not found', 'error')
        return
    end
    
    -- Verificar permisos de boss
    if shop.ownership_type == 'job' and shop.job_name then
        if Player.PlayerData.job.name ~= shop.job_name then
            TriggerClientEvent('QBCore:Notify', src, 'Not authorized', 'error')
            return
        end
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Boss grade required', 'error')
            return
        end
    end
    
    -- Actualizar nombre
    shop.shop_name = shopName
    local success = Database.UpdateShop(shopId, shop)
    
    if success then
        TriggerClientEvent('QBCore:Notify', src, 'Shop name updated successfully', 'success')
        
        -- Refrescar datos del taller
        TriggerEvent('qb-mechanic:server:requestShopData', shopId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to update shop name', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Función: Notificar a mecánicos online del taller
-- ----------------------------------------------------------------------------
function NotifyShopMechanics(shop, message, type)
    if shop.ownership_type == 'job' and shop.job_name then
        local Players = QBCore.Functions.GetPlayers()
        for _, playerId in pairs(Players) do
            local Player = QBCore.Functions.GetPlayer(playerId)
            if Player and Player.PlayerData.job.name == shop.job_name then
                TriggerClientEvent('QBCore:Notify', playerId, message, type or 'inform')
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Callbacks
-- ----------------------------------------------------------------------------
QBCore.Functions.CreateCallback('qb-mechanic:server:getOrderDetails', function(source, cb, orderId)
    local order = Database.GetOrder(orderId)
    cb(order)
end)

QBCore.Functions.CreateCallback('qb-mechanic:server:getTransactionHistory', function(source, cb, shopId, limit)
    local transactions = Database.GetShopTransactions(shopId, limit or 20)
    cb(transactions)
end)

QBCore.Functions.CreateCallback('qb-mechanic:server:getDashboardStats', function(source, cb, shopId)
    local stats = Database.GetShopStats(shopId)
    
    -- Agregar balance actual
    local shop = Database.GetShop(shopId)
    if shop and shop.ownership_type == 'job' and shop.job_name then
        stats.currentBalance = GetShopMoney(shop.job_name)
    else
        stats.currentBalance = 0
    end
    
    cb(stats)
end)