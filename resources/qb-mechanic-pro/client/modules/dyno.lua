-- client/modules/dyno.lua

local dynoActive = false

-- Función para calcular datos del Dyno (Simulación realista)
local function CalculateDynoStats(vehicle)
    local rpmCurve = {}
    local torqueCurve = {}
    
    local handling = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveForce")
    local driveInertia = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fDriveInertia")
    local maxSpeed = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fInitialDriveMaxFlatVel")
    
    -- Generar 10 puntos de datos para la gráfica
    for i = 1, 10 do
        local rpm = i * 1000
        -- Fórmula simulada de curva de potencia
        local torque = handling * driveInertia * (1.0 - (i/12)) * 500
        local hp = (torque * rpm) / 5252
        
        table.insert(rpmCurve, rpm)
        table.insert(torqueCurve, { x = rpm, y = math.floor(hp) }) -- HP
    end
    
    return {
        maxSpeed = math.floor(maxSpeed * 1.2), -- km/h aprox
        acceleration = string.format("%.2f", driveInertia),
        force = string.format("%.2f", handling),
        curve = torqueCurve
    }
end

RegisterNetEvent('qb-mechanic:client:openDyno', function()
    local vehicle = exports['qb-mechanic-pro']:GetClosestVehicle()
    
    if not vehicle then
        exports['qb-mechanic-pro']:Notify('No hay vehículo en el dyno', 'error')
        return
    end
    
    local stats = CalculateDynoStats(vehicle)
    
    -- Abrir Tablet directamente en la pestaña Dyno
    TriggerEvent('qb-mechanic:client:openTabletUI', 'dyno_view', {
        section = 'dyno',
        shop_name = 'Dyno Test',
        dynoData = stats,
        vehicleData = {
            plate = GetVehicleNumberPlateText(vehicle),
            model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        }
    })
end)