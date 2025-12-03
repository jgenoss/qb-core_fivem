-- server/custom/society/qb-core.lua

local function GetSocietyAccount(jobName)
    return 'society_' .. jobName
end

-- Añadir dinero a la sociedad
function AddSocietyMoney(jobName, amount)
    if not jobName then return false end
    
    -- Soporte para qb-banking / Renewed-Banking / qb-management
    if GetResourceState('qb-banking') == 'started' then
        exports['qb-banking']:AddMoney(GetSocietyAccount(jobName), amount, 'Mechanic Revenue')
    elseif GetResourceState('Renewed-Banking') == 'started' then
        exports['Renewed-Banking']:addAccountMoney(GetSocietyAccount(jobName), amount)
    elseif GetResourceState('qb-management') == 'started' then
        exports['qb-management']:AddMoney(jobName, amount)
    else
        -- Fallback directo a base de datos si no hay script de banco
        -- Asegúrate de tener la tabla management_funds o similar
        MySQL.update('UPDATE management_funds SET amount = amount + ? WHERE job_name = ?', {amount, jobName})
    end
end

-- Retirar dinero (usado para pagar gastos o salarios si implementas eso)
function RemoveSocietyMoney(jobName, amount)
    if not jobName then return false end
    
    if GetResourceState('qb-management') == 'started' then
        return exports['qb-management']:RemoveMoney(jobName, amount)
    elseif GetResourceState('Renewed-Banking') == 'started' then
        return exports['Renewed-Banking']:removeAccountMoney(GetSocietyAccount(jobName), amount)
    end
    return false
end

-- Exportar funciones globalmente para que otros módulos las usen
exports('AddSocietyMoney', AddSocietyMoney)
exports('RemoveSocietyMoney', RemoveSocietyMoney)