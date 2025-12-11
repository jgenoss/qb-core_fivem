local registerNUICallback = RegisterNUICallback
registerNUICallback("get-mechanic-balance", function(data, callback)
local mechanicId = data.mechanicId
-- Await server response
local success, eventName, isError, balance = lib.callback.await("jg-mechanic:server:get-mechanic-balance", false, mechanicId)
-- Send the response back to the client
callback(success, eventName, isError, balance)
end)
registerNUICallback("update-mechanic-balance", function(data, callback)
local action = data.action
local mechanicId = data.mechanicId
local amount = data.amount
local source = data.source
if action == "deposit" then
-- Await server response for deposit
local success, eventName, isError, mechanicIdResult, sourceResult, amountResult = lib.callback.await("jg-mechanic:server:mechanic-deposit", false, mechanicId, source, amount)
return callback(success, eventName, isError, mechanicIdResult, sourceResult, amountResult)
elseif action == "withdraw" then
-- Await server response for withdraw
local success, eventName, isError, mechanicIdResult, amountResult = lib.callback.await("jg-mechanic:server:mechanic-withdraw", false, mechanicId, amount)
return callback(success, eventName, isError, mechanicIdResult, amountResult, nil) -- Add nil to match the number of return variables for deposit
end
-- If the action is not deposit or withdraw, return an error
return callback({ error = true })
end)
registerNUICallback("get-mechanic-employees", function(data, callback)
local mechanicId = data.mechanicId
-- Await server response
local success, eventName, isError, employees = lib.callback.await("jg-mechanic:server:get-mechanic-employees", false, mechanicId)
-- Send the response back to the client
callback(success, eventName, isError, employees)
end)
registerNUICallback("update-mechanic-settings", function(data, callback)
local mechanicId = data.mechanicId
-- Await server response
local success, eventName, isError, mechanicIdResult, updatedData = lib.callback.await("jg-mechanic:server:update-mechanic-settings", false, mechanicId, data)
-- Send the response back to the client
callback(success, eventName, isError, mechanicIdResult, updatedData)
end)