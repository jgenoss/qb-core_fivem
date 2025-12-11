local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1
L0_1 = {}
function L1_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
if not A0_2 or 0 == A0_2 then
L2_2 = false
return L2_2
end
L2_2 = Entity
L3_2 = A0_2
L2_2 = L2_2(L3_2)
L2_2 = L2_2.state
L3_2 = A1_2.primarySecondarySync
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "primarySecondarySync"
L6_2 = A1_2.primarySecondarySync
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.disablePearl
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "disablePearl"
L6_2 = A1_2.disablePearl
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.enableStance
if nil ~= L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "enableStance"
L6_2 = A1_2.enableStance
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.wheelsAdjIndv
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "wheelsAdjIndv"
L6_2 = A1_2.wheelsAdjIndv
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.stance
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "stance"
L6_2 = A1_2.stance
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.lcInstalled
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "lightingControllerInstalled"
L6_2 = A1_2.lcInstalled
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.lcXenons
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "xenons"
L6_2 = A1_2.lcXenons
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.lcUnderglowDirections
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "underglowDirections"
L6_2 = A1_2.lcUnderglowDirections
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.lcUnderglow
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "underglow"
L6_2 = A1_2.lcUnderglow
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.tuningConfig
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "tuningConfig"
L6_2 = A1_2.tuningConfig
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.servicingData
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "servicingData"
L6_2 = A1_2.servicingData
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.nitrousInstalledBottles
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "nitrousInstalledBottles"
L6_2 = A1_2.nitrousInstalledBottles
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.nitrousFilledBottles
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "nitrousFilledBottles"
L6_2 = A1_2.nitrousFilledBottles
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L3_2 = A1_2.nitrousCapacity
if L3_2 then
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "nitrousCapacity"
L6_2 = A1_2.nitrousCapacity
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L4_2 = L2_2
L3_2 = L2_2.set
L5_2 = "jgMechStatebagsApplied"
L6_2 = true
L7_2 = true
L3_2(L4_2, L5_2, L6_2, L7_2)
L3_2 = debugPrint
L4_2 = "applyStatebagData run successfully"
L5_2 = "debug"
L6_2 = Framework
L6_2 = L6_2.Server
L6_2 = L6_2.GetPlate
L7_2 = A0_2
L6_2, L7_2 = L6_2(L7_2)
L3_2(L4_2, L5_2, L6_2, L7_2)
L3_2 = true
return L3_2
end
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = L0_1
L2_2 = L2_2[A1_2]
if not L2_2 then
L3_2 = MySQL
L3_2 = L3_2.scalar
L3_2 = L3_2.await
L4_2 = "SELECT data FROM mechanic_vehicledata WHERE plate = ?"
L5_2 = {}
L6_2 = A1_2
L5_2[1] = L6_2
L3_2 = L3_2(L4_2, L5_2)
L2_2 = L3_2
if not L2_2 then
L3_2 = debugPrint
L4_2 = "Statebag data not available in cache or database - ignore if vehicle has not interacted with jg-mechanic"
L5_2 = "warning"
L6_2 = A1_2
L3_2(L4_2, L5_2, L6_2)
L3_2 = false
return L3_2
end
L3_2 = debugPrint
L4_2 = "Retrieved statebag data from database"
L5_2 = "debug"
L6_2 = A1_2
L3_2(L4_2, L5_2, L6_2)
L3_2 = L0_1
L3_2[A1_2] = L2_2
else
L3_2 = debugPrint
L4_2 = "Retrieved statebag data from cache"
L5_2 = "debug"
L6_2 = A1_2
L3_2(L4_2, L5_2, L6_2)
end
L3_2 = L1_1
L4_2 = A0_2
L5_2 = json
L5_2 = L5_2.decode
L6_2 = L2_2
L5_2, L6_2 = L5_2(L6_2)
return L3_2(L4_2, L5_2, L6_2)
end
function L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
if not A0_2 or "" == A0_2 then
L2_2 = print
L3_2 = "^1[ERROR] Trying to write to mechanic_vehicledata with an empty vehicle plate - why are your vehicle plates returning as empty strings/false?"
L2_2(L3_2)
L2_2 = false
return L2_2
end
L2_2 = L0_1
L2_2 = L2_2[A0_2]
if not L2_2 then
L2_2 = false
return L2_2
end
if A1_2 then
L2_2 = MySQL
L2_2 = L2_2.update
L2_2 = L2_2.await
L3_2 = "UPDATE mechanic_vehicledata SET data = ? WHERE plate = ?"
L4_2 = {}
L5_2 = L0_1
L5_2 = L5_2[A0_2]
L6_2 = A0_2
L4_2[1] = L5_2
L4_2[2] = L6_2
L2_2(L3_2, L4_2)
else
L2_2 = MySQL
L2_2 = L2_2.insert
L2_2 = L2_2.await
L3_2 = "INSERT INTO mechanic_vehicledata (plate, data) VALUES (?, ?) ON DUPLICATE KEY UPDATE plate = VALUES(plate), data = VALUES(data)"
L4_2 = {}
L5_2 = A0_2
L6_2 = L0_1
L6_2 = L6_2[A0_2]
L4_2[1] = L5_2
L4_2[2] = L6_2
L2_2(L3_2, L4_2)
end
L2_2 = debugPrint
L3_2 = "Statebag data saved to DB"
L4_2 = "debug"
L5_2 = A0_2
L2_2(L3_2, L4_2, L5_2)
L2_2 = true
return L2_2
end
function L4_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
if not (A0_2 and 0 ~= A0_2 and A1_2) or nil == A2_2 then
L5_2 = debugPrint
L6_2 = "Could not set statebag on vehicle - data:"
L7_2 = "warning"
L8_2 = A1_2
L9_2 = A2_2
L5_2(L6_2, L7_2, L8_2, L9_2)
L5_2 = false
return L5_2
end
L5_2 = A4_2 or L5_2
if not A4_2 then
L5_2 = Framework
L5_2 = L5_2.Server
L5_2 = L5_2.GetPlate
L6_2 = A0_2
L5_2 = L5_2(L6_2)
end
if not L5_2 then
L6_2 = debugPrint
L7_2 = "Could not get plate for vehicle"
L8_2 = "warning"
L9_2 = A0_2
L6_2(L7_2, L8_2, L9_2)
L6_2 = false
return L6_2
end
L6_2 = Entity
L7_2 = A0_2
L6_2 = L6_2(L7_2)
L6_2 = L6_2.state
L7_2 = L6_2
L6_2 = L6_2.set
L8_2 = A1_2
L9_2 = A2_2
L10_2 = true
L6_2(L7_2, L8_2, L9_2, L10_2)
L6_2 = Config
L6_2 = L6_2.ChangePlateDuringPreview
if L6_2 then
L6_2 = Config
L6_2 = L6_2.ChangePlateDuringPreview
if L5_2 == L6_2 then
goto lbl_74
end
end
L6_2 = L0_1
L6_2 = L6_2[L5_2]
if not L6_2 then
L6_2 = L0_1
L6_2[L5_2] = "{}"
end
L6_2 = json
L6_2 = L6_2.decode
L7_2 = L0_1
L7_2 = L7_2[L5_2]
L6_2 = L6_2(L7_2)
L6_2[A1_2] = A2_2
L7_2 = L0_1
L8_2 = json
L8_2 = L8_2.encode
L9_2 = L6_2
L8_2 = L8_2(L9_2)
L7_2[L5_2] = L8_2
if A3_2 then
L7_2 = SetTimeout
L8_2 = 500
function L9_2()
local L0_3, L1_3
L0_3 = L3_1
L1_3 = L5_2
L0_3(L1_3)
end
L7_2(L8_2, L9_2)
end
::lbl_74::
L6_2 = debugPrint
L7_2 = "Successfully set statebag on vehicle"
L8_2 = "debug"
L9_2 = L5_2
L10_2 = A1_2
L11_2 = A2_2
L6_2(L7_2, L8_2, L9_2, L10_2, L11_2)
L6_2 = true
return L6_2
end
setVehicleStatebag = L4_1
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "jg-mechanic:server:retrieve-and-apply-veh-statebag-data"
function L6_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2
L3_2 = NetworkGetEntityFromNetworkId
L4_2 = A1_2
L3_2 = L3_2(L4_2)
if not (A2_2 and L3_2) or 0 == L3_2 then
L4_2 = debugPrint
L5_2 = "Vehicle or plate were nil when running retrieve-and-apply-veh-statebag-data"
L6_2 = "warning"
L7_2 = A1_2
L4_2(L5_2, L6_2, L7_2)
L4_2 = false
return L4_2
end
L4_2 = L2_1
L5_2 = L3_2
L6_2 = A2_2
return L4_2(L5_2, L6_2)
end
L4_1(L5_1, L6_1)
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "jg-mechanic:server:set-vehicle-statebag"
function L6_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
local L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
L6_2 = NetworkGetEntityFromNetworkId
L7_2 = A1_2
L6_2 = L6_2(L7_2)
L7_2 = setVehicleStatebag
L8_2 = L6_2
L9_2 = A2_2
L10_2 = A3_2
L11_2 = A4_2
L12_2 = A5_2
return L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
end
L4_1(L5_1, L6_1)
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "jg-mechanic:server:set-vehicle-statebags"
function L6_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
L5_2 = NetworkGetEntityFromNetworkId
L6_2 = A1_2
L5_2 = L5_2(L6_2)
L6_2 = pairs
L7_2 = A2_2
L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
L12_2 = setVehicleStatebag
L13_2 = L5_2
L14_2 = L10_2
L15_2 = L11_2
L16_2 = false
L17_2 = A4_2
L12_2(L13_2, L14_2, L15_2, L16_2, L17_2)
end
if A3_2 then
L6_2 = setVehicleStatebag
L7_2 = L5_2
L8_2 = "_sbFromTableSet"
L9_2 = true
L10_2 = true
L11_2 = A4_2
L6_2(L7_2, L8_2, L9_2, L10_2, L11_2)
end
L6_2 = true
return L6_2
end
L4_1(L5_1, L6_1)
L4_1 = lib
L4_1 = L4_1.callback
L4_1 = L4_1.register
L5_1 = "jg-mechanic:server:save-veh-statebag-data-to-db"
function L6_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
L3_2 = L3_1
L4_2 = A1_2
L5_2 = A2_2
return L3_2(L4_2, L5_2)
end
L4_1(L5_1, L6_1)
L4_1 = exports
L5_1 = "vehiclePlateUpdated"
function L6_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
if A0_2 == A1_2 then
return
end
L2_2 = L0_1
L3_2 = L0_1
L3_2 = L3_2[A0_2]
L2_2[A1_2] = L3_2
L2_2 = L0_1
L2_2[A0_2] = nil
L2_2 = L3_1
L3_2 = A1_2
L2_2(L3_2)
L2_2 = MySQL
L2_2 = L2_2.query
L2_2 = L2_2.await
L3_2 = "DELETE FROM mechanic_vehicledata WHERE plate = ?"
L4_2 = {}
L5_2 = A0_2
L4_2[1] = L5_2
L2_2(L3_2, L4_2)
L2_2 = MySQL
L2_2 = L2_2.query
L2_2 = L2_2.await
L3_2 = "UPDATE mechanic_orders SET plate = ? WHERE plate = ?"
L4_2 = {}
L5_2 = A1_2
L6_2 = A0_2
L4_2[1] = L5_2
L4_2[2] = L6_2
L2_2(L3_2, L4_2)
L2_2 = MySQL
L2_2 = L2_2.query
L2_2 = L2_2.await
L3_2 = "UPDATE mechanic_servicing_history SET plate = ? WHERE plate = ?"
L4_2 = {}
L5_2 = A1_2
L6_2 = A0_2
L4_2[1] = L5_2
L4_2[2] = L6_2
L2_2(L3_2, L4_2)
L2_2 = MySQL
L2_2 = L2_2.query
L2_2 = L2_2.await
L3_2 = "UPDATE mechanic_servicing_history SET plate = ? WHERE plate = ?"
L4_2 = {}
L5_2 = A1_2
L6_2 = A0_2
L4_2[1] = L5_2
L4_2[2] = L6_2
L2_2(L3_2, L4_2)
end
L4_1(L5_1, L6_1)