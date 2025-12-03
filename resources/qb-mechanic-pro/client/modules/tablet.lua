-- client/modules/tablet.lua

-- Evento para abrir la tablet
RegisterNetEvent('qb-mechanic:client:openTabletUI', function(shopId, shopData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        shop = shopData
    })
end)

-- Callback: Contratar Empleado
RegisterNUICallback('hireEmployee', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:hireEmployee', data.shopId, data.targetServerId)
    cb({ success = true }) -- La respuesta real vendrá por notificación
end)

-- Callback: Despedir Empleado
RegisterNUICallback('fireEmployee', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:fireEmployee', data.shopId, data.employeeCitizenid)
    cb({ success = true })
end)

-- Callback: Solicitar actualización de datos (refresh)
RegisterNUICallback('requestShopData', function(data, cb)
    TriggerServerEvent('qb-mechanic:server:requestShopData', data.shopId)
    cb('ok')
end)