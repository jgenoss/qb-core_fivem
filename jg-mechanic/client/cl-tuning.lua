local L0_1, L1_1, L2_1, L3_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L2_2 = {}
L3_2 = pairs
L4_2 = A1_2 or L4_2
if not A1_2 then
L4_2 = Config
L4_2 = L4_2.Tuning
end
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
if not A1_2 then
L8_2 = false
end
if "turbocharging" == L7_2 then
L9_2 = IsToggleModOn
L10_2 = A0_2
L11_2 = 18
L9_2 = L9_2(L10_2, L11_2)
if L9_2 then
L8_2 = 1
end
end
if "gearboxes" == L7_2 then
L9_2 = getVehicleHandlingValue
L10_2 = A0_2
L11_2 = "CCarHandlingData"
L12_2 = "strAdvancedFlags"
L9_2 = L9_2(L10_2, L11_2, L12_2)
L10_2 = hasFlag
L11_2 = L9_2
L12_2 = ADV_HANDLING_FLAGS
L12_2 = L12_2.MANUAL
L10_2 = L10_2(L11_2, L12_2)
if L10_2 then
L8_2 = 1
end
end
L2_2[L7_2] = L8_2
end
return L2_2
end
getVehicleTuningConfig = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
if A0_2 and A1_2 then
L2_2 = type
L3_2 = A1_2
L2_2 = L2_2(L3_2)
if "table" == L2_2 then
goto lbl_13
end
end
L2_2 = print
L3_2 = "^1[ERROR] Could not set vehicle tuning data statebag"
L2_2(L3_2)
::lbl_13::
L2_2 = setVehicleStatebag
L3_2 = A0_2
L4_2 = "tuningConfig"
L5_2 = A1_2
L6_2 = true
return L2_2(L3_2, L4_2, L5_2, L6_2)
end
L1_1 = RegisterNUICallback
L2_1 = "install-tune"
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
L2_2 = A0_2.tune
L3_2 = A0_2.option
L4_2 = A0_2.currentOption
L5_2 = A0_2.installed
L6_2 = A0_2.tuningConfig
L7_2 = Config
L7_2 = L7_2.Tuning
L7_2 = L7_2[L2_2]
if L7_2 then
L7_2 = L7_2[L3_2]
end
if not L7_2 then
L8_2 = A1_2
L9_2 = false
return L8_2(L9_2)
end
L8_2 = LocalPlayer
L8_2 = L8_2.state
L8_2 = L8_2.tabletConnectedVehicle
if L8_2 then
L8_2 = L8_2.vehicleEntity
end
L9_2 = LocalPlayer
L9_2 = L9_2.state
L9_2 = L9_2.tabletConnectedVehicle
if L9_2 then
L9_2 = L9_2.plate
end
L10_2 = DoesEntityExist
L11_2 = L8_2
L10_2 = L10_2(L11_2)
if not L10_2 then
L10_2 = A1_2
L11_2 = false
return L10_2(L11_2)
end
L10_2 = "prop"
L11_2 = {}
L11_2.prop = "spanner"
if "engineSwaps" == L2_2 then
L10_2 = "engineSwap"
end
if "tyres" == L2_2 then
L12_2 = {}
L12_2.prop = "wheel"
L11_2 = L12_2
end
L12_2 = playMinigame
L13_2 = L8_2
L14_2 = L10_2
L15_2 = L11_2
function L16_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3
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
L1_3 = L5_2
if L1_3 then
L1_3 = lib
L1_3 = L1_3.callback
L1_3 = L1_3.await
L2_3 = "jg-mechanic:server:pay-for-tune"
L3_3 = false
L4_3 = L2_2
L5_3 = L3_2
L6_3 = L4_2
L7_3 = L9_2
L1_3 = L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L7_3)
if not L1_3 then
L2_3 = A1_2
L3_3 = false
return L2_3(L3_3)
end
L2_3 = Framework
L2_3 = L2_3.Client
L2_3 = L2_3.Notify
L3_3 = Locale
L3_3 = L3_3.partInstalled
L4_3 = L3_3
L3_3 = L3_3.format
L5_3 = L7_2.name
L3_3 = L3_3(L4_3, L5_3)
L4_3 = "success"
L2_3(L3_3, L4_3)
else
L1_3 = lib
L1_3 = L1_3.callback
L1_3 = L1_3.await
L2_3 = "jg-mechanic:server:remove-tune"
L3_3 = false
L4_3 = L2_2
L5_3 = L3_2
L6_3 = L9_2
L1_3 = L1_3(L2_3, L3_3, L4_3, L5_3, L6_3)
if not L1_3 then
L2_3 = A1_2
L3_3 = false
return L2_3(L3_3)
end
L2_3 = Framework
L2_3 = L2_3.Client
L2_3 = L2_3.Notify
L3_3 = Locale
L3_3 = L3_3.partRemoved
L4_3 = L3_3
L3_3 = L3_3.format
L5_3 = L7_2.name
L3_3 = L3_3(L4_3, L5_3)
L4_3 = "success"
L2_3(L3_3, L4_3)
end
L1_3 = L0_1
L2_3 = L8_2
L3_3 = L6_2
L1_3 = L1_3(L2_3, L3_3)
if L1_3 then
L1_3 = A1_2
L2_3 = true
return L1_3(L2_3)
end
L1_3 = A1_2
L2_3 = false
return L1_3(L2_3)
end
L12_2(L13_2, L14_2, L15_2, L16_2)
end
L1_1(L2_1, L3_1)