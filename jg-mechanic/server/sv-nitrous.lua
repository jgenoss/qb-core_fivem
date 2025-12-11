local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
L2_2 = A1_2.nitrousInstalledBottles
if L2_2 then
L2_2 = A1_2.nitrousInstalledBottles
if 0 ~= L2_2 then
goto lbl_17
end
end
L2_2 = Framework
L2_2 = L2_2.Server
L2_2 = L2_2.Notify
L3_2 = A0_2
L4_2 = Locale
L4_2 = L4_2.nitrousNotInstalled
L5_2 = "error"
L2_2(L3_2, L4_2, L5_2)
L2_2 = false
do return L2_2 end
::lbl_17::
L2_2 = true
return L2_2
end
function L1_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
L2_2 = A1_2.nitrousInstalledBottles
L3_2 = A1_2.nitrousFilledBottles
if L2_2 ~= L3_2 then
L2_2 = A1_2.nitrousInstalledBottles
L2_2 = L2_2 - 1
L3_2 = A1_2.nitrousFilledBottles
if L2_2 ~= L3_2 then
goto lbl_24
end
L2_2 = A1_2.nitrousCapacity
if not (L2_2 > 0) then
goto lbl_24
end
end
L2_2 = Framework
L2_2 = L2_2.Server
L2_2 = L2_2.Notify
L3_2 = A0_2
L4_2 = Locale
L4_2 = L4_2.noEmptyNitrousBottlesToReplace
L5_2 = "error"
L2_2(L3_2, L4_2, L5_2)
L2_2 = false
do return L2_2 end
::lbl_24::
L2_2 = true
return L2_2
end
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
if not A1_2 or 0 == A1_2 then
L2_2 = false
return L2_2
end
L2_2 = Entity
L3_2 = A1_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L3_2 = L0_1
L4_2 = A0_2
L5_2 = L2_2
L3_2 = L3_2(L4_2, L5_2)
if not L3_2 then
L3_2 = false
return L3_2
end
L3_2 = L1_1
L4_2 = A0_2
L5_2 = L2_2
L3_2 = L3_2(L4_2, L5_2)
if not L3_2 then
L3_2 = false
return L3_2
end
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.RemoveItem
L4_2 = A0_2
L5_2 = "nitrous_bottle"
L3_2 = L3_2(L4_2, L5_2)
if not L3_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.couldNotRemoveNitrousInvItem
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = setVehicleStatebag
L5_2 = A1_2
L6_2 = "nitrousFilledBottles"
L7_2 = L2_2.nitrousFilledBottles
L7_2 = L7_2 + 1
L8_2 = true
L4_2(L5_2, L6_2, L7_2, L8_2)
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.GiveItem
L5_2 = A0_2
L6_2 = "empty_nitrous_bottle"
L4_2 = L4_2(L5_2, L6_2)
if not L4_2 then
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.Notify
L6_2 = A0_2
L7_2 = Locale
L7_2 = L7_2.couldNotGiveNitrousInvItem
L8_2 = "error"
L5_2(L6_2, L7_2, L8_2)
L5_2 = false
return L5_2
end
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.Notify
L6_2 = A0_2
L7_2 = Locale
L7_2 = L7_2.nitrousBottleInstalled
L8_2 = "success"
L5_2(L6_2, L7_2, L8_2)
L5_2 = true
return L5_2
end
L3_1 = RegisterNetEvent
L4_1 = "jg-mechanic:server:use-nitrous-bottle"
function L5_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
L0_2 = source
L1_2 = GetPlayerPed
L2_2 = source
L1_2 = L1_2(L2_2)
L2_2 = GetVehiclePedIsIn
L3_2 = L1_2
L4_2 = false
L2_2 = L2_2(L3_2, L4_2)
if L2_2 and 0 ~= L2_2 then
L3_2 = GetPedInVehicleSeat
L4_2 = L2_2
L5_2 = -1
L3_2 = L3_2(L4_2, L5_2)
if L3_2 == L1_2 then
goto lbl_28
end
end
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.Notify
L4_2 = L0_2
L5_2 = Locale
L5_2 = L5_2.notInsideVehicle
L6_2 = "error"
do return L3_2(L4_2, L5_2, L6_2) end
::lbl_28::
L3_2 = L2_1
L4_2 = L0_2
L5_2 = L2_2
L3_2(L4_2, L5_2)
end
L3_1(L4_1, L5_1)
L3_1 = lib
L3_1 = L3_1.callback
L3_1 = L3_1.register
L4_1 = "jg-mechanic:server:can-refill-bottle-in-current-vehicle"
function L5_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
L1_2 = GetPlayerPed
L2_2 = source
L1_2 = L1_2(L2_2)
L2_2 = GetVehiclePedIsIn
L3_2 = L1_2
L4_2 = false
L2_2 = L2_2(L3_2, L4_2)
if L2_2 and 0 ~= L2_2 then
L3_2 = GetPedInVehicleSeat
L4_2 = L2_2
L5_2 = -1
L3_2 = L3_2(L4_2, L5_2)
if L3_2 == L1_2 then
goto lbl_28
end
end
L3_2 = Framework
L3_2 = L3_2.Server
L3_2 = L3_2.Notify
L4_2 = A0_2
L5_2 = Locale
L5_2 = L5_2.notInsideVehicle
L6_2 = "error"
L3_2(L4_2, L5_2, L6_2)
L3_2 = false
do return L3_2 end
::lbl_28::
L3_2 = Entity
L4_2 = L2_2
L3_2 = L3_2(L4_2)
L3_2 = L3_2.state
L4_2 = L0_1
L5_2 = A0_2
L6_2 = L3_2
L4_2 = L4_2(L5_2, L6_2)
if not L4_2 then
L4_2 = false
return L4_2
end
L4_2 = L1_1
L5_2 = A0_2
L6_2 = L3_2
L4_2 = L4_2(L5_2, L6_2)
if not L4_2 then
L4_2 = false
return L4_2
end
L4_2 = true
return L4_2
end
L3_1(L4_1, L5_1)
L3_1 = lib
L3_1 = L3_1.callback
L3_1 = L3_1.register
L4_1 = "jg-mechanic:server:refill-nitrous-bottle"
function L5_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L1_2 = Player
L2_2 = A0_2
L1_2 = L1_2(L2_2)
L1_2 = L1_2.state
if not L1_2 then
L2_2 = false
return L2_2
end
L2_2 = L1_2.mechanicId
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = L2_2
L6_2 = {}
L7_2 = "mechanic"
L8_2 = "manager"
L6_2[1] = L7_2
L6_2[2] = L8_2
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.employeePermissionsError
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = L1_2.tabletConnectedVehicle
if L4_2 then
L4_2 = L4_2.netId
end
L5_2 = NetworkGetEntityFromNetworkId
L6_2 = L4_2
L5_2 = L5_2(L6_2)
if not L5_2 or 0 == L5_2 then
L6_2 = false
return L6_2
end
L6_2 = L2_1
L7_2 = A0_2
L8_2 = L5_2
return L6_2(L7_2, L8_2)
end
L3_1(L4_1, L5_1)
L3_1 = lib
L3_1 = L3_1.callback
L3_1 = L3_1.register
L4_1 = "jg-mechanic:server:install-new-bottle"
function L5_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
L1_2 = Player
L2_2 = A0_2
L1_2 = L1_2(L2_2)
L1_2 = L1_2.state
if not L1_2 then
L2_2 = false
return L2_2
end
L2_2 = L1_2.mechanicId
if not L2_2 then
L3_2 = false
return L3_2
end
L3_2 = isEmployee
L4_2 = A0_2
L5_2 = L2_2
L6_2 = {}
L7_2 = "mechanic"
L8_2 = "manager"
L6_2[1] = L7_2
L6_2[2] = L8_2
L7_2 = true
L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2)
if not L3_2 then
L4_2 = Framework
L4_2 = L4_2.Server
L4_2 = L4_2.Notify
L5_2 = A0_2
L6_2 = Locale
L6_2 = L6_2.employeePermissionsError
L7_2 = "error"
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = L1_2.tabletConnectedVehicle
if L4_2 then
L4_2 = L4_2.netId
end
L5_2 = NetworkGetEntityFromNetworkId
L6_2 = L4_2
L5_2 = L5_2(L6_2)
if not L5_2 or 0 == L5_2 then
L6_2 = false
return L6_2
end
L6_2 = Entity
L7_2 = L5_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
L7_2 = L6_2.nitrousInstalledBottles
if L7_2 then
L7_2 = L6_2.nitrousInstalledBottles
L8_2 = Config
L8_2 = L8_2.NitrousMaxBottlesPerVehicle
if L7_2 >= L8_2 then
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.Notify
L8_2 = A0_2
L9_2 = Locale
L9_2 = L9_2.maxBottlesInstalled
L10_2 = "error"
L7_2(L8_2, L9_2, L10_2)
L7_2 = false
return L7_2
end
end
L7_2 = Framework
L7_2 = L7_2.Server
L7_2 = L7_2.RemoveItem
L8_2 = A0_2
L9_2 = "nitrous_install_kit"
L7_2 = L7_2(L8_2, L9_2)
if not L7_2 then
L8_2 = Framework
L8_2 = L8_2.Server
L8_2 = L8_2.Notify
L9_2 = A0_2
L10_2 = Locale
L10_2 = L10_2.couldNotRemoveNitrousInstallInvItem
L11_2 = "error"
L8_2(L9_2, L10_2, L11_2)
L8_2 = false
return L8_2
end
L8_2 = L6_2.nitrousInstalledBottles
if L8_2 then
L8_2 = L6_2.nitrousInstalledBottles
L8_2 = L8_2 + 1
if L8_2 then
goto lbl_98
end
end
L8_2 = 1
::lbl_98::
L9_2 = setVehicleStatebag
L10_2 = L5_2
L11_2 = "nitrousInstalledBottles"
L12_2 = L8_2
L13_2 = true
L9_2(L10_2, L11_2, L12_2, L13_2)
L9_2 = L6_2.nitrousFilledBottles
if L9_2 then
L9_2 = L6_2.nitrousFilledBottles
L9_2 = L9_2 + 1
if L9_2 then
goto lbl_113
end
end
L9_2 = 1
::lbl_113::
L10_2 = setVehicleStatebag
L11_2 = L5_2
L12_2 = "nitrousFilledBottles"
L13_2 = L9_2
L14_2 = true
L10_2(L11_2, L12_2, L13_2, L14_2)
L10_2 = true
return L10_2
end
L3_1(L4_1, L5_1)