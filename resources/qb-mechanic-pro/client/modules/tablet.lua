-- ============================================================================
-- QB-MECHANIC-PRO - Tablet Module COMPLETO (Client)
-- ============================================================================

local tabletOpen = false
local currentShopId = nil
local currentShopData = nil

-- ----------------------------------------------------------------------------
-- Evento: Abrir tablet
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:openTabletUI', function(shopId, shopData)
    tabletOpen = true
    currentShopId = shopId
    currentShopData = shopData
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        shop = shopData
    })
end)

RegisterNetEvent('qb-mechanic:client:receiveShopData', function(shopData)
    currentShopData = shopData
    
    if tabletOpen then
        SendNUIMessage({
            action = 'updateShopData',
            shop = shopData
        })
    end
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS: Gestión de Empleados
-- ----------------------------------------------------------------------------
RegisterNUICallback('hireEmployee', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:hireEmployee', data.shopId, data.targetServerId)
    cb({ success = true })
end)

RegisterNUICallback('fireEmployee', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:fireEmployee', data.shopId, data.employeeCitizenid)
    cb({ success = true })
end)

RegisterNUICallback('updateEmployeeGrade', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:updateEmployeeGrade', data.shopId, data.employeeCitizenid, data.newGrade)
    cb({ success = true })
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS: Gestión de Órdenes
-- ----------------------------------------------------------------------------
RegisterNUICallback('startOrderInstallation', function(data, cb)
    local vehicle, distance = exports['qb-mechanic-pro']:GetClosestVehicle()
    
    if not vehicle then
        cb({success = false, message = 'No vehicle nearby'})
        return
    end
    
    -- Verificar placa
    local plate = GetVehicleNumberPlateText(vehicle)
    if plate ~= data.vehiclePlate then
        cb({success = false, message = 'Wrong vehicle. Expected: ' .. data.vehiclePlate})
        return
    end
    
    -- Verificar que el vehículo esté en el carlift (opcional)
    local isRaised = Entity(vehicle).state.carliftRaised or false
    if not isRaised then
        exports['qb-mechanic-pro']:Notify('Vehicle must be on carlift first', 'error')
        cb({success = false, message = 'Vehicle not on carlift'})
        return
    end
    
    -- Iniciar instalación
    TriggerEvent('qb-mechanic:client:installModifications', data.orderId, vehicle, data.modifications)
    cb({success = true})
end)

RegisterNUICallback('getOrderDetails', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getOrderDetails', function(order)
        cb({success = true, order = order})
    end, data.orderId)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS: Gestión Financiera
-- ----------------------------------------------------------------------------
RegisterNUICallback('depositMoney', function(data, cb)
    local amount = tonumber(data.amount)
    
    if not amount or amount <= 0 then
        cb({success = false, message = 'Invalid amount'})
        return
    end
    
    TriggerServerEvent('qb-mechanic:server:depositMoney', data.shopId, amount)
    cb({success = true})
end)

RegisterNUICallback('withdrawMoney', function(data, cb)
    local amount = tonumber(data.amount)
    
    if not amount or amount <= 0 then
        cb({success = false, message = 'Invalid amount'})
        return
    end
    
    TriggerServerEvent('qb-mechanic:server:withdrawMoney', data.shopId, amount)
    cb({success = true})
end)

RegisterNUICallback('getTransactionHistory', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getTransactionHistory', function(transactions)
        cb({success = true, transactions = transactions})
    end, data.shopId, data.limit or 20)
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS: Configuración del Taller
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
-- CALLBACKS: Dashboard y Estadísticas
-- ----------------------------------------------------------------------------
RegisterNUICallback('getDashboardStats', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getDashboardStats', function(stats)
        cb({success = true, stats = stats})
    end, data.shopId)
end)

RegisterNUICallback('requestShopData', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:requestShopData', data.shopId)
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- CALLBACKS: Cerrar UI
-- ----------------------------------------------------------------------------
RegisterNUICallback('closeTablet', function(_, cb)
    SetNuiFocus(false, false)
    tabletOpen = false
    currentShopId = nil
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- Evento: Instalar modificaciones (llamado desde startOrderInstallation)
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:installModifications', function(orderId, vehicle, modifications)
    local totalSteps = #modifications
    
    -- Actualizar estado a "installing"
    TriggerServerEvent('qb-mechanic:server:updateOrderStatus', orderId, 'installing')
    
    -- Mostrar progreso en NUI
    SendNUIMessage({
        action = 'showInstallProgress',
        orderId = orderId,
        totalSteps = totalSteps
    })
    
    -- Instalar cada modificación
    for i, mod in ipairs(modifications) do
        SendNUIMessage({
            action = 'updateInstallProgress',
            step = i,
            total = totalSteps,
            modification = mod
        })
        
        -- Aplicar modificación
        SetVehicleModKit(vehicle, 0)
        
        if mod.type == 'engine' then
            SetVehicleMod(vehicle, 11, mod.level or mod.modIndex, false)
        elseif mod.type == 'brakes' then
            SetVehicleMod(vehicle, 12, mod.level or mod.modIndex, false)
        elseif mod.type == 'transmission' then
            SetVehicleMod(vehicle, 13, mod.level or mod.modIndex, false)
        elseif mod.type == 'suspension' then
            SetVehicleMod(vehicle, 15, mod.level or mod.modIndex, false)
        elseif mod.type == 'turbo' then
            ToggleVehicleMod(vehicle, 18, mod.enabled or true)
        elseif mod.type == 'spoiler' then
            SetVehicleMod(vehicle, 0, mod.modIndex, false)
        elseif mod.type == 'fbumper' then
            SetVehicleMod(vehicle, 1, mod.modIndex, false)
        elseif mod.type == 'rbumper' then
            SetVehicleMod(vehicle, 2, mod.modIndex, false)
        elseif mod.type == 'skirts' then
            SetVehicleMod(vehicle, 3, mod.modIndex, false)
        elseif mod.type == 'exhaust' then
            SetVehicleMod(vehicle, 4, mod.modIndex, false)
        elseif mod.type == 'grille' then
            SetVehicleMod(vehicle, 6, mod.modIndex, false)
        elseif mod.type == 'hood' then
            SetVehicleMod(vehicle, 7, mod.modIndex, false)
        end
        
        -- Esperar animación
        Wait(2000)
    end
    
    -- Obtener propiedades finales
    local props = exports['qb-mechanic-pro']:GetVehicleProperties(vehicle)
    
    -- Completar orden
    TriggerServerEvent('qb-mechanic:server:completeOrder', orderId, VehToNet(vehicle), props)
    
    -- Ocultar progreso
    SendNUIMessage({
        action = 'hideInstallProgress'
    })
    
    exports['qb-mechanic-pro']:Notify('Modifications installed successfully', 'success')
end)

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('IsTabletOpen', function()
    return tabletOpen
end)

exports('GetCurrentShop', function()
    return currentShopData
end)