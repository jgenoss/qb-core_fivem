-- ============================================================================
-- QB-MECHANIC-PRO - QBCore Framework Bridge (Client)
-- ============================================================================

if Config.Framework ~= 'qbcore' and Config.Framework ~= 'qbox' then
    return
end

local QBCore = exports['qb-core']:GetCoreObject()

-- ----------------------------------------------------------------------------
-- Framework Functions
-- ----------------------------------------------------------------------------

function GetPlayerData()
    return QBCore.Functions.GetPlayerData()
end

function GetPlayerJob()
    local PlayerData = GetPlayerData()
    return PlayerData.job
end

function IsPlayerOnDuty()
    local PlayerData = GetPlayerData()
    return PlayerData.job.onduty
end

function GetPlayerMoney(moneyType)
    local PlayerData = GetPlayerData()
    return PlayerData.money[moneyType] or 0
end

-- ----------------------------------------------------------------------------
-- Vehicle Functions
-- ----------------------------------------------------------------------------

function GetVehicleProperties(vehicle)
    return QBCore.Functions.GetVehicleProperties(vehicle)
end

function SetVehicleProperties(vehicle, props)
    return QBCore.Functions.SetVehicleProperties(vehicle, props)
end

-- ----------------------------------------------------------------------------
-- Notification System
-- ----------------------------------------------------------------------------

function ShowNotification(message, type, duration)
    QBCore.Functions.Notify(message, type, duration or 5000)
end

-- ----------------------------------------------------------------------------
-- Progress Bar System
-- ----------------------------------------------------------------------------

function ShowProgressBar(data, callback)
    QBCore.Functions.Progressbar(data.name, data.label, data.duration, data.useWhileDead or false, data.canCancel or true, {
        disableMovement = data.disableMovement or false,
        disableCarMovement = data.disableCarMovement or false,
        disableMouse = data.disableMouse or false,
        disableCombat = data.disableCombat or true,
    }, {
        animDict = data.animDict,
        anim = data.anim,
        flags = data.flags or 16,
    }, {}, {}, function() -- Done
        if callback then callback(true) end
    end, function() -- Cancel
        if callback then callback(false) end
    end)
end

-- ----------------------------------------------------------------------------
-- Input System
-- ----------------------------------------------------------------------------

function ShowInput(data, callback)
    local dialog = exports['qb-input']:ShowInput({
        header = data.header,
        submitText = data.submitText or "Submit",
        inputs = data.inputs
    })
    
    if callback then
        callback(dialog)
    end
    
    return dialog
end

-- ----------------------------------------------------------------------------
-- Menu System
-- ----------------------------------------------------------------------------

function ShowMenu(data, callback)
    exports['qb-menu']:openMenu(data.elements)
    
    if callback then
        callback()
    end
end

function CloseMenu()
    exports['qb-menu']:closeMenu()
end

-- ----------------------------------------------------------------------------
-- Target System (qb-target)
-- ----------------------------------------------------------------------------

if Config.Interact == 'qb-target' then
    function AddTargetZone(name, coords, options)
        exports['qb-target']:AddBoxZone(name, coords, options.width or 1.5, options.height or 1.5, {
            name = name,
            heading = options.heading or 0,
            debugPoly = Config.Debug,
            minZ = coords.z - 1,
            maxZ = coords.z + 2,
        }, {
            options = options.options,
            distance = options.distance or 2.5
        })
    end
    
    function RemoveTargetZone(name)
        exports['qb-target']:RemoveZone(name)
    end
    
    function AddTargetEntity(entity, options)
        exports['qb-target']:AddTargetEntity(entity, {
            options = options.options,
            distance = options.distance or 2.5
        })
    end
    
    function RemoveTargetEntity(entity)
        exports['qb-target']:RemoveTargetEntity(entity)
    end
end

-- ----------------------------------------------------------------------------
-- Inventory System
-- ----------------------------------------------------------------------------

if Config.Inventory == 'qb-inventory' then
    function OpenInventory(type, id, data)
        TriggerServerEvent('inventory:server:OpenInventory', type, id, data)
    end
    
    function OpenStash(stashId)
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', stashId)
        TriggerEvent('inventory:client:SetCurrentStash', stashId)
    end
    
    function HasItem(itemName, amount)
        local PlayerData = GetPlayerData()
        local items = PlayerData.items
        
        if not items then return false end
        
        local itemCount = 0
        for _, item in pairs(items) do
            if item.name == itemName then
                itemCount = itemCount + item.amount
            end
        end
        
        return itemCount >= (amount or 1)
    end
end

-- ----------------------------------------------------------------------------
-- Drawing System
-- ----------------------------------------------------------------------------

function DrawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - coords)
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.35 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

-- ----------------------------------------------------------------------------
-- Exports
-- ----------------------------------------------------------------------------

exports('GetPlayerData', GetPlayerData)
exports('GetPlayerJob', GetPlayerJob)
exports('IsPlayerOnDuty', IsPlayerOnDuty)
exports('ShowNotification', ShowNotification)
exports('ShowProgressBar', ShowProgressBar)
exports('GetVehicleProperties', GetVehicleProperties)
exports('SetVehicleProperties', SetVehicleProperties)