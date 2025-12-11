local currentInvoice = nil -- Stores the current invoice details
RegisterNUICallback("get-unpaid-invoices", function(_, callback)
-- Await server response for unpaid invoices
local unpaidInvoices = lib.callback.await("jg-mechanic:server:get-unpaid-invoices", false)
-- Send the unpaid invoices data back to the NUI
callback(unpaidInvoices)
end)
RegisterNUICallback("save-invoice", function(data, callback)
local invoiceItems = data.invoiceItems
local invoiceTotal = data.invoiceTotal
-- Check if invoice data is valid
if not invoiceItems or not invoiceTotal then
return callback(false) -- Indicate failure
end
-- Await server response after saving the invoice
local success = lib.callback.await("jg-mechanic:server:save-invoice", false, invoiceItems, invoiceTotal)
-- Send the result back to the NUI
callback(success)
end)
RegisterNUICallback("send-invoice", function(data, callback)
local targetPlayerId = data.player
local invoiceItems = data.invoiceItems
local invoiceTotal = data.invoiceTotal
-- Check if required data is present
if not targetPlayerId or not invoiceItems then
return callback(false) -- Indicate failure
end
-- Await server response after sending the invoice
local success = lib.callback.await("jg-mechanic:server:send-invoice", false, targetPlayerId, invoiceItems, invoiceTotal)
-- Send the result back to the NUI
callback(success)
end)
RegisterNUICallback("resend-invoice", function(data, callback)
local targetPlayerId = data.player
local invoiceId = data.invoiceId
-- Check if required data is present
if not targetPlayerId or not invoiceId then
return callback(false) -- Indicate failure
end
-- Await server response after resending the invoice
local success = lib.callback.await("jg-mechanic:server:resend-invoice", false, targetPlayerId, invoiceId)
-- Send the result back to the NUI
callback(success)
end)
RegisterNUICallback("delete-invoice", function(data, callback)
local invoiceId = data.invoiceId
-- Await server response after deleting the invoice
local success = lib.callback.await("jg-mechanic:server:delete-invoice", false, invoiceId)
-- Send the result back to the NUI
callback(success)
end)
RegisterNUICallback("pay-invoice", function(data, callback)
local paymentMethod = data.paymentMethod
-- Check if there's a current invoice to pay
if not currentInvoice then
return callback({ error = true }) -- Indicate an error
end
-- Await server response after attempting to pay the invoice
local success = lib.callback.await("jg-mechanic:server:pay-invoice", false, currentInvoice.invoiceId, currentInvoice.senderPlayerId, paymentMethod)
-- Handle payment failure
if not success then
return callback({ error = true }) -- Indicate an error
end
currentInvoice = nil -- Clear the current invoice
callback(true) -- Indicate success
end)
RegisterNetEvent("jg-mechanic:client:show-invoice-to-player", function(senderPlayerId, invoiceId, invoiceItems, invoiceTotal)
-- Store the invoice details
currentInvoice = {
invoiceId = invoiceId,
senderPlayerId = senderPlayerId
}
-- Additional logic if the invoice is for the local player (potentially mechanic specific?)
if cache.serverId == senderPlayerId then
DisconnectVehicle()
LocalPlayer.state.set(LocalPlayer.state, "mechanicId", nil, true)
end
SetNuiFocus(true, true) -- Open the NUI
SendNUIMessage({
type = "show-invoice",
invoiceItems = invoiceItems,
invoiceTotal = invoiceTotal,
bankBalance = Framework.Client.GetBalance("bank"),
cashBalance = Framework.Client.GetBalance("cash"),
locale = Locale,
config = Config
}) -- Send invoice data to NUI
end)