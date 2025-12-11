local L0_1, L1_1, L2_1, L3_1
L0_1 = lib
L0_1 = L0_1.addCommand
L1_1 = Config
L1_1 = L1_1.FullRepairAdminCommand
if not L1_1 then
L1_1 = "vfix"
end
L2_1 = {}
L2_1.help = "Fully fix a vehicle (admin only)"
function L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
L1_2 = Framework
L1_2 = L1_2.Server
L1_2 = L1_2.IsAdmin
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if not L1_2 then
L1_2 = Framework
L1_2 = L1_2.Server
L1_2 = L1_2.Notify
L2_2 = A0_2
L3_2 = Locale
L3_2 = L3_2.insufficientPermissions
L4_2 = "error"
L1_2(L2_2, L3_2, L4_2)
return
end
L1_2 = TriggerClientEvent
L2_2 = "jg-mechanic:client:fix-vehicle-admin"
L3_2 = A0_2
L1_2(L2_2, L3_2)
end
L0_1(L1_1, L2_1, L3_1)