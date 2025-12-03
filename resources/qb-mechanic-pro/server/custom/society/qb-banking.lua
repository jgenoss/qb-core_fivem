-- ============================================================================
-- QB-MECHANIC-PRO - QB-Banking Integration
-- ============================================================================

if Config.SocietySystem ~= 'qb-banking' then
    return
end

-- ----------------------------------------------------------------------------
-- Agregar dinero a la cuenta del taller
-- ----------------------------------------------------------------------------
function AddShopMoney(jobName, amount, description)
    if not jobName or not amount then return false end
    
    exports['qb-banking']:AddMoney(jobName, amount, description or 'Mechanic shop transaction')
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Added $%s to %s (qb-banking)', amount, jobName))
    end
    
    return true
end

-- ----------------------------------------------------------------------------
-- Remover dinero de la cuenta del taller
-- ----------------------------------------------------------------------------
function RemoveShopMoney(jobName, amount, description)
    if not jobName or not amount then return false end
    
    local success = exports['qb-banking']:RemoveMoney(jobName, amount, description or 'Mechanic shop transaction')
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Removed $%s from %s (qb-banking)', amount, jobName))
    end
    
    return success
end

-- ----------------------------------------------------------------------------
-- Obtener saldo de la cuenta del taller
-- ----------------------------------------------------------------------------
function GetShopMoney(jobName)
    if not jobName then return 0 end
    
    local balance = exports['qb-banking']:GetAccountBalance(jobName)
    return balance or 0
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('AddShopMoney', AddShopMoney)
exports('RemoveShopMoney', RemoveShopMoney)
exports('GetShopMoney', GetShopMoney)