-- ============================================================================
-- QB-MECHANIC-PRO - QBManagement Integration
-- ============================================================================

if Config.SocietySystem ~= 'qb-management' then
    return
end

-- ----------------------------------------------------------------------------
-- Agregar dinero a la cuenta del taller
-- ----------------------------------------------------------------------------
function AddShopMoney(jobName, amount, description)
    if not jobName or not amount then return false end
    
    exports['qb-management']:AddMoney(jobName, amount)
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Added $%s to %s (qb-management)', amount, jobName))
    end
    
    return true
end

-- ----------------------------------------------------------------------------
-- Remover dinero de la cuenta del taller
-- ----------------------------------------------------------------------------
function RemoveShopMoney(jobName, amount, description)
    if not jobName or not amount then return false end
    
    local success = exports['qb-management']:RemoveMoney(jobName, amount)
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Removed $%s from %s (qb-management)', amount, jobName))
    end
    
    return success
end

-- ----------------------------------------------------------------------------
-- Obtener saldo de la cuenta del taller
-- ----------------------------------------------------------------------------
function GetShopMoney(jobName)
    if not jobName then return 0 end
    
    local balance = exports['qb-management']:GetAccount(jobName)
    return balance or 0
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('AddShopMoney', AddShopMoney)
exports('RemoveShopMoney', RemoveShopMoney)
exports('GetShopMoney', GetShopMoney)