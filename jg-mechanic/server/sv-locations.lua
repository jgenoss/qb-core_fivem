local L0_1, L1_1, L2_1
L0_1 = lib
L0_1 = L0_1.callback
L0_1 = L0_1.register
L1_1 = "jg-mechanic:server:get-mechanic-locations-data"
function L2_1()
local L0_2, L1_2
L0_2 = MySQL
L0_2 = L0_2.query
L0_2 = L0_2.await
L1_2 = "SELECT * FROM mechanic_data"
return L0_2(L1_2)
end
L0_1(L1_1, L2_1)