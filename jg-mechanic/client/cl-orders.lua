local L0_1, L1_1, L2_1
L0_1 = RegisterNUICallback
L1_1 = "get-mechanic-orders"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
L2_2 = A0_2.pageIndex
L3_2 = A0_2.pageSize
L4_2 = A1_2
L5_2 = lib
L5_2 = L5_2.callback
L5_2 = L5_2.await
L6_2 = "jg-mechanic:server:get-orders"
L7_2 = false
L8_2 = L2_2
L9_2 = L3_2
L5_2, L6_2, L7_2, L8_2, L9_2 = L5_2(L6_2, L7_2, L8_2, L9_2)
L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "mark-order-fulfilled"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L2_2 = A0_2.orderId
L3_2 = A1_2
L4_2 = lib
L4_2 = L4_2.callback
L4_2 = L4_2.await
L5_2 = "jg-mechanic:server:mark-order-fulfilled"
L6_2 = false
L7_2 = L2_2
L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2, L6_2, L7_2)
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "delete-order"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
L2_2 = A0_2.orderId
L3_2 = A1_2
L4_2 = lib
L4_2 = L4_2.callback
L4_2 = L4_2.await
L5_2 = "jg-mechanic:server:delete-order"
L6_2 = false
L7_2 = L2_2
L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2, L6_2, L7_2)
L3_2(L4_2, L5_2, L6_2, L7_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "orders-install-category"
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
L2_2 = A0_2.orderId
L3_2 = A0_2.category
L4_2 = lib
L4_2 = L4_2.callback
L4_2 = L4_2.await
L5_2 = "jg-mechanic:server:can-apply-order"
L6_2 = false
L7_2 = L2_2
L4_2 = L4_2(L5_2, L6_2, L7_2)
if not L4_2 then
L5_2 = A1_2
L6_2 = {}
L6_2.error = true
return L5_2(L6_2)
end
L5_2 = LocalPlayer
L5_2 = L5_2.state
L5_2 = L5_2.tabletConnectedVehicle
if L5_2 then
L5_2 = L5_2.vehicleEntity
end
if L5_2 then
L6_2 = DoesEntityExist
L7_2 = L5_2
L6_2 = L6_2(L7_2)
if L6_2 then
goto lbl_35
end
end
L6_2 = A1_2
L7_2 = false
do return L6_2(L7_2) end
::lbl_35::
L6_2 = Framework
L6_2 = L6_2.Client
L6_2 = L6_2.GetPlate
L7_2 = L5_2
L6_2 = L6_2(L7_2)
L7_2 = L4_2.plate
if L6_2 ~= L7_2 then
L7_2 = Framework
L7_2 = L7_2.Client
L7_2 = L7_2.Notify
L8_2 = Locale
L8_2 = L8_2.vehPlateMismatch
L9_2 = "error"
L7_2(L8_2, L9_2)
L7_2 = A1_2
L8_2 = {}
L8_2.error = true
return L7_2(L8_2)
end
L7_2 = "prop"
L8_2 = {}
L8_2.prop = "spanner"
if "respray" == L3_2 then
L7_2 = "respray"
end
if "wheels" == L3_2 then
L9_2 = {}
L9_2.prop = "wheel"
L8_2 = L9_2
end
L9_2 = playMinigame
L10_2 = L5_2
L11_2 = L7_2
L12_2 = L8_2
function L13_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3
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
L1_3 = tableKeys
L2_3 = json
L2_3 = L2_3.decode
L3_3 = L4_2.cart
if not L3_3 then
L3_3 = "{}"
end
L2_3 = L2_3(L3_3)
L3_3 = L3_2
L2_3 = L2_3[L3_3]
L1_3 = L1_3(L2_3)
L1_3 = #L1_3
if not L1_3 then
L2_3 = A1_2
L3_3 = false
return L2_3(L3_3)
end
L2_3 = lib
L2_3 = L2_3.callback
L2_3 = L2_3.await
L3_3 = "jg-mechanic:server:pay-for-order-installation"
L4_3 = false
L5_3 = L3_2
L6_3 = L1_3
L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3)
if not L2_3 then
L3_3 = A1_2
L4_3 = false
return L3_3(L4_3)
end
L3_3 = L3_2
if "repair" == L3_3 then
L3_3 = Framework
L3_3 = L3_3.Client
L3_3 = L3_3.RepairVehicle
L4_3 = L5_2
L3_3(L4_3)
L3_3 = Framework
L3_3 = L3_3.Client
L3_3 = L3_3.Notify
L4_3 = Locale
L4_3 = L4_3.vehicleRepaired
L5_3 = "success"
L3_3(L4_3, L5_3)
else
L3_3 = json
L3_3 = L3_3.decode
L4_3 = L4_2.props_to_apply
if not L4_3 then
L4_3 = "{}"
end
L3_3 = L3_3(L4_3)
L4_3 = L3_2
L3_3 = L3_3[L4_3]
if not L3_3 then
L4_3 = A1_2
L5_3 = false
return L4_3(L5_3)
end
L4_3 = setVehicleProperties
L5_3 = L5_2
L6_3 = L3_3
L7_3 = true
L4_3(L5_3, L6_3, L7_3)
L4_3 = Entity
L5_3 = L5_2
L4_3 = L4_3(L5_3)
L4_3 = L4_3.state
L5_3 = L4_3
L4_3 = L4_3.set
L6_3 = "applyVehicleProps"
L7_3 = L3_3
L8_3 = true
L4_3(L5_3, L6_3, L7_3, L8_3)
L4_3 = Framework
L4_3 = L4_3.Client
L4_3 = L4_3.Notify
L5_3 = Locale
L5_3 = L5_3.installationSuccessful
L6_3 = "success"
L4_3(L5_3, L6_3)
L4_3 = Config
L4_3 = L4_3.UpdatePropsOnChange
if L4_3 then
L4_3 = SetTimeout
L5_3 = 1000
function L6_3()
local L0_4, L1_4, L2_4, L3_4, L4_4, L5_4
L0_4 = lib
L0_4 = L0_4.callback
L0_4 = L0_4.await
L1_4 = "jg-mechanic:server:save-vehicle-props"
L2_4 = false
L3_4 = L6_2
L4_4 = getVehicleProperties
L5_4 = L5_2
L4_4, L5_4 = L4_4(L5_4)
L0_4(L1_4, L2_4, L3_4, L4_4, L5_4)
end
L4_3(L5_3, L6_3)
end
end
L3_3 = lib
L3_3 = L3_3.callback
L3_3 = L3_3.await
L4_3 = "jg-mechanic:server:mark-category-installed"
L5_3 = false
L6_3 = L2_2
L7_3 = L3_2
L3_3(L4_3, L5_3, L6_3, L7_3)
L3_3 = A1_2
L4_3 = true
L3_3(L4_3)
end
L9_2(L10_2, L11_2, L12_2, L13_2)
end
L0_1(L1_1, L2_1)