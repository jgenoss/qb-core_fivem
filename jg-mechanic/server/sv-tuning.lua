local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:pay-for-tune"
function L2_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2
L5_2 = HasActiveTabletConnection
L6_2 = A0_2
L7_2 = A4_2
L5_2 = L5_2(L6_2, L7_2)
if not L5_2 then
L5_2 = false
return L5_2
end
L5_2 = Player
L6_2 = A0_2
L5_2 = L5_2(L6_2)
L5_2 = L5_2.state
L6_2 = Config
L6_2 = L6_2.Tuning
L6_2 = L6_2[A1_2]
if L6_2 then
L6_2 = L6_2[A2_2]
end
if not L6_2 then
L7_2 = false
return L7_2
end
L7_2 = L5_2.mechanicId
L8_2 = Config
L8_2 = L8_2.MechanicLocations
L8_2 = L8_2[L7_2]
if not L8_2 then
L9_2 = false
return L9_2
end
L9_2 = isEmployee
L10_2 = A0_2
L11_2 = L7_2
L12_2 = {}
L13_2 = "mechanic"
L14_2 = "manager"
L12_2[1] = L13_2
L12_2[2] = L14_2
L13_2 = true
L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2)
if not L9_2 then
L10_2 = Framework
L10_2 = L10_2.Server
L10_2 = L10_2.Notify
L11_2 = A0_2
L12_2 = Locale
L12_2 = L12_2.employeePermissionsError
L13_2 = "error"
L10_2(L11_2, L12_2, L13_2)
L10_2 = false
return L10_2
end
L10_2 = L8_2.tuning
L10_2 = L10_2[A1_2]
L10_2 = L10_2.requiresItem
if L10_2 then
L10_2 = L6_2.itemName
if not L10_2 then
L10_2 = false
return L10_2
end
L10_2 = Framework
L10_2 = L10_2.Server
L10_2 = L10_2.RemoveItem
L11_2 = A0_2
L12_2 = L6_2.itemName
L10_2 = L10_2(L11_2, L12_2)
if not L10_2 then
L11_2 = false
return L11_2
end
L11_2 = Config
L11_2 = L11_2.TuningGiveInstalledItemBackOnRemoval
if L11_2 then
L11_2 = Config
L11_2 = L11_2.Tuning
L11_2 = L11_2[A1_2]
if L11_2 then
L11_2 = L11_2[A3_2]
end
if L11_2 then
L12_2 = L11_2.itemName
if L12_2 then
L12_2 = Framework
L12_2 = L12_2.Server
L12_2 = L12_2.GiveItem
L13_2 = A0_2
L14_2 = L11_2.itemName
L12_2 = L12_2(L13_2, L14_2)
if not L12_2 then
L13_2 = false
return L13_2
end
end
end
end
else
L10_2 = removeFromSocietyFund
L11_2 = A0_2
L12_2 = L7_2
L13_2 = L6_2.price
L10_2 = L10_2(L11_2, L12_2, L13_2)
if not L10_2 then
L11_2 = false
return L11_2
end
end
L10_2 = sendWebhook
L11_2 = A0_2
L12_2 = Webhooks
L12_2 = L12_2.TabletTuning
L13_2 = "Tuning: Tune Applied via Tablet"
L14_2 = "success"
L15_2 = {}
L16_2 = {}
L16_2.key = "Mechanic"
L16_2.value = L7_2
L17_2 = {}
L17_2.key = "Vehicle Plate"
L17_2.value = A4_2
L18_2 = {}
L18_2.key = "Tune Category"
L19_2 = Locale
L19_2 = L19_2[A1_2]
if not L19_2 then
L19_2 = A1_2
end
L18_2.value = L19_2
L19_2 = {}
L19_2.key = "Tune Option"
L20_2 = L6_2.name
L19_2.value = L20_2
L15_2[1] = L16_2
L15_2[2] = L17_2
L15_2[3] = L18_2
L15_2[4] = L19_2
L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
L10_2 = true
return L10_2
end
L0_1(L1_1, L2_1)
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:remove-tune"
function L2_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2
L4_2 = HasActiveTabletConnection
L5_2 = A0_2
L6_2 = A3_2
L4_2 = L4_2(L5_2, L6_2)
if not L4_2 then
L4_2 = false
return L4_2
end
L4_2 = Player
L5_2 = A0_2
L4_2 = L4_2(L5_2)
L4_2 = L4_2.state
L5_2 = Config
L5_2 = L5_2.Tuning
L5_2 = L5_2[A1_2]
if L5_2 then
L5_2 = L5_2[A2_2]
end
if not L5_2 then
L6_2 = false
return L6_2
end
L6_2 = L4_2.mechanicId
L7_2 = Config
L7_2 = L7_2.MechanicLocations
L7_2 = L7_2[L6_2]
if not L7_2 then
L8_2 = false
return L8_2
end
L8_2 = isEmployee
L9_2 = A0_2
L10_2 = L6_2
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
L9_2 = Config
L9_2 = L9_2.TuningGiveInstalledItemBackOnRemoval
if not L9_2 then
L9_2 = true
return L9_2
end
L9_2 = L7_2.tuning
L9_2 = L9_2[A1_2]
L9_2 = L9_2.requiresItem
if L9_2 then
L9_2 = L5_2.itemName
if not L9_2 then
L9_2 = false
return L9_2
end
L9_2 = Framework
L9_2 = L9_2.Server
L9_2 = L9_2.GiveItem
L10_2 = A0_2
L11_2 = L5_2.itemName
L9_2 = L9_2(L10_2, L11_2)
if not L9_2 then
L10_2 = false
return L10_2
end
end
L9_2 = sendWebhook
L10_2 = A0_2
L11_2 = Webhooks
L11_2 = L11_2.TabletTuning
L12_2 = "Tuning: Tune Removed"
L13_2 = "danger"
L14_2 = {}
L15_2 = {}
L15_2.key = "Mechanic"
L15_2.value = L6_2
L16_2 = {}
L16_2.key = "Vehicle Plate"
L16_2.value = A3_2
L17_2 = {}
L17_2.key = "Tune Category"
L18_2 = Locale
L18_2 = L18_2[A1_2]
if not L18_2 then
L18_2 = A1_2
end
L17_2.value = L18_2
L18_2 = {}
L18_2.key = "Tune Option"
L19_2 = L5_2.name
L18_2.value = L19_2
L14_2[1] = L15_2
L14_2[2] = L16_2
L14_2[3] = L17_2
L14_2[4] = L18_2
L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
L9_2 = true
return L9_2
end
L0_1(L1_1, L2_1)