-- ============================================================================
-- QB-MECHANIC-PRO - Workshop Module COMPLETO (Client)
-- ============================================================================

local currentVehicle = nil
local vehicleInZone = false
local nearestShop = nil
local zonesCreated = false

-- ----------------------------------------------------------------------------
-- Función: Obtener vehículo más cercano
-- ----------------------------------------------------------------------------
function GetClosestVehicle()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = nil
    local minDistance = Config.Orders.MaxVehicleDistance or 50.0
    
    for veh in EnumerateVehicles() do
        local vehCoords = GetEntityCoords(veh)
        local distance = #(playerCoords - vehCoords)
        
        if distance < minDistance then
            minDistance = distance
            vehicle = veh
        end
    end
    
    return vehicle, minDistance
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        local success
        
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success
        
        EndFindVehicle(handle)
    end)
end

-- ----------------------------------------------------------------------------
-- Función: Obtener propiedades del vehículo
-- ----------------------------------------------------------------------------
function GetVehicleProperties(vehicle)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        return QBCore.Functions.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'esx' then
        return ESX.Game.GetVehicleProperties(vehicle)
    end
end

function SetVehicleProperties(vehicle, props)
    if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
        QBCore.Functions.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'esx' then
        ESX.Game.SetVehicleProperties(vehicle, props)
    end
end

-- ----------------------------------------------------------------------------
-- Event: Crear zonas de interacción para todos los talleres
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:createShopZones', function(shops)
    if zonesCreated then return end
    zonesCreated = true
    
    for _, shop in pairs(shops) do
        CreateShopZones(shop)
    end
end)

-- ----------------------------------------------------------------------------
-- Función: Crear zonas para un taller específico
-- ----------------------------------------------------------------------------
function CreateShopZones(shop)
    if not shop.config_data or not shop.config_data.locations then return end
    
    local locations = shop.config_data.locations
    
    -- Sistema de interacción seleccionado
    if Config.Interact == 'qb-target' or Config.Interact == 'ox_target' then
        CreateTargetZones(shop, locations)
    elseif Config.Interact == 'ox_lib' then
        CreateTextUIZones(shop, locations)
    end
end

-- ----------------------------------------------------------------------------
-- Función: Crear zonas con qb-target/ox_target
-- ----------------------------------------------------------------------------
function CreateTargetZones(shop, locations)
    local targetExport = Config.Interact == 'qb-target' and 'qb-target' or 'ox_target'
    
    -- Zona de Duty
    if locations.duty then
        local loc = locations.duty
        if Config.Interact == 'qb-target' then
            exports['qb-target']:AddBoxZone('mechanic_duty_'..shop.id, 
                vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
                name = 'mechanic_duty_'..shop.id,
                heading = loc.heading or 0,
                debugPoly = Config.Debug,
                minZ = loc.z - 1,
                maxZ = loc.z + 2,
            }, {
                options = {
                    {
                        icon = 'fas fa-clock',
                        label = 'Toggle Duty',
                        job = shop.job_name,
                        action = function()
                            TriggerServerEvent('qb-mechanic:server:toggleDuty', shop.id)
                        end
                    }
                },
                distance = 2.5
            })
        else -- ox_target
            exports.ox_target:addBoxZone({
                coords = vector3(loc.x, loc.y, loc.z),
                size = vector3(1.5, 1.5, 2),
                rotation = loc.heading or 0,
                debug = Config.Debug,
                options = {
                    {
                        icon = 'fa-solid fa-clock',
                        label = 'Toggle Duty',
                        groups = shop.job_name,
                        onSelect = function()
                            TriggerServerEvent('qb-mechanic:server:toggleDuty', shop.id)
                        end
                    }
                }
            })
        end
    end
    
    -- Zona de Stash
    if locations.stash and shop.config_data.features.enable_stash then
        local loc = locations.stash
        if Config.Interact == 'qb-target' then
            exports['qb-target']:AddBoxZone('mechanic_stash_'..shop.id, 
                vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
                name = 'mechanic_stash_'..shop.id,
                heading = loc.heading or 0,
                debugPoly = Config.Debug,
                minZ = loc.z - 1,
                maxZ = loc.z + 2,
            }, {
                options = {
                    {
                        icon = 'fas fa-box',
                        label = 'Open Stash',
                        job = shop.job_name,
                        action = function()
                            TriggerEvent('qb-mechanic:client:openStash', shop.id)
                        end
                    }
                },
                distance = 2.5
            })
        else -- ox_target
            exports.ox_target:addBoxZone({
                coords = vector3(loc.x, loc.y, loc.z),
                size = vector3(1.5, 1.5, 2),
                rotation = loc.heading or 0,
                debug = Config.Debug,
                options = {
                    {
                        icon = 'fa-solid fa-box',
                        label = 'Open Stash',
                        groups = shop.job_name,
                        onSelect = function()
                            TriggerEvent('qb-mechanic:client:openStash', shop.id)
                        end
                    }
                }
            })
        end
    end
    
    -- Zona de Boss Menu (Tablet)
    if locations.bossmenu then
        local loc = locations.bossmenu
        if Config.Interact == 'qb-target' then
            exports['qb-target']:AddBoxZone('mechanic_boss_'..shop.id, 
                vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
                name = 'mechanic_boss_'..shop.id,
                heading = loc.heading or 0,
                debugPoly = Config.Debug,
                minZ = loc.z - 1,
                maxZ = loc.z + 2,
            }, {
                options = {
                    {
                        icon = 'fas fa-tablet',
                        label = 'Open Tablet',
                        job = shop.job_name,
                        action = function()
                            TriggerEvent('qb-mechanic:client:openTablet', shop.id, 'dashboard')
                        end
                    }
                },
                distance = 2.5
            })
        else -- ox_target
            exports.ox_target:addBoxZone({
                coords = vector3(loc.x, loc.y, loc.z),
                size = vector3(1.5, 1.5, 2),
                rotation = loc.heading or 0,
                debug = Config.Debug,
                options = {
                    {
                        icon = 'fa-solid fa-tablet',
                        label = 'Open Tablet',
                        groups = shop.job_name,
                        onSelect = function()
                            TriggerEvent('qb-mechanic:client:openTablet', shop.id, 'dashboard')
                        end
                    }
                }
            })
        end
    end
    
    -- Zonas de Tuneshop
    if locations.tuneshop and shop.config_data.features.enable_tuneshop then
        for i, loc in ipairs(locations.tuneshop) do
            if Config.Interact == 'qb-target' then
                exports['qb-target']:AddBoxZone('mechanic_tuneshop_'..shop.id..'_'..i, 
                    vector3(loc.x, loc.y, loc.z), 3.0, 3.0, {
                    name = 'mechanic_tuneshop_'..shop.id..'_'..i,
                    heading = loc.heading or 0,
                    debugPoly = Config.Debug,
                    minZ = loc.z - 1,
                    maxZ = loc.z + 2,
                }, {
                    options = {
                        {
                            icon = 'fas fa-wrench',
                            label = 'Open Tuning Shop',
                            action = function()
                                TriggerEvent('qb-mechanic:client:openTuneshop', shop.id)
                            end
                        }
                    },
                    distance = 3.0
                })
            else -- ox_target
                exports.ox_target:addBoxZone({
                    coords = vector3(loc.x, loc.y, loc.z),
                    size = vector3(3.0, 3.0, 2),
                    rotation = loc.heading or 0,
                    debug = Config.Debug,
                    options = {
                        {
                            icon = 'fa-solid fa-wrench',
                            label = 'Open Tuning Shop',
                            onSelect = function()
                                TriggerEvent('qb-mechanic:client:openTuneshop', shop.id)
                            end
                        }
                    }
                })
            end
        end
    end
    
    -- Zonas de Carlift
    if locations.carlift and shop.config_data.features.enable_carlift then
        for i, loc in ipairs(locations.carlift) do
            if Config.Interact == 'qb-target' then
                exports['qb-target']:AddBoxZone('mechanic_carlift_'..shop.id..'_'..i, 
                    vector3(loc.x, loc.y, loc.z), 4.0, 6.0, {
                    name = 'mechanic_carlift_'..shop.id..'_'..i,
                    heading = loc.heading or 0,
                    debugPoly = Config.Debug,
                    minZ = loc.z - 1,
                    maxZ = loc.z + 3,
                }, {
                    options = {
                        {
                            icon = 'fas fa-arrow-up',
                            label = 'Use Carlift',
                            job = shop.job_name,
                            action = function()
                                TriggerEvent('qb-mechanic:client:handleCarlift', shop.id, loc)
                            end
                        }
                    },
                    distance = 3.0
                })
            else -- ox_target
                exports.ox_target:addBoxZone({
                    coords = vector3(loc.x, loc.y, loc.z),
                    size = vector3(4.0, 6.0, 3),
                    rotation = loc.heading or 0,
                    debug = Config.Debug,
                    options = {
                        {
                            icon = 'fa-solid fa-arrow-up',
                            label = 'Use Carlift',
                            groups = shop.job_name,
                            onSelect = function()
                                TriggerEvent('qb-mechanic:client:handleCarlift', shop.id, loc)
                            end
                        }
                    }
                })
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Función: Crear zonas con ox_lib textui
-- ----------------------------------------------------------------------------
function CreateTextUIZones(shop, locations)
    -- Zona de Duty
    if locations.duty then
        local loc = locations.duty
        local point = lib.points.new({
            coords = vector3(loc.x, loc.y, loc.z),
            distance = 2.5,
        })
        
        function point:onEnter()
            lib.showTextUI('[E] - Toggle Duty', {position = 'left-center'})
        end
        
        function point:nearby()
            if IsControlJustReleased(0, 38) then -- E
                TriggerServerEvent('qb-mechanic:server:toggleDuty', shop.id)
            end
        end
        
        function point:onExit()
            lib.hideTextUI()
        end
    end
    
    -- Zona de Stash
    if locations.stash and shop.config_data.features.enable_stash then
        local loc = locations.stash
        local point = lib.points.new({
            coords = vector3(loc.x, loc.y, loc.z),
            distance = 2.5,
        })
        
        function point:onEnter()
            lib.showTextUI('[E] - Open Stash', {position = 'left-center'})
        end
        
        function point:nearby()
            if IsControlJustReleased(0, 38) then
                TriggerEvent('qb-mechanic:client:openStash', shop.id)
            end
        end
        
        function point:onExit()
            lib.hideTextUI()
        end
    end
    
    -- Zona de Boss Menu
    if locations.bossmenu then
        local loc = locations.bossmenu
        local point = lib.points.new({
            coords = vector3(loc.x, loc.y, loc.z),
            distance = 2.5,
        })
        
        function point:onEnter()
            lib.showTextUI('[E] - Open Tablet', {position = 'left-center'})
        end
        
        function point:nearby()
            if IsControlJustReleased(0, 38) then
                TriggerEvent('qb-mechanic:client:openTablet', shop.id, 'dashboard')
            end
        end
        
        function point:onExit()
            lib.hideTextUI()
        end
    end
    
    -- Zonas de Tuneshop
    if locations.tuneshop and shop.config_data.features.enable_tuneshop then
        for i, loc in ipairs(locations.tuneshop) do
            local point = lib.points.new({
                coords = vector3(loc.x, loc.y, loc.z),
                distance = 3.0,
            })
            
            function point:onEnter()
                lib.showTextUI('[E] - Open Tuning Shop', {position = 'left-center'})
            end
            
            function point:nearby()
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qb-mechanic:client:openTuneshop', shop.id)
                end
            end
            
            function point:onExit()
                lib.hideTextUI()
            end
        end
    end
    
    -- Zonas de Carlift
    if locations.carlift and shop.config_data.features.enable_carlift then
        for i, loc in ipairs(locations.carlift) do
            local point = lib.points.new({
                coords = vector3(loc.x, loc.y, loc.z),
                distance = 3.0,
            })
            
            function point:onEnter()
                lib.showTextUI('[E] - Use Carlift', {position = 'left-center'})
            end
            
            function point:nearby()
                if IsControlJustReleased(0, 38) then
                    TriggerEvent('qb-mechanic:client:handleCarlift', shop.id, loc)
                end
            end
            
            function point:onExit()
                lib.hideTextUI()
            end
        end
    end
end

-- ----------------------------------------------------------------------------
-- Event: Abrir tuneshop
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:openTuneshop', function(shopId)
    local vehicle, distance = GetClosestVehicle()
    
    if not vehicle then
        exports['qb-mechanic-pro']:Notify('No vehicle nearby', 'error')
        return
    end
    
    if distance > 5.0 then
        exports['qb-mechanic-pro']:Notify('Vehicle is too far', 'error')
        return
    end
    
    -- Obtener propiedades actuales
    local props = GetVehicleProperties(vehicle)
    
    -- Entrar al modo tuneshop
    TriggerEvent('qb-mechanic:client:enterTuneshop', vehicle)
    
    -- Abrir UI de tuneshop
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTuneshop',
        shopId = shopId,
        vehicle = {
            model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
            plate = GetVehicleNumberPlateText(vehicle),
            netId = VehToNet(vehicle),
            currentMods = props
        }
    })
end)

-- ----------------------------------------------------------------------------
-- Event: Abrir tablet
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:openTablet', function(shopId, section)
    TriggerServerEvent('qb-mechanic:server:requestShopData', shopId)
end)

RegisterNetEvent('qb-mechanic:client:receiveShopData', function(shopData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openTablet',
        shop = shopData
    })
end)

-- ----------------------------------------------------------------------------
-- NUI Callback: Crear orden
-- ----------------------------------------------------------------------------
RegisterNUICallback('createOrder', function(data, cb)
    local vehicle, distance = GetClosestVehicle()
    
    if not vehicle then
        cb({success = false, message = 'No vehicle nearby'})
        return
    end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    
    TriggerServerEvent('qb-mechanic:server:createOrder', {
        shopId = data.shopId,
        vehiclePlate = plate,
        vehicleModel = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)),
        modifications = data.modifications,
        totalCost = data.totalCost
    })
    
    cb({success = true})
end)

-- ----------------------------------------------------------------------------
-- Función: Instalar modificaciones paso a paso
-- ----------------------------------------------------------------------------
function InstallModifications(vehicle, modifications, callback)
    local totalSteps = #modifications
    local currentStep = 0
    
    for _, mod in ipairs(modifications) do
        currentStep = currentStep + 1
        
        SendNUIMessage({
            action = 'updateInstallProgress',
            step = currentStep,
            total = totalSteps,
            current = mod
        })
        
        ApplyModification(vehicle, mod)
        
        Wait(2000)
    end
    
    callback(true)
end

function ApplyModification(vehicle, mod)
    SetVehicleModKit(vehicle, 0)
    
    if mod.type == 'engine' then
        SetVehicleMod(vehicle, 11, mod.level, false)
    elseif mod.type == 'brakes' then
        SetVehicleMod(vehicle, 12, mod.level, false)
    elseif mod.type == 'transmission' then
        SetVehicleMod(vehicle, 13, mod.level, false)
    elseif mod.type == 'suspension' then
        SetVehicleMod(vehicle, 15, mod.level, false)
    elseif mod.type == 'turbo' then
        ToggleVehicleMod(vehicle, 18, mod.enabled)
    elseif mod.type == 'spoiler' then
        SetVehicleMod(vehicle, 0, mod.index, false)
    elseif mod.type == 'fbumper' then
        SetVehicleMod(vehicle, 1, mod.index, false)
    elseif mod.type == 'rbumper' then
        SetVehicleMod(vehicle, 2, mod.index, false)
    end
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('GetClosestVehicle', GetClosestVehicle)
exports('GetVehicleProperties', GetVehicleProperties)
exports('SetVehicleProperties', SetVehicleProperties)
exports('InstallModifications', InstallModifications)
exports('ApplyModification', ApplyModification)