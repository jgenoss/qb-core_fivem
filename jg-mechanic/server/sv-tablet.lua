local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = {}
function L1_1(A0_2, A1_2)
local L2_2
L2_2 = L0_1
L2_2 = L2_2[A1_2]
if L2_2 then
L2_2 = L0_1
L2_2 = L2_2[A1_2]
L2_2 = L2_2.src
L2_2 = L2_2 == A0_2
end
return L2_2
end
HasActiveTabletConnection = L1_1
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:connect-vehicle"
function L3_1(A0_2, A1_2, A2_2)
local L3_2, L4_2
L3_2 = L0_1
L3_2 = L3_2[A1_2]
if L3_2 then
L3_2 = L3_2.netId
end
if L3_2 == A2_2 then
L3_2 = false
return L3_2
end
L3_2 = L0_1
L4_2 = {}
L4_2.netId = A2_2
L4_2.src = A0_2
L3_2[A1_2] = L4_2
L3_2 = true
return L3_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:disconnect-vehicle"
function L3_1(A0_2, A1_2)
local L2_2
L2_2 = L0_1
L2_2 = L2_2[A1_2]
if not L2_2 then
L2_2 = true
return L2_2
end
L2_2 = L0_1
L2_2 = L2_2[A1_2]
L2_2 = L2_2.src
if L2_2 ~= A0_2 then
L2_2 = false
return L2_2
end
L2_2 = L0_1
L2_2[A1_2] = nil
L2_2 = true
return L2_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:get-player-mechanics"
function L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
L1_2 = {}
L2_2 = Framework
L2_2 = L2_2.Server
L2_2 = L2_2.IsAdmin
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L3_2 = Config
L3_2 = L3_2.UseFrameworkJobs
if L3_2 then
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.GetPlayerJob
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L4_2 = MySQL
L4_2 = L4_2.query
L4_2 = L4_2.await
L5_2 = "SELECT name, label FROM mechanic_data"
L4_2 = L4_2(L5_2)
L5_2 = pairs
L6_2 = L4_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
L11_2 = Config
L11_2 = L11_2.MechanicLocations
L12_2 = L10_2.name
L11_2 = L11_2[L12_2]
if L11_2 then
L12_2 = Config
L12_2 = L12_2.AdminsHaveEmployeePermissions
if not L12_2 or not L2_2 then
L12_2 = L11_2.job
L13_2 = L3_2.name
if L12_2 ~= L13_2 then
goto lbl_54
end
end
L12_2 = L11_2.type
if "owned" == L12_2 then
L12_2 = L10_2.name
L13_2 = L10_2.label
if "" ~= L13_2 then
L13_2 = L10_2.label
if L13_2 then
goto lbl_53
end
end
L13_2 = L10_2.name
::lbl_53::
L1_2[L12_2] = L13_2
end
end
::lbl_54::
end
else
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.GetPlayerIdentifier
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L4_2 = MySQL
L4_2 = L4_2.query
L4_2 = L4_2.await
L5_2 = "SELECT d.*, e.identifier, e.role FROM mechanic_data d LEFT JOIN mechanic_employees e ON d.name = e.mechanic AND e.identifier = ?"
L6_2 = {}
L7_2 = L3_2
L6_2[1] = L7_2
L4_2 = L4_2(L5_2, L6_2)
L5_2 = pairs
L6_2 = L4_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
L11_2 = Config
L11_2 = L11_2.MechanicLocations
L12_2 = L10_2.name
L11_2 = L11_2[L12_2]
if L11_2 then
L12_2 = Config
L12_2 = L12_2.AdminsHaveEmployeePermissions
if not L12_2 or not L2_2 then
L12_2 = L10_2.owner_id
if L12_2 ~= L3_2 then
L12_2 = L10_2.role
if "manager" ~= L12_2 then
L12_2 = L10_2.role
if "mechanic" ~= L12_2 then
goto lbl_109
end
end
end
end
L12_2 = L11_2.type
if "owned" == L12_2 then
L12_2 = L10_2.name
L13_2 = L10_2.label
if "" ~= L13_2 then
L13_2 = L10_2.label
if L13_2 then
goto lbl_108
end
end
L13_2 = L10_2.name
::lbl_108::
L1_2[L12_2] = L13_2
end
end
::lbl_109::
end
end
return L1_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:get-tablet-mechanic-data"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
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
L4_2 = MySQL
L4_2 = L4_2.scalar
L4_2 = L4_2.await
L5_2 = "SELECT COUNT(*) FROM mechanic_orders WHERE mechanic = ?"
L6_2 = {}
L7_2 = A1_2
L6_2[1] = L7_2
L4_2 = L4_2(L5_2, L6_2)
L5_2 = MySQL
L5_2 = L5_2.scalar
L5_2 = L5_2.await
L6_2 = "SELECT COUNT(*) FROM mechanic_orders WHERE mechanic = ? AND fulfilled = 0"
L7_2 = {}
L8_2 = A1_2
L7_2[1] = L8_2
L5_2 = L5_2(L6_2, L7_2)
L6_2 = MySQL
L6_2 = L6_2.scalar
L6_2 = L6_2.await
L7_2 = "SELECT COUNT(*) FROM mechanic_invoices WHERE mechanic = ?"
L8_2 = {}
L9_2 = A1_2
L8_2[1] = L9_2
L6_2 = L6_2(L7_2, L8_2)
L7_2 = MySQL
L7_2 = L7_2.scalar
L7_2 = L7_2.await
L8_2 = "SELECT COUNT(*) FROM mechanic_invoices WHERE paid = 0 AND mechanic = ?"
L9_2 = {}
L10_2 = A1_2
L9_2[1] = L10_2
L7_2 = L7_2(L8_2, L9_2)
L8_2 = MySQL
L8_2 = L8_2.scalar
L8_2 = L8_2.await
L9_2 = "SELECT COUNT(*) FROM mechanic_employees WHERE mechanic = ?"
L10_2 = {}
L11_2 = A1_2
L10_2[1] = L11_2
L8_2 = L8_2(L9_2, L10_2)
L9_2 = {}
L10_2 = L3_2.label
L9_2.label = L10_2
L10_2 = L3_2.balance
L9_2.balance = L10_2
L10_2 = L3_2.owner_id
L9_2.ownerId = L10_2
L10_2 = L5_2 or L10_2
if not L5_2 then
L10_2 = 0
end
L9_2.ordersCount = L10_2
L10_2 = L7_2 or L10_2
if not L7_2 then
L10_2 = 0
end
L9_2.unpaidInvoicesCount = L10_2
L9_2.employeeRole = L2_2
L10_2 = {}
L11_2 = L4_2 or L11_2
if not L4_2 then
L11_2 = 0
end
L10_2.totalOrders = L11_2
L11_2 = L6_2 or L11_2
if not L6_2 then
L11_2 = 0
end
L10_2.totalInvoices = L11_2
L11_2 = L8_2 or L11_2
if not L8_2 then
L11_2 = 0
end
L10_2.totalEmployees = L11_2
L9_2.stats = L10_2
return L9_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:get-vehicle-mileage"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
L2_2 = exports
L2_2 = L2_2["jg-vehiclemileage"]
L3_2 = L2_2
L2_2 = L2_2.GetMileage
L4_2 = A1_2
return L2_2(L3_2, L4_2)
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:toggle-on-duty"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
L2_2 = Player
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = L2_2.mechanicId
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = isEmployee
L5_2 = A0_2
L6_2 = L3_2
L7_2 = {}
L8_2 = "mechanic"
L9_2 = "manager"
L7_2[1] = L8_2
L7_2[2] = L9_2
L8_2 = true
L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
if not L4_2 then
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.Notify
L6_2 = A0_2
L7_2 = Locale
L7_2 = L7_2.employeePermissionsError
L8_2 = "error"
L5_2(L6_2, L7_2, L8_2)
L5_2 = false
return L5_2
end
L5_2 = GlobalState
L5_2 = L5_2.mechanicsOnDuty
if not L5_2 then
L5_2 = {}
end
L6_2 = tostring
L7_2 = A0_2
L6_2 = L6_2(L7_2)
L7_2 = L3_2 or L7_2
if not A1_2 or not L3_2 then
L7_2 = false
end
L5_2[L6_2] = L7_2
L6_2 = GlobalState
L7_2 = L6_2
L6_2 = L6_2.set
L8_2 = "mechanicsOnDuty"
L9_2 = L5_2
L10_2 = true
L6_2(L7_2, L8_2, L9_2, L10_2)
L6_2 = true
return L6_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:is-on-duty"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
L2_2 = GlobalState
if L2_2 then
L2_2 = L2_2.mechanicsOnDuty
end
if not L2_2 then
L2_2 = false
return L2_2
end
L2_2 = GlobalState
L2_2 = L2_2.mechanicsOnDuty
L3_2 = tostring
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L2_2 = L2_2[L3_2]
L2_2 = L2_2 == A1_2
return L2_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:get-tablet-preferences"
function L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2
L1_2 = Framework
L1_2 = L1_2.Server
L1_2 = L1_2.GetPlayerIdentifier
L2_2 = A0_2
L1_2 = L1_2(L2_2)
L2_2 = MySQL
L2_2 = L2_2.scalar
L2_2 = L2_2.await
L3_2 = "SELECT preferences FROM mechanic_settings WHERE identifier = ?"
L4_2 = {}
L5_2 = L1_2
L4_2[1] = L5_2
L2_2 = L2_2(L3_2, L4_2)
if L2_2 then
L3_2 = json
L3_2 = L3_2.decode
L4_2 = L2_2
L3_2 = L3_2(L4_2)
if L3_2 then
goto lbl_24
end
end
L3_2 = false
::lbl_24::
return L3_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:save-tablet-settings"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L2_2 = Player
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = L2_2.mechanicId
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = isEmployee
L5_2 = A0_2
L6_2 = L3_2
L7_2 = {}
L8_2 = "mechanic"
L9_2 = "manager"
L7_2[1] = L8_2
L7_2[2] = L9_2
L8_2 = true
L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
if not L4_2 then
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.Notify
L6_2 = A0_2
L7_2 = Locale
L7_2 = L7_2.employeePermissionsError
L8_2 = "error"
L5_2(L6_2, L7_2, L8_2)
L5_2 = false
return L5_2
end
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.GetPlayerIdentifier
L6_2 = A0_2
L5_2 = L5_2(L6_2)
L6_2 = MySQL
L6_2 = L6_2.insert
L6_2 = L6_2.await
L7_2 = "INSERT INTO mechanic_settings (identifier, preferences) VALUES(?, ?) ON DUPLICATE KEY UPDATE preferences = ?"
L8_2 = {}
L9_2 = L5_2
L10_2 = json
L10_2 = L10_2.encode
L11_2 = A1_2
L10_2 = L10_2(L11_2)
L11_2 = json
L11_2 = L11_2.encode
L12_2 = A1_2
L11_2, L12_2 = L11_2(L12_2)
L8_2[1] = L9_2
L8_2[2] = L10_2
L8_2[3] = L11_2
L8_2[4] = L12_2
L6_2(L7_2, L8_2)
L6_2 = true
return L6_2
end
L1_1(L2_1, L3_1)
L1_1 = Config
L1_1 = L1_1.UseTabletCommand
if L1_1 then
L1_1 = lib
L1_1 = L1_1.addCommand
L2_1 = Config
L2_1 = L2_1.UseTabletCommand
if not L2_1 then
L2_1 = "tablet"
end
L3_1 = {}
L3_1.help = "Open mechanic tablet"
function L4_1(A0_2)
local L1_2, L2_2, L3_2
L1_2 = TriggerClientEvent
L2_2 = "jg-mechanic:client:use-tablet"
L3_2 = A0_2
L1_2(L2_2, L3_2)
end
L1_1(L2_1, L3_1, L4_1)
end