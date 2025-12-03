-- ============================================================================
-- QB-MECHANIC-PRO - Workshop Module (Client)
-- Gestión de zonas, interacciones y lógica de talleres
-- ============================================================================

local currentVehicle = nil
local vehicleInZone = false
local nearestShop = nil

-- ----------------------------------------------------------------------------
-- Función: Obtener vehículo más cercano
-- ----------------------------------------------------------------------------
local function GetClosestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = nil
    local minDistance = Config.Orders.MaxVehicleDistance or 50.0
    
    -- Buscar vehículos cercanos
    for veh in EnumerateVehicles() do
        local vehCoords = GetEntityCoords(veh)
        local distance = #(playerCoords - vehCoords)
        
        if distance < minDistance then
            minDistance = distance
            vehicle = veh
        end
    end
    
    return vehicle, minDistance
end

-- ----------------------------------------------------------------------------
-- Función: Enumerar vehículos
-- ----------------------------------------------------------------------------
function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local success
        
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success
        
        EndFindVehicle(handle)
    end)
end

-- ----------------------------------------------------------------------------
-- Función: Obtener propiedades del vehículo
-- ----------------------------------------------------------------------------
local function GetVehicleProperties(vehicle)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'esx' then
        return ESX.Game.GetVehicleProperties(vehicle)
    end
end

-- ----------------------------------------------------------------------------
-- Función: Aplicar propiedades al vehículo
-- ----------------------------------------------------------------------------
local function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        QBCore.Functions.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'esx' then
        ESX.Game.SetVehicleProperties(vehicle, props)
    end
end

-- ----------------------------------------------------------------------------
-- Event: Abrir tuneshop
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:openTuneshop', function(shopId)
    local vehicle, distance = GetClosestVehicle()
    
    if not vehicle then
        exports['qb-mechanic']:Notify('No vehicle nearby', 'error')
        return
    end
    
    if distance > 5.0 then
        exports['qb-mechanic']:Notify('Vehicle is too far', 'error')
        return
    end
    
    -- Obtener propiedades actuales
    local props = GetVehicleProperties(vehicle)
    
    -- Abrir UI de tuneshop
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTuneshop',
        shopId = shopId,
        vehicle = {
            model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
            plate = GetVehicleNumberPlateText(vehicle),
            netId = VehToNet(vehicle),
            currentMods = props
        },
        categories = Config.VehicleMods.Categories,
        mods = {
            performance = Config.VehicleMods.Performance,
            cosmetic = Config.VehicleMods.Cosmetic
        }
    })
end)

-- ----------------------------------------------------------------------------
-- Event: Usar carlift
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:useCarlift', function(shopId, location)
    local vehicle, distance = GetClosestVehicle()
    
    if not vehicle then
        exports['qb-mechanic']:Notify('No vehicle nearby', 'error')
        return
    end
    
    if distance > 5.0 then
        exports['qb-mechanic']:Notify('Vehicle is too far', 'error')
        return
    end
    
    -- Verificar si el vehículo ya está elevado
    local isRaised = Entity(vehicle).state.carliftRaised or false
    
    if isRaised then
        -- Bajar vehículo
        LowerVehicle(vehicle)
    else
        -- Elevar vehículo
        RaiseVehicle(vehicle, location)
    end
end)

-- ----------------------------------------------------------------------------
-- Función: Elevar vehículo
-- ----------------------------------------------------------------------------
function RaiseVehicle(vehicle, location)
    if not Config.Carlift.Enabled then return end
    
    local targetHeight = Config.Carlift.RaiseHeight or 3.0
    local currentHeight = 0.0
    
    -- Congelar vehículo
    FreezeEntityPosition(vehicle, true)
    
    -- Animación de elevación
    CreateThread(function()
        while currentHeight < targetHeight do
            currentHeight = currentHeight + Config.Carlift.AnimationSpeed
            
            local coords = GetEntityCoords(vehicle)
            SetEntityCoords(vehicle, coords.x, coords.y, coords.z + Config.Carlift.AnimationSpeed, false, false, false, false)
            
            Wait(10)
        end
        
        -- Marcar como elevado
        Entity(vehicle).state:set('carliftRaised', true, true)
        exports['qb-mechanic']:Notify('Vehicle raised', 'success')
    end)
end

-- ----------------------------------------------------------------------------
-- Función: Bajar vehículo
-- ----------------------------------------------------------------------------
function LowerVehicle(vehicle)
    local targetHeight = Config.Carlift.RaiseHeight or 3.0
    local currentHeight = targetHeight
    
    -- Animación de descenso
    CreateThread(function()
        while currentHeight > 0 do
            currentHeight = currentHeight - Config.Carlift.AnimationSpeed
            
            local coords = GetEntityCoords(vehicle)
            SetEntityCoords(vehicle, coords.x, coords.y, coords.z - Config.Carlift.AnimationSpeed, false, false, false, false)
            
            Wait(10)
        end
        
        -- Descongelar vehículo
        FreezeEntityPosition(vehicle, false)
        
        -- Marcar como no elevado
        Entity(vehicle).state:set('carliftRaised', false, true)
        exports['qb-mechanic']:Notify('Vehicle lowered', 'success')
    end)
end

-- ----------------------------------------------------------------------------
-- Event: Abrir tablet
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:openTablet', function(shopId, section)
    -- Solicitar datos del taller al servidor
    TriggerServerEvent('qb-mechanic:server:requestShopData', shopId)
end)

RegisterNetEvent('qb-mechanic:client:receiveShopData', function(shopData)
    -- Abrir UI de tablet
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        shop = shopData
    })
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Crear orden
-- ----------------------------------------------------------------------------
RegisterNUICallback('createOrder', function(data, cb)
    local vehicle, distance = GetClosestVehicle()
    
    if not vehicle then
        cb({success = false, message = 'No vehicle nearby'})
        return
    end
    
    -- Obtener placa
    local plate = GetVehicleNumberPlateText(vehicle)
    
    -- Enviar al servidor
    TriggerServerEvent('qb-mechanic:server:createOrder', {
        shopId = data.shopId,
        vehiclePlate = plate,
        vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
        modifications = data.modifications,
        totalCost = data.totalCost
    })
    
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Instalar modificaciones
-- ----------------------------------------------------------------------------
RegisterNUICallback('installOrder', function(data, cb)
    local vehicle, distance = GetClosestVehicle()
    
    if not vehicle then
        cb({success = false, message = 'No vehicle nearby'})
        return
    end
    
    -- Verificar placa
    local plate = GetVehicleNumberPlateText(vehicle)
    if plate ~= data.vehiclePlate then
        cb({success = false, message = 'Wrong vehicle'})
        return
    end
    
    -- Iniciar instalación
    InstallModifications(vehicle, data.modifications, function(success)
        if success then
            -- Guardar propiedades
            local props = GetVehicleProperties(vehicle)
            TriggerServerEvent('qb-mechanic:server:completeOrder', data.orderId, VehToNet(vehicle), props)
            
            cb({success = true})
        else
            cb({success = false, message = 'Installation failed'})
        end
    end)
end)

-- ----------------------------------------------------------------------------
-- Función: Instalar modificaciones paso a paso
-- ----------------------------------------------------------------------------
function InstallModifications(vehicle, modifications, callback)
    local totalSteps = #modifications
    local currentStep = 0
    
    -- Mostrar barra de progreso
    for _, mod in ipairs(modifications) do
        currentStep = currentStep + 1
        
        -- Actualizar UI con progreso
        SendNUIMessage({
            action = 'updateInstallProgress',
            step = currentStep,
            total = totalSteps,
            current = mod
        })
        
        -- Aplicar modificación
        ApplyModification(vehicle, mod)
        
        -- Esperar animación
        Wait(2000)
    end
    
    -- Instalación completa
    callback(true)
end

-- ----------------------------------------------------------------------------
-- Función: Aplicar una modificación individual
-- ----------------------------------------------------------------------------
function ApplyModification(vehicle, mod)
    SetVehicleModKit(vehicle, 0)
    
    if mod.type == 'engine' then
        SetVehicleMod(vehicle, 11, mod.level, false)
    elseif mod.type == 'brakes' then
        SetVehicleMod(vehicle, 12, mod.level, false)
    elseif mod.type == 'transmission' then
        SetVehicleMod(vehicle, 13, mod.level, false)
    elseif mod.type == 'suspension' then
        SetVehicleMod(vehicle, 15, mod.level, false)
    elseif mod.type == 'turbo' then
        ToggleVehicleMod(vehicle, 18, mod.enabled)
    elseif mod.type == 'spoiler' then
        SetVehicleMod(vehicle, 0, mod.index, false)
    elseif mod.type == 'fbumper' then
        SetVehicleMod(vehicle, 1, mod.index, false)
    elseif mod.type == 'rbumper' then
        SetVehicleMod(vehicle, 2, mod.index, false)
    end
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('GetClosestVehicle', GetClosestVehicle)
exports('GetVehicleProperties', GetVehicleProperties)
exports('SetVehicleProperties', SetVehicleProperties)
