local L0_1, L1_1, L2_1
L0_1 = exports
L1_1 = "doesVehicleNeedServicing"
function L2_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
if not A0_2 then
L1_2 = false
return L1_2
end
L1_2 = MySQL
L1_2 = L1_2.scalar
L1_2 = L1_2.await
L2_2 = "SELECT "
L3_2 = Framework
L3_2 = L3_2.VehProps
L4_2 = " FROM "
L5_2 = Framework
L5_2 = L5_2.VehiclesTable
L6_2 = " WHERE plate = ?"
L2_2 = L2_2 .. L3_2 .. L4_2 .. L5_2 .. L6_2
L3_2 = {}
L4_2 = A0_2
L3_2[1] = L4_2
L1_2 = L1_2(L2_2, L3_2)
if not L1_2 then
L2_2 = false
return L2_2
end
L2_2 = json
L2_2 = L2_2.decode
L3_2 = L1_2 or L3_2
if not L1_2 then
L3_2 = "{}"
end
L2_2 = L2_2(L3_2)
L1_2 = L2_2
L2_2 = L1_2.servicingData
if L2_2 then
L3_2 = type
L4_2 = L2_2
L3_2 = L3_2(L4_2)
if "table" == L3_2 then
goto lbl_42
end
end
L3_2 = false
do return L3_2 end
::lbl_42::
L3_2 = pairs
L4_2 = L2_2
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
L9_2 = Config
L9_2 = L9_2.ServiceRequiredThreshold
if L8_2 <= L9_2 then
L9_2 = true
return L9_2
end
end
L3_2 = false
return L3_2
end
L0_1(L1_1, L2_1)
L0_1 = exports
L1_1 = "getVehicleServiceHistory"
function L2_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
if not A0_2 then
L1_2 = false
return L1_2
end
L1_2 = MySQL
L1_2 = L1_2.query
L1_2 = L1_2.await
L2_2 = "SELECT msh.*, COALESCE(CASE WHEN md.label IS NOT NULL AND TRIM(md.label) != '' THEN md.label ELSE msh.mechanic END, msh.mechanic) AS mechanic_label FROM mechanic_servicing_history msh LEFT JOIN mechanic_data md ON msh.mechanic = md.name WHERE msh.plate = ? ORDER BY date DESC"
L3_2 = {}
L4_2 = A0_2
L3_2[1] = L4_2
return L1_2(L2_2, L3_2)
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:pay-for-service"
function L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
L3_2 = HasActiveTabletConnection
L4_2 = A0_2
L5_2 = A1_2
L3_2 = L3_2(L4_2, L5_2)
if not L3_2 then
L3_2 = false
return L3_2
end
L3_2 = Player
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L3_2 = L3_2.state
L4_2 = Config
L4_2 = L4_2.Servicing
L4_2 = L4_2[A2_2]
if not L4_2 then
L5_2 = false
return L5_2
end
L5_2 = L4_2.itemName
L6_2 = L4_2.itemQuantity
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
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.RemoveItem
L10_2 = A0_2
L11_2 = L5_2
L12_2 = L6_2 or L12_2
if not L6_2 then
L12_2 = 1
end
L9_2 = L9_2(L10_2, L11_2, L12_2)
if not L9_2 then
L10_2 = false
return L10_2
end
L10_2 = Framework
L10_2 = L10_2.Server
L10_2 = L10_2.GetPlayerIdentifier
L11_2 = A0_2
L10_2 = L10_2(L11_2)
L11_2 = exports
L11_2 = L11_2["jg-vehiclemileage"]
L12_2 = L11_2
L11_2 = L11_2.GetMileage
L13_2 = A1_2
L11_2 = L11_2(L12_2, L13_2)
L12_2 = MySQL
L12_2 = L12_2.insert
L12_2 = L12_2.await
L13_2 = "INSERT INTO mechanic_servicing_history (identifier, mechanic, plate, mileage_km, serviced_part) VALUES (?, ?, ?, ?, ?)"
L14_2 = {}
L15_2 = L10_2
L16_2 = L7_2
L17_2 = A1_2
L18_2 = L11_2
L19_2 = A2_2
L14_2[1] = L15_2
L14_2[2] = L16_2
L14_2[3] = L17_2
L14_2[4] = L18_2
L14_2[5] = L19_2
L12_2(L13_2, L14_2)
L12_2 = sendWebhook
L13_2 = A0_2
L14_2 = Webhooks
L14_2 = L14_2.Servicing
L15_2 = "Servicing: Vehicle Serviced"
L16_2 = "success"
L17_2 = {}
L18_2 = {}
L18_2.key = "Mechanic"
L18_2.value = L7_2
L19_2 = {}
L19_2.key = "Vehicle Plate"
L19_2.value = A1_2
L20_2 = {}
L20_2.key = "Part Serviced"
L21_2 = Locale
L21_2 = L21_2[A2_2]
if not L21_2 then
L21_2 = A2_2
end
L20_2.value = L21_2
L17_2[1] = L18_2
L17_2[2] = L19_2
L17_2[3] = L20_2
L12_2(L13_2, L14_2, L15_2, L16_2, L17_2)
L12_2 = true
return L12_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:get-servicing-history"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
L2_2 = Player
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
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
L5_2 = exports
L5_2 = L5_2["jg-mechanic"]
L6_2 = L5_2
L5_2 = L5_2.getVehicleServiceHistory
L7_2 = A1_2
L5_2 = L5_2(L6_2, L7_2)
L6_2 = exports
L6_2 = L6_2["jg-vehiclemileage"]
L7_2 = L6_2
L6_2 = L6_2.GetMileage
L8_2 = A1_2
L6_2, L7_2 = L6_2(L7_2, L8_2)
L8_2 = {}
L8_2.servicingHistory = L5_2
L8_2.mileageUnit = L7_2
return L8_2
end
L0_1(L1_1, L2_1)