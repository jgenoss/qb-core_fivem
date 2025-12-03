-- ============================================================================
-- QB-MECHANIC-PRO - Renewed-Banking Integration
-- ============================================================================

if Config.SocietySystem ~= 'Renewed-Banking' then
    return
end

-- ----------------------------------------------------------------------------
-- Agregar dinero a la cuenta del taller
-- ----------------------------------------------------------------------------
function AddShopMoney(jobName, amount, description)
    if not jobName or not amount then return false end
    
    exports['Renewed-Banking']:addBusinessFunds(jobName, amount)
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Added $%s to %s (Renewed-Banking)', amount, jobName))
    end
    
    return true
end

-- ----------------------------------------------------------------------------
-- Remover dinero de la cuenta del taller
-- ----------------------------------------------------------------------------
function RemoveShopMoney(jobName, amount, description)
    if not jobName or not amount then return false end
    
    local success = exports['Renewed-Banking']:removeBusinessFunds(jobName, amount)
    
    if Config.Debug then
        print(string.format('^2[QB-MECHANIC-PRO]^0 Removed $%s from %s (Renewed-Banking)', amount, jobName))
    end
    
    return success
end

-- ----------------------------------------------------------------------------
-- Obtener saldo de la cuenta del taller
-- ----------------------------------------------------------------------------
function GetShopMoney(jobName)
    if not jobName then return 0 end
    
    local balance = exports['Renewed-Banking']:getBusinessFunds(jobName)
    return balance or 0
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('AddShopMoney', AddShopMoney)
exports('RemoveShopMoney', RemoveShopMoney)
exports('GetShopMoney', GetShopMoney)