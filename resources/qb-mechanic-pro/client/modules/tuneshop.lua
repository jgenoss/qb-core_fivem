-- client/modules/tuneshop.lua

local inTuneshop = false
local currentVehicle = nil
local originalMods = {}
local cam = nil

-- Configuración de cámaras por categoría (Offset relativo al vehículo)
local CamOffsets = {
    ['default'] = {x = -2.5, y = 3.5, z = 1.0, fov = 60.0},
    ['engine'] = {x = -1.5, y = 1.5, z = 1.5, fov = 50.0}, -- Frente
    ['wheels'] = {x = -2.0, y = 0.0, z = 0.5, fov = 40.0}, -- Lateral bajo
    ['exhaust'] = {x = -1.5, y = -3.5, z = 0.5, fov = 50.0}, -- Trasera baja
    ['interior'] = {x = 0.5, y = 0.2, z = 0.6, fov = 80.0}, -- Interior
    ['spoiler'] = {x = -2.0, y = -3.0, z = 1.5, fov = 60.0}, -- Trasera alta
}

-- Función para crear/mover cámara
local function SetCameraPosition(category)
    if not inTuneshop or not DoesEntityExist(currentVehicle) then return end
    
    local offset = CamOffsets[category] or CamOffsets['default']
    local pos = GetOffsetFromEntityInWorldCoords(currentVehicle, offset.x, offset.y, offset.z)
    local targetPos = GetEntityCoords(currentVehicle)

    if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)
    end

    SetCamCoord(cam, pos.x, pos.y, pos.z)
    PointCamAtCoord(cam, targetPos.x, targetPos.y, targetPos.z)
end

-- Evento: Entrar al modo tuneshop (activado desde workshop.lua)
RegisterNetEvent('qb-mechanic:client:enterTuneshop', function(vehicle)
    currentVehicle = vehicle
    inTuneshop = true
    
    -- Guardar mods originales por si cancela
    originalMods = exports['qb-mechanic-pro']:GetVehicleProperties(vehicle)
    
    -- Congelar vehículo y apagar motor
    SetVehicleEngineOn(vehicle, false, false, true)
    FreezeEntityPosition(vehicle, true)
    SetVehicleLights(vehicle, 2) -- Luces encendidas
    
    -- Iniciar cámara
    SetCameraPosition('default')
end)

-- Evento: Salir del modo tuneshop
RegisterNetEvent('qb-mechanic:client:exitTuneshop', function(save)
    if not inTuneshop then return end
    
    -- Si no guardamos, restaurar mods
    if not save and currentVehicle and originalMods then
        exports['qb-mechanic-pro']:SetVehicleProperties(currentVehicle, originalMods)
    end
    
    -- Destruir cámara
    if DoesCamExist(cam) then
        DestroyCam(cam, true)
        RenderScriptCams(false, true, 1000, true, true)
        cam = nil
    end
    
    if DoesEntityExist(currentVehicle) then
        FreezeEntityPosition(currentVehicle, false)
        SetVehicleLights(currentVehicle, 0)
    end
    
    inTuneshop = false
    currentVehicle = nil
    originalMods = {}
end)

-- NUI Callback: Previsualizar Mod
RegisterNUICallback('previewMod', function(data, cb)
    if not inTuneshop or not currentVehicle then return end
    
    local modType = tonumber(data.modType)
    local modIndex = tonumber(data.modIndex)
    
    -- Aplicar mod visualmente
    if modType == 'respray' then
        local colorType = data.colorType -- 'primary', 'secondary'
        if colorType == 'primary' then
            SetVehicleColours(currentVehicle, modIndex, select(2, GetVehicleColours(currentVehicle)))
        else
            SetVehicleColours(currentVehicle, select(1, GetVehicleColours(currentVehicle)), modIndex)
        end
    else
        -- Mods normales (spoilers, bumpers, etc)
        SetVehicleModKit(currentVehicle, 0)
        SetVehicleMod(currentVehicle, modType, modIndex, false)
    end
    
    cb('ok')
end)

-- NUI Callback: Cambiar Cámara
RegisterNUICallback('updateCamera', function(data, cb)
    local category = data.category -- 'engine', 'wheels', etc.
    SetCameraPosition(category)
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Obtener precio de modificación
-- ----------------------------------------------------------------------------
RegisterNUICallback('getModificationPrice', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-mechanic:server:getModificationPrice', function(price)
        cb({price = price})
    end, data.modType, data.modIndex, data.level)
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Añadir al carrito
-- ----------------------------------------------------------------------------
RegisterNUICallback('addToCart', function(data, cb)
    -- El carrito se maneja en el cliente, solo confirmamos
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Remover del carrito
-- ----------------------------------------------------------------------------
RegisterNUICallback('removeFromCart', function(data, cb)
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Vaciar carrito
-- ----------------------------------------------------------------------------
RegisterNUICallback('clearCart', function(data, cb)
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Procesar compra (checkout)
-- ----------------------------------------------------------------------------
RegisterNUICallback('purchaseMods', function(data, cb)
    if not inTuneshop or not currentVehicle then
        cb({success = false, message = 'Not in tuneshop'})
        return
    end
    
    local plate = GetVehicleNumberPlateText(currentVehicle)
    
    TriggerServerEvent('qb-mechanic:server:purchaseMods', {
        shopId = data.shopId,
        vehiclePlate = plate,
        modifications = data.modifications,
        totalCost = data.totalCost,
        paymentMethod = data.paymentMethod
    })
    
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Cancelar compra
-- ----------------------------------------------------------------------------
RegisterNUICallback('cancelPurchase', function(data, cb)
    if originalMods and currentVehicle then
        exports['qb-mechanic-pro']:SetVehicleProperties(currentVehicle, originalMods)
    end
    cb('ok')
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Cerrar tuneshop
-- ----------------------------------------------------------------------------
RegisterNUICallback('closeTuneshop', function(data, cb)
    TriggerEvent('qb-mechanic:client:exitTuneshop', false)
    SetNuiFocus(false, false)
    cb('ok')
end)