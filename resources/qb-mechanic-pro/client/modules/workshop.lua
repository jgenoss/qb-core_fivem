-- ============================================================================
-- QB-MECHANIC-PRO - Workshop Module (Client) COMPLETO
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Event: Crear zonas de interacción para talleres
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:createShopZones', function(shops)
    for _, shop in pairs(shops) do
        CreateShopZones(shop)
    end
end)

-- ----------------------------------------------------------------------------
-- Función: Crear todas las zonas de un taller
-- ----------------------------------------------------------------------------
function CreateShopZones(shop)
    if not shop.config_data or not shop.config_data.locations then return end
    
    local locations = shop.config_data.locations
    
    -- Zonas de Duty (On/Off duty)
    if locations.duty and shop.config_data.features.enable_duty then
        for i, loc in ipairs(locations.duty) do
            if Config.Interact == 'qb-target' then
                exports['qb-target']:AddBoxZone('mechanic_duty_'..shop.id..'_'..i, 
                    vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
                    name = 'mechanic_duty_'..shop.id..'_'..i,
                    heading = loc.heading or 0,
                    debugPoly = Config.Debug,
                    minZ = loc.z - 1,
                    maxZ = loc.z + 2,
                }, {
                    options = {
                        {
                            icon = 'fas fa-briefcase',
                            label = 'Toggle Duty',
                            job = shop.job_name,
                            action = function()
                                TriggerServerEvent('qb-mechanic:server:toggleDuty')
                            end
                        }
                    },
                    distance = 2.5
                })
            else -- ox_lib
                exports.ox_target:addBoxZone({
                    coords = vector3(loc.x, loc.y, loc.z),
                    size = vector3(1.5, 1.5, 2),
                    rotation = loc.heading or 0,
                    debug = Config.Debug,
                    options = {
                        {
                            icon = 'fa-solid fa-briefcase',
                            label = 'Toggle Duty',
                            groups = shop.job_name,
                            onSelect = function()
                                TriggerServerEvent('qb-mechanic:server:toggleDuty')
                            end
                        }
                    }
                })
            end
        end
    end
    
    -- Zonas de Stash
    if locations.stash and shop.config_data.features.enable_stash then
        for i, loc in ipairs(locations.stash) do
            if Config.Interact == 'qb-target' then
                exports['qb-target']:AddBoxZone('mechanic_stash_'..shop.id..'_'..i, 
                    vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
                    name = 'mechanic_stash_'..shop.id..'_'..i,
                    heading = loc.heading or 0,
                    debugPoly = Config.Debug,
                    minZ = loc.z - 1,
                    maxZ = loc.z + 2,
                }, {
                    options = {
                        {
                            icon = 'fas fa-toolbox',
                            label = 'Open Stash',
                            job = shop.job_name,
                            action = function()
                                TriggerEvent('qb-mechanic:client:openStash', shop.id)
                            end
                        }
                    },
                    distance = 2.5
                })
            else
                exports.ox_target:addBoxZone({
                    coords = vector3(loc.x, loc.y, loc.z),
                    size = vector3(1.5, 1.5, 2),
                    rotation = loc.heading or 0,
                    debug = Config.Debug,
                    options = {
                        {
                            icon = 'fa-solid fa-toolbox',
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
    end
    
    -- Zonas de Tablet
    if locations.tablet and shop.config_data.features.enable_tablet then
        for i, loc in ipairs(locations.tablet) do
            if Config.Interact == 'qb-target' then
                exports['qb-target']:AddBoxZone('mechanic_tablet_'..shop.id..'_'..i, 
                    vector3(loc.x, loc.y, loc.z), 1.5, 1.5, {
                    name = 'mechanic_tablet_'..shop.id..'_'..i,
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
            else
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
            else
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
    
    -- Zonas de Car Lift (si usas ox_lib points)
    if locations.carlift and Config.Interact == 'ox_lib' then
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
    local vehicle, distance = exports['qb-mechanic-pro']:GetClosestVehicle()
    
    if not vehicle then
        exports['qb-mechanic-pro']:Notify('No vehicle nearby', 'error')
        return
    end
    
    if distance > 5.0 then
        exports['qb-mechanic-pro']:Notify('Vehicle is too far', 'error')
        return
    end
    
    -- Obtener propiedades actuales
    local props = exports['qb-mechanic-pro']:GetVehicleProperties(vehicle)
    
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

-- ----------------------------------------------------------------------------
-- NUI Callback: Crear orden
-- ----------------------------------------------------------------------------
RegisterNUICallback('createOrder', function(data, cb)
    local vehicle, distance = exports['qb-mechanic-pro']:GetClosestVehicle()
    
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
        
        -- Actualizar progreso en UI
        SendNUIMessage({
            action = 'updateInstallProgress',
            step = currentStep,
            total = totalSteps,
            current = mod
        })
        
        -- Aplicar modificación al vehículo
        ApplyModification(vehicle, mod)
        
        -- Esperar 2 segundos por cada modificación
        Wait(2000)
    end
    
    -- Instalación completada exitosamente
    callback(true)
end

-- ----------------------------------------------------------------------------
-- Función: Aplicar una modificación individual
-- ----------------------------------------------------------------------------
function ApplyModification(vehicle, mod)
    SetVehicleModKit(vehicle, 0)
    
    if mod.type == 'engine' then
        SetVehicleMod(vehicle, 11, mod.level or 0, false)
    elseif mod.type == 'brakes' then
        SetVehicleMod(vehicle, 12, mod.level or 0, false)
    elseif mod.type == 'transmission' then
        SetVehicleMod(vehicle, 13, mod.level or 0, false)
    elseif mod.type == 'suspension' then
        SetVehicleMod(vehicle, 15, mod.level or 0, false)
    elseif mod.type == 'armor' then
        SetVehicleMod(vehicle, 16, mod.level or 0, false)
    elseif mod.type == 'turbo' then
        ToggleVehicleMod(vehicle, 18, mod.enabled or false)
    elseif mod.type == 'spoiler' then
        SetVehicleMod(vehicle, 0, mod.index or 0, false)
    elseif mod.type == 'fbumper' then
        SetVehicleMod(vehicle, 1, mod.index or 0, false)
    elseif mod.type == 'rbumper' then
        SetVehicleMod(vehicle, 2, mod.index or 0, false)
    elseif mod.type == 'skirts' then
        SetVehicleMod(vehicle, 3, mod.index or 0, false)
    elseif mod.type == 'exhaust' then
        SetVehicleMod(vehicle, 4, mod.index or 0, false)
    elseif mod.type == 'grille' then
        SetVehicleMod(vehicle, 6, mod.index or 0, false)
    elseif mod.type == 'hood' then
        SetVehicleMod(vehicle, 7, mod.index or 0, false)
    elseif mod.type == 'roof' then
        SetVehicleMod(vehicle, 10, mod.index or 0, false)
    end
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------
exports('InstallModifications', InstallModifications)
exports('ApplyModification', ApplyModification)