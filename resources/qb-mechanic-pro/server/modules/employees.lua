-- server/modules/employees.lua

-- Evento: Actualizar grado de empleado (Promover/Degradar)
RegisterNetEvent('qb-mechanic:server:updateGrade', function(shopId, targetCitizenId, newGrade)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    local shop = Database.GetShop(shopId)
    if not shop then return end
    
    -- Verificar si quien ejecuta la acción es Jefe
    if not Config.DefaultPermissions.ManagementAccess(Player, shop) then
        TriggerClientEvent('QBCore:Notify', src, 'No tienes permisos de gestión', 'error')
        return
    end
    
    -- Validaciones de lógica
    if newGrade < 0 then newGrade = 0 end
    if newGrade >= (shop.boss_grade or 3) then 
        TriggerClientEvent('QBCore:Notify', src, 'No puedes ascender a alguien a Jefe directamente', 'error')
        return 
    end

    -- Actualizar en DB
    local success = Database.UpdateEmployeeGrade(shopId, targetCitizenId, newGrade)
    
    if success then
        -- Si el jugador objetivo está conectado, actualizamos su Job en tiempo real
        local TargetPlayer = QBCore.Functions.GetPlayerByCitizenId(targetCitizenId)
        if TargetPlayer and shop.ownership_type == 'job' and shop.job_name then
            TargetPlayer.Functions.SetJob(shop.job_name, newGrade)
            TriggerClientEvent('QBCore:Notify', TargetPlayer.PlayerData.source, 'Tu rango en el taller ha cambiado a: ' .. newGrade, 'primary')
        end
        
        TriggerClientEvent('QBCore:Notify', src, 'Grado de empleado actualizado', 'success')
        
        -- Refrescar la UI del jefe
        TriggerEvent('qb-mechanic:server:requestShopData', shopId)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Error al actualizar grado', 'error')
    end
end)

-- Nota: Los eventos hireEmployee y fireEmployee ya estaban en shops.lua. 
-- Lo ideal sería moverlos aquí para mantener el orden, pero si ya los tienes allá, no hace falta duplicarlos.