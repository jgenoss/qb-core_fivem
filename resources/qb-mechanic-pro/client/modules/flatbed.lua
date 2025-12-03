-- client/modules/flatbed.lua

local flatbedModel = GetHashKey("flatbed") -- Cambiar por el modelo de tu servidor si es distinto
local isAttaching = false

-- Función para encontrar el vehículo más cercano detrás del flatbed
local function GetVehicleBehindFlatbed(flatbed)
    local rearPos = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, -5.0, 0.0)
    local vehicle = GetClosestVehicle(rearPos.x, rearPos.y, rearPos.z, 5.0, 0, 70) -- 70 = todos los coches, motos, etc
    
    if vehicle == flatbed then return nil end
    return vehicle
end

-- Función principal para cargar/descargar
local function ToggleFlatbed()
    local ped = PlayerPedId()
    local flatbed = GetVehiclePedIsIn(ped, false)
    
    if not flatbed or GetEntityModel(flatbed) ~= flatbedModel then
        flatbed = GetVehiclePedIsIn(ped, true) -- Intentar obtener último vehículo
        if not flatbed or GetEntityModel(flatbed) ~= flatbedModel then
            exports['qb-mechanic-pro']:Notify("No estás en una grúa de plataforma", "error")
            return
        end
    end

    if isAttaching then return end
    isAttaching = true

    -- Verificar si ya tiene un coche cargado
    local attachedEntity = nil
    for i = 1, 10 do -- Buscar entidades adjuntas (forma simplificada)
        -- En un script complejo usaríamos tablas de estado, aquí buscamos por proximidad/attach
        -- Para simplificar, verificaremos si hay un vehículo pegado al bone "bodyshell" o similar
    end
    
    -- Como GetAttachedEntities no es nativo simple, usaremos una variable de estado en la entidad
    local currentAttached = Entity(flatbed).state.flatbedAttachedVehicle
    
    if currentAttached and DoesEntityExist(NetToVeh(currentAttached)) then
        -- DESCARGAR
        local veh = NetToVeh(currentAttached)
        DetachEntity(veh, true, true)
        
        -- Moverlo un poco atrás para que no colisione
        local dropPos = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, -8.0, 0.0)
        SetEntityCoords(veh, dropPos.x, dropPos.y, dropPos.z, false, false, false, true)
        SetVehicleOnGroundProperly(veh)
        
        Entity(flatbed).state:set('flatbedAttachedVehicle', nil, true)
        exports['qb-mechanic-pro']:Notify("Vehículo descargado", "success")
    else
        -- CARGAR
        local targetVeh = GetVehicleBehindFlatbed(flatbed)
        
        if targetVeh and DoesEntityExist(targetVeh) then
            -- Animación o tiempo de espera
            exports['qb-mechanic-pro']:Notify("Cargando vehículo...", "primary", 3000)
            Wait(3000)
            
            -- Attach
            local bone = GetEntityBoneIndexByName(flatbed, "bodyshell")
            AttachEntityToEntity(targetVeh, flatbed, bone, 0.0, -2.5, 0.4, 0.0, 0.0, 0.0, true, false, true, false, 0, true)
            
            Entity(flatbed).state:set('flatbedAttachedVehicle', VehToNet(targetVeh), true)
            exports['qb-mechanic-pro']:Notify("Vehículo cargado", "success")
        else
            exports['qb-mechanic-pro']:Notify("No hay vehículo detrás para cargar", "error")
        end
    end
    
    isAttaching = false
end

-- Registrar evento para el menú radial
RegisterNetEvent('qb-mechanic:client:toggleFlatbed', function()
    ToggleFlatbed()
end)