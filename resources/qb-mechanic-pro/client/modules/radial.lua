-- client/modules/radial.lua

local radialOpen = false

-- Función para abrir/cerrar el menú
local function ToggleRadial(state)
    radialOpen = state
    SetNuiFocus(state, state)
    
    if state then
        -- Definimos las opciones del menú
        local menuOptions = {
            {
                id = 'tablet',
                label = 'Tablet',
                icon = 'fa-tablet-alt',
                event = 'qb-mechanic:client:openTablet' -- Abriría la tablet general o del taller más cercano
            },
            {
                id = 'repair',
                label = 'Reparar',
                icon = 'fa-wrench',
                event = 'qb-mechanic:client:quickRepair'
            },
            {
                id = 'clean',
                label = 'Limpiar',
                icon = 'fa-soap',
                event = 'qb-mechanic:client:cleanVehicle'
            },
            {
                id = 'flatbed',
                label = 'Plataforma',
                icon = 'fa-truck-pickup',
                event = 'qb-mechanic:client:toggleFlatbed'
            },
            {
                id = 'carlift',
                label = 'Elevador',
                icon = 'fa-arrow-up',
                event = 'qb-mechanic:client:useCarlift' -- Usa la lógica que creamos antes
            }
        }

        SendNUIMessage({
            action = 'openRadial',
            options = menuOptions
        })
    else
        SendNUIMessage({
            action = 'closeRadial'
        })
    end
end

-- Comando para abrir (puedes vincularlo a una tecla en Key Mappings)
RegisterCommand('mechanicMenu', function()
    local playerData = exports['qb-mechanic-pro']:GetPlayerData()
    
    -- Verificar si tiene trabajo de mecánico (o está on duty)
    if playerData.job and playerData.job.name == 'mechanic' then -- Ajusta el nombre del job
        ToggleRadial(not radialOpen)
    else
        exports['qb-mechanic-pro']:Notify('No eres mecánico', 'error')
    end
end)
RegisterKeyMapping('mechanicMenu', 'Abrir Menú Mecánico', 'keyboard', 'F1')

-- Callbacks de NUI
RegisterNUICallback('radialClick', function(data, cb)
    ToggleRadial(false)
    
    if data.event then
        -- Si el evento requiere argumentos (como el shopId para la tablet), 
        -- aquí deberías obtener el taller más cercano
        local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
        
        if data.id == 'carlift' then
             -- Lógica simple para buscar el taller más cercano si es necesario
             -- O simplemente disparar el evento
             TriggerEvent(data.event)
        elseif data.id == 'tablet' then
             -- Buscar taller cercano para abrir su tablet específica
             -- Por ahora abrimos una genérica
             TriggerEvent(data.event, 'bennys_lsia', 'dashboard') -- ID de ejemplo
        else
             TriggerEvent(data.event)
        end
    end
    cb('ok')
end)

RegisterNUICallback('closeRadial', function(_, cb)
    ToggleRadial(false)
    cb('ok')
end)

-- Eventos de utilidad rápida (Reparación/Limpieza)
RegisterNetEvent('qb-mechanic:client:cleanVehicle', function()
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    if vehicle then
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_MAID_CLEAN", 0, true)
        QBCore.Functions.Progressbar("clean_vehicle", "Limpiando vehículo...", 5000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- Done
            SetVehicleDirtLevel(vehicle, 0)
            ClearPedTasks(PlayerPedId())
            exports['qb-mechanic-pro']:Notify('Vehículo limpio', 'success')
        end)
    end
end)
