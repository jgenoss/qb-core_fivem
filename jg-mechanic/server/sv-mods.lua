local L0_1, L1_1, L2_1, L3_1, L4_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L1_2 = pairs
L2_2 = Config
L2_2 = L2_2.Mods
L2_2 = L2_2.Cosmetics
L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
L7_2 = L6_2.name
if L7_2 == A0_2 then
L7_2 = L6_2.ignorePriceMult
if L7_2 then
L7_2 = true
return L7_2
end
end
end
L1_2 = false
return L1_2
end
function L1_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2
L3_2 = 0
L4_2 = A0_2.mods
L5_2 = Config
L5_2 = L5_2.ModsPricesAsPercentageOfVehicleValue
if L5_2 then
L5_2 = pairs
L6_2 = L4_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2 in L5_2, L6_2, L7_2, L8_2 do
L10_2 = L4_2[L9_2]
L11_2 = round
L12_2 = L4_2[L9_2]
L12_2 = L12_2.percentVehVal
if not L12_2 then
L12_2 = 0.01
end
L12_2 = A1_2 * L12_2
L13_2 = 0
L11_2 = L11_2(L12_2, L13_2)
L10_2.price = L11_2
end
end
L5_2 = pairs
L6_2 = A2_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
L11_2 = pairs
L12_2 = L10_2
L11_2, L12_2, L13_2, L14_2 = L11_2(L12_2)
for L15_2, L16_2 in L11_2, L12_2, L13_2, L14_2 do
L17_2 = L16_2.modIndex
L18_2 = L0_1
L19_2 = L15_2
L18_2 = L18_2(L19_2)
L19_2 = L4_2[L9_2]
if L19_2 then
L19_2 = L4_2[L9_2]
L19_2 = L19_2.price
L20_2 = L4_2[L9_2]
L20_2 = L20_2.priceMult
if not L18_2 or not L19_2 then
L21_2 = round
L22_2 = type
L23_2 = L17_2
L22_2 = L22_2(L23_2)
if "number" == L22_2 and L17_2 > 0 then
L22_2 = L20_2 or L22_2
if not L20_2 then
L22_2 = 0
end
L22_2 = L17_2 * L22_2
L22_2 = 1 + L22_2
if L22_2 then
goto lbl_67
end
end
L22_2 = 1
::lbl_67::
L22_2 = L19_2 * L22_2
L23_2 = 0
L21_2 = L21_2(L22_2, L23_2)
L19_2 = L21_2
end
if -1 == L17_2 then
L19_2 = 0
end
L3_2 = L3_2 + L19_2
end
end
end
return L3_2
end
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:purchase-mods"
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L5_2 = Config
L5_2 = L5_2.MechanicLocations
L5_2 = L5_2[A1_2]
if not L5_2 then
L6_2 = false
return L6_2
end
L6_2 = isEmployee
L7_2 = A0_2
L8_2 = A1_2
L9_2 = {}
L10_2 = "mechanic"
L11_2 = "manager"
L9_2[1] = L10_2
L9_2[2] = L11_2
L10_2 = false
L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2)
if "noPayment" ~= A4_2 and "mechanic" ~= A4_2 and "bank" ~= A4_2 and "cash" ~= A4_2 then
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.Notify
L8_2 = A0_2
L9_2 = "INVALID_PAYMENT_METHOD"
L10_2 = "error"
L7_2(L8_2, L9_2, L10_2)
L7_2 = false
return L7_2
end
if "noPayment" == A4_2 then
L7_2 = L5_2.type
if "owned" == L7_2 and L6_2 then
L7_2 = Config
L7_2 = L7_2.DisableNoPaymentOptionForEmployees
if not L7_2 then
goto lbl_55
end
end
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.Notify
L8_2 = A0_2
L9_2 = "INVALID_PAYMENT_METHOD"
L10_2 = "error"
L7_2(L8_2, L9_2, L10_2)
L7_2 = false
return L7_2
end
::lbl_55::
if "noPayment" == A4_2 then
L7_2 = 0
return L7_2
end
L7_2 = L1_1
L8_2 = L5_2
L9_2 = A2_2
L10_2 = A3_2
L7_2 = L7_2(L8_2, L9_2, L10_2)
if "mechanic" == A4_2 and L6_2 then
L8_2 = Config
L8_2 = L8_2.MechanicEmployeesCanSelfServiceMods
if L8_2 then
L8_2 = removeFromSocietyFund
L9_2 = A0_2
L10_2 = A1_2
L11_2 = L7_2
L8_2 = L8_2(L9_2, L10_2, L11_2)
if not L8_2 then
L9_2 = false
return L9_2
end
end
elseif "bank" == A4_2 or "cash" == A4_2 then
L8_2 = Framework
L8_2 = L8_2.Server
L8_2 = L8_2.GetPlayerBalance
L9_2 = A0_2
L10_2 = A4_2
L8_2 = L8_2(L9_2, L10_2)
if L7_2 > L8_2 then
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.Notify
L10_2 = A0_2
L11_2 = Locale
L11_2 = L11_2.notEnoughMoney
L12_2 = "error"
L9_2(L10_2, L11_2, L12_2)
L9_2 = false
return L9_2
end
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.PlayerRemoveMoney
L10_2 = A0_2
L11_2 = L7_2
L12_2 = A4_2
L9_2(L10_2, L11_2, L12_2)
L9_2 = L5_2.type
if "owned" == L9_2 then
L9_2 = addToSocietyFund
L10_2 = A0_2
L11_2 = A1_2
L12_2 = L7_2
L9_2(L10_2, L11_2, L12_2)
end
else
L8_2 = false
return L8_2
end
return L7_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:open-mods-menu"
function L4_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
L2_2 = Config
L2_2 = L2_2.ChangePlateDuringPreview
if L2_2 then
L2_2 = NetworkGetEntityFromNetworkId
L3_2 = A1_2
L2_2 = L2_2(L3_2)
L3_2 = SetVehicleNumberPlateText
L4_2 = L2_2
L5_2 = Config
L5_2 = L5_2.ChangePlateDuringPreview
L3_2(L4_2, L5_2)
end
L2_2 = true
return L2_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:self-service-mods-applied"
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
local L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2
L7_2 = Config
L7_2 = L7_2.ChangePlateDuringPreview
if L7_2 then
L7_2 = NetworkGetEntityFromNetworkId
L8_2 = A2_2
L7_2 = L7_2(L8_2)
L8_2 = SetVehicleNumberPlateText
L9_2 = L7_2
L10_2 = A3_2
L8_2(L9_2, L10_2)
end
L7_2 = Webhooks
L7_2 = L7_2.SelfService
if not L7_2 then
L7_2 = true
return L7_2
end
L7_2 = {}
function L8_2(A0_3, A1_3)
local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
L2_3 = {}
L3_3 = pairs
L4_3 = A0_3
L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
L9_3 = #L2_3
L9_3 = L9_3 + 1
L2_3[L9_3] = L7_3
end
L3_3 = table
L3_3 = L3_3.concat
L4_3 = L2_3
L5_3 = A1_3
return L3_3(L4_3, L5_3)
end
L9_2 = pairs
L10_2 = A4_2
L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
L15_2 = #L7_2
L15_2 = L15_2 + 1
L16_2 = {}
L17_2 = Locale
L17_2 = L17_2[L13_2]
if not L17_2 then
L17_2 = L13_2
end
L16_2.key = L17_2
L17_2 = L8_2
L18_2 = L14_2
L19_2 = ", "
L17_2 = L17_2(L18_2, L19_2)
L16_2.value = L17_2
L7_2[L15_2] = L16_2
end
L9_2 = sendWebhook
L10_2 = A0_2
L11_2 = Webhooks
L11_2 = L11_2.SelfService
L12_2 = "Self-Service Tuning Completed"
L13_2 = "success"
L14_2 = tableConcat
L15_2 = {}
L16_2 = {}
L16_2.key = "Mechanic"
L16_2.value = A1_2
L17_2 = {}
L17_2.key = "Vehicle"
L17_2.value = A3_2
L18_2 = {}
L18_2.key = "Paid"
L18_2.value = A5_2
L19_2 = {}
L19_2.key = "Payment Method"
L19_2.value = A6_2
L15_2[1] = L16_2
L15_2[2] = L17_2
L15_2[3] = L18_2
L15_2[4] = L19_2
L16_2 = L7_2
L14_2, L15_2, L16_2, L17_2, L18_2, L19_2 = L14_2(L15_2, L16_2)
L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
L9_2 = true
return L9_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:place-order"
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
local L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2
L7_2 = Config
L7_2 = L7_2.MechanicLocations
L7_2 = L7_2[A1_2]
if not L7_2 then
L8_2 = false
return L8_2
end
L8_2 = Framework
L8_2 = L8_2.Server
L8_2 = L8_2.GetPlayerIdentifier
L9_2 = A0_2
L8_2 = L8_2(L9_2)
L9_2 = MySQL
L9_2 = L9_2.insert
L9_2 = L9_2.await
L10_2 = "INSERT INTO mechanic_orders (identifier, mechanic, plate, cart, props_to_apply, amount_paid) VALUES (?, ?, ?, ?, ?, ?)"
L11_2 = {}
L12_2 = L8_2
L13_2 = A1_2
L14_2 = A2_2
L15_2 = json
L15_2 = L15_2.encode
L16_2 = A3_2
L15_2 = L15_2(L16_2)
L16_2 = json
L16_2 = L16_2.encode
L17_2 = A5_2
L16_2 = L16_2(L17_2)
L17_2 = A4_2
L11_2[1] = L12_2
L11_2[2] = L13_2
L11_2[3] = L14_2
L11_2[4] = L15_2
L11_2[5] = L16_2
L11_2[6] = L17_2
L9_2 = L9_2(L10_2, L11_2)
L10_2 = TriggerEvent
L11_2 = "jg-mechanic:server:order-placed-config"
L12_2 = L9_2
L13_2 = A1_2
L14_2 = A2_2
L15_2 = A3_2
L16_2 = A4_2
L17_2 = A5_2
L18_2 = A6_2
L10_2(L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
L10_2 = sendWebhook
L11_2 = A0_2
L12_2 = Webhooks
L12_2 = L12_2.Orders
L13_2 = "Orders: Order Placed"
L14_2 = "success"
L15_2 = {}
L16_2 = {}
L16_2.key = "Mechanic"
L16_2.value = A1_2
L17_2 = {}
L17_2.key = "Order #"
L17_2.value = L9_2
L18_2 = {}
L18_2.key = "Vehicle"
L18_2.value = A2_2
L19_2 = {}
L19_2.key = "Paid"
L19_2.value = A4_2
L20_2 = {}
L20_2.key = "Payment Method"
L20_2.value = A6_2
L15_2[1] = L16_2
L15_2[2] = L17_2
L15_2[3] = L18_2
L15_2[4] = L19_2
L15_2[5] = L20_2
L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
L10_2 = true
return L10_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:self-service-repair-vehicle"
function L4_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L4_2 = Config
L4_2 = L4_2.MechanicLocations
L4_2 = L4_2[A1_2]
if not L4_2 then
L5_2 = false
return L5_2
end
L5_2 = L4_2.mods
L5_2 = L5_2.repair
L5_2 = L5_2.enabled
L6_2 = L4_2.mods
L6_2 = L6_2.repair
L6_2 = L6_2.price
L7_2 = L4_2.mods
L7_2 = L7_2.repair
L7_2 = L7_2.percentVehVal
if not L5_2 then
L8_2 = false
return L8_2
end
L8_2 = Config
L8_2 = L8_2.ModsPricesAsPercentageOfVehicleValue
if L8_2 then
L8_2 = round
L9_2 = L7_2 or L9_2
if not L7_2 then
L9_2 = 0.01
end
L9_2 = A2_2 * L9_2
L10_2 = 0
L8_2 = L8_2(L9_2, L10_2)
L6_2 = L8_2
end
if "bank" ~= A3_2 and "cash" ~= A3_2 then
L8_2 = Framework
L8_2 = L8_2.Server
L8_2 = L8_2.Notify
L9_2 = A0_2
L10_2 = "INVALID_PAYMENT_METHOD"
L11_2 = "error"
L8_2(L9_2, L10_2, L11_2)
L8_2 = false
return L8_2
end
L8_2 = Framework
L8_2 = L8_2.Server
L8_2 = L8_2.GetPlayerBalance
L9_2 = A0_2
L10_2 = A3_2
L8_2 = L8_2(L9_2, L10_2)
if L6_2 > L8_2 then
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.Notify
L10_2 = A0_2
L11_2 = Locale
L11_2 = L11_2.notEnoughMoney
L12_2 = "error"
L9_2(L10_2, L11_2, L12_2)
L9_2 = false
return L9_2
end
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.PlayerRemoveMoney
L10_2 = A0_2
L11_2 = L6_2
L12_2 = A3_2
L9_2(L10_2, L11_2, L12_2)
L9_2 = L4_2.type
if "owned" == L9_2 then
L9_2 = addToSocietyFund
L10_2 = A0_2
L11_2 = A1_2
L12_2 = L6_2
L9_2(L10_2, L11_2, L12_2)
end
L9_2 = true
return L9_2
end
L2_1(L3_1, L4_1)
L2_1 = lib
L2_1 = L2_1.callback
L2_1 = L2_1.register
L3_1 = "jg-mechanic:server:count-currently-on-duty"
function L4_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L2_2 = GlobalState
if L2_2 then
L2_2 = L2_2.mechanicsOnDuty
end
if not L2_2 then
L2_2 = 0
return L2_2
end
L2_2 = 0
L3_2 = pairs
L4_2 = GlobalState
L4_2 = L4_2.mechanicsOnDuty
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
L9_2 = DoesEntityExist
L10_2 = GetPlayerPed
L11_2 = L7_2
L10_2, L11_2 = L10_2(L11_2)
L9_2 = L9_2(L10_2, L11_2)
if L9_2 and L8_2 == A1_2 then
L2_2 = L2_2 + 1
end
end
return L2_2
end
L2_1(L3_1, L4_1)