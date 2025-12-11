local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:dyno-share-with-player"
function L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2
L3_2 = Player
L4_2 = A1_2
L3_2 = L3_2(L4_2)
L3_2 = L3_2.state
if L3_2 then
L4_2 = L3_2.isBusy
if L4_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.playerIsBusy
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
end
L4_2 = TriggerClientEvent
L5_2 = "jg-mechanic:client:dyno-show-results-sheet"
L6_2 = A1_2
L7_2 = A2_2
L4_2(L5_2, L6_2, L7_2)
L4_2 = true
return L4_2
end
L0_1(L1_1, L2_1)