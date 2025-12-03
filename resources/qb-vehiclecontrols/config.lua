Config = {}

-- =====================================================
-- CONFIGURACIÓN PRINCIPAL
-- =====================================================

-- MODO DE APERTURA DEL MENÚ
-- true  = TOGGLE (presionar para abrir, click/ESC para cerrar)
-- false = HOLD (mantener presionado, soltar para cerrar)
Config.Toggle = false

-- TECLA PARA ABRIR EL MENÚ
-- Opciones: 'LMENU' (Left Alt), 'Z', 'CAPSLOCK', 'INSERT', 'HOME', 'U', 'Y'
Config.OpenKey = 'U'

-- PERMITIR MOVIMIENTO MIENTRAS EL MENÚ ESTÁ ABIERTO
-- true  = Puedes moverte y disparar (SetNuiFocusKeepInput)
-- false = Controles completamente deshabilitados
Config.UseWhilstWalking = false

-- =====================================================
-- NOMBRES DE TECLAS (para UI)
-- =====================================================

Config.KeyNames = {
    ['LMENU'] = 'ALT',
    ['Z'] = 'Z',
    ['CAPSLOCK'] = 'BLOQ MAYÚS',
    ['INSERT'] = 'INSERT',
    ['HOME'] = 'HOME',
    ['U'] = 'U',
    ['Y'] = 'Y'
}

Config.CurrentKeyName = Config.KeyNames[Config.OpenKey] or Config.OpenKey

-- =====================================================
-- VEHÍCULOS EXCLUIDOS
-- =====================================================

Config.ExcludedVehicles = {
    'polmav',       -- Helicóptero policial
    'buzzard',      -- Helicóptero de ataque
    'hunter',       -- Avión militar
    'lazer',        -- Jet militar
    'hydra',        -- Jet VTOL
    -- Añade más modelos aquí
}

-- Función para verificar si el vehículo está excluido
function IsVehicleExcluded(vehicleModel)
    local modelName = string.lower(GetDisplayNameFromVehicleModel(vehicleModel))
    for _, excluded in ipairs(Config.ExcludedVehicles) do
        if string.lower(excluded) == modelName then
            return true
        end
    end
    return false
end

-- =====================================================
-- PERMISOS DE ACCIONES
-- =====================================================

Config.Permissions = {
    doors = true,       -- Controlar puertas
    windows = true,     -- Controlar ventanas
    lights = true,      -- Controlar luces/direccionales
    engine = true       -- Controlar motor
}

-- =====================================================
-- NOTIFICACIONES
-- =====================================================

Config.Notifications = {
    enabled = true,
    duration = 2000,
    position = 'top-right'
}

-- =====================================================
-- INTERFAZ VISUAL
-- =====================================================

Config.UI = {
    theme = 'dark',
    primaryColor = '#00d9ff',
    secondaryColor = '#ffffff',
    accentColor = '#ff3232'
}

-- =====================================================
-- DEBUG
-- =====================================================

-- ACTIVAR PARA VER LOGS DE DEPURACIÓN
-- true  = Muestra logs detallados de apertura/cierre
-- false = Sin logs (producción)
Config.Debug = true  -- Activado temporalmente para debuggear parpadeo

function DebugLog(message)
    if Config.Debug then
        print('^3[DEBUG qb-vehiclecontrols]^7 ' .. message)
    end
end

-- =====================================================
-- LOG DE INICIO
-- =====================================================

CreateThread(function()
    Wait(2000)
    print('^2========================================^7')
    print('^2[qb-vehiclecontrols] Sistema Iniciado^7')
    print('^3Modo del menú:^7 ' .. (Config.Toggle and 'TOGGLE (Click)' or 'HOLD (Mantener)'))
    print('^3Tecla del menú:^7 ' .. Config.CurrentKeyName .. ' (' .. Config.OpenKey .. ')')
    print('^3Movimiento durante menú:^7 ' .. (Config.UseWhilstWalking and 'SÍ' or 'NO'))
    print('^2========================================^7')
end)