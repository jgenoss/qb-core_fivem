local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1
L0_1 = false
L1_1 = false
L2_1 = false
L3_1 = 0
function L4_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
L2_2 = GetPedInVehicleSeat
L3_2 = A1_2
L4_2 = -1
L2_2 = L2_2(L3_2, L4_2)
L2_2 = IsEntityInWater
L3_2 = A1_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2 == A0_2 and L2_2
return L2_2
end
function L5_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2
L2_2 = isVehicleElectric
L3_2 = GetEntityArchetypeName
L4_2 = A0_2
L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2 = L3_2(L4_2)
L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2)
if L2_2 then
return
end
L2_2 = L1_1
if L2_2 then
return
end
L2_2 = true
L1_1 = L2_2
L2_2 = {}
L3_2 = "taillight_l"
L4_2 = "taillight_r"
L2_2[1] = L3_2
L2_2[2] = L4_2
L3_2 = "veh_light_red_trail"
L4_2 = 1.0
L5_2 = RequestNamedPtfxAsset
L6_2 = "veh_xs_vehicle_mods"
L5_2(L6_2)
while true do
L5_2 = HasNamedPtfxAssetLoaded
L6_2 = "veh_xs_vehicle_mods"
L5_2 = L5_2(L6_2)
if L5_2 then
break
end
L5_2 = Wait
L6_2 = 1
L5_2(L6_2)
end
L5_2 = SetVehicleNitroEnabled
L6_2 = A0_2
L7_2 = true
L5_2(L6_2, L7_2)
L5_2 = SetVehicleRocketBoostPercentage
L6_2 = A0_2
L7_2 = 100
L5_2(L6_2, L7_2)
L5_2 = SetVehicleRocketBoostRefillTime
L6_2 = A0_2
L7_2 = 0.1
L5_2(L6_2, L7_2)
L5_2 = SetVehicleRocketBoostActive
L6_2 = A0_2
L7_2 = true
L5_2(L6_2, L7_2)
L5_2 = SetVehicleBoostActive
L6_2 = A0_2
L7_2 = true
L5_2(L6_2, L7_2)
if not A1_2 then
L5_2 = Config
L5_2 = L5_2.NitrousScreenEffects
if L5_2 then
L5_2 = SetTimecycleModifier
L6_2 = "RaceTurboFlash"
L5_2(L6_2)
L5_2 = SetTimecycleModifierStrength
L6_2 = 0.8
L5_2(L6_2)
L5_2 = ShakeGameplayCam
L6_2 = "SKY_DIVING_SHAKE"
L7_2 = 0.25
L5_2(L6_2, L7_2)
end
L5_2 = Config
L5_2 = L5_2.NitrousRearLightTrails
if L5_2 then
L5_2 = ipairs
L6_2 = L2_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
L11_2 = GetEntityBoneIndexByName
L12_2 = A0_2
L13_2 = L10_2
L11_2 = L11_2(L12_2, L13_2)
L12_2 = UseParticleFxAssetNextCall
L13_2 = "core"
L12_2(L13_2)
L12_2 = StartParticleFxLoopedOnEntityBone
L13_2 = L3_2
L14_2 = A0_2
L15_2 = 0.0
L16_2 = 0.0
L17_2 = 0.0
L18_2 = 0.0
L19_2 = 0.0
L20_2 = 0.0
L21_2 = L11_2
L22_2 = L4_2
L23_2 = false
L24_2 = false
L25_2 = false
L12_2 = L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2)
L13_2 = SetParticleFxLoopedEvolution
L14_2 = L12_2
L15_2 = "speed"
L16_2 = 2.0
L17_2 = false
L13_2(L14_2, L15_2, L16_2, L17_2)
end
end
L5_2 = Entity
L6_2 = A0_2
L5_2 = L5_2(L6_2)
L5_2 = L5_2.state
L6_2 = L5_2
L5_2 = L5_2.set
L7_2 = "nitrousFx"
L8_2 = "nitrous"
L9_2 = true
L5_2(L6_2, L7_2, L8_2, L9_2)
end
L5_2 = CreateThread
function L6_2()
local L0_3, L1_3, L2_3
while true do
L0_3 = A1_2
if L0_3 then
break
end
L0_3 = L1_1
if not L0_3 then
break
end
L0_3 = SetVehicleCheatPowerIncrease
L1_3 = A0_2
L2_3 = Config
L2_3 = L2_3.NitrousPowerIncreaseMult
if not L2_3 then
L2_3 = 2.0
end
L0_3(L1_3, L2_3)
L0_3 = Wait
L1_3 = 0
L0_3(L1_3)
end
end
L5_2(L6_2)
end
function L6_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = false
L1_1 = L2_2
L2_2 = SetVehicleNitroEnabled
L3_2 = A0_2
L4_2 = false
L2_2(L3_2, L4_2)
L2_2 = SetVehicleRocketBoostActive
L3_2 = A0_2
L4_2 = false
L2_2(L3_2, L4_2)
L2_2 = SetVehicleBoostActive
L3_2 = A0_2
L4_2 = false
L2_2(L3_2, L4_2)
L2_2 = SetVehicleCheatPowerIncrease
L3_2 = A0_2
L4_2 = 1.0
L2_2(L3_2, L4_2)
if not A1_2 then
L2_2 = Config
L2_2 = L2_2.NitrousScreenEffects
if L2_2 then
L2_2 = ClearTimecycleModifier
L2_2()
L2_2 = StopGameplayCamShaking
L3_2 = true
L2_2(L3_2)
end
L2_2 = Config
L2_2 = L2_2.NitrousRearLightTrails
if L2_2 then
L2_2 = RemoveParticleFxFromEntity
L3_2 = A0_2
L2_2(L3_2)
end
L2_2 = Entity
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L3_2 = L2_2
L2_2 = L2_2.set
L4_2 = "nitrousFx"
L5_2 = false
L6_2 = true
L2_2(L3_2, L4_2, L5_2, L6_2)
end
end
function L7_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2
L2_2 = L2_1
if L2_2 then
return
end
L2_2 = true
L2_1 = L2_2
L2_2 = RemoveParticleFxFromEntity
L3_2 = A0_2
L2_2(L3_2)
L2_2 = {}
L3_2 = "wheel_lf"
L4_2 = "wheel_rf"
L2_2[1] = L3_2
L2_2[2] = L4_2
L3_2 = 1.0
L4_2 = "ent_sht_steam"
L5_2 = ipairs
L6_2 = L2_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
L11_2 = GetEntityBoneIndexByName
L12_2 = A0_2
L13_2 = L10_2
L11_2 = L11_2(L12_2, L13_2)
L12_2 = GetWorldPositionOfEntityBone
L13_2 = A0_2
L14_2 = L11_2
L12_2 = L12_2(L13_2, L14_2)
L13_2 = GetOffsetFromEntityGivenWorldCoords
L14_2 = A0_2
L15_2 = L12_2.x
L16_2 = L12_2.y
L17_2 = L12_2.z
L13_2 = L13_2(L14_2, L15_2, L16_2, L17_2)
L14_2 = UseParticleFxAssetNextCall
L15_2 = "core"
L14_2(L15_2)
L14_2 = StartParticleFxLoopedOnEntity
L15_2 = L4_2
L16_2 = A0_2
L17_2 = L13_2.x
L17_2 = L17_2 + 0.03
L18_2 = L13_2.y
L18_2 = L18_2 + 0.1
L19_2 = L13_2.z
L19_2 = L19_2 + 0.2
L20_2 = 20.0
L21_2 = 0.0
L22_2 = 0.5
L23_2 = L3_2
L24_2 = false
L25_2 = false
L26_2 = false
L14_2(L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
end
L5_2 = SetVehicleBoostActive
L6_2 = A0_2
L7_2 = true
L5_2(L6_2, L7_2)
if not A1_2 then
L5_2 = Entity
L6_2 = A0_2
L5_2 = L5_2(L6_2)
L5_2 = L5_2.state
L6_2 = L5_2
L5_2 = L5_2.set
L7_2 = "nitrousFx"
L8_2 = "purge"
L9_2 = true
L5_2(L6_2, L7_2, L8_2, L9_2)
end
end
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = false
L2_1 = L2_2
L2_2 = RemoveParticleFxFromEntity
L3_2 = A0_2
L2_2(L3_2)
L2_2 = SetVehicleBoostActive
L3_2 = A0_2
L4_2 = false
L2_2(L3_2, L4_2)
if not A1_2 then
L2_2 = Entity
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L3_2 = L2_2
L2_2 = L2_2.set
L4_2 = "nitrousFx"
L5_2 = false
L6_2 = true
L2_2(L3_2, L4_2, L5_2, L6_2)
end
end
function L9_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2
L4_2 = Entity
L5_2 = A0_2
L4_2 = L4_2(L5_2)
L4_2 = L4_2.state
if not L4_2 then
return
end
L5_2 = SendNUIMessage
L6_2 = {}
L7_2 = {}
L7_2.using = A1_2
L7_2.cooldown = A2_2
L8_2 = L4_2.nitrousInstalledBottles
L7_2.installedBottles = L8_2
L8_2 = L4_2.nitrousFilledBottles
L7_2.filledBottles = L8_2
L7_2.capacity = A3_2
L8_2 = Config
L8_2 = L8_2.NitrousBottleDuration
L7_2.maxCapacity = L8_2
L8_2 = L4_2.nitrousFilledBottles
L8_2 = 0 == L8_2 and A3_2 <= 0
L7_2.empty = L8_2
L6_2.nitrousHudData = L7_2
L5_2(L6_2)
end
L10_1 = RegisterCommand
L11_1 = "+nitrousKeymap"
function L12_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
L0_2 = cache
L0_2 = L0_2.ped
L1_2 = GetVehiclePedIsIn
L2_2 = cache
L2_2 = L2_2.ped
L3_2 = false
L1_2 = L1_2(L2_2, L3_2)
if not L1_2 then
return
end
L2_2 = Entity
L3_2 = L1_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L3_2 = L2_2.nitrousInstalledBottles
if L3_2 then
L3_2 = L2_2.nitrousInstalledBottles
if 0 ~= L3_2 then
goto lbl_22
end
end
do return end
::lbl_22::
L3_2 = L2_2.nitrousCooldown
if L3_2 then
L3_2 = L9_1
L4_2 = L1_2
L5_2 = false
L6_2 = true
L7_2 = 0
return L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = L2_2.nitrousFilledBottles
if 0 == L3_2 then
L3_2 = L2_2.nitrousCapacity
if L3_2 <= 0 then
L3_2 = L9_1
L4_2 = L1_2
L5_2 = false
L6_2 = false
L7_2 = 0
return L3_2(L4_2, L5_2, L6_2, L7_2)
end
end
L3_2 = true
L0_1 = L3_2
L3_2 = L2_2.nitrousCapacity
if not L3_2 then
L3_2 = 0.0
end
L4_2 = L2_2.nitrousFilledBottles
if L3_2 <= 0 and L4_2 > 0 then
L5_2 = Config
L5_2 = L5_2.NitrousBottleDuration
if not L5_2 then
L5_2 = 10.0
end
L4_2 = L4_2 - 1
L3_2 = L5_2
L5_2 = setVehicleStatebag
L6_2 = L1_2
L7_2 = "nitrousCapacity"
L8_2 = L3_2
L9_2 = false
L5_2(L6_2, L7_2, L8_2, L9_2)
L5_2 = setVehicleStatebag
L6_2 = L1_2
L7_2 = "nitrousFilledBottles"
L8_2 = L4_2
L9_2 = true
L5_2(L6_2, L7_2, L8_2, L9_2)
end
L5_2 = CreateThread
function L6_2()
local L0_3, L1_3, L2_3, L3_3, L4_3
while true do
L0_3 = L0_1
if not L0_3 then
break
end
L0_3 = L4_1
L1_3 = L0_2
L2_3 = L1_2
L0_3 = L0_3(L1_3, L2_3)
if not L0_3 then
break
end
L0_3 = L3_2
if not (L0_3 > 0) then
break
end
L0_3 = L1_2
L3_1 = L0_3
L0_3 = IsControlPressed
L1_3 = 0
L2_3 = 71
L0_3 = L0_3(L1_3, L2_3)
if not L0_3 then
L0_3 = GetVehicleThrottleOffset
L1_3 = L1_2
L0_3 = L0_3(L1_3)
L1_3 = 0.05
if not (L0_3 > L1_3) then
goto lbl_52
end
end
L0_3 = L2_1
if L0_3 then
L0_3 = L8_1
L1_3 = L1_2
L2_3 = false
L0_3(L1_3, L2_3)
end
L0_3 = L5_1
L1_3 = L1_2
L2_3 = false
L0_3(L1_3, L2_3)
L0_3 = round
L1_3 = L3_2
L1_3 = L1_3 - 0.1
L2_3 = 2
L0_3 = L0_3(L1_3, L2_3)
L3_2 = L0_3
L0_3 = L9_1
L1_3 = L1_2
L2_3 = true
L3_3 = false
L4_3 = L3_2
L0_3(L1_3, L2_3, L3_3, L4_3)
goto lbl_83
::lbl_52::
L0_3 = L1_1
if L0_3 then
L0_3 = L6_1
L1_3 = L1_2
L2_3 = false
L0_3(L1_3, L2_3)
end
L0_3 = L7_1
L1_3 = L1_2
L2_3 = false
L0_3(L1_3, L2_3)
L0_3 = round
L1_3 = L3_2
L2_3 = Config
L2_3 = L2_3.NitrousPurgeDrainRate
if not L2_3 then
L2_3 = 1
end
L2_3 = 0.1 * L2_3
L1_3 = L1_3 - L2_3
L2_3 = 2
L0_3 = L0_3(L1_3, L2_3)
L3_2 = L0_3
L0_3 = L9_1
L1_3 = L1_2
L2_3 = true
L3_3 = false
L4_3 = L3_2
L0_3(L1_3, L2_3, L3_3, L4_3)
::lbl_83::
L0_3 = Wait
L1_3 = 100
L0_3(L1_3)
end
L0_3 = L6_1
L1_3 = L1_2
L2_3 = false
L0_3(L1_3, L2_3)
L0_3 = L8_1
L1_3 = L1_2
L2_3 = false
L0_3(L1_3, L2_3)
L0_3 = L3_2
if L0_3 < 0 then
L0_3 = 0
L3_2 = L0_3
end
L0_3 = setVehicleStatebag
L1_3 = L1_2
L2_3 = "nitrousCapacity"
L3_3 = L3_2
L4_3 = true
L0_3(L1_3, L2_3, L3_3, L4_3)
L0_3 = L3_2
if L0_3 <= 0 then
L0_3 = setVehicleStatebag
L1_3 = L1_2
L2_3 = "nitrousCooldown"
L3_3 = true
L0_3(L1_3, L2_3, L3_3)
L0_3 = L9_1
L1_3 = L1_2
L2_3 = false
L3_3 = true
L4_3 = 0
L0_3(L1_3, L2_3, L3_3, L4_3)
L0_3 = CreateThread
function L1_3()
local L0_4, L1_4, L2_4, L3_4, L4_4
L0_4 = Wait
L1_4 = Config
L1_4 = L1_4.NitrousBottleCooldown
L1_4 = L1_4 * 1000
L0_4(L1_4)
L0_4 = setVehicleStatebag
L1_4 = L1_2
L2_4 = "nitrousCooldown"
L3_4 = false
L0_4(L1_4, L2_4, L3_4)
L0_4 = L9_1
L1_4 = L1_2
L2_4 = false
L3_4 = false
L4_4 = 0
L0_4(L1_4, L2_4, L3_4, L4_4)
end
L0_3(L1_3)
end
end
L5_2(L6_2)
end
L13_1 = false
L10_1(L11_1, L12_1, L13_1)
L10_1 = RegisterCommand
L11_1 = "-nitrousKeymap"
function L12_1()
local L0_2, L1_2, L2_2, L3_2, L4_2
L0_2 = GetVehiclePedIsIn
L1_2 = cache
L1_2 = L1_2.ped
L2_2 = false
L0_2 = L0_2(L1_2, L2_2)
if not L0_2 then
return
end
L1_2 = Entity
L2_2 = L0_2
L1_2 = L1_2(L2_2)
L1_2 = L1_2.state
L2_2 = L1_2.nitrousInstalledBottles
if L2_2 then
L2_2 = L1_2.nitrousInstalledBottles
if 0 ~= L2_2 then
goto lbl_20
end
end
do return end
::lbl_20::
L2_2 = L0_1
if L2_2 then
L2_2 = false
L0_1 = L2_2
L2_2 = L6_1
L3_2 = L0_2
L4_2 = false
L2_2(L3_2, L4_2)
L2_2 = L8_1
L3_2 = L0_2
L4_2 = false
L2_2(L3_2, L4_2)
end
end
L13_1 = false
L10_1(L11_1, L12_1, L13_1)
L10_1 = RegisterKeyMapping
L11_1 = "+nitrousKeymap"
L12_1 = "Use installed nitrous"
L13_1 = "keyboard"
L14_1 = Config
L14_1 = L14_1.NitrousDefaultKeyMapping
L10_1(L11_1, L12_1, L13_1, L14_1)
L10_1 = AddStateBagChangeHandler
L11_1 = "nitrousFx"
L12_1 = ""
function L13_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2
L3_2 = GetEntityFromStateBagName
L4_2 = A0_2
L3_2 = L3_2(L4_2)
if 0 ~= L3_2 then
L4_2 = DoesEntityExist
L5_2 = L3_2
L4_2 = L4_2(L5_2)
if L4_2 then
goto lbl_12
end
end
do return end
::lbl_12::
L4_2 = L3_1
if L3_2 == L4_2 then
return
end
if "nitrous" == A2_2 then
L4_2 = L5_1
L5_2 = L3_2
L6_2 = true
L4_2(L5_2, L6_2)
elseif "purge" == A2_2 then
L4_2 = L7_1
L5_2 = L3_2
L6_2 = true
L4_2(L5_2, L6_2)
else
L4_2 = L6_1
L5_2 = L3_2
L6_2 = true
L4_2(L5_2, L6_2)
L4_2 = L8_1
L5_2 = L3_2
L6_2 = true
L4_2(L5_2, L6_2)
end
end
L10_1(L11_1, L12_1, L13_1)
L10_1 = RegisterNUICallback
L11_1 = "install-new-bottle"
function L12_1(A0_2, A1_2)
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
L3_2 = GetEntityModel
L4_2 = L2_2
L3_2 = L3_2(L4_2)
L4_2 = IsThisModelACar
L5_2 = L3_2
L4_2 = L4_2(L5_2)
if not L4_2 then
L4_2 = IsThisModelAQuadbike
L5_2 = L3_2
L4_2 = L4_2(L5_2)
if not L4_2 then
L4_2 = A1_2
L5_2 = false
return L4_2(L5_2)
end
end
L4_2 = isVehicleElectric
L5_2 = GetEntityArchetypeName
L6_2 = L2_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
if L4_2 then
L4_2 = A1_2
L5_2 = false
return L4_2(L5_2)
end
L4_2 = playMinigame
L5_2 = L2_2
L6_2 = "prop"
L7_2 = {}
L7_2.prop = "canister"
function L8_2(A0_3)
local L1_3, L2_3, L3_3, L4_3
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
L2_3 = "jg-mechanic:server:install-new-bottle"
L3_3 = false
L1_3 = L1_3(L2_3, L3_3)
if not L1_3 then
L2_3 = A1_2
L3_3 = false
return L2_3(L3_3)
end
L2_3 = Framework
L2_3 = L2_3.Client
L2_3 = L2_3.Notify
L3_3 = Locale
L3_3 = L3_3.nitrousBottleInstalled
L4_3 = "success"
L2_3(L3_3, L4_3)
L2_3 = A1_2
L3_3 = true
L2_3(L3_3)
end
L4_2(L5_2, L6_2, L7_2, L8_2)
end
L10_1(L11_1, L12_1)
L10_1 = RegisterNUICallback
L11_1 = "refill-bottle"
function L12_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L2_2 = Framework
L2_2 = L2_2.Client
L2_2 = L2_2.ProgressBar
L3_2 = Locale
L3_2 = L3_2.refillingBottle
L4_2 = 5000
L5_2 = false
L6_2 = false
function L7_2()
local L0_3, L1_3, L2_3, L3_3
L0_3 = A1_2
L1_3 = lib
L1_3 = L1_3.callback
L1_3 = L1_3.await
L2_3 = "jg-mechanic:server:refill-nitrous-bottle"
L3_3 = false
L1_3, L2_3, L3_3 = L1_3(L2_3, L3_3)
L0_3(L1_3, L2_3, L3_3)
end
function L8_2()
local L0_3, L1_3
L0_3 = A1_2
L1_3 = false
L0_3(L1_3)
end
L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2)
end
L10_1(L11_1, L12_1)
L10_1 = RegisterNetEvent
L11_1 = "jg-mechanic:client:use-nitrous-bottle"
function L12_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L0_2 = lib
L0_2 = L0_2.callback
L0_2 = L0_2.await
L1_2 = "jg-mechanic:server:can-refill-bottle-in-current-vehicle"
L2_2 = false
L0_2 = L0_2(L1_2, L2_2)
if not L0_2 then
return
end
L1_2 = Framework
L1_2 = L1_2.Client
L1_2 = L1_2.ProgressBar
L2_2 = Locale
L2_2 = L2_2.refillingBottle
L3_2 = 2500
L4_2 = false
L5_2 = false
function L6_2()
local L0_3, L1_3
L0_3 = TriggerServerEvent
L1_3 = "jg-mechanic:server:use-nitrous-bottle"
L0_3(L1_3)
end
function L7_2()
local L0_3, L1_3
end
L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2)
end
L10_1(L11_1, L12_1)