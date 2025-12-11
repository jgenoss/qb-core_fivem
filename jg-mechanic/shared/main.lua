local L0_1, L1_1, L2_1
L0_1 = {}
Globals = L0_1
L0_1 = {}
Functions = L0_1
L0_1 = Locales
L1_1 = Config
L1_1 = L1_1.Locale
if not L1_1 then
L1_1 = "en"
end
L0_1 = L0_1[L1_1]
Locale = L0_1
L0_1 = exports
L1_1 = "config"
function L2_1()
local L0_2, L1_2
L0_2 = Config
return L0_2
end
L0_1(L1_1, L2_1)
function L0_1(A0_2, A1_2, ...)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
L2_2 = Config
L2_2 = L2_2.Debug
if not L2_2 then
return
end
L2_2 = "^2[DEBUG]^7"
if "warning" == A1_2 then
L2_2 = "^3[WARNING]^7"
end
L3_2 = {}
L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = ...
L3_2[1] = L4_2
L3_2[2] = L5_2
L3_2[3] = L6_2
L3_2[4] = L7_2
L3_2[5] = L8_2
L3_2[6] = L9_2
L3_2[7] = L10_2
L3_2[8] = L11_2
L4_2 = ""
L5_2 = 1
L6_2 = #L3_2
L7_2 = 1
for L8_2 = L5_2, L6_2, L7_2 do
L9_2 = type
L10_2 = L3_2[L8_2]
L9_2 = L9_2(L10_2)
if "table" == L9_2 then
L9_2 = L4_2
L10_2 = json
L10_2 = L10_2.encode
L11_2 = L3_2[L8_2]
L10_2 = L10_2(L11_2)
L9_2 = L9_2 .. L10_2
L4_2 = L9_2
else
L9_2 = type
L10_2 = L3_2[L8_2]
L9_2 = L9_2(L10_2)
if "string" ~= L9_2 then
L9_2 = L4_2
L10_2 = tostring
L11_2 = L3_2[L8_2]
L10_2 = L10_2(L11_2)
L9_2 = L9_2 .. L10_2
L4_2 = L9_2
else
L9_2 = L4_2
L10_2 = L3_2[L8_2]
L9_2 = L9_2 .. L10_2
L4_2 = L9_2
end
end
L9_2 = #L3_2
if L8_2 ~= L9_2 then
L9_2 = L4_2
L10_2 = " "
L9_2 = L9_2 .. L10_2
L4_2 = L9_2
end
end
L5_2 = print
L6_2 = L2_2
L7_2 = A0_2
L8_2 = L4_2
L5_2(L6_2, L7_2, L8_2)
end
debugPrint = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2
if A0_2 then
L1_2 = DoesEntityExist
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if L1_2 then
goto lbl_10
end
end
L1_2 = false
do return L1_2 end
::lbl_10::
L1_2 = GetVehicleNumberPlateText
L2_2 = A0_2
L1_2 = L1_2(L2_2)
if not L1_2 then
L2_2 = false
return L2_2
end
L2_2 = string
L2_2 = L2_2.gsub
L3_2 = L1_2
L4_2 = "^%s*(.-)%s*$"
L5_2 = "%1"
L2_2 = L2_2(L3_2, L4_2, L5_2)
return L2_2
end
getTrimmedVehiclePlate = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
L1_2 = GetGameBuildNumber
L1_2 = L1_2()
L2_2 = 3258
if L1_2 >= L2_2 then
L1_2 = Citizen
L1_2 = L1_2.InvokeNative
L2_2 = 2290933623539066425
L3_2 = joaat
L4_2 = A0_2
L3_2, L4_2 = L3_2(L4_2)
L1_2 = L1_2(L2_2, L3_2, L4_2)
L1_2 = 1 == L1_2
return L1_2
end
L1_2 = lib
L1_2 = L1_2.table
L1_2 = L1_2.contains
L2_2 = Config
L2_2 = L2_2.ElectricVehicles
L3_2 = A0_2
return L1_2(L2_2, L3_2)
end
isVehicleElectric = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
L2_2 = A1_2 or nil
if not A1_2 then
L2_2 = 0
end
L3_2 = 10
L2_2 = L3_2 ^ L2_2
L3_2 = math
L3_2 = L3_2.floor
L4_2 = A0_2 * L2_2
L4_2 = L4_2 + 0.5
L3_2 = L3_2(L4_2)
L3_2 = L3_2 / L2_2
return L3_2
end
round = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
L2_2 = pairs
L3_2 = A1_2
L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
L8_2 = type
L9_2 = L7_2
L8_2 = L8_2(L9_2)
if "table" == L8_2 then
L8_2 = type
L9_2 = A0_2[L6_2]
L8_2 = L8_2(L9_2)
if "table" == L8_2 then
L8_2 = deepMerge
L9_2 = A0_2[L6_2]
L10_2 = L7_2
L8_2(L9_2, L10_2)
end
elseif "nil (deleted)" == L7_2 then
A0_2[L6_2] = nil
else
A0_2[L6_2] = L7_2
end
end
return A0_2
end
deepMerge = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
L2_2 = {}
L3_2 = #A0_2
if L3_2 > 0 then
L3_2 = #A1_2
if L3_2 > 0 then
L3_2 = 1
L4_2 = #A0_2
L5_2 = 1
for L6_2 = L3_2, L4_2, L5_2 do
L7_2 = #L2_2
L7_2 = L7_2 + 1
L8_2 = A0_2[L6_2]
L2_2[L7_2] = L8_2
end
L3_2 = 1
L4_2 = #A1_2
L5_2 = 1
for L6_2 = L3_2, L4_2, L5_2 do
L7_2 = #L2_2
L7_2 = L7_2 + 1
L8_2 = A1_2[L6_2]
L2_2[L7_2] = L8_2
end
end
else
L3_2 = pairs
L4_2 = A0_2
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
L2_2[L7_2] = L8_2
end
L3_2 = pairs
L4_2 = A1_2
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
L2_2[L7_2] = L8_2
end
end
return L2_2
end
tableConcat = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
L1_2 = {}
L2_2 = pairs
L3_2 = A0_2
L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
L8_2 = #L1_2
L8_2 = L8_2 + 1
L1_2[L8_2] = L6_2
end
return L1_2
end
tableKeys = L0_1
function L0_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2
L3_2 = 0
L4_2 = 2.147483648E9
L5_2 = 0
repeat
L6_2 = A0_2 + A1_2
L6_2 = L6_2 + L4_2
L7_2 = A0_2 % L4_2
A1_2 = A1_2 % L4_2
A0_2 = L7_2
L5_2 = L6_2
L6_2 = L4_2 * A2_2
L7_2 = L5_2 - A0_2
L7_2 = L7_2 - A1_2
L6_2 = L6_2 % L7_2
L6_2 = L3_2 + L6_2
L4_2 = L4_2 / 2
L3_2 = L6_2
until L4_2 < 1
return L3_2
end
bitOper = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
L2_2 = bitOper
L3_2 = A0_2
L4_2 = A1_2
L5_2 = 4
L2_2 = L2_2(L3_2, L4_2, L5_2)
L2_2 = L2_2 == A1_2
return L2_2
end
hasFlag = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = hasFlag
L3_2 = A0_2
L4_2 = A1_2
L2_2 = L2_2(L3_2, L4_2)
if L2_2 then
return A0_2
end
L2_2 = math
L2_2 = L2_2.floor
L3_2 = bitOper
L4_2 = A0_2
L5_2 = A1_2
L6_2 = 1
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2, L6_2)
return L2_2(L3_2, L4_2, L5_2, L6_2)
end
addFlag = L0_1
function L0_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2
L2_2 = hasFlag
L3_2 = A0_2
L4_2 = A1_2
L2_2 = L2_2(L3_2, L4_2)
if not L2_2 then
return A0_2
end
L2_2 = math
L2_2 = L2_2.floor
L3_2 = bitOper
L4_2 = A0_2
L5_2 = A1_2
L6_2 = 3
L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2, L5_2, L6_2)
return L2_2(L3_2, L4_2, L5_2, L6_2)
end
removeFlag = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2
L1_2 = GetControlInstructionalButton
L2_2 = 0
L3_2 = A0_2
L4_2 = true
L1_2 = L1_2(L2_2, L3_2, L4_2)
L2_2 = string
L2_2 = L2_2.gsub
L3_2 = L1_2
L4_2 = "^t_"
L5_2 = ""
L2_2 = L2_2(L3_2, L4_2, L5_2)
if L1_2 ~= L2_2 then
return L2_2
end
L3_2 = CONTROL_KEYBINDS
L3_2 = L3_2[L1_2]
if L3_2 then
L3_2 = CONTROL_KEYBINDS
L3_2 = L3_2[L1_2]
return L3_2
end
return L1_2
end
parseControlBinding = L0_1