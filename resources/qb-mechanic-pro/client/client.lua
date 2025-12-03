-- ----------------------------------------------------------------------------
-- 8. INICIALIZACIÓN DE ZONAS AL RECIBIR TALLERES
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:receiveShops', function(shops)
    loadedShops = shops
    if Config.Debug then print('^2[QB-MECHANIC-PRO]^0 Loaded ' .. #shops .. ' shops') end
    
    -- Crear blips
    for _, shop in pairs(shops) do
        CreateShopBlip(shop)
    end
    
    -- Crear zonas de interacción
    TriggerEvent('qb-mechanic:client:createShopZones', shops)
end)

-- ----------------------------------------------------------------------------
-- Event: Teletransportar jugador
-- ----------------------------------------------------------------------------
RegisterNetEvent('qb-mechanic:client:teleport', function(x, y, z)
    local ped = PlayerPedId()
    SetEntityCoords(ped, x, y, z, false, false, false, false)
    Notify('Teleported to shop', 'success')
end)

-- Función para crear blips
function CreateShopBlip(shop)
    if not shop.config_data or not shop.config_data.blip then return end
    
    local blipConfig = shop.config_data.blip
    if not blipConfig.enabled then return end
    
    -- Usar ubicación de duty como referencia
    local coords = shop.config_data.locations.duty
    if not coords then return end
    
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, blipConfig.sprite or 446)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipConfig.scale or 0.8)
    SetBlipColour(blip, blipConfig.color or 5)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipConfig.label or shop.shop_name)
    EndTextCommandSetBlipName(blip)
end