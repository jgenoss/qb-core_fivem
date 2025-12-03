local QBCore = exports['qb-core']:GetCoreObject()
local ActiveShops = {} -- {[id] = {ped = entity, blip = blip, target = bool}}
local isPlacing = false
local tempShopData = {}
local ghostPed = nil
local placementThread = nil

-- Variables para Previews en NUI
local nuiPreviewPed = nil
local nuiPreviewBlip = nil

-- ================================================================
-- UTILIDADES (Orden Correcto)
-- ================================================================
local function NormalizeHeading(heading)
    while heading < 0.0 do heading = heading + 360.0 end
    while heading >= 360.0 do heading = heading - 360.0 end
    return heading
end

local function RotationToDirection(rotation)
    local adjustedRotation = vector3(
        (math.pi / 180) * rotation.x,
        (math.pi / 180) * rotation.y,
        (math.pi / 180) * rotation.z
    )
    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        math.sin(adjustedRotation.x)
    )
    return direction
end

local function RayCastGamePlayCamera(distance)
    local camCoord = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)
    local direction = RotationToDirection(camRot)
    local destination = camCoord + (direction * distance)
    
    local rayHandle = StartShapeTestRay(
        camCoord.x, camCoord.y, camCoord.z,
        destination.x, destination.y, destination.z,
        -1, -- Hit everything except player
        PlayerPedId(),
        0
    )
    
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    return hit == 1, endCoords, surfaceNormal, entityHit
end

local function LoadModel(model)
    local modelHash = type(model) == "string" and GetHashKey(model) or model
    if not IsModelValid(modelHash) then return false end
    if HasModelLoaded(modelHash) then return true end
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    return HasModelLoaded(modelHash)
end

-- ================================================================
-- PREVIEWS EN TIEMPO REAL (NUI)
-- ================================================================

local function DeleteNuiPreviewPed()
    if nuiPreviewPed and DoesEntityExist(nuiPreviewPed) then
        DeleteEntity(nuiPreviewPed)
        nuiPreviewPed = nil
    end
end

local function DeleteNuiPreviewBlip()
    if nuiPreviewBlip and DoesBlipExist(nuiPreviewBlip) then
        RemoveBlip(nuiPreviewBlip)
        nuiPreviewBlip = nil
    end
end

RegisterNUICallback('previewPed', function(data, cb)
    local model = data.model
    if not model then return end

    DeleteNuiPreviewPed()

    if LoadModel(model) then
        local pCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, -1.0)
        local heading = GetEntityHeading(PlayerPedId()) - 180.0
        
        nuiPreviewPed = CreatePed(4, GetHashKey(model), pCoords.x, pCoords.y, pCoords.z, heading, false, false)
        
        SetEntityAlpha(nuiPreviewPed, 200, false)
        SetEntityCollision(nuiPreviewPed, false, false)
        FreezeEntityPosition(nuiPreviewPed, true)
        SetEntityInvincible(nuiPreviewPed, true)
        SetBlockingOfNonTemporaryEvents(nuiPreviewPed, true)
    end
    cb('ok')
end)

RegisterNUICallback('removePreviewPed', function(_, cb)
    DeleteNuiPreviewPed()
    cb('ok')
end)

RegisterNUICallback('previewBlip', function(data, cb)
    DeleteNuiPreviewBlip()
    
    if data.enable then
        local pCoords = GetEntityCoords(PlayerPedId())
        nuiPreviewBlip = AddBlipForCoord(pCoords.x, pCoords.y, pCoords.z)
        SetBlipSprite(nuiPreviewBlip, tonumber(data.sprite) or 52)
        SetBlipColour(nuiPreviewBlip, tonumber(data.color) or 2)
        SetBlipScale(nuiPreviewBlip, 1.0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("[PREVIEW] Tienda")
        EndTextCommandSetBlipName(nuiPreviewBlip)
    end
    cb('ok')
end)

RegisterNUICallback('removePreviewBlip', function(_, cb)
    DeleteNuiPreviewBlip()
    cb('ok')
end)


-- ================================================================
-- SPAWN INDIVIDUAL DE TIENDA
-- ================================================================
local function SpawnShop(shop)
    if ActiveShops[shop.id] then return end
    if not shop.coords or not shop.coords.x then return end
    
    if not LoadModel(shop.pedModel) then return end
    
    -- Crear NPC
    local ped = CreatePed(4, GetHashKey(shop.pedModel), shop.coords.x, shop.coords.y, shop.coords.z, shop.coords.h or 0.0, false, true)
    
    if not DoesEntityExist(ped) then return end
    
    -- Configurar NPC
    SetEntityAsMissionEntity(ped, true, true)
    
    -- [FIX] Altura correcta
    local foundGround, zPos = GetGroundZFor_3dCoord(shop.coords.x, shop.coords.y, shop.coords.z + 1.0, 0)
    if foundGround then
        SetEntityCoords(ped, shop.coords.x, shop.coords.y, zPos, false, false, false, true)
    else
        SetEntityOnGroundProperly(ped)
    end

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    
    -- Target
    -- exports['qb-target']:AddTargetEntity(ped, {
    --     options = {
    --         {
    --             icon = "fas fa-shopping-basket",
    --             label = "Abrir " .. shop.name,
    --             action = function()
    --                 -- Enviar SOLO el ID como número, no data table
    --                 TriggerServerEvent("shopcreator:server:OpenShop", tonumber(shop.id))
    --             end
    --         }
    --     },
    --     distance = 2.5
    -- })

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = "fas fa-shopping-basket",
                label = "Abrir " .. shop.name,
                action = function()
                    -- 🔥 Llamar al export de qb-shop-ui
                    exports['qb-shop-ui']:OpenShop(tonumber(shop.id))
                end
            }
        },
        distance = 2.5
    })
    
    -- Blip
    local blip = nil
    if shop.blip and shop.blip.enable then
        blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
        SetBlipSprite(blip, tonumber(shop.blip.sprite) or 52)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, tonumber(shop.blip.color) or 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(shop.name)
        EndTextCommandSetBlipName(blip)
    end
    
    ActiveShops[shop.id] = {
        ped = ped,
        blip = blip,
        coords = vector3(shop.coords.x, shop.coords.y, shop.coords.z),
        target = true
    }
    
    SetModelAsNoLongerNeeded(GetHashKey(shop.pedModel))
end

local function DeleteShop(shopId)
    local shop = ActiveShops[shopId]
    if not shop then return end
    if shop.ped and DoesEntityExist(shop.ped) then
        exports['qb-target']:RemoveTargetEntity(shop.ped)
        DeleteEntity(shop.ped)
    end
    if shop.blip and DoesBlipExist(shop.blip) then RemoveBlip(shop.blip) end
    ActiveShops[shopId] = nil
end

local function SyncShops(newShops)
    local newIds = {}
    for _, shop in pairs(newShops) do newIds[shop.id] = true end
    for id, _ in pairs(ActiveShops) do
        if not newIds[id] then DeleteShop(id) end
    end
    for _, shop in pairs(newShops) do
        if not ActiveShops[shop.id] then SpawnShop(shop) end
    end
end

-- ================================================================
-- MODO COLOCACIÓN
-- ================================================================
local function CleanupPlacement()
    if ghostPed and DoesEntityExist(ghostPed) then
        DeleteEntity(ghostPed)
        ghostPed = nil
    end
    isPlacing = false
    if placementThread then placementThread = nil end
end

local function StartPlacementMode()
    if isPlacing then return end
    isPlacing = true
    
    if not LoadModel(tempShopData.pedModel) then
        QBCore.Functions.Notify("Error cargando modelo", "error")
        CleanupPlacement()
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    ghostPed = CreatePed(4, GetHashKey(tempShopData.pedModel), playerCoords.x, playerCoords.y, playerCoords.z, 0.0, false, false)
    
    SetEntityAlpha(ghostPed, 180, false)
    SetEntityCollision(ghostPed, false, false)
    SetEntityInvincible(ghostPed, true)
    
    local currentHeading = GetEntityHeading(PlayerPedId())
    QBCore.Functions.Notify("~g~[E]~w~ Confirmar | ~y~Flechas~w~ Rotar | ~r~[Backspace]~w~ Cancelar", "primary", 15000)
    
    placementThread = true
    CreateThread(function()
        while isPlacing and placementThread do
            Wait(0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            
            local hit, coords, normal, entity = RayCastGamePlayCamera(20.0)
            
            if hit then
                SetEntityCoords(ghostPed, coords.x, coords.y, coords.z, false, false, false, false)
                SetEntityHeading(ghostPed, currentHeading)
                PlaceObjectOnGroundProperly(ghostPed)
                
                local pedCoords = GetEntityCoords(ghostPed)
                DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 0.98, 0,0,0, 0,0,0, 1.0, 1.0, 0.5, 0, 255, 0, 100, false, false, 2, false, nil, nil, false)
            end
            
            if IsControlPressed(0, 174) then currentHeading = NormalizeHeading(currentHeading + 2.0) end
            if IsControlPressed(0, 175) then currentHeading = NormalizeHeading(currentHeading - 2.0) end
            
            if IsControlJustPressed(0, 38) and hit then
                local finalCoords = GetEntityCoords(ghostPed)
                local finalHeading = NormalizeHeading(GetEntityHeading(ghostPed))
                tempShopData.coords = { x = finalCoords.x, y = finalCoords.y, z = finalCoords.z, h = finalHeading }
                TriggerServerEvent('shopcreator:server:CreateShop', tempShopData)
                CleanupPlacement()
            end
            
            if IsControlJustPressed(0, 177) then
                CleanupPlacement()
                TriggerEvent('shopcreator:client:OpenDashboard')
            end
        end
    end)
end

-- ================================================================
-- EVENTOS Y CALLBACKS
-- ================================================================
RegisterNetEvent('shopcreator:client:OpenDashboard', function()
    QBCore.Functions.TriggerCallback('shopcreator:server:GetItems', function(items)
        QBCore.Functions.TriggerCallback('shopcreator:server:GetAllShops', function(shops)
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openDashboard',
                items = items,
                shops = shops,
                imgDir = "nui://" .. Config.InventoryResource .. "/html/images/",
                shopTypes = Config.ShopTypes,
                pedModels = Config.PedModels,
                blipPresets = Config.BlipPresets,
                itemCategories = Config.ItemCategories
            })
        end)
    end)
end)

RegisterNetEvent('shopcreator:client:Sync', function(shops) SyncShops(shops) end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    DeleteNuiPreviewPed()  -- Limpiar preview si se cierra
    DeleteNuiPreviewBlip() -- Limpiar preview si se cierra
    cb('ok')
end)

RegisterNUICallback('teleportToShop', function(data, cb)
    if data.coords then
        SetEntityCoords(PlayerPedId(), data.coords.x, data.coords.y, data.coords.z)
    end
    cb('ok')
end)

RegisterNUICallback('deleteShop', function(data, cb)
    print('Deleting shop ID:', data.id)
    TriggerServerEvent('shopcreator:server:DeleteShop', data.id)
    cb('ok')
end)

RegisterNUICallback('startPlacement', function(data, cb)
    tempShopData = data
    SetNuiFocus(false, false)
    DeleteNuiPreviewPed()  -- Limpiar preview antes de colocar
    DeleteNuiPreviewBlip()
    Wait(100)
    StartPlacementMode()
    cb('ok')
end)

-- ================================================================
-- 📝 EDICIÓN DE TIENDA (NUEVO - AÑADIR DESPUÉS DE LOS EVENTOS)
-- ================================================================

RegisterNUICallback('editShop', function(data, cb)
    print('📝 Editando tienda ID:', data.id)
    
    QBCore.Functions.TriggerCallback('shopcreator:server:GetShop', function(shop)
        if shop then
            -- Enviar datos al NUI para pre-llenar el formulario
            SendNUIMessage({
                action = 'loadShopForEdit',
                shop = shop
            })
        else
            QBCore.Functions.Notify('Error al cargar tienda', 'error')
        end
    end, data.id)
    
    cb('ok')
end)

RegisterNUICallback('updateShop', function(data, cb)
    print('💾 Actualizando tienda ID:', data.id)
    TriggerServerEvent('shopcreator:server:UpdateShop', data)
    cb('ok')
end)

RegisterNUICallback('updatePlacement', function(data, cb)
    tempShopData = data
    SetNuiFocus(false, false)
    DeleteNuiPreviewPed()
    DeleteNuiPreviewBlip()
    Wait(100)
    StartUpdatePlacementMode()
    cb('ok')
end)

-- ================================================================
-- 🗺️ MODO COLOCACIÓN PARA ACTUALIZACIÓN (NUEVO)
-- ================================================================

function StartUpdatePlacementMode()
    if isPlacing then return end
    isPlacing = true
    
    if not LoadModel(tempShopData.pedModel) then
        QBCore.Functions.Notify("Error cargando modelo", "error")
        CleanupPlacement()
        return
    end
    
    local playerCoords = GetEntityCoords(PlayerPedId())
    ghostPed = CreatePed(4, GetHashKey(tempShopData.pedModel), playerCoords.x, playerCoords.y, playerCoords.z, 0.0, false, false)
    
    SetEntityAlpha(ghostPed, 180, false)
    SetEntityCollision(ghostPed, false, false)
    SetEntityInvincible(ghostPed, true)
    
    local currentHeading = GetEntityHeading(PlayerPedId())
    QBCore.Functions.Notify("~g~[E]~w~ Confirmar | ~y~Flechas~w~ Rotar | ~r~[Backspace]~w~ Cancelar", "primary", 15000)
    
    placementThread = true
    CreateThread(function()
        while isPlacing and placementThread do
            Wait(0)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            
            local hit, coords, normal, entity = RayCastGamePlayCamera(20.0)
            
            if hit then
                SetEntityCoords(ghostPed, coords.x, coords.y, coords.z, false, false, false, false)
                SetEntityHeading(ghostPed, currentHeading)
                PlaceObjectOnGroundProperly(ghostPed)
                
                local pedCoords = GetEntityCoords(ghostPed)
                DrawMarker(1, pedCoords.x, pedCoords.y, pedCoords.z - 0.98, 0,0,0, 0,0,0, 1.0, 1.0, 0.5, 255, 165, 0, 100, false, false, 2, false, nil, nil, false)
            end
            
            if IsControlPressed(0, 174) then currentHeading = NormalizeHeading(currentHeading + 2.0) end
            if IsControlPressed(0, 175) then currentHeading = NormalizeHeading(currentHeading - 2.0) end
            
            if IsControlJustPressed(0, 38) and hit then
                local finalCoords = GetEntityCoords(ghostPed)
                local finalHeading = NormalizeHeading(GetEntityHeading(ghostPed))
                tempShopData.coords = { x = finalCoords.x, y = finalCoords.y, z = finalCoords.z, h = finalHeading }
                TriggerServerEvent('shopcreator:server:UpdateShop', tempShopData)
                CleanupPlacement()
            end
            
            if IsControlJustPressed(0, 177) then
                CleanupPlacement()
                TriggerEvent('shopcreator:client:OpenDashboard')
            end
        end
    end)
end

AddEventHandler('onResourceStart', function(res)
    if GetCurrentResourceName() ~= res then return end
    Wait(1000)
    QBCore.Functions.TriggerCallback('shopcreator:server:GetAllShops', function(shops)
        if shops then SyncShops(shops) end
    end)
end)

AddEventHandler('onResourceStop', function(res)
    if GetCurrentResourceName() ~= res then return end
    for id, _ in pairs(ActiveShops) do DeleteShop(id) end
    CleanupPlacement()
    DeleteNuiPreviewPed()
    DeleteNuiPreviewBlip()
end)