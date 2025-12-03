--[[
    ═══════════════════════════════════════════════════════════
    EVENTOS COMPARTIDOS - HUD ULTIMATE v13.2
    Centraliza todos los nombres de eventos para evitar errores
    ═══════════════════════════════════════════════════════════
]]

VEHICLE_EVENTS = {
    -- Eventos de actualización de datos
    UPDATE_VEHICLE_DATA = 'hud:vehicle:updateData',
    UPDATE_VEHICLE_STATUS = 'hud:vehicle:updateStatus',
    
    -- Eventos de alertas
    ENGINE_SEIZED = 'hud:vehicle:engineSeized',
    ENGINE_FIRE = 'hud:vehicle:engineFire',
    LOW_OIL = 'hud:vehicle:lowOil',
    OVERHEAT = 'hud:vehicle:overheat',
    
    -- Eventos de control
    RESET_VEHICLE = 'hud:vehicle:reset',
    SET_OIL_LEVEL = 'hud:vehicle:setOilLevel',
    TOGGLE_SEIZE = 'hud:vehicle:toggleSeize',
}

HUD_EVENTS = {
    -- Eventos de UI
    TOGGLE_HUD = 'hud:ui:toggle',
    UPDATE_HUD = 'hud:ui:update',
    TOGGLE_EDIT_MODE = 'hud:ui:toggleEditMode',
    
    -- Eventos de estrés
    GAIN_STRESS = 'hud:client:GainStress',
    RELIEVE_STRESS = 'hud:client:RelieveStress',
    UPDATE_STRESS = 'hud:client:UpdateStress',
}

-- Export para uso en otros scripts
if IsDuplicityVersion() then
    -- Server
    exports('GetVehicleEvents', function() return VEHICLE_EVENTS end)
    exports('GetHudEvents', function() return HUD_EVENTS end)
end