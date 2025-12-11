local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
L0_1 = false
function L1_1(A0_2)
local L1_2, L2_2
L1_2 = Globals
L1_2 = L1_2.HoldingTablet
if L1_2 then
L1_2 = stopTabletAnim
L1_2()
L1_2 = true
L0_1 = L1_2
end
L1_2 = TriggerEvent
L2_2 = "jg-mechanic:client:tablet-hidden-for-interaction"
L1_2(L2_2)
L1_2 = SendNUIMessage
L2_2 = {}
L2_2.instructionText = A0_2
L1_2(L2_2)
end
hideTabletToShowInteractionPrompt = L1_1
function L1_1()
local L0_2, L1_2
L0_2 = L0_1
if L0_2 then
L0_2 = playTabletAnim
L0_2()
L0_2 = false
L0_1 = L0_2
end
L0_2 = TriggerEvent
L1_2 = "jg-mechanic:client:tablet-shown-after-interaction"
L0_2(L1_2)
L0_2 = SendNUIMessage
L1_2 = {}
L1_2.instructionText = false
L0_2(L1_2)
end
showTabletAfterInteractionPrompt = L1_1
function L1_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
if not A0_2 then
L1_2 = false
return L1_2
end
L1_2 = A0_2.netId
L2_2 = A0_2.plate
while true do
L3_2 = NetworkGetEntityFromNetworkId
L4_2 = L1_2
L3_2 = L3_2(L4_2)
if L3_2 then
break
end
L3_2 = Wait
L4_2 = 0
L3_2(L4_2)
end
L3_2 = NetToVeh
L4_2 = L1_2
L3_2 = L3_2(L4_2)
L4_2 = DoesEntityExist
L5_2 = L3_2
L4_2 = L4_2(L5_2)
if not L4_2 then
L4_2 = false
return L4_2
end
L4_2 = GetEntitySpeed
L5_2 = L3_2
L4_2 = L4_2(L5_2)
if L4_2 > 1.0 then
L4_2 = Framework
L4_2 = L4_2.Client
L4_2 = L4_2.Notify
L5_2 = Locale
L5_2 = L5_2.stopVehicleFirst
L6_2 = "error"
L4_2(L5_2, L6_2)
L4_2 = false
return L4_2
end
L4_2 = lib
L4_2 = L4_2.callback
L4_2 = L4_2.await
L5_2 = "jg-mechanic:server:connect-vehicle"
L6_2 = false
L7_2 = L2_2
L8_2 = L1_2
L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
if not L4_2 then
L4_2 = Framework
L4_2 = L4_2.Client
L4_2 = L4_2.Notify
L5_2 = "Another mechanic is connected to this vehicle"
L6_2 = "error"
L4_2(L5_2, L6_2)
L4_2 = false
return L4_2
end
L4_2 = FreezeEntityPosition
L5_2 = L3_2
L6_2 = true
L4_2(L5_2, L6_2)
A0_2.vehicleEntity = L3_2
L4_2 = LocalPlayer
L4_2 = L4_2.state
L5_2 = L4_2
L4_2 = L4_2.set
L6_2 = "tabletConnectedVehicle"
L7_2 = A0_2
L8_2 = true
L4_2(L5_2, L6_2, L7_2, L8_2)
L4_2 = Entity
L5_2 = L3_2
L4_2 = L4_2(L5_2)
L4_2 = L4_2.state
L5_2 = GetEntityModel
L6_2 = L3_2
L5_2 = L5_2(L6_2)
L6_2 = IsThisModelACar
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if not L6_2 then
L6_2 = IsThisModelAQuadbike
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if not L6_2 then
goto lbl_90
end
end
L6_2 = "car"
::lbl_90::
if not L6_2 then
L6_2 = IsThisModelABike
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if L6_2 then
L6_2 = "bike"
if L6_2 then
goto lbl_99
end
end
L6_2 = "other"
end
::lbl_99::
L7_2 = getVehicleTuningConfig
L8_2 = L3_2
L9_2 = L4_2.tuningConfig
L7_2 = L7_2(L8_2, L9_2)
L8_2 = {}
L8_2.vehicleType = L6_2
L9_2 = GetEntityArchetypeName
L10_2 = L3_2
L9_2 = L9_2(L10_2)
L8_2.archetypeName = L9_2
L9_2 = isVehicleElectric
L10_2 = GetEntityArchetypeName
L11_2 = L3_2
L10_2, L11_2 = L10_2(L11_2)
L9_2 = L9_2(L10_2, L11_2)
L8_2.isVehicleElectric = L9_2
L8_2.tuningConfig = L7_2
L9_2 = L4_2.servicingData
L8_2.servicingData = L9_2
L9_2 = {}
L10_2 = L4_2.nitrousInstalledBottles
L9_2.installedBottles = L10_2
L10_2 = L4_2.nitrousFilledBottles
L9_2.filledBottles = L10_2
L10_2 = L4_2.nitrousCapacity
if L10_2 then
L10_2 = L4_2.nitrousCapacity
L10_2 = L10_2 * 10
if L10_2 then
goto lbl_134
end
end
L10_2 = 0
::lbl_134::
L9_2.activeBtlCapacity = L10_2
L8_2.nitrousData = L9_2
return L8_2
end
ConnectVehicle = L1_1
function L1_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
L0_2 = LocalPlayer
L0_2 = L0_2.state
L0_2 = L0_2.tabletConnectedVehicle
if not L0_2 then
L1_2 = false
return L1_2
end
L1_2 = L0_2.vehicleEntity
if L1_2 then
L2_2 = DoesEntityExist
L3_2 = L1_2
L2_2 = L2_2(L3_2)
if L2_2 then
L2_2 = FreezeEntityPosition
L3_2 = L1_2
L4_2 = false
L2_2(L3_2, L4_2)
end
end
L2_2 = lib
L2_2 = L2_2.callback
L2_2 = L2_2.await
L3_2 = "jg-mechanic:server:disconnect-vehicle"
L4_2 = false
L5_2 = L0_2.plate
L2_2(L3_2, L4_2, L5_2)
L2_2 = LocalPlayer
L2_2 = L2_2.state
L3_2 = L2_2
L2_2 = L2_2.set
L4_2 = "tabletConnectedVehicle"
L5_2 = nil
L6_2 = true
L2_2(L3_2, L4_2, L5_2, L6_2)
L2_2 = true
return L2_2
end
DisconnectVehicle = L1_1
function L1_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
L0_2 = cache
L0_2 = L0_2.ped
L1_2 = {}
L2_2 = GetEntityCoords
L3_2 = L0_2
L2_2 = L2_2(L3_2)
L3_2 = Config
L3_2 = L3_2.TabletConnectionMaxDistance
if not L3_2 then
L3_2 = 4.0
end
L4_2 = lib
L4_2 = L4_2.getNearbyVehicles
L5_2 = L2_2
L6_2 = L3_2
L7_2 = true
L4_2 = L4_2(L5_2, L6_2, L7_2)
if not L4_2 then
L4_2 = {}
end
L5_2 = ipairs
L6_2 = L4_2
L5_2, L6_2, L7_2, L8_2 = L5_2(L6_2)
for L9_2, L10_2 in L5_2, L6_2, L7_2, L8_2 do
L11_2 = Framework
L11_2 = L11_2.Client
L11_2 = L11_2.GetPlate
L12_2 = L10_2.vehicle
L11_2 = L11_2(L12_2)
L12_2 = lib
L12_2 = L12_2.callback
L12_2 = L12_2.await
L13_2 = "jg-mechanic:server:get-vehicle-mileage"
L14_2 = false
L15_2 = L11_2
L12_2, L13_2 = L12_2(L13_2, L14_2, L15_2)
L14_2 = #L1_2
L14_2 = L14_2 + 1
L15_2 = {}
L16_2 = VehToNet
L17_2 = L10_2.vehicle
L16_2 = L16_2(L17_2)
L15_2.netId = L16_2
L16_2 = Framework
L16_2 = L16_2.Client
L16_2 = L16_2.GetVehicleLabel
L17_2 = GetEntityArchetypeName
L18_2 = L10_2.vehicle
L17_2, L18_2 = L17_2(L18_2)
L16_2 = L16_2(L17_2, L18_2)
L15_2.label = L16_2
L16_2 = Framework
L16_2 = L16_2.Client
L16_2 = L16_2.GetPlate
L17_2 = L10_2.vehicle
L16_2 = L16_2(L17_2)
L15_2.plate = L16_2
L15_2.mileage = L12_2
L15_2.mileageUnit = L13_2
L1_2[L14_2] = L15_2
end
return L1_2
end
function L2_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
L0_2 = false
L1_2 = {}
L2_2 = lib
L2_2 = L2_2.callback
L2_2 = L2_2.await
L3_2 = "jg-mechanic:server:get-player-mechanics"
L4_2 = false
L2_2 = L2_2(L3_2, L4_2)
L3_2 = next
L4_2 = L2_2
L3_2 = L3_2(L4_2)
if nil == L3_2 then
L3_2 = Framework
L3_2 = L3_2.Client
L3_2 = L3_2.Notify
L4_2 = Locale
L4_2 = L4_2.notPartOfAnyMechanics
L5_2 = "error"
L3_2(L4_2, L5_2)
L3_2 = false
return L3_2
end
L3_2 = cache
L3_2 = L3_2.vehicle
if L3_2 then
L3_2 = cache
L3_2 = L3_2.vehicle
L4_2 = Framework
L4_2 = L4_2.Client
L4_2 = L4_2.GetPlate
L5_2 = L3_2
L4_2 = L4_2(L5_2)
L5_2 = lib
L5_2 = L5_2.callback
L5_2 = L5_2.await
L6_2 = "jg-mechanic:server:get-vehicle-mileage"
L7_2 = false
L8_2 = L4_2
L5_2, L6_2 = L5_2(L6_2, L7_2, L8_2)
L7_2 = {}
L8_2 = VehToNet
L9_2 = L3_2
L8_2 = L8_2(L9_2)
L7_2.netId = L8_2
L8_2 = Framework
L8_2 = L8_2.Client
L8_2 = L8_2.GetVehicleLabel
L9_2 = GetEntityArchetypeName
L10_2 = L3_2
L9_2, L10_2 = L9_2(L10_2)
L8_2 = L8_2(L9_2, L10_2)
L7_2.label = L8_2
L8_2 = Framework
L8_2 = L8_2.Client
L8_2 = L8_2.GetPlate
L9_2 = L3_2
L8_2 = L8_2(L9_2)
L7_2.plate = L8_2
L7_2.mileage = L5_2
L7_2.mileageUnit = L6_2
L0_2 = L7_2
L7_2 = ConnectVehicle
L8_2 = L0_2
L7_2 = L7_2(L8_2)
if not L7_2 then
L8_2 = false
return L8_2
end
L1_2 = L7_2
end
L3_2 = lib
L3_2 = L3_2.callback
L3_2 = L3_2.await
L4_2 = "jg-mechanic:server:get-tablet-preferences"
L5_2 = false
L3_2 = L3_2(L4_2, L5_2)
L4_2 = LocalPlayer
L4_2 = L4_2.state
L5_2 = L4_2
L4_2 = L4_2.set
L6_2 = "isBusy"
L7_2 = true
L8_2 = true
L4_2(L5_2, L6_2, L7_2, L8_2)
L4_2 = playTabletAnim
L4_2()
L4_2 = SetNuiFocus
L5_2 = true
L6_2 = true
L4_2(L5_2, L6_2)
L4_2 = SendNUIMessage
L5_2 = lib
L5_2 = L5_2.table
L5_2 = L5_2.merge
L6_2 = {}
L6_2.type = "show-tablet"
L7_2 = GetGameBuildNumber
L7_2 = L7_2()
if not L7_2 then
L7_2 = 0
end
L6_2.gameBuild = L7_2
L6_2.connectedVehicle = L0_2
L6_2.availableMechanics = L2_2
L7_2 = L1_1
L7_2 = L7_2()
L6_2.vehicleConnections = L7_2
L7_2 = {}
L8_2 = GetClockHours
L8_2 = L8_2()
L7_2.hours = L8_2
L8_2 = GetClockMinutes
L8_2 = L8_2()
L7_2.mins = L8_2
L6_2.gameTime = L7_2
L6_2.preferences = L3_2
L7_2 = Config
L6_2.config = L7_2
L7_2 = Locale
L6_2.locale = L7_2
L7_2 = L1_2
L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L5_2(L6_2, L7_2)
L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
end
L3_1 = RegisterNUICallback
L4_1 = "tablet-login"
function L5_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
L2_2 = A0_2.mechanicId
L3_2 = Config
L3_2 = L3_2.MechanicLocations
if L3_2 then
L3_2 = L3_2[L2_2]
end
if not L2_2 or not L3_2 then
L4_2 = A1_2
L5_2 = false
return L4_2(L5_2)
end
L4_2 = LocalPlayer
L4_2 = L4_2.state
L5_2 = L4_2
L4_2 = L4_2.set
L6_2 = "mechanicId"
L7_2 = L2_2
L8_2 = true
L4_2(L5_2, L6_2, L7_2, L8_2)
L4_2 = lib
L4_2 = L4_2.callback
L4_2 = L4_2.await
L5_2 = "jg-mechanic:server:get-tablet-mechanic-data"
L6_2 = false
L7_2 = L2_2
L4_2 = L4_2(L5_2, L6_2, L7_2)
if not L4_2 then
L5_2 = A1_2
L6_2 = {}
L6_2.error = true
return L5_2(L6_2)
end
L5_2 = A1_2
L6_2 = {}
L7_2 = Framework
L7_2 = L7_2.Client
L7_2 = L7_2.GetPlayerJobDuty
L8_2 = L2_2
L7_2 = L7_2(L8_2)
L6_2.onDuty = L7_2
L7_2 = L4_2.label
L6_2.label = L7_2
L7_2 = L4_2.balance
L6_2.balance = L7_2
L7_2 = L4_2.ownerId
L6_2.ownerId = L7_2
L7_2 = L4_2.ordersCount
L6_2.ordersCount = L7_2
L7_2 = L4_2.unpaidInvoicesCount
L6_2.unpaidInvoicesCount = L7_2
L7_2 = L4_2.employeeRole
L6_2.employeeRole = L7_2
L7_2 = L4_2.stats
L6_2.stats = L7_2
L7_2 = L3_2.tuning
L6_2.mechanicTuningConfig = L7_2
L7_2 = {}
L8_2 = Framework
L8_2 = L8_2.Client
L8_2 = L8_2.GetBalance
L9_2 = "bank"
L8_2 = L8_2(L9_2)
L7_2.bank = L8_2
L8_2 = Framework
L8_2 = L8_2.Client
L8_2 = L8_2.GetBalance
L9_2 = "cash"
L8_2 = L8_2(L9_2)
L7_2.cash = L8_2
L6_2.playerBalance = L7_2
return L5_2(L6_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "connect-vehicle"
function L5_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
L2_2 = A1_2
L3_2 = ConnectVehicle
L4_2 = A0_2.vehicle
L3_2, L4_2 = L3_2(L4_2)
L2_2(L3_2, L4_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "disconnect-vehicle"
function L5_1(A0_2, A1_2)
local L2_2, L3_2
L2_2 = A1_2
L3_2 = DisconnectVehicle
L3_2 = L3_2()
L2_2(L3_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "toggle-on-duty"
function L5_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
if not A0_2 then
L2_2 = A1_2
L3_2 = false
return L2_2(L3_2)
end
L2_2 = A0_2.toggle
L3_2 = lib
L3_2 = L3_2.callback
L3_2 = L3_2.await
L4_2 = "jg-mechanic:server:toggle-on-duty"
L5_2 = false
L6_2 = L2_2
L3_2 = L3_2(L4_2, L5_2, L6_2)
if not L3_2 then
L4_2 = A1_2
L5_2 = false
L4_2(L5_2)
end
L4_2 = Framework
L4_2 = L4_2.Client
L4_2 = L4_2.ToggleJobDuty
L5_2 = L2_2
L4_2(L5_2)
if L2_2 then
L4_2 = Framework
L4_2 = L4_2.Client
L4_2 = L4_2.Notify
L5_2 = Locale
L5_2 = L5_2.onDutyNotify
L6_2 = "success"
L4_2(L5_2, L6_2)
else
L4_2 = Framework
L4_2 = L4_2.Client
L4_2 = L4_2.Notify
L5_2 = Locale
L5_2 = L5_2.offDutyNotify
L6_2 = "success"
L4_2(L5_2, L6_2)
end
L4_2 = A1_2
L5_2 = true
L4_2(L5_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNUICallback
L4_1 = "save-preferences"
function L5_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = A0_2.preferences
if not L2_2 then
L3_2 = A1_2
L4_2 = false
return L3_2(L4_2)
end
L3_2 = lib
L3_2 = L3_2.callback
L3_2 = L3_2.await
L4_2 = "jg-mechanic:server:save-tablet-settings"
L5_2 = false
L6_2 = L2_2
L3_2 = L3_2(L4_2, L5_2, L6_2)
if not L3_2 then
L4_2 = A1_2
L5_2 = false
return L4_2(L5_2)
end
L4_2 = A1_2
L5_2 = true
L4_2(L5_2)
end
L3_1(L4_1, L5_1)
L3_1 = RegisterNetEvent
L4_1 = "jg-mechanic:client:use-tablet"
function L5_1()
local L0_2, L1_2
L0_2 = L2_1
L0_2()
end
L3_1(L4_1, L5_1)
L3_1 = AddEventHandler
L4_1 = "onResourceStop"
function L5_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
L1_2 = GetCurrentResourceName
L1_2 = L1_2()
if L1_2 == A0_2 then
L1_2 = LocalPlayer
L1_2 = L1_2.state
L1_2 = L1_2.tabletConnectedVehicle
if L1_2 then
L2_2 = L1_2.vehicleEntity
if L2_2 then
L2_2 = FreezeEntityPosition
L3_2 = L1_2.vehicleEntity
L4_2 = false
L2_2(L3_2, L4_2)
end
end
end
end
L3_1(L4_1, L5_1)