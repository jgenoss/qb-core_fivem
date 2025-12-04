-- client/modules/creator.lua

local creatorActive = false
local currentCoords = nil

-- Evento para abrir el UI (activado desde server o comando)
RegisterNetEvent('qb-mechanic:client:openCreator', function()
    creatorActive = true
    SetNuiFocus(true, true)
    
    -- Enviamos los datos actuales de talleres a la UI
    -- Nota: loadedShops se define en client.lua como variable global
    SendNUIMessage({
        action = 'openCreator',
        shops = exports['qb-mechanic-pro']:GetAllShops() -- Asegúrate de exportar loadedShops en client.lua
    })
end)

-- Callback: Guardar Taller
RegisterNUICallback('saveShop', function(data, cb)
    -- Aquí podrías añadir validaciones extra si quisieras
    TriggerServerEvent('qb-mechanic:server:saveShop', data)
    cb({ success = true })
end)

-- Callback: Borrar Taller
RegisterNUICallback('deleteShop', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:deleteShop', data.shopId)
    cb({ success = true })
end)

-- Callback: Cerrar UI
RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    creatorActive = false
    cb('ok')
end)

-- ================================================================
-- SISTEMA DE SELECCIÓN DE COORDENADAS (Modo Colocación)
-- ================================================================
local selectingLocation = false

RegisterNUICallback('startLocationSelection', function(data, cb)
    -- 1. Quitamos el foco del NUI para que el jugador pueda moverse
    SetNuiFocus(false, false)
    selectingLocation = true
    cb('ok')

    -- 2. Iniciamos el hilo de selección
    CreateThread(function()
        while selectingLocation do
            Wait(0)
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            -- Dibujar marcador visual en el suelo
            DrawMarker(0, coords.x, coords.y, coords.z + 1.0, 0,0,0, 0,0,0, 0.5, 0.5, 0.5, 0, 163, 255, 200, true, false, 2, false, nil, nil, false)
            DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0,0,0, 0,0,0, 1.0, 1.0, 1.0, 0, 163, 255, 100, false, false, 2, false, nil, nil, false)
            
            -- Instrucciones en pantalla
            -- (Opcional: Si tienes qb-core notify o drawtext, úsalo aquí)
            
            -- CONFIRMAR con tecla 'E' (38)
            if IsControlJustPressed(0, 38) then 
                selectingLocation = false
                
                local finalCoords = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    w = heading
                }

                -- 3. Devolvemos el foco y los datos a la UI
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'updateLocation', -- Evento que escucha JS
                    type = data.type,          -- Qué estamos marcando (stash, duty, etc)
                    coords = finalCoords       -- Las coordenadas elegidas
                })
            end

            -- CANCELAR con tecla 'Backspace' (177)
            if IsControlJustPressed(0, 177) then
                selectingLocation = false
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'cancelLocation' -- Solo reabre el menú sin guardar
                })
            end
        end
    end)
end)

-- Callback: Establecer ubicación (Duty, Stash, etc.)
RegisterNUICallback('setLocation', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Preparamos el objeto de coordenadas
    local coordsData = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = heading
    }

    -- DEVOLVEMOS los datos a la UI (Esto es lo que faltaba)
    cb({
        success = true,
        coords = coordsData
    })
end)

-- Callback: Teletransportarse a un taller
RegisterNUICallback('teleportToShop', function(data, cb)
    local shopId = data.shopId
    -- Buscamos el taller en la lista local
    -- (Asumiendo que tienes acceso a loadedShops o usas un callback al server)
    -- Por simplicidad, pedimos al server que nos teletransporte o buscamos en cache
    TriggerServerEvent('qb-mechanic:server:teleportToShop', shopId)
    cb('ok')
end)