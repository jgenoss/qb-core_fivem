-- client/modules/carlift.lua

local lifting = false
local liftObjects = {} -- Cache para guardar objetos de elevadores

-- Función auxiliar para encontrar el elevador más cercano (objeto del mapa)
-- Si usas props dinámicos, usa GetClosestObjectOfType
local function GetClosestLift(coords)
    -- Ajusta el modelo según lo que uses en tu servidor
    local liftModel = GetHashKey("prop_carjack") 
    local lift = GetClosestObjectOfType(coords.x, coords.y, coords.z, 3.0, liftModel, false, false, false)
    return lift
end

-- Evento principal: Usar Elevador
RegisterNetEvent('qb-mechanic:client:handleCarlift', function(shopId, locationData)
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle() -- Usando el export que definiste en workshop.lua
    
    if not vehicle then
        exports['qb-mechanic-pro']:Notify('No hay vehículo cerca', 'error')
        return
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    
    -- Estado: Si ya está arriba, lo bajamos. Si está abajo, lo subimos.
    local isRaised = Entity(vehicle).state.isRaised or false

    if lifting then return end -- Evitar spam
    lifting = true

    if not isRaised then
        -- SUBIR
        exports['qb-mechanic-pro']:Notify('Elevando vehículo...', 'primary', 2000)
        
        -- Congelar vehículo
        FreezeEntityPosition(vehicle, true)
        
        -- Animación simple de subida
        local currentPos = GetEntityCoords(vehicle)
        local targetZ = currentPos.z + 2.0 -- Subir 2 metros
        
        CreateThread(function()
            while GetEntityCoords(vehicle).z < targetZ do
                local pos = GetEntityCoords(vehicle)
                SetEntityCoords(vehicle, pos.x, pos.y, pos.z + 0.02, true, true, true, false)
                Wait(10)
            end
            
            Entity(vehicle).state:set('isRaised', true, true)
            lifting = false
            exports['qb-mechanic-pro']:Notify('Vehículo elevado', 'success')
        end)
    else
        -- BAJAR
        exports['qb-mechanic-pro']:Notify('Bajando vehículo...', 'primary', 2000)
        
        local currentPos = GetEntityCoords(vehicle)
        -- Buscamos el suelo
        local foundGround, groundZ = GetGroundZFor_3dCoord(currentPos.x, currentPos.y, currentPos.z, 0)
        if not foundGround then groundZ = currentPos.z - 2.0 end
        
        CreateThread(function()
            while GetEntityCoords(vehicle).z > groundZ + 0.5 do -- +0.5 buffer para no atravesar suelo
                local pos = GetEntityCoords(vehicle)
                SetEntityCoords(vehicle, pos.x, pos.y, pos.z - 0.02, true, true, true, false)
                Wait(10)
            end
            
            FreezeEntityPosition(vehicle, false) -- Descongelar
            Entity(vehicle).state:set('isRaised', false, true)
            lifting = false
            exports['qb-mechanic-pro']:Notify('Vehículo bajado', 'success')
        end)
    end
end)