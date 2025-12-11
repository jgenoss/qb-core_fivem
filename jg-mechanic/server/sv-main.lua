local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:nearby-players"
function L2_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
L4_2 = lib
L4_2 = L4_2.getNearbyPlayers
L5_2 = A1_2
L6_2 = A2_2
L4_2 = L4_2(L5_2, L6_2)
L5_2 = {}
L6_2 = ipairs
L7_2 = L4_2
L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
if not A3_2 then
L12_2 = L11_2.id
if A0_2 == L12_2 then
goto lbl_34
end
end
L12_2 = #L5_2
L12_2 = L12_2 + 1
L13_2 = {}
L14_2 = L11_2.id
L13_2.id = L14_2
L14_2 = Framework
L14_2 = L14_2.Server
L14_2 = L14_2.GetPlayerInfo
L15_2 = L11_2.id
L14_2 = L14_2(L15_2)
if L14_2 then
L14_2 = L14_2.name
end
L13_2.name = L14_2
L5_2[L12_2] = L13_2
::lbl_34::
end
return L5_2
end
L0_1(L1_1, L2_1)
L0_1 = AddEventHandler
L1_1 = "onResourceStart"
function L2_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
L1_2 = GetCurrentResourceName
L1_2 = L1_2()
if L1_2 ~= A0_2 then
return
end
L1_2 = initSQL
L1_2()
L1_2 = pairs
L2_2 = Config
L2_2 = L2_2.MechanicLocations
L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
L7_2 = MySQL
L7_2 = L7_2.query
L7_2 = L7_2.await
L8_2 = "INSERT IGNORE INTO mechanic_data (name, balance) VALUES(?, 0)"
L9_2 = {}
L10_2 = L5_2
L9_2[1] = L10_2
L7_2(L8_2, L9_2)
end
end
L0_1(L1_1, L2_1)