local QBCore = exports['qb-core']:GetCoreObject()
local currentShop = nil
local isShopOpen = false

-- ================================================================
-- FUNCIÓN: CLASIFICAR ITEM
-- ================================================================
local function ClassifyItem(itemName)
    for _, cat in ipairs(Config.ItemCategories) do
        if cat.id ~= "misc" then
            for _, keyword in ipairs(cat.keywords) do
                if string.find(string.lower(itemName), keyword) then
                    return cat.id
                end
            end
        end
    end
    return "misc"
end

-- ================================================================
-- FUNCIÓN: OBTENER CATEGORÍAS DISPONIBLES
-- ================================================================
local function GetAvailableCategories(items)
    local categories = {}
    local used = {}
    
    for _, item in ipairs(items) do
        local catId = ClassifyItem(item.name)
        if not used[catId] then
            used[catId] = true
            for _, cat in ipairs(Config.ItemCategories) do
                if cat.id == catId then
                    table.insert(categories, {
                        id = cat.id,
                        label = cat.label,
                        icon = cat.icon
                    })
                    break
                end
            end
        end
    end
    
    return categories
end

-- ================================================================
-- EVENTO: ABRIR TIENDA (LLAMADO DESDE qb-advanced-shops)
-- ================================================================
RegisterNetEvent('qb-shop-ui:client:OpenShop', function(shopData)
    if isShopOpen then return end
    
    currentShop = shopData
    isShopOpen = true
    
    -- Enriquecer items con información de QBCore
    local enrichedItems = {}
    for _, item in ipairs(shopData.items) do
        local qbItem = QBCore.Shared.Items[item.name:lower()]
        if qbItem then
            table.insert(enrichedItems, {
                name = item.name:lower(),
                label = qbItem.label,
                price = item.price,
                amount = item.amount,
                image = qbItem.image or (item.name .. ".png"),
                category = ClassifyItem(item.name:lower())
            })
        end
    end
    
    -- Enviar datos a NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openShop',
        shopData = {
            id = shopData.id,
            name = shopData.name,
            type = shopData.type,
            items = enrichedItems
        },
        categories = GetAvailableCategories(enrichedItems),
        imgDir = "nui://" .. Config.InventoryResource .. "/html/images/"
    })
end)

-- ================================================================
-- CALLBACK NUI: CERRAR TIENDA
-- ================================================================
RegisterNUICallback('closeShop', function(_, cb)
    SetNuiFocus(false, false)
    isShopOpen = false
    currentShop = nil
    cb('ok')
end)

-- ================================================================
-- CALLBACK NUI: PROCESAR COMPRA
-- ================================================================
RegisterNUICallback('processPurchase', function(data, cb)
    if not currentShop then 
        cb({success = false, message = "Tienda no disponible"})
        return 
    end
    
    -- Validar datos
    if not data.cart or #data.cart == 0 then
        cb({success = false, message = "Carrito vacío"})
        return
    end
    
    if not data.paymentMethod or (data.paymentMethod ~= "cash" and data.paymentMethod ~= "bank") then
        cb({success = false, message = "Método de pago inválido"})
        return
    end
    
    -- Enviar al servidor para validación y procesamiento
    QBCore.Functions.TriggerCallback('qb-shop-ui:server:ProcessPurchase', function(result)
        if result.success then
            -- Cerrar tienda tras compra exitosa
            SetNuiFocus(false, false)
            isShopOpen = false
            currentShop = nil
            
            QBCore.Functions.Notify(result.message, 'success', 5000)
        else
            QBCore.Functions.Notify(result.message, 'error', 5000)
        end
        
        cb(result)
    end, {
        shopId = currentShop.id,
        cart = data.cart,
        paymentMethod = data.paymentMethod,
        total = data.total
    })
end)

-- ================================================================
-- CLEANUP
-- ================================================================
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if isShopOpen then
        SetNuiFocus(false, false)
        isShopOpen = false
        currentShop = nil
    end
end)

-- ================================================================
-- EXPORT: Abrir tienda (para otros recursos)
-- ================================================================
exports('OpenShop', function(shopId)
    TriggerServerEvent('qb-shop-ui:server:RequestShopOpen', shopId)
end)