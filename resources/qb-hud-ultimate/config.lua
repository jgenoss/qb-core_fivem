CONFIG = {
    -- ═══════════════════════════════════════════════════════════
    -- ⚙️ CONFIGURACIÓN GENERAL
    -- ═══════════════════════════════════════════════════════════
    
    DebugMode = false,  -- ✨ NUEVO: Activar logs detallados en consola
    
    SPEED_MULTIPLIER = 3.6,
    DIRECTIONS = { [0] = 'N', [1] = 'NO', [2] = 'O', [3] = 'SO', [4] = 'S', [5] = 'SE', [6] = 'E', [7] = 'NE', [8] = 'N' },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🗄️ PERSISTENCIA DE DATOS (MySQL)
    -- ═══════════════════════════════════════════════════════════
    
    EnablePersistence = false,  -- ✨ NUEVO: Guardar datos en MySQL
    DataRetentionDays = 7,      -- ✨ NUEVO: Días antes de limpiar datos antiguos
    AutoCleanupInterval = 60,   -- ✨ NUEVO: Minutos entre limpiezas automáticas
    
    -- ═══════════════════════════════════════════════════════════
    -- 🛠️ ITEMS MECÁNICOS
    -- ═══════════════════════════════════════════════════════════
    
    Items = {  -- ✨ NUEVO
        MotorOil = {
            name = 'motor_oil',
            fillAmount = 100,           -- Rellena al 100%
            minLevelToUse = 90,         -- No se puede usar si está sobre 90%
            progressTime = 15000,       -- 15 segundos
            requiredInVehicle = true,   -- Debe estar en vehículo
            requiredDriver = true,      -- Debe ser conductor
        },
        Coolant = {
            name = 'coolant',
            fillAmount = 100,
            minLevelToUse = 90,
            progressTime = 10000,       -- 10 segundos
            requiredInVehicle = true,
            requiredDriver = true,
        },
        CarBattery = {
            name = 'car_battery',
            fillAmount = 100,
            minLevelToUse = 90,
            progressTime = 20000,       -- 20 segundos
            requiredInVehicle = true,
            requiredDriver = true,
        },
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🌡️ TEMPERATURA
    -- ═══════════════════════════════════════════════════════════
    
    TEMP_AMBIENT_BASE = 20,
    TEMP_MIN_RUNNING = 60,
    TEMP_OPTIMAL = 90,
    TEMP_WARNING = 105,
    TEMP_CRITICAL = 120,
    TEMP_MELTDOWN = 130,
    TEMP_IGNITION = 135,
    TEMP_MAX = 150,
    
    TEMP_COOLDOWN_RATE = 0.8,
    TEMP_IDLE_BASE = 0.4,
    TEMP_DRIVING_BASE = 0.6,
    TEMP_DAMAGED_MULTIPLIER = 2.5,
    TEMP_NO_COOLANT_MULTIPLIER = 3.0,
    
    -- ═══════════════════════════════════════════════════════════
    -- 💧 REFRIGERANTE
    -- ═══════════════════════════════════════════════════════════
    
    COOLANT_CONSUMPTION_IDLE = 0.002,      -- Aumentado para realismo
    COOLANT_CONSUMPTION_NORMAL = 0.008,    -- Aumentado para realismo
    COOLANT_CONSUMPTION_DAMAGED = 0.020,   -- Aumentado para realismo
    
    COOLANT_EVAPORATION_TEMP_THRESHOLD = 100,
    COOLANT_EVAPORATION_RATE = {
        [100] = 0.005,
        [105] = 0.015,
        [110] = 0.035,
        [115] = 0.075,
        [120] = 0.150,
        [125] = 0.300,
        [130] = 0.500,
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🛢️ SISTEMA DE ACEITE ULTRA-REALISTA
    -- ═══════════════════════════════════════════════════════════

    -- Consumo base por segundo
    OIL_CONSUMPTION_IDLE = 0.0015,        -- Ralentí: ~18 horas para vaciar
    OIL_CONSUMPTION_NORMAL = 0.006,       -- Normal: ~4.6 horas
    OIL_CONSUMPTION_HIGH_RPM = 0.018,     -- RPM altas: ~1.5 horas

    -- Multiplicadores por daño del motor
    OIL_CONSUMPTION_BY_DAMAGE = {
        [1000] = 1.0,      -- Perfecto
        [950]  = 1.1,
        [900]  = 1.3,
        [850]  = 1.6,
        [800]  = 2.0,
        [750]  = 2.8,
        [700]  = 3.8,
        [650]  = 5.2,
        [600]  = 7.0,
        [550]  = 10.0,
        [500]  = 14.0,
        [450]  = 20.0,
        [400]  = 28.0,
        [350]  = 40.0,
        [300]  = 55.0,
        [250]  = 75.0,
        [200]  = 100.0,
        [150]  = 140.0,
        [100]  = 200.0,
        [50]   = 300.0,
    },

    -- Multiplicadores por temperatura
    OIL_CONSUMPTION_BY_TEMP = {
        [60]  = 1.0,
        [80]  = 1.1,
        [90]  = 1.2,
        [100] = 1.5,
        [105] = 2.0,
        [110] = 3.5,
        [115] = 6.0,
        [120] = 10.0,
        [125] = 18.0,
        [130] = 35.0,
        [135] = 60.0,
        [140] = 100.0,
    },

    -- Ajustes por estilo de conducción
    OIL_CONSUMPTION_AGGRESSIVE_DRIVING = 1.8,
    OIL_CONSUMPTION_TURBO_BOOST = 2.2,
    OIL_CONSUMPTION_RACING = 2.5,
    
    -- Efectos por nivel de aceite
    OIL_EFFECTS = {
        [100] = { 
            powerLoss = 0.00,
            tempIncrease = 0,
            damageRate = 0,
            seizeChance = 0,
            smokeLevel = 0,
            description = "✅ Perfecto"
        },
        [80] = { 
            powerLoss = 0.00,
            tempIncrease = 5,
            damageRate = 0,
            seizeChance = 0,
            smokeLevel = 0,
            description = "⚠️ Bajo"
        },
        [50] = { 
            powerLoss = 0.05,
            tempIncrease = 15,
            damageRate = 2,
            seizeChance = 0.001,
            smokeLevel = 1,
            description = "⚠️ Serio"
        },
        [30] = { 
            powerLoss = 0.20,
            tempIncrease = 30,
            damageRate = 8,
            seizeChance = 0.005,
            smokeLevel = 2,
            description = "🔴 Crítico"
        },
        [10] = { 
            powerLoss = 0.40,
            tempIncrease = 50,
            damageRate = 20,
            seizeChance = 0.02,
            smokeLevel = 3,
            description = "🔴 Destructivo"
        },
        [5] = { 
            powerLoss = 0.70,
            tempIncrease = 80,
            damageRate = 50,
            seizeChance = 0.10,
            smokeLevel = 4,
            description = "☠️ Gripaje Inminente"
        },
    },
    
    SMOKE_PARTICLES = {
        [1] = { scale = 0.3, alpha = 100 },
        [2] = { scale = 0.6, alpha = 150 },
        [3] = { scale = 1.0, alpha = 200 },
        [4] = { scale = 1.5, alpha = 255 },
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- ❄️ REFRIGERACIÓN POR VIENTO
    -- ═══════════════════════════════════════════════════════════
    
    WIND_COOLING = {
        [0]   = 0,      [20]  = -0.1,   [40]  = -0.3,
        [60]  = -0.6,   [80]  = -1.0,   [100] = -1.5,
        [120] = -2.0,   [150] = -2.5,
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- ⚠️ CONSECUENCIAS CRÍTICAS
    -- ═══════════════════════════════════════════════════════════
    
    ENGINE_SEIZE_OIL_THRESHOLD = 5,
    ENGINE_MELTDOWN_TEMP = 130,
    ENGINE_FIRE_TEMP = 135,
    ENGINE_SHUTDOWN_TEMP = 125,
    
    DAMAGE_PER_SECOND_NO_OIL = 25,
    DAMAGE_PER_SECOND_OVERHEATING = 15,
    DAMAGE_PER_SECOND_NO_COOLANT = 20,
    
    POWER_LOSS_PER_TEMP = 0.005,
    POWER_LOSS_LOW_OIL = 0.3,
    
    -- ═══════════════════════════════════════════════════════════
    -- 🌦️ EFECTOS CLIMÁTICOS
    -- ═══════════════════════════════════════════════════════════
    
    WEATHER_EFFECTS = {
        ['CLEAR']       = { tempMod = 1.2,  cooling = 1.0 },
        ['EXTRASUNNY']  = { tempMod = 1.4,  cooling = 0.9 },
        ['OVERCAST']    = { tempMod = 1.0,  cooling = 1.1 },
        ['CLOUDS']      = { tempMod = 1.0,  cooling = 1.1 },
        ['RAIN']        = { tempMod = 0.7,  cooling = 1.8 },
        ['THUNDER']     = { tempMod = 0.6,  cooling = 2.0 },
        ['CLEARING']    = { tempMod = 0.9,  cooling = 1.2 },
        ['FOGGY']       = { tempMod = 0.8,  cooling = 1.3 },
        ['SMOG']        = { tempMod = 1.1,  cooling = 0.9 },
        ['SNOW']        = { tempMod = 0.5,  cooling = 2.5 },
        ['BLIZZARD']    = { tempMod = 0.4,  cooling = 3.0 },
        ['SNOWLIGHT']   = { tempMod = 0.6,  cooling = 2.2 },
        ['XMAS']        = { tempMod = 0.7,  cooling = 2.0 },
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- ⏰ EFECTOS POR HORA DEL DÍA
    -- ═══════════════════════════════════════════════════════════
    
    TIME_EFFECTS = {
        NIGHT = 0.7,
        MORNING = 0.9,
        MIDDAY = 1.3,
        AFTERNOON = 1.1,
        EVENING = 0.8,
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🚗 EFECTOS POR CLASE DE VEHÍCULO
    -- ═══════════════════════════════════════════════════════════
    
    VEHICLE_CLASS_EFFECTS = {
        [0]  = { heat = 1.0, cooling = 1.0 },  -- Compacts
        [1]  = { heat = 1.1, cooling = 1.0 },  -- Sedans
        [2]  = { heat = 1.3, cooling = 0.9 },  -- SUVs
        [3]  = { heat = 1.2, cooling = 1.0 },  -- Coupes
        [4]  = { heat = 1.0, cooling = 1.1 },  -- Muscle
        [5]  = { heat = 1.1, cooling = 1.0 },  -- Sports Classics
        [6]  = { heat = 1.4, cooling = 0.8 },  -- Sports
        [7]  = { heat = 1.6, cooling = 0.7 },  -- Super
        [8]  = { heat = 0.9, cooling = 1.2 },  -- Motorcycles
        [9]  = { heat = 1.2, cooling = 1.0 },  -- Off-road
        [10] = { heat = 1.5, cooling = 0.8 },  -- Industrial
        [11] = { heat = 1.0, cooling = 1.1 },  -- Utility
        [12] = { heat = 1.3, cooling = 0.9 },  -- Vans
        [14] = { heat = 1.1, cooling = 1.0 },  -- Boats
        [15] = { heat = 1.0, cooling = 1.3 },  -- Helicopters
        [16] = { heat = 1.0, cooling = 1.3 },  -- Planes
        [17] = { heat = 1.0, cooling = 1.1 },  -- Service
        [18] = { heat = 1.2, cooling = 1.0 },  -- Emergency
        [19] = { heat = 1.5, cooling = 0.8 },  -- Military
        [20] = { heat = 1.4, cooling = 0.8 },  -- Commercial
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🏞️ EFECTOS POR SUPERFICIE
    -- ═══════════════════════════════════════════════════════════
    
    SURFACE_EFFECTS = {
        ASPHALT   = 1.0,
        DIRT      = 1.2,
        GRASS     = 1.3,
        SAND      = 1.5,
        WATER     = 2.0,
        SNOW      = 1.4,
        GRAVEL    = 1.2,
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🔋 BATERÍA
    -- ═══════════════════════════════════════════════════════════
    
    BATTERY_DRAIN_OFF = 0.001,
    BATTERY_DRAIN_ACCESSORIES = 0.003,
    BATTERY_DRAIN_AC = 0.005,
    BATTERY_CHARGE_RATE = 0.05,
    BATTERY_MIN = 40,
    
    -- ═══════════════════════════════════════════════════════════
    -- 🌡️ OTROS SISTEMAS
    -- ═══════════════════════════════════════════════════════════
    
    AC_HEAT_LOAD = 0.15,
    RADIATOR_FAN_THRESHOLD = 65,
    RADIATOR_FAN_COOLING = -2.5,
    ALTITUDE_THRESHOLD = 500,

    -- ═══════════════════════════════════════════════════════════
    -- 🔧 SISTEMA DE DAÑO DE MOTOR
    -- ═══════════════════════════════════════════════════════════
    
    ENGINE_DAMAGE_THRESHOLDS = {
        PERFECT = 1000,      -- 100% salud
        LIGHT = 800,         -- 80% - Daño leve
        MODERATE = 600,      -- 60% - Daño moderado
        SEVERE = 400,        -- 40% - Daño severo
        CRITICAL = 200,      -- 20% - Daño crítico
        DESTROYED = 100,     -- 10% - Casi destruido
    },

    ENGINE_DAMAGE_EFFECTS = {
        [0] = {  -- Perfecto
            powerLoss = 0.00,
            tempIncrease = 0,
            oilConsumption = 1.0,
            description = "✅ Perfecto"
        },
        [1] = {  -- Leve
            powerLoss = 0.05,
            tempIncrease = 5,
            oilConsumption = 1.2,
            description = "⚠️ Daño Leve"
        },
        [2] = {  -- Moderado
            powerLoss = 0.15,
            tempIncrease = 15,
            oilConsumption = 1.5,
            description = "🟠 Daño Moderado"
        },
        [3] = {  -- Severo
            powerLoss = 0.35,
            tempIncrease = 30,
            oilConsumption = 2.5,
            description = "🔴 Daño Severo"
        },
        [4] = {  -- Crítico
            powerLoss = 0.60,
            tempIncrease = 50,
            oilConsumption = 5.0,
            description = "☠️ Daño Crítico"
        },
    },
    
    -- ═══════════════════════════════════════════════════════════
    -- 🚨 ALERTAS Y NOTIFICACIONES
    -- ═══════════════════════════════════════════════════════════
    
    Alerts = {  -- ✨ NUEVO
        LowOilCooldown = 30000,        -- 30 segundos entre alertas de aceite bajo
        CriticalOilCooldown = 15000,   -- 15 segundos entre alertas críticas
        LowCoolantCooldown = 30000,    -- 30 segundos entre alertas de coolant
        OverheatCooldown = 30000,      -- 30 segundos entre alertas de sobrecalentamiento
        CriticalTempCooldown = 20000,  -- 20 segundos entre alertas de temperatura crítica
        DamageCheckInterval = 10000,   -- 10 segundos entre checks de daño
    },
}

-- ═══════════════════════════════════════════════════════════
-- 🔧 FUNCIONES DE UTILIDAD
-- ═══════════════════════════════════════════════════════════

--[[
    Obtener configuración con valor por defecto
    @param key string - Clave de configuración
    @param default any - Valor por defecto
    @return any - Valor de configuración o default
]]
function CONFIG.Get(key, default)
    return CONFIG[key] ~= nil and CONFIG[key] or default
end

--[[
    Verificar si está en modo debug
    @return boolean
]]
function CONFIG.IsDebug()
    return CONFIG.DebugMode == true
end

--[[
    Imprimir mensaje de debug (solo si DebugMode = true)
    @param message string - Mensaje a imprimir
    @param color string - Color (opcional): 'error', 'success', 'warning', 'info'
]]
function CONFIG.Debug(message, color)
    if not CONFIG.IsDebug() then return end
    
    local colorCode = '^0'
    if color == 'error' then
        colorCode = '^1'
    elseif color == 'success' then
        colorCode = '^2'
    elseif color == 'warning' then
        colorCode = '^3'
    elseif color == 'info' then
        colorCode = '^5'
    end
    
    print(colorCode .. '[HUD DEBUG] ' .. message .. '^0')
end

--[[
    Validar que todas las configuraciones críticas existen
    @return boolean, string - Success, Error message
]]
function CONFIG.Validate()
    local required = {
        'TEMP_MAX', 'TEMP_MIN_RUNNING', 'TEMP_OPTIMAL', 'TEMP_CRITICAL',
        'OIL_CONSUMPTION_IDLE', 'COOLANT_CONSUMPTION_IDLE',
        'ENGINE_SEIZE_OIL_THRESHOLD', 'SPEED_MULTIPLIER', 'OIL_EFFECTS'
    }
    
    for _, key in ipairs(required) do
        if CONFIG[key] == nil then
            return false, 'Falta configuración crítica: CONFIG.' .. key
        end
    end
    
    return true, 'Todas las configuraciones están presentes'
end

-- ═══════════════════════════════════════════════════════════
-- ✅ AUTO-VALIDACIÓN AL CARGAR
-- ═══════════════════════════════════════════════════════════

if IsDuplicityVersion() then
    -- Server-side
    CreateThread(function()
        Wait(1000)
        local success, message = CONFIG.Validate()
        if success then
            print('^2[CONFIG] ✅ Configuración validada exitosamente^0')
        else
            print('^1[CONFIG] ❌ ERROR: ' .. message .. '^0')
        end
    end)
else
    -- Client-side
    CreateThread(function()
        Wait(1000)
        local success, message = CONFIG.Validate()
        if success then
            CONFIG.Debug('Configuración validada exitosamente', 'success')
        else
            CONFIG.Debug('ERROR: ' .. message, 'error')
        end
    end)
end