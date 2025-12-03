-- ============================================================================
-- QB-MECHANIC-PRO - Acciones de Mecánico y Items
-- ============================================================================

-- Configuración de ítems para Swap de Motor
local items = {
    hoist = 'engine_hoist',
    engine = 'car_engine'
}

-- ============================================================================
-- SISTEMA DE SWAP DE MOTORES (Engine Swap)
-- ============================================================================

-- Evento: Finalizar extracción de motor
RegisterNetEvent('qb-mechanic:server:finishEngineRemove', function(netId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local entity = NetworkGetEntityFromNetworkId(netId)
    
    if not Player or not DoesEntityExist(entity) then return end

    -- Dar ítem de motor al jugador
    local info = {
        label = "Motor Usado",
        type = "engine",
        description = "Un motor extraído de un vehículo."
    }
    
    if Player.Functions.AddItem(items.engine, 1, false, info) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items.engine], "add")
    else
        TriggerClientEvent('QBCore:Notify', src, 'No tienes espacio en el inventario', 'error')
    end
end)

-- Evento: Finalizar instalación de motor
RegisterNetEvent('qb-mechanic:server:finishEngineInstall', function(netId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if not Player or not DoesEntityExist(entity) then return end

    -- Quitar ítem de motor
    if Player.Functions.RemoveItem(items.engine, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[items.engine], "remove")
    else
        TriggerClientEvent('QBCore:Notify', src, 'No tienes un motor para instalar', 'error')
    end
end)

-- Usable Item: Hoist (Grúa de motor)
QBCore.Functions.CreateUseableItem(items.hoist, function(source, item)
    TriggerClientEvent('qb-mechanic:client:startEngineSwap', source)
end)

-- ============================================================================
-- NUEVOS ITEMS DE SERVICIO (REPARACIÓN, LIMPIEZA, REMOLQUE)
-- ============================================================================

-- Item: Kit de Reparación Normal
QBCore.Functions.CreateUseableItem("repairkit", function(source, item)
    TriggerClientEvent("qb-mechanic:client:useRepairKit", source, false)
end)

-- Item: Kit de Reparación Avanzado
QBCore.Functions.CreateUseableItem("advanced_repairkit", function(source, item)
    TriggerClientEvent("qb-mechanic:client:useRepairKit", source, true)
end)

-- Item: Esponja (Limpieza)
QBCore.Functions.CreateUseableItem("sponge", function(source, item)
    TriggerClientEvent("qb-mechanic:client:useSponge", source)
end)

-- Item: Cuerda (Remolque manual)
QBCore.Functions.CreateUseableItem("rope", function(source, item)
    TriggerClientEvent("qb-mechanic:client:useRope", source)
end)

-- ============================================================================
-- UTILIDADES DE INVENTARIO
-- ============================================================================

-- Evento genérico para consumir un item tras una acción exitosa
RegisterNetEvent('qb-mechanic:server:removeItem', function(item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        if Player.Functions.RemoveItem(item, 1) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
        end
    end
end)