-- ============================================================================
-- QB-MECHANIC-PRO - QBCore Society System (Server)
-- Gestión de dinero de sociedad usando management_funds
-- ============================================================================

if not Config.UseSociety or Config.SocietySystem ~= 'qb-core' then
    return
end

local useNewBanking = false

-- ----------------------------------------------------------------------------
-- Detectar sistema bancario
-- ----------------------------------------------------------------------------
local function checkManagementFunds()
    local result = MySQL.query.await([[
        SELECT COUNT(*) as count 
        FROM information_schema.tables 
        WHERE table_schema = DATABASE() AND table_name = ?
    ]], {"management_funds"})
    
    if result and result[1] and result[1].count > 0 then
        if Config.Debug then
            print("^2[QB-MECHANIC-PRO]^0 Using 'management_funds' table")
        end
        return true
    else
        if Config.Debug then
            print("^3[QB-MECHANIC-PRO]^0 Table 'management_funds' not found")
        end
        return false
    end
end

local function checkBankAccountsTable()
    local result = MySQL.query.await([[
        SELECT COUNT(*) as count 
        FROM information_schema.tables 
        WHERE table_schema = DATABASE() AND table_name = ?
    ]], {"bank_accounts"})
    
    if result and result[1] and result[1].count > 0 then
        if Config.Debug then
            print("^2[QB-MECHANIC-PRO]^0 Using 'bank_accounts' table instead")
        end
        return true
    else
        if Config.Debug then
            print("^1[QB-MECHANIC-PRO]^0 No valid bank table found!^0")
        end
        return false
    end
end

-- Verificar qué tabla usar
if checkManagementFunds() then
    useNewBanking = false
elseif checkBankAccountsTable() then
    useNewBanking = true
else
    print("^1[QB-MECHANIC-PRO] FATAL ERROR: No bank management system found!^0")
    return
end

-- ----------------------------------------------------------------------------
-- Funciones de Society
-- ----------------------------------------------------------------------------

if not useNewBanking then
    -- Usar management_funds (qb-management estilo)
    
    function GetJobAccountMoney(jobName)
        if not jobName or jobName == "" then
            return 0
        end
        
        local result = MySQL.query.await("SELECT amount FROM `management_funds` WHERE job_name = ?", {jobName})
        
        if result and result[1] then
            return tonumber(result[1].amount) or 0
        else
            -- Crear entrada si no existe
            MySQL.insert.await('INSERT INTO `management_funds` (`job_name`, `amount`, `type`) VALUES (?, 0, ?)', {jobName, 'boss'})
            return 0
        end
    end
    
    function AddJobAccountMoney(jobName, amount)
        if not jobName or jobName == "" or not amount or amount <= 0 then
            return false
        end
        
        -- Asegurar que existe la entrada
        GetJobAccountMoney(jobName)
        
        local affectedRows = MySQL.update.await([[
            UPDATE `management_funds` 
            SET amount = amount + ? 
            WHERE job_name = ?
        ]], {amount, jobName})
        
        return affectedRows > 0
    end
    
    function RemoveJobAccountMoney(jobName, amount)
        if not jobName or jobName == "" or not amount or amount <= 0 then
            return false
        end
        
        local currentBalance = GetJobAccountMoney(jobName)
        if currentBalance < amount then
            return false
        end
        
        local affectedRows = MySQL.update.await([[
            UPDATE `management_funds` 
            SET amount = amount - ? 
            WHERE job_name = ? AND amount >= ?
        ]], {amount, jobName, amount})
        
        return affectedRows > 0
    end
    
else
    -- Usar bank_accounts (sistemas bancarios modernos)
    
    function GetJobAccountMoney(jobName)
        if not jobName or jobName == "" then
            return 0
        end
        
        local accountName = 'society_' .. jobName
        local result = MySQL.query.await("SELECT amount FROM `bank_accounts` WHERE account_name = ?", {accountName})
        
        if result and result[1] then
            return tonumber(result[1].amount) or 0
        else
            -- Crear cuenta si no existe
            MySQL.insert.await([[
                INSERT INTO `bank_accounts` (`account_name`, `amount`, `account_type`) 
                VALUES (?, 0, 'shared')
            ]], {accountName})
            return 0
        end
    end
    
    function AddJobAccountMoney(jobName, amount)
        if not jobName or jobName == "" or not amount or amount <= 0 then
            return false
        end
        
        local accountName = 'society_' .. jobName
        
        -- Asegurar que existe la cuenta
        GetJobAccountMoney(jobName)
        
        local affectedRows = MySQL.update.await([[
            UPDATE `bank_accounts` 
            SET amount = amount + ? 
            WHERE account_name = ?
        ]], {amount, accountName})
        
        return affectedRows > 0
    end
    
    function RemoveJobAccountMoney(jobName, amount)
        if not jobName or jobName == "" or not amount or amount <= 0 then
            return false
        end
        
        local accountName = 'society_' .. jobName
        local currentBalance = GetJobAccountMoney(jobName)
        
        if currentBalance < amount then
            return false
        end
        
        local affectedRows = MySQL.update.await([[
            UPDATE `bank_accounts` 
            SET amount = amount - ? 
            WHERE account_name = ? AND amount >= ?
        ]], {amount, accountName, amount})
        
        return affectedRows > 0
    end
end

-- ----------------------------------------------------------------------------
-- Funciones de pago
-- ----------------------------------------------------------------------------

function PayEmployee(source, amount, reason)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.AddMoney('cash', amount, reason or 'mechanic-commission')
    return true
end

function ChargeCustomer(source, amount, reason)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    -- Intentar cobrar de bank primero, luego cash
    if Player.Functions.RemoveMoney('bank', amount, reason or 'mechanic-service') then
        return true
    elseif Player.Functions.RemoveMoney('cash', amount, reason or 'mechanic-service') then
        return true
    end
    
    return false
end

function RefundCustomer(source, amount, reason)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    Player.Functions.AddMoney('bank', amount, reason or 'mechanic-refund')
    return true
end

-- ----------------------------------------------------------------------------
-- Procesamiento de órdenes
-- ----------------------------------------------------------------------------

function ProcessOrderPayment(source, shopData, orderData)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end
    
    local totalCost = orderData.totalCost
    
    -- Cobrar al cliente
    if not ChargeCustomer(source, totalCost, 'Mechanic Service') then
        return false, 'insufficient_funds'
    end
    
    -- Si es job-restricted, añadir dinero a la sociedad
    if shopData.ownership_type == 'job' and shopData.job_name then
        AddJobAccountMoney(shopData.job_name, totalCost)
    end
    
    -- Registrar transacción
    Database.CreateTransaction({
        shopId = shopData.id,
        type = 'order_payment',
        amount = totalCost,
        description = 'Order #' .. orderData.orderId,
        employeeCitizenid = nil,
        orderId = orderData.orderId
    })
    
    return true
end

function ProcessOrderCompletion(mechanicSource, shopData, orderData)
    local Mechanic = QBCore.Functions.GetPlayer(mechanicSource)
    if not Mechanic then return false end
    
    local totalCost = orderData.totalCost
    
    -- Calcular comisión del mecánico
    local commission = math.floor(totalCost * Config.Commissions.MechanicShare)
    
    -- Pagar comisión al mecánico
    PayEmployee(mechanicSource, commission, 'Order Commission')
    
    -- Registrar transacción de comisión
    Database.CreateTransaction({
        shopId = shopData.id,
        type = 'commission',
        amount = commission,
        description = 'Commission for Order #' .. orderData.orderId,
        employeeCitizenid = Mechanic.PlayerData.citizenid,
        orderId = orderData.orderId
    })
    
    return true
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------

exports('GetJobAccountMoney', GetJobAccountMoney)
exports('AddJobAccountMoney', AddJobAccountMoney)
exports('RemoveJobAccountMoney', RemoveJobAccountMoney)
exports('PayEmployee', PayEmployee)
exports('ChargeCustomer', ChargeCustomer)
exports('RefundCustomer', RefundCustomer)
exports('ProcessOrderPayment', ProcessOrderPayment)
exports('ProcessOrderCompletion', ProcessOrderCompletion)

-- ----------------------------------------------------------------------------
-- Log de inicialización
-- ----------------------------------------------------------------------------

if Config.Debug then
    print('^2[QB-MECHANIC-PRO]^0 Society system initialized')
    print('^3Banking System:^0 ' .. (useNewBanking and 'bank_accounts' or 'management_funds'))
end