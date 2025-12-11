local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1
L0_1 = -1375594465
L1_1 = -277236775
L2_1 = {}
L3_1 = false
function L4_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L4_2 = CreateObjectNoOffset
L5_2 = L0_1
L6_2 = A0_2
L7_2 = A1_2
L8_2 = A2_2 - 1.025
L9_2 = true
L10_2 = true
L11_2 = true
L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
if not L4_2 then
L5_2 = false
L6_2 = false
return L5_2, L6_2
end
while true do
L5_2 = DoesEntityExist
L6_2 = L4_2
L5_2 = L5_2(L6_2)
if L5_2 then
break
end
L5_2 = Wait
L6_2 = 1
L5_2(L6_2)
end
L5_2 = SetEntityHeading
L6_2 = L4_2
L7_2 = A3_2
L5_2(L6_2, L7_2)
L5_2 = FreezeEntityPosition
L6_2 = L4_2
L7_2 = true
L5_2(L6_2, L7_2)
L5_2 = CreateObjectNoOffset
L6_2 = L1_1
L7_2 = A0_2
L8_2 = A1_2
L9_2 = A2_2 - 1.0
L10_2 = true
L11_2 = true
L12_2 = true
L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
if not L5_2 then
L6_2 = false
L7_2 = false
return L6_2, L7_2
end
while true do
L6_2 = DoesEntityExist
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if L6_2 then
break
end
L6_2 = Wait
L7_2 = 1
L6_2(L7_2)
end
L6_2 = SetEntityHeading
L7_2 = L5_2
L8_2 = A3_2
L6_2(L7_2, L8_2)
L6_2 = FreezeEntityPosition
L7_2 = L5_2
L8_2 = true
L6_2(L7_2, L8_2)
L6_2 = NetworkGetNetworkIdFromEntity
L7_2 = L4_2
L6_2 = L6_2(L7_2)
L7_2 = NetworkGetNetworkIdFromEntity
L8_2 = L5_2
L7_2, L8_2, L9_2, L10_2, L11_2, L12_2 = L7_2(L8_2)
return L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
end
function L5_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
L0_2 = true
L3_1 = L0_2
L0_2 = GlobalState
L0_2 = L0_2.carLiftsData
if L0_2 then
L0_2 = pairs
L1_2 = GlobalState
L1_2 = L1_2.carLiftsData
L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
L6_2 = ipairs
L7_2 = L5_2
L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
L12_2 = DeleteEntity
L13_2 = NetworkGetEntityFromNetworkId
L14_2 = L11_2.platform
L13_2, L14_2, L15_2, L16_2, L17_2 = L13_2(L14_2)
L12_2(L13_2, L14_2, L15_2, L16_2, L17_2)
L12_2 = DeleteEntity
L13_2 = NetworkGetEntityFromNetworkId
L14_2 = L11_2.stand
L13_2, L14_2, L15_2, L16_2, L17_2 = L13_2(L14_2)
L12_2(L13_2, L14_2, L15_2, L16_2, L17_2)
end
end
end
L0_2 = {}
L1_2 = pairs
L2_2 = Config
L2_2 = L2_2.MechanicLocations
L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
L7_2 = L6_2.carLifts
if L7_2 then
L7_2 = L0_2[L5_2]
if L7_2 then
L7_2 = L0_2[L5_2]
L7_2 = #L7_2
if 0 ~= L7_2 then
goto lbl_85
end
end
L7_2 = ipairs
L8_2 = L6_2.carLifts
L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
L13_2 = L4_1
L14_2 = L12_2.x
L15_2 = L12_2.y
L16_2 = L12_2.z
L17_2 = L12_2.w
L13_2, L14_2 = L13_2(L14_2, L15_2, L16_2, L17_2)
if not L13_2 or not L14_2 then
L15_2 = false
return L15_2
end
L15_2 = L0_2[L5_2]
if not L15_2 then
L15_2 = {}
L0_2[L5_2] = L15_2
end
L15_2 = L0_2[L5_2]
L16_2 = L0_2[L5_2]
L16_2 = #L16_2
L16_2 = L16_2 + 1
L17_2 = {}
L17_2.platform = L13_2
L17_2.stand = L14_2
L17_2.coords = L12_2
L15_2[L16_2] = L17_2
end
end
::lbl_85::
end
L2_1 = L0_2
L1_2 = GlobalState
L2_2 = L1_2
L1_2 = L1_2.set
L3_2 = "carLiftsData"
L4_2 = L0_2
L1_2(L2_2, L3_2, L4_2)
end
L6_1 = lib
L6_1 = L6_1.callback
L6_1 = L6_1.register
L7_1 = "jg-mechanic:server:get-created-lifts"
function L8_1()
local L0_2, L1_2, L2_2, L3_2
L0_2 = L3_1
if not L0_2 then
L0_2 = L5_1
L0_2()
end
L0_2 = lib
L0_2 = L0_2.waitFor
function L1_2()
local L0_3, L1_3
L0_3 = L2_1
if L0_3 then
L0_3 = true
return L0_3
end
end
L2_2 = "Lifts say they have been created, but they are still false"
L3_2 = 30000
L0_2(L1_2, L2_2, L3_2)
L0_2 = L2_1
return L0_2
end
L6_1(L7_1, L8_1)