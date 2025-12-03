-- client/modules/service_items.lua

-- Usar Kit de Reparación
RegisterNetEvent('qb-mechanic:client:useRepairKit', function(advanced)
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    if not vehicle then return end
    
    local ped = PlayerPedId()
    
    -- Verificar si el capó está abierto (opcional)
    -- Animación
    TaskStartScenarioInPlace(ped, "PROP_HUMAN_BUM_BIN", 0, true)
    
    QBCore.Functions.Progressbar("repair_vehicle", "Reparando vehículo...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        ClearPedTasks(ped)
        
        if advanced then
            SetVehicleFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
        else
            SetVehicleEngineHealth(vehicle, 1000.0)
        end
        
        exports['qb-mechanic-pro']:Notify("Vehículo reparado", "success")
        TriggerServerEvent('qb-mechanic:server:removeItem', advanced and 'advanced_repairkit' or 'repairkit')
    end, function() -- Cancel
        ClearPedTasks(ped)
    end)
end)

-- Usar Esponja (Limpieza)
RegisterNetEvent('qb-mechanic:client:useSponge', function()
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    if not vehicle then return end
    
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_MAID_CLEAN", 0, true)
    
    QBCore.Functions.Progressbar("clean_vehicle", "Limpiando...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        SetVehicleDirtLevel(vehicle, 0.0)
        ClearPedTasks(PlayerPedId())
        exports['qb-mechanic-pro']:Notify("Vehículo limpio y reluciente", "success")
    end)
end)