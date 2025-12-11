local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1
PreviewingNewStance = false
L0_1 = false
function L1_1(A0_2)
local L1_2, L2_2, L3_2
L1_2 = GetEntityModel
L2_2 = A0_2
L1_2 = L1_2(L2_2)
L2_2 = IsThisModelACar
L3_2 = L1_2
L2_2 = L2_2(L3_2)
if not L2_2 then
L2_2 = IsThisModelAQuadbike
L3_2 = L1_2
L2_2 = L2_2(L3_2)
end
return L2_2
end
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
if A0_2 then
L2_2 = DoesEntityExist
L3_2 = A0_2
L2_2 = L2_2(L3_2)
if L2_2 and A1_2 then
L2_2 = L1_1
L3_2 = A0_2
L2_2 = L2_2(L3_2)
if L2_2 then
goto lbl_17
end
end
end
L2_2 = false
do return L2_2 end
::lbl_17::
L2_2 = SetVehicleSuspensionHeight
L3_2 = A0_2
L4_2 = A1_2.height
L4_2 = L4_2 + 0.0
L4_2 = -L4_2
L2_2(L3_2, L4_2)
L2_2 = SetVehicleWheelXOffset
L3_2 = A0_2
L4_2 = 0
L5_2 = A1_2.xOffset
L5_2 = L5_2[1]
L5_2 = -L5_2
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelXOffset
L3_2 = A0_2
L4_2 = 1
L5_2 = A1_2.xOffset
L5_2 = L5_2[2]
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelXOffset
L3_2 = A0_2
L4_2 = 2
L5_2 = A1_2.xOffset
L5_2 = L5_2[3]
L5_2 = -L5_2
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelXOffset
L3_2 = A0_2
L4_2 = 3
L5_2 = A1_2.xOffset
L5_2 = L5_2[4]
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelYRotation
L3_2 = A0_2
L4_2 = 0
L5_2 = A1_2.yRot
L5_2 = L5_2[1]
L5_2 = -L5_2
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelYRotation
L3_2 = A0_2
L4_2 = 1
L5_2 = A1_2.yRot
L5_2 = L5_2[2]
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelYRotation
L3_2 = A0_2
L4_2 = 2
L5_2 = A1_2.yRot
L5_2 = L5_2[3]
L5_2 = -L5_2
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
L2_2 = SetVehicleWheelYRotation
L3_2 = A0_2
L4_2 = 3
L5_2 = A1_2.yRot
L5_2 = L5_2[4]
L5_2 = L5_2 + 0.0
L2_2(L3_2, L4_2, L5_2)
end
function L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
if A0_2 then
L1_2 = DoesEntityExist
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if L1_2 then
L1_2 = L1_1
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if L1_2 then
goto lbl_15
end
end
end
L1_2 = false
do return L1_2 end
::lbl_15::
L1_2 = {}
L2_2 = round
L3_2 = GetVehicleSuspensionHeight
L4_2 = A0_2
L3_2 = L3_2(L4_2)
L4_2 = 4
L2_2 = L2_2(L3_2, L4_2)
L1_2.height = L2_2
L2_2 = {}
L3_2 = round
L4_2 = GetVehicleWheelXOffset
L5_2 = A0_2
L6_2 = 0
L4_2 = L4_2(L5_2, L6_2)
L5_2 = 4
L3_2 = L3_2(L4_2, L5_2)
L3_2 = -L3_2
L4_2 = round
L5_2 = GetVehicleWheelXOffset
L6_2 = A0_2
L7_2 = 1
L5_2 = L5_2(L6_2, L7_2)
L6_2 = 4
L4_2 = L4_2(L5_2, L6_2)
L5_2 = round
L6_2 = GetVehicleWheelXOffset
L7_2 = A0_2
L8_2 = 2
L6_2 = L6_2(L7_2, L8_2)
L7_2 = 4
L5_2 = L5_2(L6_2, L7_2)
L5_2 = -L5_2
L6_2 = round
L7_2 = GetVehicleWheelXOffset
L8_2 = A0_2
L9_2 = 3
L7_2 = L7_2(L8_2, L9_2)
L8_2 = 4
L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2, L8_2)
L2_2[1] = L3_2
L2_2[2] = L4_2
L2_2[3] = L5_2
L2_2[4] = L6_2
L2_2[5] = L7_2
L2_2[6] = L8_2
L2_2[7] = L9_2
L1_2.xOffset = L2_2
L2_2 = {}
L3_2 = round
L4_2 = GetVehicleWheelYRotation
L5_2 = A0_2
L6_2 = 0
L4_2 = L4_2(L5_2, L6_2)
L5_2 = 4
L3_2 = L3_2(L4_2, L5_2)
L3_2 = -L3_2
L4_2 = round
L5_2 = GetVehicleWheelYRotation
L6_2 = A0_2
L7_2 = 1
L5_2 = L5_2(L6_2, L7_2)
L6_2 = 4
L4_2 = L4_2(L5_2, L6_2)
L5_2 = round
L6_2 = GetVehicleWheelYRotation
L7_2 = A0_2
L8_2 = 2
L6_2 = L6_2(L7_2, L8_2)
L7_2 = 4
L5_2 = L5_2(L6_2, L7_2)
L5_2 = -L5_2
L6_2 = round
L7_2 = GetVehicleWheelYRotation
L8_2 = A0_2
L9_2 = 3
L7_2 = L7_2(L8_2, L9_2)
L8_2 = 4
L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2, L8_2)
L2_2[1] = L3_2
L2_2[2] = L4_2
L2_2[3] = L5_2
L2_2[4] = L6_2
L2_2[5] = L7_2
L2_2[6] = L8_2
L2_2[7] = L9_2
L1_2.yRot = L2_2
return L1_2
end
getVehicleDefaultStance = L3_1
function L3_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2
if A0_2 then
L4_2 = L1_1
L5_2 = A0_2
L4_2 = L4_2(L5_2)
if L4_2 then
goto lbl_9
end
end
do return end
::lbl_9::
if A1_2 then
L4_2 = L2_1
L5_2 = A0_2
L6_2 = A3_2
L4_2(L5_2, L6_2)
else
L4_2 = L2_1
L5_2 = A0_2
L6_2 = A2_2
L4_2(L5_2, L6_2)
end
end
previewVehicleStance = L3_1
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
if A0_2 then
L5_2 = L1_1
L6_2 = A0_2
L5_2 = L5_2(L6_2)
if L5_2 then
goto lbl_9
end
end
do return end
::lbl_9::
L5_2 = Entity
L6_2 = A0_2
L5_2 = L5_2(L6_2)
L5_2 = L5_2.state
L6_2 = Entity
L7_2 = A0_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
L7_2 = L6_2
L6_2 = L6_2.set
L8_2 = "enableStance"
L9_2 = A1_2
L10_2 = true
L6_2(L7_2, L8_2, L9_2, L10_2)
if A1_2 then
L6_2 = Entity
L7_2 = A0_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
L7_2 = L6_2
L6_2 = L6_2.set
L8_2 = "wheelsAdjIndv"
L9_2 = A2_2
L10_2 = true
L6_2(L7_2, L8_2, L9_2, L10_2)
L6_2 = Entity
L7_2 = A0_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
L7_2 = L6_2
L6_2 = L6_2.set
L8_2 = "stance"
L9_2 = A4_2
L10_2 = true
L6_2(L7_2, L8_2, L9_2, L10_2)
end
L6_2 = L5_2.defaultStance
if not L6_2 then
L6_2 = Entity
L7_2 = A0_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
L7_2 = L6_2
L6_2 = L6_2.set
L8_2 = "defaultStance"
L9_2 = A3_2
L10_2 = true
L6_2(L7_2, L8_2, L9_2, L10_2)
end
end
setStanceState = L3_1
L3_1 = {}
L4_1 = {}
L5_1 = {}
L6_1 = {}
L7_1 = nil
L8_1 = false
L9_1 = false
L10_1 = Config
if L10_1 then
L10_1 = Config
L10_1 = L10_1.StanceNearbyVehiclesFreqMs
if L10_1 then
goto lbl_31
end
end
L10_1 = 500
::lbl_31::
L11_1 = 80.0
function L12_1(A0_2)
local L1_2, L2_2, L3_2
L1_2 = GetEntityFromStateBagName
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if 0 ~= L1_2 then
L2_2 = DoesEntityExist
L3_2 = L1_2
L2_2 = L2_2(L3_2)
if L2_2 then
L2_2 = IsEntityAVehicle
L3_2 = L1_2
L2_2 = L2_2(L3_2)
if L2_2 then
goto lbl_18
end
end
end
L2_2 = nil
do return L2_2 end
::lbl_18::
return L1_2
end
function L13_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
if not A0_2 then
L1_2 = 0
return L1_2
end
L1_2 = A0_2.height
if not L1_2 then
L1_2 = 0
end
L1_2 = L1_2 * 131.0
L2_2 = A0_2.xOffset
if L2_2 then
L2_2 = 1
L3_2 = A0_2.xOffset
L3_2 = #L3_2
L4_2 = 1
for L5_2 = L2_2, L3_2, L4_2 do
L6_2 = L1_2 * 31.0
L7_2 = A0_2.xOffset
L7_2 = L7_2[L5_2]
if not L7_2 then
L7_2 = 0
end
L1_2 = L6_2 + L7_2
end
end
L2_2 = A0_2.yRot
if L2_2 then
L2_2 = 1
L3_2 = A0_2.yRot
L3_2 = #L3_2
L4_2 = 1
for L5_2 = L2_2, L3_2, L4_2 do
L6_2 = L1_2 * 37.0
L7_2 = A0_2.yRot
L7_2 = L7_2[L5_2]
if not L7_2 then
L7_2 = 0
end
L1_2 = L6_2 + L7_2
end
end
L2_2 = math
L2_2 = L2_2.floor
L3_2 = L1_2 * 1000.0
return L2_2(L3_2)
end
function L14_1(A0_2)
local L1_2, L2_2
L1_2 = L5_1
L2_2 = L5_1
L2_2 = L2_2[A0_2]
if not L2_2 then
L2_2 = 0
end
L2_2 = L2_2 + 1
L1_2[A0_2] = L2_2
end
function L15_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L1_2 = L3_1
L2_2 = L4_1
L3_2 = L5_1
L4_2 = L6_1
L5_2 = nil
L6_2 = nil
L7_2 = nil
L4_2[A0_2] = nil
L3_2[A0_2] = L7_2
L2_2[A0_2] = L6_2
L1_2[A0_2] = L5_2
end
function L16_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = L4_1
L2_2 = L2_2[A0_2]
if L2_2 then
L3_2 = L2_2.stance
if L3_2 then
goto lbl_9
end
end
do return end
::lbl_9::
L3_2 = L13_1
L4_2 = L2_2.stance
L3_2 = L3_2(L4_2)
if not A1_2 then
L4_2 = L6_1
L4_2 = L4_2[A0_2]
if L3_2 == L4_2 then
goto lbl_24
end
end
L4_2 = L2_1
L5_2 = A0_2
L6_2 = L2_2.stance
L4_2(L5_2, L6_2)
L4_2 = L6_1
L4_2[A0_2] = L3_2
::lbl_24::
end
function L17_1(A0_2)
local L1_2, L2_2, L3_2
L1_2 = Entity
L2_2 = A0_2
L1_2 = L1_2(L2_2)
L1_2 = L1_2.state
if not L1_2 then
return
end
L2_2 = L1_2.enableStance
if L2_2 then
L2_2 = L3_1
L2_2[A0_2] = true
L2_2 = L4_1
L3_2 = L4_1
L3_2 = L3_2[A0_2]
if not L3_2 then
L3_2 = {}
end
L2_2[A0_2] = L3_2
L2_2 = L4_1
L2_2 = L2_2[A0_2]
L3_2 = L1_2.stance
L2_2.stance = L3_2
L2_2 = L4_1
L2_2 = L2_2[A0_2]
L3_2 = L1_2.defaultStance
L2_2.defaultStance = L3_2
L2_2 = L14_1
L3_2 = A0_2
L2_2(L3_2)
end
end
function L18_1()
local L0_2, L1_2
L0_2 = L8_1
if not L0_2 then
L0_2 = L7_1
if L0_2 then
L1_2 = L7_1
L0_2 = L3_1
L0_2 = L0_2[L1_2]
if L0_2 then
goto lbl_13
end
end
end
do return end
::lbl_13::
L0_2 = true
L8_1 = L0_2
L0_2 = CreateThread
function L1_2()
local L0_3, L1_3, L2_3
while true do
L0_3 = L7_1
if not L0_3 then
break
end
L1_3 = L7_1
L0_3 = L3_1
L0_3 = L0_3[L1_3]
if not L0_3 then
break
end
L0_3 = DoesEntityExist
L1_3 = L7_1
L0_3 = L0_3(L1_3)
if not L0_3 then
break
end
L0_3 = PreviewingNewStance
if not L0_3 then
L0_3 = L16_1
L1_3 = L7_1
L2_3 = true
L0_3(L1_3, L2_3)
end
L0_3 = Wait
L1_3 = 0
L0_3(L1_3)
end
L0_3 = false
L8_1 = L0_3
end
L0_2(L1_2)
end
function L19_1()
local L0_2, L1_2
L0_2 = L9_1
if not L0_2 then
L0_2 = next
L1_2 = L3_1
L0_2 = L0_2(L1_2)
if L0_2 then
goto lbl_10
end
end
do return end
::lbl_10::
L0_2 = true
L9_1 = L0_2
L0_2 = CreateThread
function L1_2()
local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3
while true do
L0_3 = cache
if L0_3 then
L0_3 = cache
L0_3 = L0_3.ped
if L0_3 then
goto lbl_10
end
end
L0_3 = PlayerPedId
L0_3 = L0_3()
::lbl_10::
L1_3 = GetEntityCoords
L2_3 = L0_3
L1_3 = L1_3(L2_3)
L2_3 = cache
if L2_3 then
L2_3 = cache
L2_3 = L2_3.vehicle
if L2_3 then
goto lbl_24
end
end
L2_3 = GetVehiclePedIsIn
L3_3 = L0_3
L4_3 = false
L2_3 = L2_3(L3_3, L4_3)
::lbl_24::
L3_3 = ipairs
L4_3 = GetGamePool
L5_3 = "CVehicle"
L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3 = L4_3(L5_3)
L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3)
for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
if L8_3 ~= L2_3 then
L9_3 = DoesEntityExist
L10_3 = L8_3
L9_3 = L9_3(L10_3)
if L9_3 then
L9_3 = GetEntityCoords
L10_3 = L8_3
L9_3 = L9_3(L10_3)
L9_3 = L9_3 - L1_3
L9_3 = #L9_3
L10_3 = L11_1
if L9_3 <= L10_3 then
L9_3 = Entity
L10_3 = L8_3
L9_3 = L9_3(L10_3)
L9_3 = L9_3.state
if L9_3 then
L10_3 = L9_3.enableStance
if L10_3 then
L10_3 = L3_1
L10_3 = L10_3[L8_3]
if not L10_3 then
L10_3 = L3_1
L10_3[L8_3] = true
end
L10_3 = L4_1
L10_3 = L10_3[L8_3]
if not L10_3 then
L10_3 = L4_1
L11_3 = {}
L12_3 = L9_3.stance
L11_3.stance = L12_3
L12_3 = L9_3.defaultStance
L11_3.defaultStance = L12_3
L10_3[L8_3] = L11_3
L10_3 = L14_1
L11_3 = L8_3
L10_3(L11_3)
end
end
end
end
end
end
end
L3_3 = pairs
L4_3 = L3_1
L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
for L7_3 in L3_3, L4_3, L5_3, L6_3 do
L8_3 = DoesEntityExist
L9_3 = L7_3
L8_3 = L8_3(L9_3)
if not L8_3 then
L8_3 = L15_1
L9_3 = L7_3
L8_3(L9_3)
elseif L7_3 ~= L2_3 then
L8_3 = GetEntityCoords
L9_3 = L7_3
L8_3 = L8_3(L9_3)
L8_3 = L8_3 - L1_3
L8_3 = #L8_3
L9_3 = L11_1
if L8_3 <= L9_3 then
L8_3 = L16_1
L9_3 = L7_3
L10_3 = true
L8_3(L9_3, L10_3)
end
end
end
L3_3 = next
L4_3 = L3_1
L3_3 = L3_3(L4_3)
if not L3_3 then
break
end
L3_3 = Wait
L4_3 = L10_1
L3_3(L4_3)
end
L0_3 = false
L9_1 = L0_3
end
L0_2(L1_2)
end
L20_1 = AddStateBagChangeHandler
L21_1 = "enableStance"
L22_1 = ""
function L23_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2
L3_2 = L12_1
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if not L3_2 then
return
end
if A2_2 then
L4_2 = Entity
L5_2 = L3_2
L4_2 = L4_2(L5_2)
L4_2 = L4_2.state
L5_2 = L3_1
L5_2[L3_2] = true
L5_2 = L4_1
L6_2 = L4_1
L6_2 = L6_2[L3_2]
if not L6_2 then
L6_2 = {}
end
L5_2[L3_2] = L6_2
L5_2 = L4_1
L5_2 = L5_2[L3_2]
if L4_2 then
L6_2 = L4_2.stance
if L6_2 then
goto lbl_33
end
end
L6_2 = L4_1
L6_2 = L6_2[L3_2]
L6_2 = L6_2.stance
::lbl_33::
L5_2.stance = L6_2
L5_2 = L4_1
L5_2 = L5_2[L3_2]
if L4_2 then
L6_2 = L4_2.defaultStance
if L6_2 then
goto lbl_44
end
end
L6_2 = L4_1
L6_2 = L6_2[L3_2]
L6_2 = L6_2.defaultStance
::lbl_44::
L5_2.defaultStance = L6_2
L5_2 = L6_1
L5_2[L3_2] = nil
L5_2 = L5_1
L6_2 = L5_1
L6_2 = L6_2[L3_2]
if not L6_2 then
L6_2 = 0
end
L6_2 = L6_2 + 1
L5_2[L3_2] = L6_2
L5_2 = L7_1
if L3_2 == L5_2 then
L5_2 = L18_1
L5_2()
L5_2 = PreviewingNewStance
if not L5_2 then
L5_2 = L16_1
L6_2 = L3_2
L7_2 = true
L5_2(L6_2, L7_2)
end
end
else
L4_2 = L4_1
L4_2 = L4_2[L3_2]
if L4_2 then
L4_2 = L4_1
L4_2 = L4_2[L3_2]
L4_2 = L4_2.defaultStance
if L4_2 then
L4_2 = L2_1
L5_2 = L3_2
L6_2 = L4_1
L6_2 = L6_2[L3_2]
L6_2 = L6_2.defaultStance
L4_2(L5_2, L6_2)
L4_2 = L6_1
L5_2 = L13_1
L6_2 = L4_1
L6_2 = L6_2[L3_2]
L6_2 = L6_2.defaultStance
L5_2 = L5_2(L6_2)
L4_2[L3_2] = L5_2
end
end
L4_2 = L3_1
L4_2[L3_2] = nil
end
L4_2 = L19_1
L4_2()
end
L20_1(L21_1, L22_1, L23_1)
L20_1 = AddStateBagChangeHandler
L21_1 = "stance"
L22_1 = ""
function L23_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
L3_2 = L12_1
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if not L3_2 then
return
end
L4_2 = L3_1
L4_2[L3_2] = true
L4_2 = L4_1
L5_2 = L4_1
L5_2 = L5_2[L3_2]
if not L5_2 then
L5_2 = {}
end
L4_2[L3_2] = L5_2
L4_2 = L4_1
L4_2 = L4_2[L3_2]
L4_2.stance = A2_2
L4_2 = L14_1
L5_2 = L3_2
L4_2(L5_2)
end
L20_1(L21_1, L22_1, L23_1)
L20_1 = AddStateBagChangeHandler
L21_1 = "defaultStance"
L22_1 = ""
function L23_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
L3_2 = L12_1
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if not L3_2 then
return
end
L4_2 = L4_1
L5_2 = L4_1
L5_2 = L5_2[L3_2]
if not L5_2 then
L5_2 = {}
end
L4_2[L3_2] = L5_2
L4_2 = L4_1
L4_2 = L4_2[L3_2]
L4_2.defaultStance = A2_2
end
L20_1(L21_1, L22_1, L23_1)
function L20_1(A0_2)
local L1_2, L2_2
L7_1 = A0_2
if A0_2 then
L1_2 = DoesEntityExist
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if L1_2 then
L1_2 = IsEntityAVehicle
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if L1_2 then
L1_2 = L17_1
L2_2 = A0_2
L1_2(L2_2)
end
end
end
L1_2 = L18_1
L1_2()
end
L21_1 = lib
L21_1 = L21_1.onCache
L22_1 = "vehicle"
L23_1 = L20_1
L21_1(L22_1, L23_1)
L21_1 = cache
L21_1 = L21_1.vehicle
if L21_1 then
L21_1 = L20_1
L22_1 = cache
L22_1 = L22_1.vehicle
L21_1(L22_1)
end
L21_1 = CreateThread
function L22_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L0_2 = Wait
L1_2 = 0
L0_2(L1_2)
L0_2 = ipairs
L1_2 = GetGamePool
L2_2 = "CVehicle"
L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2 = L1_2(L2_2)
L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2)
for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
L6_2 = DoesEntityExist
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if L6_2 then
L6_2 = IsEntityAVehicle
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if L6_2 then
L6_2 = L17_1
L7_2 = L5_2
L6_2(L7_2)
end
end
end
L0_2 = L19_1
L0_2()
end
L21_1(L22_1)
L21_1 = RegisterNUICallback
L22_1 = "save-kit-stance"
function L23_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = L0_1
if not L2_2 then
L2_2 = A1_2
L3_2 = {}
L3_2.error = true
return L2_2(L3_2)
end
L2_2 = cache
L2_2 = L2_2.vehicle
if not L2_2 then
L2_2 = A1_2
L3_2 = {}
L3_2.error = true
return L2_2(L3_2)
end
PreviewingNewStance = false
L2_2 = setVehicleStatebag
L3_2 = cache
L3_2 = L3_2.vehicle
L4_2 = "defaultStance"
L5_2 = A0_2.defaultStance
L2_2(L3_2, L4_2, L5_2)
L2_2 = setVehicleStatebag
L3_2 = cache
L3_2 = L3_2.vehicle
L4_2 = "wheelsAdjIndv"
L5_2 = A0_2.wheelsAdjIndv
L2_2(L3_2, L4_2, L5_2)
L2_2 = setVehicleStatebag
L3_2 = cache
L3_2 = L3_2.vehicle
L4_2 = "stance"
L5_2 = A0_2.stance
L2_2(L3_2, L4_2, L5_2)
L2_2 = setVehicleStatebag
L3_2 = cache
L3_2 = L3_2.vehicle
L4_2 = "enableStance"
L5_2 = A0_2.enableStance
L6_2 = true
L2_2(L3_2, L4_2, L5_2, L6_2)
L2_2 = A1_2
L3_2 = true
return L2_2(L3_2)
end
L21_1(L22_1, L23_1)
L21_1 = RegisterNUICallback
L22_1 = "preview-kit-stance"
function L23_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = L0_1
if not L2_2 then
L2_2 = A1_2
L3_2 = {}
L3_2.error = true
return L2_2(L3_2)
end
L2_2 = cache
L2_2 = L2_2.vehicle
if not L2_2 then
L2_2 = A1_2
L3_2 = {}
L3_2.error = true
return L2_2(L3_2)
end
PreviewingNewStance = true
L2_2 = previewVehicleStance
L3_2 = cache
L3_2 = L3_2.vehicle
L4_2 = A0_2.enableStance
L5_2 = A0_2.defaultStance
L6_2 = A0_2.stance
L2_2(L3_2, L4_2, L5_2, L6_2)
L2_2 = A1_2
L3_2 = true
return L2_2(L3_2)
end
L21_1(L22_1, L23_1)
L21_1 = RegisterNetEvent
L22_1 = "jg-mechanic:client:show-stancer-kit"
function L23_1()
local L0_2, L1_2, L2_2, L3_2, L4_2
L0_2 = lib
L0_2 = L0_2.callback
L0_2 = L0_2.await
L1_2 = "jg-mechanic:server:has-item"
L2_2 = false
L3_2 = "stancing_kit"
L0_2 = L0_2(L1_2, L2_2, L3_2)
L0_1 = L0_2
L0_2 = L0_1
if not L0_2 then
return
end
L0_2 = cache
L0_2 = L0_2.vehicle
if not L0_2 then
L0_2 = Framework
L0_2 = L0_2.Client
L0_2 = L0_2.Notify
L1_2 = Locale
L1_2 = L1_2.notInsideVehicle
L2_2 = "error"
return L0_2(L1_2, L2_2)
end
L0_2 = L1_1
L1_2 = cache
L1_2 = L1_2.vehicle
L0_2 = L0_2(L1_2)
if not L0_2 then
L0_2 = Framework
L0_2 = L0_2.Client
L0_2 = L0_2.Notify
L1_2 = Locale
L1_2 = L1_2.cannotStanceVehicleType
if not L1_2 then
L1_2 = "VEHICLE_INCOMPATIBLE"
end
L2_2 = "error"
return L0_2(L1_2, L2_2)
end
L0_2 = Entity
L1_2 = cache
L1_2 = L1_2.vehicle
L0_2 = L0_2(L1_2)
L0_2 = L0_2.state
L1_2 = setupVehicleCamera
L2_2 = cache
L2_2 = L2_2.vehicle
L1_2(L2_2)
L1_2 = SetNuiFocus
L2_2 = true
L3_2 = true
L1_2(L2_2, L3_2)
L1_2 = SendNUIMessage
L2_2 = {}
L2_2.type = "show-stancing-menu"
L3_2 = L0_2.enableStance
if not L3_2 then
L3_2 = false
end
L2_2.enableStance = L3_2
L3_2 = L0_2.wheelsAdjIndv
if not L3_2 then
L3_2 = false
end
L2_2.wheelsAdjIndv = L3_2
L3_2 = L0_2.stance
if not L3_2 then
L3_2 = getVehicleDefaultStance
L4_2 = cache
L4_2 = L4_2.vehicle
L3_2 = L3_2(L4_2)
end
L2_2.stance = L3_2
L3_2 = L0_2.defaultStance
if not L3_2 then
L3_2 = getVehicleDefaultStance
L4_2 = cache
L4_2 = L4_2.vehicle
L3_2 = L3_2(L4_2)
end
L2_2.defaultStance = L3_2
L3_2 = Config
L2_2.config = L3_2
L3_2 = Locale
L2_2.locale = L3_2
L1_2(L2_2)
end
L21_1(L22_1, L23_1)