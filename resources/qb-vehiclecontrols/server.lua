local QBCore = exports['qb-core']:GetCoreObject()

-- Log de inicio
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('^2[qb-vehiclecontrols]^7 Sistema de control vehicular iniciado correctamente')
    end
end)

-- Sincronización de estados de luces (opcional para multijugador)
RegisterNetEvent('vehiclecontrol:sync:lights', function(netId, lightData)
    local src = source
    TriggerClientEvent('vehiclecontrol:sync:lights', -1, netId, lightData, src)
end)

-- Log de comandos para debugging
RegisterCommand('vehicledebug', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player and (Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name == 'mechanic') then
        TriggerClientEvent('QBCore:Notify', source, 'Sistema de control vehicular activo', 'success')
    end
end, false)