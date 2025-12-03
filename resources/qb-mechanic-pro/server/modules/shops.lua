-- ============================================================================
-- QB-MECHANIC-PRO - Shops Module (Server)
-- Gestión de talleres, órdenes y empleados
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
        
        if Player.PlayerData.job.grade.level < (shop.boss_grade or 3) then
            TriggerClientEvent('QBCore:Notify', src, 'Insufficient grade', 'error')
            return
        end
    end
    
    -- Obtener datos adicionales
    shop.employees = Database.GetShopEmployees(shopId)
    shop.orders = Database.GetShopOrders(shopId)
    shop.stats = Database.GetShopStats(shopId)
    shop.transactions = Database.GetShopTransactions(shopId, 20)
    
    -- Enviar al cliente
    TriggerClientEvent('qb-mechanic:client:receiveShopData', src, shop)
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
    
    -- Procesar pago
    local success, error = ProcessOrderPayment(src, shop, {totalCost = order.totalCost})
    
    if not success then
        if error == 'insufficient_funds' then
            TriggerClientEvent('QBCore:Notify', src, 'Insufficient funds', 'error')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Payment failed', 'error')
        end
        return
    end
    
    -- Crear orden en base de datos
    local orderId = Database.CreateOrder(order)
    
    if orderId then
        TriggerClientEvent('QBCore:Notify', src, 'Order created successfully', 'success')
        
        -- Notificar a mecánicos online del taller
        NotifyShopMechanics(shop, 'New order received', 'inform')
    else
        -- Refund si falla la creación
        RefundCustomer(src, order.totalCost, 'Order creation failed')
        TriggerClientEvent('QBCore:Notify', src, 'Order creation failed', 'error')
    end
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
    
    -- Procesar comisión para el mecánico
    ProcessOrderCompletion(src, shop, {
        orderId = orderId,
        totalCost = order.total_cost
    })
    
    -- Actualizar vehículo en base de datos (player_vehicles)
    MySQL.update.await([[
        UPDATE player_vehicles 
        SET mods = ? 
        WHERE plate = ?
    ]], {
        json.encode(vehicleProps),
        order.vehicle_plate
    })
    
    -- Notificar al cliente propietario del vehículo
    local customerPlayer = QBCore.Functions.GetPlayerByCitizenId(order.customer_citizenid)
    if customerPlayer then
        TriggerClientEvent('QBCore:Notify', customerPlayer.PlayerData.source, 
            'Your vehicle modifications have been completed', 'success')
    end
    
    TriggerClientEvent('QBCore:Notify', src, 'Order completed successfully', 'success')
end)

-- ----------------------------------------------------------------------------
-- Event: Contratar empleado
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:server:hireEmployee', function(shopId, targetServerId)
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
            TriggerClientEvent('QBCore:Notify', src, 'Insufficient grade', 'error')
            return
        end
    end
    
    -- Obtener jugador objetivo
    local TargetPlayer = QBCore.Functions.GetPlayer(tonumber(targetServerId))
    
    if not TargetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Player not found or not online', 'error')
        return
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
            TriggerClientEvent('QBCore:Notify', src, 'Insufficient grade', 'error')
            return
        end
    end
    
    -- Eliminar empleado
    local success = Database.RemoveEmployee(shopId, employeeCitizenid)
    
    if success then
        -- Notificar al empleado si está online
        local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(employeeCitizenid)
        if TargetPlayer then
            TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 
                'You have been fired from ' .. shop.shop_name, 'error')
            
            -- Remover job si aplica
            if shop.ownership_type == 'job' and shop.job_name then
                TargetPlayer.Functions.SetJob('unemployed', 0)
            end
        end
        
        TriggerClientEvent('QBCore:Notify', src, 'Employee fired successfully', 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, 'Failed to fire employee', 'error')
    end
end)

-- ----------------------------------------------------------------------------
-- Función: Notificar a mecánicos del taller
-- ----------------------------------------------------------------------------
function NotifyShopMechanics(shop, message, type)
    if shop.ownership_type ~= 'job' or not shop.job_name then
        return
    end
    
    local players = QBCore.Functions.GetQBPlayers()
    
    for _, player in pairs(players) do
        if player.PlayerData.job.name == shop.job_name and player.PlayerData.job.onduty then
            TriggerClientEvent('QBCore:Notify', player.PlayerData.source, message, type or 'inform')
        end
    end
end

-- ----------------------------------------------------------------------------
-- Log de inicialización
-- ----------------------------------------------------------------------------

if Config.Debug then
    print('^2[QB-MECHANIC-PRO]^0 Shops module loaded')
end