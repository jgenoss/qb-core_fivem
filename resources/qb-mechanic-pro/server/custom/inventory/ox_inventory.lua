-- ============================================================================
-- QB-MECHANIC-PRO - OX_Inventory Integration
-- ============================================================================

if Config.Inventory ~= 'ox_inventory' then
    return
end

-- ----------------------------------------------------------------------------
-- Crear stash para un taller
-- ----------------------------------------------------------------------------
function CreateMechanicStash(shopId)
    local stashId = 'mechanic_' .. shopId
    
    exports.ox_inventory:RegisterStash(stashId, 'Mechanic Stash', 50, 100000, false)
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Stash registered: %s', stashId))
    end
    
    return stashId
end

-- ----------------------------------------------------------------------------
-- Abrir stash
-- ----------------------------------------------------------------------------
function OpenMechanicStash(source, shopId)
    local stashId = 'mechanic_' .. shopId
    exports.ox_inventory:forceOpenInventory(source, 'stash', stashId)
end

-- ----------------------------------------------------------------------------
-- Dar item a jugador
-- ----------------------------------------------------------------------------
function GiveItem(source, item, amount, metadata)
    local success = exports.ox_inventory:AddItem(source, item, amount or 1, metadata or {})
    return success
end

-- ----------------------------------------------------------------------------
-- Remover item de jugador
-- ----------------------------------------------------------------------------
function RemoveItem(source, item, amount)
    local success = exports.ox_inventory:RemoveItem(source, item, amount or 1)
    return success
end

-- ----------------------------------------------------------------------------
-- Verificar si el jugador tiene un item
-- ----------------------------------------------------------------------------
function HasItem(source, item, amount)
    local count = exports.ox_inventory:GetItemCount(source, item)
    return count >= (amount or 1)
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('CreateMechanicStash', CreateMechanicStash)
exports('OpenMechanicStash', OpenMechanicStash)
exports('GiveItem', GiveItem)
exports('RemoveItem', RemoveItem)
exports('HasItem', HasItem)