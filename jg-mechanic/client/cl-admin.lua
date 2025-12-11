local registerNetEvent = RegisterNetEvent
local openAdminEvent = "jg-mechanic:client:open-admin"
local function openAdminPanel()
-- Get admin data from the server
local adminData = lib.callback.await("jg-mechanic:server:get-admin-data", false)
if not adminData then
return -- Exit if no admin data received
end
-- Set NUI focus to allow interaction
SetNuiFocus(true, true)
-- Send data to the NUI
SendNUIMessage({
type = "show-mechanic-admin",
mechanics = adminData,
config = Config,
locale = Locale,
})
end
registerNetEvent(openAdminEvent, openAdminPanel)
local registerNUICallback = RegisterNUICallback
local deleteMechanicDataCallback = "delete-mechanic-data"
local function deleteMechanicData(data, callback)
local mechanicId = data.mechanicId
-- Delete mechanic data on the server
local success = lib.callback.await("jg-mechanic:server:delete-mechanic-data", false, mechanicId)
if not success then
-- Return an error to the NUI if deletion failed
local response = {}
response.error = true
return callback(response)
end
-- Reopen the admin panel after successful deletion
TriggerEvent("jg-mechanic:client:open-admin")
callback(true) -- Inform NUI of success
end
registerNUICallback(deleteMechanicDataCallback, deleteMechanicData)
local setMechanicOwnerCallback = "set-mechanic-owner"
local function setMechanicOwner(data, callback)
local mechanicId = data.mechanicId
local player = data.player
-- Set mechanic owner on the server
local success = lib.callback.await("jg-mechanic:server:set-mechanic-owner", false, mechanicId, player)
if not success then
-- Return an error to the NUI if setting owner failed
local response = {}
response.error = true
return callback(response)
end
-- Reopen the admin panel after successfully setting the owner
TriggerEvent("jg-mechanic:client:open-admin")
callback(true) -- Inform NUI of success
end
registerNUICallback(setMechanicOwnerCallback, setMechanicOwner)