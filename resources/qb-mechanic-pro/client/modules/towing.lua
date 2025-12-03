-- client/modules/towing.lua
local towRope = nil
local attachedVehicle = nil

RegisterNetEvent('qb-mechanic:client:useRope', function()
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    local ped = PlayerPedId()
    
    if not vehicle then 
        exports['qb-mechanic-pro']:Notify("No hay vehículo cerca", "error")
        return 
    end

    if attachedVehicle then
        -- Si ya tenemos uno, intentamos unirlo al segundo
        local firstVeh = attachedVehicle
        local secondVeh = vehicle
        
        if firstVeh == secondVeh then
            -- Cancelar/Soltar
            if towRope then DeleteRope(towRope) towRope = nil end
            attachedVehicle = nil
            exports['qb-mechanic-pro']:Notify("Cuerda guardada", "primary")
            return
        end

        -- Unir los dos
        local p1 = GetOffsetFromEntityInWorldCoords(firstVeh, 0.0, -2.0, 0.0)
        local p2 = GetOffsetFromEntityInWorldCoords(secondVeh, 0.0, 2.0, 0.0)
        
        RopeLoadTextures()
        while not RopeAreTexturesLoaded() do Wait(0) end
        
        towRope = AddRope(p1.x, p1.y, p1.z, 0.0, 0.0, 0.0, 10.0, 4, 10.0, 1.0, 0, 0, 0, 0, 0, 0)
        AttachEntitiesToRope(towRope, firstVeh, secondVeh, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, 10.0, false, false, nil, nil)
        
        exports['qb-mechanic-pro']:Notify("Vehículos unidos", "success")
        attachedVehicle = nil -- Reset para el siguiente uso
    else
        -- Seleccionar primer vehículo
        attachedVehicle = vehicle
        exports['qb-mechanic-pro']:Notify("Primer vehículo seleccionado. Ve al segundo.", "primary")
    end
end)