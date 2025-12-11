local L0_1, L1_1, L2_1, L3_1
L0_1 = {}
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:get-orders"
function L3_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
L3_2 = Player
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L3_2 = L3_2.state
L3_2 = L3_2.mechanicId
if not L3_2 then
L4_2 = {}
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
L5_2 = {}
return L5_2
end
L5_2 = MySQL
L5_2 = L5_2.query
L5_2 = L5_2.await
L6_2 = "SELECT * FROM mechanic_orders WHERE mechanic = ? AND fulfilled = 0 ORDER BY date DESC LIMIT ? OFFSET ?"
L7_2 = {}
L8_2 = L3_2
L9_2 = A2_2
L10_2 = A1_2 * A2_2
L7_2[1] = L8_2
L7_2[2] = L9_2
L7_2[3] = L10_2
L5_2 = L5_2(L6_2, L7_2)
L6_2 = ipairs
L7_2 = L5_2
L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
L12_2 = L5_2[L10_2]
L13_2 = Framework
L13_2 = L13_2.Server
L13_2 = L13_2.GetPlayerInfoFromIdentifier
L14_2 = L11_2.identifier
L13_2 = L13_2(L14_2)
if L13_2 then
L13_2 = L13_2.name
end
if not L13_2 then
L13_2 = "-"
end
L12_2.recipient = L13_2
end
L6_2 = MySQL
L6_2 = L6_2.scalar
L6_2 = L6_2.await
L7_2 = "SELECT COUNT(*) FROM mechanic_orders WHERE mechanic = ? AND fulfilled = 0"
L8_2 = {}
L9_2 = L3_2
L8_2[1] = L9_2
L6_2 = L6_2(L7_2, L8_2)
L7_2 = math
L7_2 = L7_2.ceil
L8_2 = L6_2 / A2_2
L7_2 = L7_2(L8_2)
L8_2 = {}
L8_2.orders = L5_2
L8_2.pageCount = L7_2
L8_2.totalOrders = L6_2
return L8_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:can-apply-order"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L2_2 = Player
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L2_2 = L2_2.mechanicId
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = L2_2
L6_2 = {}
L7_2 = "mechanic"
L8_2 = "manager"
L6_2[1] = L7_2
L6_2[2] = L8_2
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
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
L4_2 = MySQL
L4_2 = L4_2.single
L4_2 = L4_2.await
L5_2 = "SELECT * FROM mechanic_orders WHERE id = ? AND mechanic = ? AND fulfilled = 0"
L6_2 = {}
L7_2 = A1_2
L8_2 = L2_2
L6_2[1] = L7_2
L6_2[2] = L8_2
L4_2 = L4_2(L5_2, L6_2)
if not L4_2 then
L5_2 = false
return L5_2
end
return L4_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:pay-for-order-installation"
function L3_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
L3_2 = Player
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L3_2 = L3_2.state
L4_2 = Config
L4_2 = L4_2.Mods
L4_2 = L4_2.ItemsRequired
L4_2 = L4_2[A1_2]
L5_2 = L4_2.itemName
L6_2 = L4_2.removeItem
if not L5_2 then
L7_2 = false
return L7_2
end
L7_2 = L3_2.mechanicId
if not L7_2 then
L8_2 = false
return L8_2
end
L8_2 = isEmployee
L9_2 = A0_2
L10_2 = L7_2
L11_2 = {}
L12_2 = "mechanic"
L13_2 = "manager"
L11_2[1] = L12_2
L11_2[2] = L13_2
L12_2 = true
L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2)
if not L8_2 then
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.Notify
L10_2 = A0_2
L11_2 = Locale
L11_2 = L11_2.employeePermissionsError
L12_2 = "error"
L9_2(L10_2, L11_2, L12_2)
L9_2 = false
return L9_2
end
if L6_2 then
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.RemoveItem
L10_2 = A0_2
L11_2 = L5_2
L12_2 = A2_2 or L12_2
if not A2_2 then
L12_2 = 1
end
L9_2 = L9_2(L10_2, L11_2, L12_2)
if not L9_2 then
L10_2 = false
return L10_2
end
end
L9_2 = true
return L9_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:mark-category-installed"
function L3_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L3_2 = Player
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L3_2 = L3_2.state
L3_2 = L3_2.mechanicId
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
L5_2 = MySQL
L5_2 = L5_2.scalar
L5_2 = L5_2.await
L6_2 = "SELECT installation_progress FROM mechanic_orders WHERE id = ? AND mechanic = ? AND fulfilled = 0"
L7_2 = {}
L8_2 = A1_2
L9_2 = L3_2
L7_2[1] = L8_2
L7_2[2] = L9_2
L5_2 = L5_2(L6_2, L7_2)
L6_2 = json
L6_2 = L6_2.decode
L7_2 = L5_2 or L7_2
if not L5_2 then
L7_2 = "{}"
end
L6_2 = L6_2(L7_2)
L5_2 = L6_2
L6_2 = type
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if "table" ~= L6_2 then
L6_2 = {}
L5_2 = L6_2
end
L5_2[A2_2] = true
L6_2 = MySQL
L6_2 = L6_2.update
L6_2 = L6_2.await
L7_2 = "UPDATE mechanic_orders SET installation_progress = ? WHERE id = ? AND mechanic = ?"
L8_2 = {}
L9_2 = json
L9_2 = L9_2.encode
L10_2 = L5_2
L9_2 = L9_2(L10_2)
L10_2 = A1_2
L11_2 = L3_2
L8_2[1] = L9_2
L8_2[2] = L10_2
L8_2[3] = L11_2
L6_2(L7_2, L8_2)
L6_2 = true
return L6_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:mark-order-fulfilled"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
L2_2 = L0_1
L2_2 = L2_2[A1_2]
if L2_2 then
L2_2 = false
return L2_2
end
L2_2 = L0_1
L2_2[A1_2] = true
L2_2 = Player
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L2_2 = L2_2.mechanicId
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = L2_2
L6_2 = {}
L7_2 = "mechanic"
L8_2 = "manager"
L6_2[1] = L7_2
L6_2[2] = L8_2
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.employeePermissionsError
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = L0_1
L4_2[A1_2] = nil
L4_2 = false
return L4_2
end
L4_2 = Config
L4_2 = L4_2.MechanicLocations
L4_2 = L4_2[L2_2]
if not L4_2 then
L5_2 = L0_1
L5_2[A1_2] = nil
L5_2 = false
return L5_2
end
L5_2 = MySQL
L5_2 = L5_2.scalar
L5_2 = L5_2.await
L6_2 = "SELECT amount_paid FROM mechanic_orders WHERE id = ? AND fulfilled = 0"
L7_2 = {}
L8_2 = A1_2
L7_2[1] = L8_2
L5_2 = L5_2(L6_2, L7_2)
if not L5_2 then
L6_2 = debugPrint
L7_2 = "Order could not be found in mechanic_orders - id: %s"
L8_2 = L7_2
L7_2 = L7_2.format
L9_2 = tostring
L10_2 = A1_2
L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L9_2(L10_2)
L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
L8_2 = "warning"
L6_2(L7_2, L8_2)
L6_2 = false
return L6_2
end
L6_2 = L4_2
if L6_2 then
L6_2 = L6_2.commission
end
if not L6_2 then
L6_2 = 0
end
L7_2 = math
L7_2 = L7_2.floor
L8_2 = L5_2 * L6_2
L8_2 = L8_2 / 100
L7_2 = L7_2(L8_2)
L8_2 = L4_2.job
L9_2 = debugPrint
L10_2 = "Mechanic ID: "
L11_2 = L2_2
L10_2 = L10_2 .. L11_2
L11_2 = "debug"
L9_2(L10_2, L11_2)
L9_2 = debugPrint
L10_2 = "Order ID: "
L11_2 = A1_2
L10_2 = L10_2 .. L11_2
L11_2 = "debug"
L9_2(L10_2, L11_2)
L9_2 = debugPrint
L10_2 = "Order Amount: "
L11_2 = L5_2
L10_2 = L10_2 .. L11_2
L11_2 = "debug"
L9_2(L10_2, L11_2)
L9_2 = debugPrint
L10_2 = "Commission Percentage: "
L11_2 = L6_2
L10_2 = L10_2 .. L11_2
L11_2 = "debug"
L9_2(L10_2, L11_2)
L9_2 = debugPrint
L10_2 = "Commission Amount: "
L11_2 = L7_2
L10_2 = L10_2 .. L11_2
L11_2 = "debug"
L9_2(L10_2, L11_2)
L9_2 = debugPrint
L10_2 = "Society Name: "
L11_2 = L8_2
L10_2 = L10_2 .. L11_2
L11_2 = "debug"
L9_2(L10_2, L11_2)
if not L7_2 or L7_2 <= 0 then
L9_2 = debugPrint
L10_2 = "Invalid commission amount. Skipping the removal of money..."
L11_2 = "warning"
L9_2(L10_2, L11_2)
else
L9_2 = removeFromSocietyFund
L10_2 = A0_2
L11_2 = L2_2
L12_2 = L7_2
L9_2(L10_2, L11_2, L12_2)
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.PlayerAddMoney
L10_2 = A0_2
L11_2 = L7_2
L12_2 = "bank"
L9_2(L10_2, L11_2, L12_2)
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.Notify
L10_2 = A0_2
L11_2 = "Commission paid"
L12_2 = "success"
L9_2(L10_2, L11_2, L12_2)
end
L9_2 = MySQL
L9_2 = L9_2.update
L9_2 = L9_2.await
L10_2 = "UPDATE mechanic_orders SET fulfilled = 1 WHERE mechanic = ? AND id = ?"
L11_2 = {}
L12_2 = L2_2
L13_2 = A1_2
L11_2[1] = L12_2
L11_2[2] = L13_2
L9_2(L10_2, L11_2)
L9_2 = sendWebhook
L10_2 = A0_2
L11_2 = Webhooks
L11_2 = L11_2.Orders
L12_2 = "Orders: Order Marked as Fulfilled"
L13_2 = "default"
L14_2 = {}
L15_2 = {}
L15_2.key = "Mechanic"
L15_2.value = L2_2
L16_2 = {}
L16_2.key = "Order #"
L16_2.value = A1_2
L17_2 = {}
L17_2.key = "Commission Earned"
L17_2.value = L7_2
L14_2[1] = L15_2
L14_2[2] = L16_2
L14_2[3] = L17_2
L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
L9_2 = L0_1
L9_2[A1_2] = nil
L9_2 = true
return L9_2
end
L1_1(L2_1, L3_1)
L1_1 = lib
L1_1 = L1_1.callback
L1_1 = L1_1.register
L2_1 = "jg-mechanic:server:delete-order"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
L2_2 = Player
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L2_2 = L2_2.mechanicId
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = L2_2
L6_2 = Config
L6_2 = L6_2.RequireManagementForOrderDeletion
if L6_2 then
L6_2 = {}
L7_2 = "manager"
L6_2[1] = L7_2
if L6_2 then
goto lbl_28
end
end
L6_2 = {}
L7_2 = "mechanic"
L8_2 = "manager"
L6_2[1] = L7_2
L6_2[2] = L8_2
::lbl_28::
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
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
L4_2 = MySQL
L4_2 = L4_2.single
L4_2 = L4_2.await
L5_2 = "SELECT identifier, amount_paid FROM mechanic_orders WHERE fulfilled = 0 AND id = ?"
L6_2 = {}
L7_2 = A1_2
L6_2[1] = L7_2
L4_2 = L4_2(L5_2, L6_2)
if not L4_2 then
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.Notify
L6_2 = A0_2
L7_2 = "NO_UNFULFILLED_ORDER"
L8_2 = "error"
L5_2(L6_2, L7_2, L8_2)
L5_2 = false
return L5_2
end
L5_2 = L4_2.amount_paid
if L5_2 < 0 then
L5_2 = false
return L5_2
end
L5_2 = removeFromSocietyFund
L6_2 = A0_2
L7_2 = L2_2
L8_2 = L4_2.amount_paid
L5_2 = L5_2(L6_2, L7_2, L8_2)
if not L5_2 then
L6_2 = false
return L6_2
end
L6_2 = Framework
L6_2 = L6_2.Server
L6_2 = L6_2.PlayerAddMoneyOffline
L7_2 = L4_2.identifier
L8_2 = L4_2.amount_paid
L6_2(L7_2, L8_2)
L6_2 = MySQL
L6_2 = L6_2.update
L6_2 = L6_2.await
L7_2 = "UPDATE mechanic_orders SET fulfilled = 1 WHERE mechanic = ? AND id = ?"
L8_2 = {}
L9_2 = L2_2
L10_2 = A1_2
L8_2[1] = L9_2
L8_2[2] = L10_2
L6_2(L7_2, L8_2)
L6_2 = sendWebhook
L7_2 = A0_2
L8_2 = Webhooks
L8_2 = L8_2.Orders
L9_2 = "Orders: Order Deleted"
L10_2 = "default"
L11_2 = {}
L12_2 = {}
L12_2.key = "Mechanic"
L12_2.value = L2_2
L13_2 = {}
L13_2.key = "Order #"
L13_2.value = A1_2
L14_2 = {}
L14_2.key = "Amount Refunded"
L15_2 = L4_2.amount_paid
L14_2.value = L15_2
L11_2[1] = L12_2
L11_2[2] = L13_2
L11_2[3] = L14_2
L6_2(L7_2, L8_2, L9_2, L10_2, L11_2)
L6_2 = true
return L6_2
end
L1_1(L2_1, L3_1)