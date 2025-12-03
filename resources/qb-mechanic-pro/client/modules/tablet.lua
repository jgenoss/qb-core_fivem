-- ============================================================================
-- QB-MECHANIC-PRO - Tablet Module (Client) COMPLETO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Función Auxiliar: Buscar vehículo por placa
-- ----------------------------------------------------------------------------
local function GetClosestVehicleWithPlate(targetPlate)
    local vehicles = GetGamePool('CVehicle')
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    targetPlate = targetPlate:gsub("%s+", "") -- Remover espacios
    
    for _, veh in pairs(vehicles) do
        local plate = GetVehicleNumberPlateText(veh):gsub("%s+", "")
        
        if plate == targetPlate then
            local distance = #(playerCoords - GetEntityCoords(veh))
            if distance < 10.0 then
                return veh
            end
        end
    end
    
    return nil
end

-- ----------------------------------------------------------------------------
-- Event: Comenzar instalación de modificaciones
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:beginInstallation', function(order)
    local vehicle = GetClosestVehicleWithPlate(order.vehicle_plate)
    
    if not vehicle then
        exports['qb-mechanic-pro']:Notify('Vehicle not found nearby. Bring it closer.', 'error')
        TriggerServerEvent('qb-mechanic:server:completeOrder', order.id, false)
        return
    end
    
    -- Mostrar UI de progreso
    SendNUIMessage({
        action = 'showInstallProgress',
        order = order
    })
    
    -- Ejecutar instalación usando la función de workshop.lua
    exports['qb-mechanic-pro']:InstallModifications(vehicle, order.modifications, function(success)
        -- Guardar vehículo en base de datos (usando qb-core o qb-vehiclekeys)
        if success then
            local props = exports['qb-mechanic-pro']:GetVehicleProperties(vehicle)
            
            -- Intentar guardar con diferentes sistemas
            if GetResourceState('qb-vehiclekeys') == 'started' then
                TriggerServerEvent('qb-vehiclekeys:server:updateVehicle', order.vehicle_plate, props)
            end
            
            if GetResourceState('qb-garages') == 'started' then
                TriggerServerEvent('qb-garages:server:updateVehicle', order.vehicle_plate, props)
            end
            
            -- Fallback genérico
            TriggerServerEvent('qb-mechanic:server:saveVehicleProperties', order.vehicle_plate, props)
        end
        
        -- Notificar servidor de finalización
        TriggerServerEvent('qb-mechanic:server:completeOrder', order.id, success)
        
        -- Ocultar UI de progreso
        SendNUIMessage({
            action = 'hideInstallProgress'
        })
    end)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Gestión de Empleados
-- ----------------------------------------------------------------------------
RegisterNUICallback('hireEmployee', function(data, cb)
    local targetId = tonumber(data.targetId)
    
    if not targetId then
        cb({success = false, message = 'Invalid server ID'})
        return
    end
    
    TriggerServerEvent('qb-mechanic:server:hireEmployee', data.shopId, targetId)
    cb({success = true})
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:fireEmployee', data.shopId, data.citizenid)
    cb({success = true})
end)

RegisterNUICallback('updateEmployeeGrade', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:updateEmployeeGrade', data.shopId, data.citizenid, data.grade)
    cb({success = true})
end)

RegisterNUICallback('getEmployees', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getEmployees', function(employees)
        cb({success = true, employees = employees})
    end, data.shopId)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Gestión de Órdenes
-- ----------------------------------------------------------------------------
RegisterNUICallback('getOrders', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getOrders', function(orders)
        cb({success = true, orders = orders})
    end, data.shopId, data.status)
end)

RegisterNUICallback('startInstallation', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:startInstallation', data.orderId)
    cb({success = true})
end)

RegisterNUICallback('cancelOrder', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:cancelOrder', data.orderId, data.reason)
    cb({success = true})
end)

RegisterNUICallback('getOrderDetails', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getOrderDetails', function(order)
        cb({success = true, order = order})
    end, data.orderId)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Estadísticas y Dashboard
-- ----------------------------------------------------------------------------
RegisterNUICallback('getDashboardStats', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getDashboardStats', function(stats)
        cb({success = true, stats = stats})
    end, data.shopId)
end)

RegisterNUICallback('getRevenueData', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getRevenueData', function(revenue)
        cb({success = true, revenue = revenue})
    end, data.shopId, data.period)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Finanzas
-- ----------------------------------------------------------------------------
RegisterNUICallback('withdrawMoney', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:withdrawMoney', data.shopId, data.amount)
    cb({success = true})
end)

RegisterNUICallback('depositMoney', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:depositMoney', data.shopId, data.amount)
    cb({success = true})
end)

RegisterNUICallback('getTransactionHistory', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getTransactionHistory', function(transactions)
        cb({success = true, transactions = transactions})
    end, data.shopId, data.limit or 20)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Configuración del Taller
-- ----------------------------------------------------------------------------
RegisterNUICallback('updateShopSettings', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:updateShopSettings', data.shopId, data.settings)
    cb({success = true})
end)

RegisterNUICallback('saveShopName', function(data, cb)
    if not data.shopName or data.shopName == '' then
        cb({success = false, message = 'Shop name cannot be empty'})
        return
    end
    
    TriggerServerEvent('qb-mechanic:server:saveShopName', data.shopId, data.shopName)
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Solicitar datos del taller
-- ----------------------------------------------------------------------------
RegisterNUICallback('requestShopData', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:requestShopData', data.shopId)
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS NUI: Cerrar UI
-- ----------------------------------------------------------------------------
RegisterNUICallback('closeTablet', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeTablet' })
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- Event: Recibir datos del taller desde servidor
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:receiveShopData', function(shopData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        shop = shopData
    })
end)

-- ----------------------------------------------------------------------------
-- Event: Actualizar lista de empleados
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:updateEmployees', function(employees)
    SendNUIMessage({
        action = 'updateEmployees',
        employees = employees
    })
end)

-- ----------------------------------------------------------------------------
-- Event: Actualizar lista de órdenes
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:updateOrders', function(orders)
    SendNUIMessage({
        action = 'updateOrders',
        orders = orders
    })
end)

-- ----------------------------------------------------------------------------
-- Comando: Abrir Tablet (para testing)
-- ----------------------------------------------------------------------------
RegisterCommand('tablet', function()
    local job, grade = exports['qb-mechanic-pro']:GetPlayerJob()
    
    -- Buscar taller del jugador
    local shops = exports['qb-mechanic-pro']:GetAllShops()
    for _, shop in pairs(shops) do
        if shop.job_name == job then
            TriggerEvent('qb-mechanic:client:openTablet', shop.id, 'dashboard')
            return
        end
    end
    
    exports['qb-mechanic-pro']:Notify('You are not employed at any mechanic shop', 'error')
end, false)