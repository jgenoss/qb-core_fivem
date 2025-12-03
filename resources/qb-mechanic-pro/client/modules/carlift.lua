-- ============================================================================
-- QB-MECHANIC-PRO - Carlift Module (Client)
-- ============================================================================

local carliftObjects = {}
local raisedVehicles = {}

-- ----------------------------------------------------------------------------
-- Event: Manejar carlift (raise/lower)
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:handleCarlift', function(shopId, location)
    local vehicle, distance = exports['qb-mechanic-pro']:GetClosestVehicle()
    
    if not vehicle then
        exports['qb-mechanic-pro']:Notify('No vehicle nearby', 'error')
        return
    end
    
    if distance > 5.0 then
        exports['qb-mechanic-pro']:Notify('Vehicle is too far', 'error')
        return
    end
    
    local isRaised = Entity(vehicle).state.carliftRaised or false
    
    if isRaised then
        LowerVehicle(vehicle)
    else
        RaiseVehicle(vehicle, location)
    end
end)

-- ----------------------------------------------------------------------------
-- Función: Levantar vehículo
-- ----------------------------------------------------------------------------
function RaiseVehicle(vehicle, location)
    local vehCoords = GetEntityCoords(vehicle)
    local targetZ = vehCoords.z + (Config.Carlift.RaiseHeight or 3.0)
    
    -- Congelar vehículo
    FreezeEntityPosition(vehicle, true)
    SetEntityInvincible(vehicle, true)
    
    -- Animación de subida
    CreateThread(function()
        local currentZ = vehCoords.z
        
        while currentZ < targetZ do
            currentZ = currentZ + (Config.Carlift.AnimationSpeed or 0.02)
            SetEntityCoords(vehicle, vehCoords.x, vehCoords.y, currentZ, false, false, false, false)
            Wait(10)
        end
        
        -- Marcar como levantado
        Entity(vehicle).state:set('carliftRaised', true, true)
        
        exports['qb-mechanic-pro']:Notify('Vehicle raised', 'success')
    end)
end

-- ----------------------------------------------------------------------------
-- Función: Bajar vehículo
-- ----------------------------------------------------------------------------
function LowerVehicle(vehicle)
    local vehCoords = GetEntityCoords(vehicle)
    local groundZ = vehCoords.z - (Config.Carlift.RaiseHeight or 3.0)
    
    -- Animación de bajada
    CreateThread(function()
        local currentZ = vehCoords.z
        
        while currentZ > groundZ do
            currentZ = currentZ - (Config.Carlift.AnimationSpeed or 0.02)
            SetEntityCoords(vehicle, vehCoords.x, vehCoords.y, currentZ, false, false, false, false)
            Wait(10)
        end
        
        -- Descongelar vehículo
        FreezeEntityPosition(vehicle, false)
        SetEntityInvincible(vehicle, false)
        
        -- Marcar como bajado
        Entity(vehicle).state:set('carliftRaised', false, true)
        
        exports['qb-mechanic-pro']:Notify('Vehicle lowered', 'success')
    end)
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('RaiseVehicle', RaiseVehicle)
exports('LowerVehicle', LowerVehicle)
exports('IsVehicleRaised', function(vehicle)
    return Entity(vehicle).state.carliftRaised or false
end)