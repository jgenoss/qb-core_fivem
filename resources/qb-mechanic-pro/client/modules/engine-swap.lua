-- client/modules/engine-swap.lua

local usingHoist = false
local hoistProp = nil
local engineProp = nil

-- Configuración local de animaciones y props
local swapConfig = {
    hoistModel = 'prop_engine_hoist',
    engineModel = 'prop_car_engine_01',
    animDict = 'mini@repair',
    animName = 'fixing_a_ped'
}

-- Función auxiliar para cargar modelos
local function LoadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
end

-- Función auxiliar para cargar animaciones
local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

-- Evento: Iniciar extracción de motor
RegisterNetEvent('qb-mechanic:client:startEngineSwap', function()
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    
    if not vehicle then 
        exports['qb-mechanic-pro']:Notify('No hay vehículo cerca', 'error')
        return 
    end

    -- Verificar si el capó está abierto
    if GetVehicleDoorAngleRatio(vehicle, 4) < 0.1 then
        exports['qb-mechanic-pro']:Notify('El capó debe estar abierto', 'error')
        return
    end

    local playerPed = PlayerPedId()
    local vehCoords = GetEntityCoords(vehicle)
    local forward = GetEntityForwardVector(vehicle)
    
    -- Posición para el hoist (frente al coche)
    local hoistPos = vehCoords + (forward * 1.5)
    
    -- 1. Spawnear la grúa (Hoist)
    LoadModel(swapConfig.hoistModel)
    hoistProp = CreateObject(GetHashKey(swapConfig.hoistModel), hoistPos.x, hoistPos.y, hoistPos.z, true, true, false)
    PlaceObjectOnGroundProperly(hoistProp)
    SetEntityHeading(hoistProp, GetEntityHeading(vehicle) - 180.0)
    
    usingHoist = true
    
    -- 2. Animación de trabajo
    LoadAnimDict(swapConfig.animDict)
    TaskPlayAnim(playerPed, swapConfig.animDict, swapConfig.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    
    -- Barra de progreso
    QBCore.Functions.Progressbar("engine_remove", "Extrayendo Motor...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        -- 3. Crear el prop del motor colgando
        LoadModel(swapConfig.engineModel)
        engineProp = CreateObject(GetHashKey(swapConfig.engineModel), hoistPos.x, hoistPos.y, hoistPos.z + 1.0, true, true, false)
        AttachEntityToEntity(engineProp, hoistProp, 0, 0.0, 0.0, 1.2, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
        
        -- Limpiar animación
        ClearPedTasks(playerPed)
        
        -- Notificar al servidor (aquí se debería dar el ítem al jugador)
        TriggerServerEvent('qb-mechanic:server:finishEngineRemove', VehToNet(vehicle))
        
        exports['qb-mechanic-pro']:Notify('Motor extraído correctamente. Usa el menú para guardarlo.', 'success')
        
    end, function() -- Cancel
        usingHoist = false
        DeleteEntity(hoistProp)
        ClearPedTasks(playerPed)
    end)
end)

-- Evento: Instalar motor (teniendo el ítem/prop)
RegisterNetEvent('qb-mechanic:client:installEngine', function()
    if not usingHoist or not DoesEntityExist(engineProp) then
        exports['qb-mechanic-pro']:Notify('Necesitas tener un motor en la grúa', 'error')
        return
    end

    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    if not vehicle then return end

    local playerPed = PlayerPedId()

    TaskPlayAnim(playerPed, swapConfig.animDict, swapConfig.animName, 8.0, -8.0, -1, 1, 0, false, false, false)

    QBCore.Functions.Progressbar("engine_install", "Instalando Motor...", 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        -- Eliminar props
        DeleteEntity(engineProp)
        DeleteEntity(hoistProp)
        usingHoist = false
        engineProp = nil
        hoistProp = nil
        
        ClearPedTasks(playerPed)
        
        -- Lógica de servidor para aplicar stats del nuevo motor
        TriggerServerEvent('qb-mechanic:server:finishEngineInstall', VehToNet(vehicle))
        
        exports['qb-mechanic-pro']:Notify('Motor instalado exitosamente', 'success')
    end)
end)

-- Limpieza al detener el recurso
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if hoistProp then DeleteEntity(hoistProp) end
        if engineProp then DeleteEntity(engineProp) end
    end
end)