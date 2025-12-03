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

-- Callback: Establecer ubicación (Duty, Stash, etc.)
RegisterNUICallback('setLocation', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    -- Devolvemos las coordenadas actuales a la UI
    cb({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading
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