local registerNetEvent = RegisterNetEvent
local function showConfirmEmployment(data)
SetNuiFocus(true, true) -- Enable NUI focus
SendNUIMessage({
type = "show-confirm-employment",
data = data,
config = Config,
locale = Locale
})
end
registerNetEvent("jg-mechanic:client:show-confirm-employment", showConfirmEmployment)
local registerNUICallback = RegisterNUICallback
local function acceptHireRequest(data, callback)
TriggerServerEvent("jg-mechanic:server:hire-employee", data)
callback(true) -- Acknowledge the NUI callback
end
registerNUICallback("accept-hire-request", acceptHireRequest)
local function denyHireRequest(data, callback)
TriggerServerEvent("jg-mechanic:server:employee-hire-rejected", data.requesterId)
callback(true) -- Acknowledge the NUI callback
end
registerNUICallback("deny-hire-request", denyHireRequest)
local function requestHireEmployee(data, callback)
if not data.playerId then
return callback({ error = true }) -- Handle missing player ID
end
local playerData = Player(data)
if playerData and playerData.state and playerData.state.isBusy then
-- Notify the client if the player is busy
Framework.Client.Notify(Locale.playerIsBusy, "error")
return callback(true) -- Acknowledge the NUI callback
end
TriggerServerEvent("jg-mechanic:server:request-hire-employee", data)
callback(true) -- Acknowledge the NUI callback
end
registerNUICallback("request-hire-employee", requestHireEmployee)
local function fireEmployee(data, callback)
local employeeIdentifier = data.identifier
local mechanicId = data.mechanicId
TriggerServerEvent("jg-mechanic:server:fire-employee", employeeIdentifier, mechanicId)
callback(true) -- Acknowledge the NUI callback
end
registerNUICallback("fire-employee", fireEmployee)
local function updateEmployeeRole(data, callback)
local employeeIdentifier = data.identifier
local mechanicId = data.mechanicId
local newRole = data.newRole
TriggerServerEvent("jg-mechanic:server:update-employee-role", employeeIdentifier, mechanicId, newRole)
callback(true) -- Acknowledge the NUI callback
end
registerNUICallback("update-employee-role", updateEmployeeRole)