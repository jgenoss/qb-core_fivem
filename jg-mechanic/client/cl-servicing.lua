local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = {}
L0_1.suspension = 100
L0_1.tyres = 100
L0_1.brakePads = 100
L0_1.engineOil = 100
L0_1.clutch = 100
L0_1.airFilter = 100
L0_1.sparkPlugs = 100
L0_1.evMotor = 100
L0_1.evBattery = 100
L0_1.evCoolant = 100
L1_1 = AddStateBagChangeHandler
L2_1 = "vehicleMileage"
L3_1 = ""
function L4_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
L3_2 = Config
L3_2 = L3_2.EnableVehicleServicing
if not L3_2 then
return
end
L3_2 = GetEntityFromStateBagName
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if 0 ~= L3_2 then
L4_2 = DoesEntityExist
L5_2 = L3_2
L4_2 = L4_2(L5_2)
if L4_2 then
goto lbl_17
end
end
do return end
::lbl_17::
L4_2 = cache
L4_2 = L4_2.vehicle
if L4_2 == L3_2 then
L4_2 = cache
L4_2 = L4_2.seat
if -1 == L4_2 then
goto lbl_26
end
end
do return end
::lbl_26::
L4_2 = GetEntityArchetypeName
L5_2 = L3_2
L4_2 = L4_2(L5_2)
L5_2 = Config
L5_2 = L5_2.ServicingBlacklist
if L5_2 then
L5_2 = type
L6_2 = Config
L6_2 = L6_2.ServicingBlacklist
L5_2 = L5_2(L6_2)
if "table" == L5_2 then
L5_2 = lib
L5_2 = L5_2.table
L5_2 = L5_2.contains
L6_2 = Config
L6_2 = L6_2.ServicingBlacklist
L7_2 = L4_2
L5_2 = L5_2(L6_2, L7_2)
if L5_2 then
return
end
end
end
L5_2 = A2_2 % 1
if 0 ~= L5_2 or A2_2 < 1 then
return
end
L5_2 = GetEntityModel
L6_2 = L3_2
L5_2 = L5_2(L6_2)
L6_2 = isVehicleElectric
L7_2 = L4_2
L6_2 = L6_2(L7_2)
L7_2 = IsThisModelACar
L8_2 = L5_2
L7_2 = L7_2(L8_2)
if not L7_2 then
L7_2 = IsThisModelABike
L8_2 = L5_2
L7_2 = L7_2(L8_2)
if not L7_2 then
L7_2 = IsThisModelAQuadbike
L8_2 = L5_2
L7_2 = L7_2(L8_2)
end
end
if not L7_2 then
return
end
L8_2 = Entity
L9_2 = L3_2
L8_2 = L8_2(L9_2)
L8_2 = L8_2.state
L9_2 = L8_2.servicingData
if not L9_2 then
L9_2 = L0_1
end
L10_2 = pairs
L11_2 = Config
L11_2 = L11_2.Servicing
L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2)
for L14_2, L15_2 in L10_2, L11_2, L12_2, L13_2 do
L16_2 = L15_2.restricted
if "electric" ~= L16_2 or not L6_2 then
L16_2 = L15_2.restricted
if "combustion" ~= L16_2 or L6_2 then
L16_2 = L15_2.restricted
if L16_2 then
goto lbl_122
end
end
end
L16_2 = round
L17_2 = math
L17_2 = L17_2.max
L18_2 = 0
L19_2 = L9_2[L14_2]
L20_2 = L15_2.lifespanInKm
L21_2 = 100
L20_2 = L21_2 / L20_2
if not L20_2 then
L20_2 = 0
end
L19_2 = L19_2 - L20_2
L17_2 = L17_2(L18_2, L19_2)
L18_2 = 5
L16_2 = L16_2(L17_2, L18_2)
L9_2[L14_2] = L16_2
::lbl_122::
end
L10_2 = setVehicleStatebag
L11_2 = L3_2
L12_2 = "servicingData"
L13_2 = L9_2
L14_2 = true
L10_2(L11_2, L12_2, L13_2, L14_2)
L10_2 = false
L11_2 = pairs
L12_2 = L9_2
L11_2, L12_2, L13_2, L14_2 = L11_2(L12_2)
for L15_2, L16_2 in L11_2, L12_2, L13_2, L14_2 do
L17_2 = Config
L17_2 = L17_2.ServiceRequiredThreshold
if L16_2 <= L17_2 then
L10_2 = true
end
end
if L10_2 then
L11_2 = Framework
L11_2 = L11_2.Client
L11_2 = L11_2.Notify
L12_2 = Locale
L12_2 = L12_2.serviceVehicleSoon
L13_2 = "error"
L11_2(L12_2, L13_2)
end
end
L1_1(L2_1, L3_1, L4_1)
L1_1 = RegisterNUICallback
L2_1 = "service-vehicle"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
L2_2 = A0_2.name
L3_2 = A0_2.stats
L4_2 = Config
L4_2 = L4_2.Servicing
L4_2 = L4_2[L2_2]
if not L4_2 or not L3_2 then
L5_2 = A1_2
L6_2 = false
return L5_2(L6_2)
end
L5_2 = LocalPlayer
L5_2 = L5_2.state
L5_2 = L5_2.tabletConnectedVehicle
if L5_2 then
L5_2 = L5_2.vehicleEntity
end
if L5_2 then
L6_2 = DoesEntityExist
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if L6_2 then
goto lbl_31
end
end
L6_2 = A1_2
L7_2 = false
do return L6_2(L7_2) end
::lbl_31::
L6_2 = Framework
L6_2 = L6_2.Client
L6_2 = L6_2.GetPlate
L7_2 = L5_2
L6_2 = L6_2(L7_2)
L7_2 = Entity
L8_2 = L5_2
L7_2 = L7_2(L8_2)
L7_2 = L7_2.state
L8_2 = L7_2.servicingData
L9_2 = "spanner"
if "tyres" == L2_2 or "brakePads" == L2_2 then
L9_2 = "wheel"
end
L10_2 = playMinigame
L11_2 = L5_2
L12_2 = "prop"
L13_2 = {}
L13_2.prop = L9_2
function L14_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3
L1_3 = showTabletAfterInteractionPrompt
L1_3()
L1_3 = SetNuiFocus
L2_3 = true
L3_3 = true
L1_3(L2_3, L3_3)
if not A0_3 then
L1_3 = A1_2
L2_3 = false
return L1_3(L2_3)
end
L1_3 = lib
L1_3 = L1_3.callback
L1_3 = L1_3.await
L2_3 = "jg-mechanic:server:pay-for-service"
L3_3 = false
L4_3 = L6_2
L5_3 = L2_2
L1_3 = L1_3(L2_3, L3_3, L4_3, L5_3)
if not L1_3 then
L2_3 = A1_2
L3_3 = false
return L2_3(L3_3)
end
L2_3 = Framework
L2_3 = L2_3.Client
L2_3 = L2_3.Notify
L3_3 = Locale
L3_3 = L3_3.partServiced
L4_3 = L3_3
L3_3 = L3_3.format
L5_3 = Locale
L6_3 = L2_2
L5_3 = L5_3[L6_3]
if not L5_3 then
L5_3 = L2_2
end
L3_3 = L3_3(L4_3, L5_3)
L4_3 = "success"
L2_3(L3_3, L4_3)
L3_3 = L2_2
L2_3 = L8_2
L2_3[L3_3] = 100
L2_3 = setVehicleStatebag
L3_3 = L5_2
L4_3 = "servicingData"
L5_3 = L8_2
L6_3 = true
L2_3(L3_3, L4_3, L5_3, L6_3)
L2_3 = A1_2
L3_3 = true
L2_3(L3_3)
end
L10_2(L11_2, L12_2, L13_2, L14_2)
end
L1_1(L2_1, L3_1)
L1_1 = RegisterNUICallback
L2_1 = "get-service-history"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L2_2 = LocalPlayer
L2_2 = L2_2.state
L2_2 = L2_2.tabletConnectedVehicle
if L2_2 then
L2_2 = L2_2.vehicleEntity
end
if L2_2 then
L3_2 = DoesEntityExist
L4_2 = L2_2
L3_2 = L3_2(L4_2)
if L3_2 then
goto lbl_18
end
end
L3_2 = A1_2
L4_2 = false
do return L3_2(L4_2) end
::lbl_18::
L3_2 = Framework
L3_2 = L3_2.Client
L3_2 = L3_2.GetPlate
L4_2 = L2_2
L3_2 = L3_2(L4_2)
L4_2 = A1_2
L5_2 = lib
L5_2 = L5_2.callback
L5_2 = L5_2.await
L6_2 = "jg-mechanic:server:get-servicing-history"
L7_2 = false
L8_2 = L3_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2, L7_2, L8_2)
L4_2(L5_2, L6_2, L7_2, L8_2)
end
L1_1(L2_1, L3_1)