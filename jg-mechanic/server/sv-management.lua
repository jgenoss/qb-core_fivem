local L0_1, L1_1, L2_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
L2_2 = Config
L2_2 = L2_2.UseFrameworkJobs
if L2_2 then
L2_2 = Config
L2_2 = L2_2.MechanicLocations
L2_2 = L2_2[A1_2]
if L2_2 then
L2_2 = L2_2.job
end
if not L2_2 then
L3_2 = 0
return L3_2
end
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.GetSocietyBalance
L4_2 = L2_2
L5_2 = "job"
L3_2 = L3_2(L4_2, L5_2)
if not L3_2 then
L3_2 = 0
end
return L3_2
else
L2_2 = MySQL
L2_2 = L2_2.scalar
L2_2 = L2_2.await
L3_2 = "SELECT balance FROM mechanic_data WHERE name = ?"
L4_2 = {}
L5_2 = A1_2
L4_2[1] = L5_2
L2_2 = L2_2(L3_2, L4_2)
L3_2 = L2_2 or L3_2
if not L2_2 then
L3_2 = 0
end
return L3_2
end
end
getSocietyFund = L0_1
function L0_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2
if not A2_2 or A2_2 < 0 then
L3_2 = false
return L3_2
end
L3_2 = Config
L3_2 = L3_2.UseFrameworkJobs
if L3_2 then
L3_2 = Config
L3_2 = L3_2.MechanicLocations
L3_2 = L3_2[A1_2]
if L3_2 then
L3_2 = L3_2.job
end
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.PayIntoSocietyFund
L5_2 = L3_2
L6_2 = "job"
L7_2 = A2_2
L4_2(L5_2, L6_2, L7_2)
else
L3_2 = MySQL
L3_2 = L3_2.update
L3_2 = L3_2.await
L4_2 = "UPDATE mechanic_data SET balance = balance + ? WHERE name = ?"
L5_2 = {}
L6_2 = A2_2
L7_2 = A1_2
L5_2[1] = L6_2
L5_2[2] = L7_2
L3_2(L4_2, L5_2)
end
L3_2 = true
return L3_2
end
addToSocietyFund = L0_1
function L0_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
if not A2_2 or A2_2 < 0 then
L3_2 = false
return L3_2
end
L3_2 = Config
L3_2 = L3_2.UseFrameworkJobs
if L3_2 then
L3_2 = Config
L3_2 = L3_2.MechanicLocations
L3_2 = L3_2[A1_2]
if L3_2 then
L3_2 = L3_2.job
end
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.GetSocietyBalance
L5_2 = L3_2
L6_2 = "job"
L4_2 = L4_2(L5_2, L6_2)
if A2_2 > L4_2 then
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.Notify
L6_2 = A0_2
L7_2 = Locale
L7_2 = L7_2.notEnoughMoney
L8_2 = "error"
L5_2(L6_2, L7_2, L8_2)
L5_2 = false
return L5_2
end
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.RemoveFromSocietyFund
L6_2 = L3_2
L7_2 = "job"
L8_2 = A2_2
L5_2(L6_2, L7_2, L8_2)
else
L3_2 = MySQL
L3_2 = L3_2.scalar
L3_2 = L3_2.await
L4_2 = "SELECT balance FROM mechanic_data WHERE name = ?"
L5_2 = {}
L6_2 = A1_2
L5_2[1] = L6_2
L3_2 = L3_2(L4_2, L5_2)
if A2_2 > L3_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.notEnoughMoney
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = MySQL
L4_2 = L4_2.update
L4_2 = L4_2.await
L5_2 = "UPDATE mechanic_data SET balance = balance - ? WHERE name = ?"
L6_2 = {}
L7_2 = A2_2
L8_2 = A1_2
L6_2[1] = L7_2
L6_2[2] = L8_2
L4_2(L5_2, L6_2)
end
L3_2 = true
return L3_2
end
removeFromSocietyFund = L0_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:get-mechanic-balance"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L2_2 = isEmployee
L3_2 = A0_2
L4_2 = A1_2
L5_2 = {}
L6_2 = "mechanic"
L7_2 = "manager"
L5_2[1] = L6_2
L5_2[2] = L7_2
L6_2 = true
L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
if not L2_2 then
L2_2 = Framework
L2_2 = L2_2.Server
L2_2 = L2_2.Notify
L3_2 = A0_2
L4_2 = Locale
L4_2 = L4_2.employeePermissionsError
L5_2 = "error"
L2_2(L3_2, L4_2, L5_2)
L2_2 = false
return L2_2
end
L2_2 = getSocietyFund
L3_2 = A0_2
L4_2 = A1_2
return L2_2(L3_2, L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:get-mechanic-employees"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L2_2 = Framework
L2_2 = L2_2.Server
L2_2 = L2_2.GetPlayerIdentifier
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L3_2 = Config
L3_2 = L3_2.UseFrameworkJobs
if L3_2 then
L3_2 = {}
return L3_2
end
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = A1_2
L6_2 = "manager"
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.Notify
L4_2 = A0_2
L5_2 = Locale
L5_2 = L5_2.employeePermissionsError
L6_2 = "error"
L3_2(L4_2, L5_2, L6_2)
L3_2 = false
return L3_2
end
L3_2 = MySQL
L3_2 = L3_2.query
L3_2 = L3_2.await
L4_2 = "SELECT * FROM mechanic_employees WHERE mechanic = ?"
L5_2 = {}
L6_2 = A1_2
L5_2[1] = L6_2
L3_2 = L3_2(L4_2, L5_2)
L4_2 = ipairs
L5_2 = L3_2
L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
L10_2 = {}
L11_2 = L9_2.player
L10_2.id = L11_2
L11_2 = L9_2.identifier
L10_2.identifier = L11_2
L11_2 = Framework
L11_2 = L11_2.Server
L11_2 = L11_2.GetPlayerInfoFromIdentifier
L12_2 = L9_2.identifier
L11_2 = L11_2(L12_2)
if L11_2 then
L11_2 = L11_2.name
end
if not L11_2 then
L11_2 = "-"
end
L10_2.name = L11_2
L11_2 = L9_2.role
L10_2.role = L11_2
L11_2 = L9_2.joined
L10_2.joined = L11_2
L11_2 = L9_2.identifier
L11_2 = L2_2 == L11_2
L10_2.me = L11_2
L3_2[L8_2] = L10_2
end
return L3_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:mechanic-deposit"
function L2_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L4_2 = isEmployee
L5_2 = A0_2
L6_2 = A1_2
L7_2 = "manager"
L8_2 = true
L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
if not L4_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.employeePermissionsError
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
if A3_2 < 0 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = "Stop trying to exploit the script"
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.GetPlayerBalance
L5_2 = A0_2
L6_2 = A2_2
L4_2 = L4_2(L5_2, L6_2)
if A3_2 > L4_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.notEnoughMoney
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.PlayerRemoveMoney
L5_2 = A0_2
L6_2 = A3_2
L7_2 = A2_2
L4_2(L5_2, L6_2, L7_2)
L4_2 = MySQL
L4_2 = L4_2.update
L4_2 = L4_2.await
L5_2 = "UPDATE mechanic_data SET balance = balance + ? WHERE name = ?"
L6_2 = {}
L7_2 = A3_2
L8_2 = A1_2
L6_2[1] = L7_2
L6_2[2] = L8_2
L4_2(L5_2, L6_2)
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.depositSuccess
L7_2 = "success"
L4_2(L5_2, L6_2, L7_2)
L4_2 = sendWebhook
L5_2 = A0_2
L6_2 = Webhooks
L6_2 = L6_2.Mechanic
L7_2 = "Mechanic: Money Deposited"
L8_2 = nil
L9_2 = {}
L10_2 = {}
L10_2.key = "Mechanic"
L10_2.value = A1_2
L11_2 = {}
L11_2.key = "Amount"
L11_2.value = A3_2
L9_2[1] = L10_2
L9_2[2] = L11_2
L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
L4_2 = true
return L4_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:mechanic-withdraw"
function L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = A1_2
L6_2 = "manager"
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.Notify
L4_2 = A0_2
L5_2 = Locale
L5_2 = L5_2.employeePermissionsError
L6_2 = "error"
L3_2(L4_2, L5_2, L6_2)
L3_2 = false
return L3_2
end
if A2_2 < 0 then
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.Notify
L4_2 = A0_2
L5_2 = "Stop trying to exploit the script"
L6_2 = "error"
L3_2(L4_2, L5_2, L6_2)
L3_2 = false
return L3_2
end
L3_2 = MySQL
L3_2 = L3_2.single
L3_2 = L3_2.await
L4_2 = "SELECT * FROM mechanic_data WHERE name = ?"
L5_2 = {}
L6_2 = A1_2
L5_2[1] = L6_2
L3_2 = L3_2(L4_2, L5_2)
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = L3_2.balance
if A2_2 > L4_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.insufficientFunds
L7_2 = L6_2
L6_2 = L6_2.format
L8_2 = tostring
L9_2 = A2_2
L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2, L11_2)
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.PlayerAddMoney
L5_2 = A0_2
L6_2 = A2_2
L7_2 = "bank"
L4_2(L5_2, L6_2, L7_2)
L4_2 = MySQL
L4_2 = L4_2.update
L4_2 = L4_2.await
L5_2 = "UPDATE mechanic_data SET balance = balance - ? WHERE name = ?"
L6_2 = {}
L7_2 = A2_2
L8_2 = A1_2
L6_2[1] = L7_2
L6_2[2] = L8_2
L4_2(L5_2, L6_2)
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.withdrawSuccess
L7_2 = "success"
L4_2(L5_2, L6_2, L7_2)
L4_2 = sendWebhook
L5_2 = A0_2
L6_2 = Webhooks
L6_2 = L6_2.Mechanic
L7_2 = "Mechanic: Money Withdraw"
L8_2 = nil
L9_2 = {}
L10_2 = {}
L10_2.key = "Mechanic"
L10_2.value = A1_2
L11_2 = {}
L11_2.key = "Amount"
L11_2.value = A2_2
L9_2[1] = L10_2
L9_2[2] = L11_2
L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
L4_2 = true
return L4_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:update-mechanic-settings"
function L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = A1_2
L6_2 = "manager"
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.Notify
L4_2 = A0_2
L5_2 = Locale
L5_2 = L5_2.employeePermissionsError
L6_2 = "error"
L3_2(L4_2, L5_2, L6_2)
L3_2 = false
return L3_2
end
L3_2 = MySQL
L3_2 = L3_2.update
L3_2 = L3_2.await
L4_2 = "UPDATE mechanic_data SET label = ? WHERE name = ?"
L5_2 = {}
L6_2 = A2_2.label
L7_2 = A1_2
L5_2[1] = L6_2
L5_2[2] = L7_2
L3_2(L4_2, L5_2)
L3_2 = TriggerClientEvent
L4_2 = "jg-mechanic:client:refresh-mechanic-zones-and-blips"
L5_2 = -1
L3_2(L4_2, L5_2)
L3_2 = sendWebhook
L4_2 = A0_2
L5_2 = Webhooks
L5_2 = L5_2.Mechanic
L6_2 = "Mechanic: Name Updated"
L7_2 = nil
L8_2 = {}
L9_2 = {}
L9_2.key = "Mechanic"
L9_2.value = A1_2
L10_2 = {}
L10_2.key = "New name"
L11_2 = A2_2.label
L10_2.value = L11_2
L8_2[1] = L9_2
L8_2[2] = L10_2
L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
L3_2 = true
return L3_2
end
L0_1(L1_1, L2_1)