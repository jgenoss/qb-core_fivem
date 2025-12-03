-- server/custom/inventory/qb-inventory.lua

if Config.Inventory ~= 'qb-inventory' then return end

function AddItem(source, item, amount, info)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.AddItem(item, amount, false, info)
end

function RemoveItem(source, item, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    return Player.Functions.RemoveItem(item, amount)
end

function RegisterStash(shopId, label, slots, weight)
    -- qb-inventory no requiere registro de stash en server-side al inicio,
    -- se abre dinámicamente con el evento OpenInventory.
    -- Pero podemos guardar la configuración si es necesario.
end

-- Exportar
exports('AddItem', AddItem)
exports('RemoveItem', RemoveItem)