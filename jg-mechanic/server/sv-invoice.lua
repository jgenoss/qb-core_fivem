local L0_1, L1_1, L2_1, L3_1, L4_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L1_2 = Player
L2_2 = A0_2
L1_2 = L1_2(L2_2)
L1_2 = L1_2.state
L2_2 = L1_2.mechanicId
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
return L2_2
end
function L1_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L4_2 = MySQL
L4_2 = L4_2.insert
L4_2 = L4_2.await
L5_2 = "INSERT INTO mechanic_invoices (identifier, mechanic, total, data) VALUES(?, ?, ?, ?)"
L6_2 = {}
L7_2 = A0_2
L8_2 = A1_2
L9_2 = A2_2
L10_2 = json
L10_2 = L10_2.encode
L11_2 = A3_2
L10_2, L11_2 = L10_2(L11_2)
L6_2[1] = L7_2
L6_2[2] = L8_2
L6_2[3] = L9_2
L6_2[4] = L10_2
L6_2[5] = L11_2
return L4_2(L5_2, L6_2)
end
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:get-unpaid-invoices"
function L4_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L1_2 = L0_1
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if not L1_2 then
L2_2 = false
return L2_2
end
L2_2 = MySQL
L2_2 = L2_2.query
L2_2 = L2_2.await
L3_2 = "SELECT * FROM mechanic_invoices WHERE mechanic = ? AND paid = 0 ORDER BY date DESC"
L4_2 = {}
L5_2 = L1_2
L4_2[1] = L5_2
L2_2 = L2_2(L3_2, L4_2)
L3_2 = ipairs
L4_2 = L2_2
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
L9_2 = L2_2[L7_2]
L10_2 = Framework
L10_2 = L10_2.Server
L10_2 = L10_2.GetPlayerInfoFromIdentifier
L11_2 = L8_2.identifier
L10_2 = L10_2(L11_2)
if L10_2 then
L10_2 = L10_2.name
end
if not L10_2 then
L10_2 = "-"
end
L9_2.recipient = L10_2
end
return L2_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:send-invoice"
function L4_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2
L4_2 = L0_1
L5_2 = A0_2
L4_2 = L4_2(L5_2)
if not L4_2 then
L5_2 = false
return L5_2
end
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.GetPlayerIdentifier
L6_2 = A1_2
L5_2 = L5_2(L6_2)
if not L5_2 then
L6_2 = false
return L6_2
end
L6_2 = Player
L7_2 = A1_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
if L6_2 then
L7_2 = L6_2.isBusy
if L7_2 and A0_2 ~= A1_2 then
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.Notify
L8_2 = A0_2
L9_2 = Locale
L9_2 = L9_2.playerIsBusy
L10_2 = "error"
L7_2(L8_2, L9_2, L10_2)
L7_2 = false
return L7_2
end
end
L7_2 = L1_1
L8_2 = L5_2
L9_2 = L4_2
L10_2 = A3_2
L11_2 = A2_2
L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2)
if not L7_2 then
L8_2 = false
return L8_2
end
L8_2 = {}
L9_2 = ipairs
L10_2 = A2_2
L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
L15_2 = #L8_2
L15_2 = L15_2 + 1
L16_2 = "%s (%d)"
L17_2 = L16_2
L16_2 = L16_2.format
L18_2 = L14_2.title
L19_2 = L14_2.amount
L16_2 = L16_2(L17_2, L18_2, L19_2)
L8_2[L15_2] = L16_2
end
L9_2 = TriggerClientEvent
L10_2 = "jg-mechanic:client:show-invoice-to-player"
L11_2 = A1_2
L12_2 = A0_2
L13_2 = L7_2
L14_2 = A2_2
L15_2 = A3_2
L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
L9_2 = sendWebhook
L10_2 = A0_2
L11_2 = Webhooks
L11_2 = L11_2.Invoices
L12_2 = "Invoices: Invoice Sent"
L13_2 = "success"
L14_2 = {}
L15_2 = {}
L15_2.key = "Mechanic"
L15_2.value = L4_2
L16_2 = {}
L16_2.key = "Invoice #"
L16_2.value = L7_2
L17_2 = {}
L17_2.key = "Recipient"
L18_2 = Framework
L18_2 = L18_2.Server
L18_2 = L18_2.GetPlayerInfo
L19_2 = A1_2
L18_2 = L18_2(L19_2)
if L18_2 then
L18_2 = L18_2.name
end
if not L18_2 then
L18_2 = A1_2
end
L17_2.value = L18_2
L18_2 = {}
L18_2.key = "Total"
L18_2.value = A3_2
L19_2 = {}
L19_2.key = "Breakdown"
L20_2 = table
L20_2 = L20_2.concat
L21_2 = L8_2
L22_2 = ", "
L20_2 = L20_2(L21_2, L22_2)
L19_2.value = L20_2
L14_2[1] = L15_2
L14_2[2] = L16_2
L14_2[3] = L17_2
L14_2[4] = L18_2
L14_2[5] = L19_2
L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
L9_2 = true
return L9_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:resend-invoice"
function L4_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2
L3_2 = L0_1
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.GetPlayerIdentifier
L5_2 = A1_2
L4_2 = L4_2(L5_2)
if not L4_2 then
L5_2 = false
return L5_2
end
L5_2 = Player
L6_2 = A1_2
L5_2 = L5_2(L6_2)
L5_2 = L5_2.state
if L5_2 then
L6_2 = L5_2.isBusy
if L6_2 then
L6_2 = Framework
L6_2 = L6_2.Server
L6_2 = L6_2.Notify
L7_2 = A0_2
L8_2 = Locale
L8_2 = L8_2.playerIsBusy
L9_2 = "error"
L6_2(L7_2, L8_2, L9_2)
L6_2 = false
return L6_2
end
end
L6_2 = MySQL
L6_2 = L6_2.single
L6_2 = L6_2.await
L7_2 = "SELECT * FROM mechanic_invoices WHERE id = ? AND mechanic = ?"
L8_2 = {}
L9_2 = A2_2
L10_2 = L3_2
L8_2[1] = L9_2
L8_2[2] = L10_2
L6_2 = L6_2(L7_2, L8_2)
if not L6_2 then
L7_2 = false
return L7_2
end
L7_2 = MySQL
L7_2 = L7_2.update
L7_2 = L7_2.await
L8_2 = "UPDATE mechanic_invoices SET identifier = ? WHERE id = ? AND mechanic = ?"
L9_2 = {}
L10_2 = L4_2
L11_2 = A2_2
L12_2 = L3_2
L9_2[1] = L10_2
L9_2[2] = L11_2
L9_2[3] = L12_2
L7_2(L8_2, L9_2)
L7_2 = json
L7_2 = L7_2.decode
L8_2 = L6_2.data
L7_2 = L7_2(L8_2)
L8_2 = TriggerClientEvent
L9_2 = "jg-mechanic:client:show-invoice-to-player"
L10_2 = A1_2
L11_2 = A0_2
L12_2 = A2_2
L13_2 = L7_2
L14_2 = L6_2.total
L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
L8_2 = {}
L9_2 = ipairs
L10_2 = L7_2
L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
L15_2 = #L8_2
L15_2 = L15_2 + 1
L16_2 = "%s (%d)"
L17_2 = L16_2
L16_2 = L16_2.format
L18_2 = L14_2.title
L19_2 = L14_2.amount
L16_2 = L16_2(L17_2, L18_2, L19_2)
L8_2[L15_2] = L16_2
end
L9_2 = sendWebhook
L10_2 = A0_2
L11_2 = Webhooks
L11_2 = L11_2.Invoices
L12_2 = "Invoices: Invoice Re-sent"
L13_2 = "success"
L14_2 = {}
L15_2 = {}
L15_2.key = "Mechanic"
L15_2.value = L3_2
L16_2 = {}
L16_2.key = "Invoice #"
L16_2.value = A2_2
L17_2 = {}
L17_2.key = "Recipient"
L18_2 = Framework
L18_2 = L18_2.Server
L18_2 = L18_2.GetPlayerInfo
L19_2 = A1_2
L18_2 = L18_2(L19_2)
if L18_2 then
L18_2 = L18_2.name
end
if not L18_2 then
L18_2 = A1_2
end
L17_2.value = L18_2
L18_2 = {}
L18_2.key = "Total"
L19_2 = L6_2.total
L18_2.value = L19_2
L19_2 = {}
L19_2.key = "Breakdown"
L20_2 = table
L20_2 = L20_2.concat
L21_2 = L8_2
L22_2 = ", "
L20_2 = L20_2(L21_2, L22_2)
L19_2.value = L20_2
L14_2[1] = L15_2
L14_2[2] = L16_2
L14_2[3] = L17_2
L14_2[4] = L18_2
L14_2[5] = L19_2
L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
L9_2 = true
return L9_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:save-invoice"
function L4_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L3_2 = L0_1
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if not L3_2 then
L4_2 = false
return L4_2
end
L4_2 = L1_1
L5_2 = nil
L6_2 = L3_2
L7_2 = A2_2
L8_2 = A1_2
return L4_2(L5_2, L6_2, L7_2, L8_2)
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:delete-invoice"
function L4_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
L2_2 = L0_1
L3_2 = A0_2
L2_2 = L2_2(L3_2)
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = MySQL
L3_2 = L3_2.update
L3_2 = L3_2.await
L4_2 = "DELETE FROM mechanic_invoices WHERE id = ? AND mechanic = ?"
L5_2 = {}
L6_2 = A1_2
L7_2 = L2_2
L5_2[1] = L6_2
L5_2[2] = L7_2
L3_2(L4_2, L5_2)
L3_2 = sendWebhook
L4_2 = A0_2
L5_2 = Webhooks
L5_2 = L5_2.Invoices
L6_2 = "Invoices: Invoice Deleted"
L7_2 = "danger"
L8_2 = {}
L9_2 = {}
L9_2.key = "Mechanic"
L9_2.value = L2_2
L10_2 = {}
L10_2.key = "Invoice #"
L10_2.value = A1_2
L8_2[1] = L9_2
L8_2[2] = L10_2
L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
L3_2 = true
return L3_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:pay-invoice"
function L4_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.GetPlayerIdentifier
L5_2 = A0_2
L4_2 = L4_2(L5_2)
if not L4_2 then
L5_2 = debugPrint
L6_2 = "Failed to get identifier for src: "
L7_2 = A0_2
L6_2 = L6_2 .. L7_2
L7_2 = "warning"
L5_2(L6_2, L7_2)
L5_2 = false
return L5_2
end
L5_2 = MySQL
L5_2 = L5_2.single
L5_2 = L5_2.await
L6_2 = "SELECT * FROM mechanic_invoices WHERE id = ? AND identifier = ?"
L7_2 = {}
L8_2 = A1_2
L9_2 = L4_2
L7_2[1] = L8_2
L7_2[2] = L9_2
L5_2 = L5_2(L6_2, L7_2)
if L5_2 then
L6_2 = L5_2.total
if not (L6_2 <= 0) then
goto lbl_43
end
end
L6_2 = debugPrint
L7_2 = "Invalid or unpaid invoice."
L8_2 = "warning"
L9_2 = "ID: "
L10_2 = A1_2
L9_2 = L9_2 .. L10_2
L10_2 = "Identifier: "
L11_2 = L4_2
L10_2 = L10_2 .. L11_2
L6_2(L7_2, L8_2, L9_2, L10_2)
L6_2 = false
do return L6_2 end
::lbl_43::
if "bank" ~= A3_2 and "cash" ~= A3_2 then
L6_2 = debugPrint
L7_2 = "Invalid payment method:"
L8_2 = A3_2
L7_2 = L7_2 .. L8_2
L8_2 = "warning"
L6_2(L7_2, L8_2)
L6_2 = Framework
L6_2 = L6_2.Server
L6_2 = L6_2.Notify
L7_2 = A0_2
L8_2 = "INVALID_PAYMENT_METHOD"
L9_2 = "error"
L6_2(L7_2, L8_2, L9_2)
L6_2 = false
return L6_2
end
L6_2 = Framework
L6_2 = L6_2.Server
L6_2 = L6_2.GetPlayerBalance
L7_2 = A0_2
L8_2 = A3_2
L6_2 = L6_2(L7_2, L8_2)
L7_2 = debugPrint
L8_2 = "Player balance for "
L9_2 = A3_2
L10_2 = " is "
L11_2 = L6_2
L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2
L9_2 = "debug"
L7_2(L8_2, L9_2)
L7_2 = L5_2.total
if L6_2 < L7_2 then
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.Notify
L8_2 = A0_2
L9_2 = Locale
L9_2 = L9_2.notEnoughMoney
L10_2 = "error"
L7_2(L8_2, L9_2, L10_2)
L7_2 = false
return L7_2
end
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.PlayerRemoveMoney
L8_2 = A0_2
L9_2 = L5_2.total
L10_2 = A3_2
L7_2(L8_2, L9_2, L10_2)
L7_2 = debugPrint
L8_2 = "Deducted "
L9_2 = L5_2.total
L10_2 = " from player "
L11_2 = A0_2
L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2
L9_2 = "debug"
L7_2(L8_2, L9_2)
L7_2 = Config
L7_2 = L7_2.MechanicLocations
L8_2 = L5_2.mechanic
L7_2 = L7_2[L8_2]
if not L7_2 then
L7_2 = {}
end
L8_2 = L7_2
if L8_2 then
L8_2 = L8_2.commission
end
if not L8_2 then
L8_2 = 0
end
L9_2 = math
L9_2 = L9_2.floor
L10_2 = L5_2.total
L11_2 = L8_2 / 100
L10_2 = L10_2 * L11_2
L9_2 = L9_2(L10_2)
if not L9_2 then
L9_2 = 0
end
L10_2 = debugPrint
L11_2 = "Commission rate for "
L12_2 = L5_2.mechanic
L13_2 = " is "
L14_2 = L8_2
L15_2 = "%"
L11_2 = L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2
L12_2 = "debug"
L10_2(L11_2, L12_2)
L10_2 = debugPrint
L11_2 = "Calculated commission: "
L12_2 = L9_2
L11_2 = L11_2 .. L12_2
L12_2 = "debug"
L10_2(L11_2, L12_2)
L10_2 = L5_2.total
if L9_2 > 0 and A2_2 and A2_2 ~= A0_2 then
L11_2 = L5_2.total
L10_2 = L11_2 - L9_2
L11_2 = Framework
L11_2 = L11_2.Server
L11_2 = L11_2.PlayerAddMoney
L12_2 = A2_2
L13_2 = L9_2
L14_2 = "bank"
L11_2(L12_2, L13_2, L14_2)
L11_2 = debugPrint
L12_2 = "Paid commission of "
L13_2 = L9_2
L14_2 = " to sender "
L15_2 = A2_2
L12_2 = L12_2 .. L13_2 .. L14_2 .. L15_2
L11_2(L12_2)
end
L11_2 = addToSocietyFund
L12_2 = A0_2
L13_2 = L5_2.mechanic
L14_2 = L10_2
L11_2(L12_2, L13_2, L14_2)
L11_2 = debugPrint
L12_2 = "Society fund contribution for "
L13_2 = L5_2.mechanic
L14_2 = " is "
L15_2 = L10_2
L12_2 = L12_2 .. L13_2 .. L14_2 .. L15_2
L13_2 = "debug"
L11_2(L12_2, L13_2)
L11_2 = MySQL
L11_2 = L11_2.update
L11_2 = L11_2.await
L12_2 = "UPDATE mechanic_invoices SET paid = 1 WHERE id = ? AND identifier = ?"
L13_2 = {}
L14_2 = A1_2
L15_2 = L4_2
L13_2[1] = L14_2
L13_2[2] = L15_2
L11_2(L12_2, L13_2)
L11_2 = debugPrint
L12_2 = "Marked invoice as paid. ID: "
L13_2 = A1_2
L12_2 = L12_2 .. L13_2
L13_2 = "debug"
L11_2(L12_2, L13_2)
L11_2 = Framework
L11_2 = L11_2.Server
L11_2 = L11_2.Notify
L12_2 = A2_2
L13_2 = Locale
L13_2 = L13_2.invoicePaid
L14_2 = "success"
L11_2(L12_2, L13_2, L14_2)
L11_2 = sendWebhook
L12_2 = A0_2
L13_2 = Webhooks
L13_2 = L13_2.Invoices
L14_2 = "Invoices: Invoice Paid"
L15_2 = "success"
L16_2 = {}
L17_2 = {}
L17_2.key = "Mechanic"
L18_2 = L5_2.mechanic
L17_2.value = L18_2
L18_2 = {}
L18_2.key = "Invoice #"
L18_2.value = A1_2
L19_2 = {}
L19_2.key = "Total"
L20_2 = L5_2.total
L19_2.value = L20_2
L20_2 = {}
L20_2.key = "Commission"
L20_2.value = L9_2
L21_2 = {}
L21_2.key = "Payment Method"
L21_2.value = A3_2
L16_2[1] = L17_2
L16_2[2] = L18_2
L16_2[3] = L19_2
L16_2[4] = L20_2
L16_2[5] = L21_2
L11_2(L12_2, L13_2, L14_2, L15_2, L16_2)
L11_2 = true
return L11_2
end
L2_1(L3_1, L4_1)