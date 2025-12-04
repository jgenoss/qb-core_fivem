-- ============================================================================
-- QB-MECHANIC-PRO - Configuración Completa
-- ============================================================================

Config = {}

-- ============================================================================
-- CONFIGURACIÓN BÁSICA
-- ============================================================================
Config.Debug = false -- Activar logs de debug
Config.Locale = 'es' -- Idioma: 'en', 'es', 'fr', 'de', etc.

-- ============================================================================
-- FRAMEWORK & INVENTORY
-- ============================================================================
Config.Framework = 'qbcore' -- 'qbcore', 'qbox', 'esx'
Config.Inventory = 'qb-inventory' -- 'qb-inventory', 'ox_inventory', 'qs-inventory', 'ps-inventory'
Config.SocietySystem = 'qb-management' -- 'qb-management', 'qb-banking', 'Renewed-Banking'

-- ============================================================================
-- SISTEMA DE INTERACCIÓN
-- ============================================================================
Config.Interact = 'qb-target' -- 'qb-target', 'ox_target', 'ox_lib'

-- ============================================================================
-- SISTEMA DE COMISIONES
-- ============================================================================
Config.EnableCommissions = true
Config.CommissionRate = 0.10 -- 10% de comisión para mecánicos

-- ============================================================================
-- PRECIOS DE MODIFICACIONES
-- ============================================================================
Config.VehicleMods = {
    -- PERFORMANCE
    Performance = {
        {id = 'engine', label = 'Motor', modType = 11, maxLevel = 4, basePrice = 5000},
        {id = 'brakes', label = 'Frenos', modType = 12, maxLevel = 3, basePrice = 3000},
        {id = 'transmission', label = 'Transmisión', modType = 13, maxLevel = 3, basePrice = 4000},
        {id = 'suspension', label = 'Suspensión', modType = 15, maxLevel = 4, basePrice = 2500},
        {id = 'armor', label = 'Blindaje', modType = 16, maxLevel = 5, basePrice = 7500},
        {id = 'turbo', label = 'Turbo', modType = 18, toggle = true, basePrice = 15000},
    },
    
    -- COSMETIC
    Cosmetic = {
        {id = 'spoiler', label = 'Alerón', modType = 0, basePrice = 1000},
        {id = 'fbumper', label = 'Parachoques Delantero', modType = 1, basePrice = 1500},
        {id = 'rbumper', label = 'Parachoques Trasero', modType = 2, basePrice = 1500},
        {id = 'skirts', label = 'Faldones', modType = 3, basePrice = 1200},
        {id = 'exhaust', label = 'Escape', modType = 4, basePrice = 1000},
        {id = 'grille', label = 'Parrilla', modType = 6, basePrice = 800},
        {id = 'hood', label = 'Capó', modType = 7, basePrice = 2000},
        {id = 'fender', label = 'Guardabarros', modType = 8, basePrice = 1000},
        {id = 'roof', label = 'Techo', modType = 10, basePrice = 1500},
    },
    
    -- WHEELS
    Wheels = {
        {id = 'front_wheels', label = 'Ruedas Delanteras', modType = 23, basePrice = 2000},
        {id = 'back_wheels', label = 'Ruedas Traseras', modType = 24, basePrice = 2000},
        {id = 'wheel_color', label = 'Color de Ruedas', basePrice = 500},
        {id = 'custom_tires', label = 'Neumáticos Custom', basePrice = 1500},
    },
    
    -- PAINT
    Paint = {
        {id = 'primary_color', label = 'Color Primario', basePrice = 1000},
        {id = 'secondary_color', label = 'Color Secundario', basePrice = 1000},
        {id = 'pearlescent', label = 'Perlado', basePrice = 500},
        {id = 'wheel_color', label = 'Color de Ruedas', basePrice = 500},
        {id = 'interior_color', label = 'Color Interior', basePrice = 750},
        {id = 'dashboard_color', label = 'Color Dashboard', basePrice = 750},
    },
    
    -- LIGHTING
    Lighting = {
        {id = 'xenon', label = 'Xenón', basePrice = 2000},
        {id = 'xenon_color', label = 'Color Xenón', basePrice = 500},
        {id = 'neon', label = 'Neón', basePrice = 3000},
        {id = 'neon_color', label = 'Color Neón', basePrice = 500},
    },
    
    -- EXTRAS
    Extras = {
        {id = 'window_tint', label = 'Polarizado', basePrice = 1000},
        {id = 'plate_index', label = 'Estilo de Placa', basePrice = 500},
        {id = 'tire_smoke', label = 'Humo de Neumáticos', basePrice = 2000},
    },
}

-- ============================================================================
-- MULTIPLICADORES DE PRECIO POR TIPO DE MOD
-- ============================================================================
Config.PriceMultipliers = {
    -- Performance mods (por nivel)
    [11] = 1.0,  -- Engine (base)
    [12] = 1.0,  -- Brakes
    [13] = 1.0,  -- Transmission
    [15] = 1.0,  -- Suspension
    [16] = 1.0,  -- Armor
    [18] = 1.0,  -- Turbo
    
    -- Cosmetic mods
    [0] = 1.0,   -- Spoiler
    [1] = 1.0,   -- Front Bumper
    [2] = 1.0,   -- Rear Bumper
    [3] = 1.0,   -- Side Skirts
    [4] = 1.0,   -- Exhaust
    [6] = 1.0,   -- Grille
    [7] = 1.0,   -- Hood
    [8] = 1.0,   -- Fenders
    [10] = 1.0,  -- Roof
    
    -- Wheels
    [23] = 1.0,  -- Front Wheels
    [24] = 1.0,  -- Back Wheels
    
    -- Special
    ['window_tint'] = 1.0,
    ['plate_index'] = 1.0,
    ['neon'] = 1.0,
    ['xenon'] = 1.0,
}

-- ============================================================================
-- SISTEMA DE CARLIFT (Elevador)
-- ============================================================================
Config.Carlift = {
    Enabled = true,
    RaiseHeight = 3.0,         -- Altura en metros
    AnimationSpeed = 0.02,     -- Velocidad de animación
    RequiresPermission = true, -- Requiere job para usar
}

-- ============================================================================
-- SISTEMA DE DUTY (Servicio)
-- ============================================================================
Config.Duty = {
    Enabled = true,
    RequiresDuty = true,  -- Requiere estar en servicio para usar tablets/stash
}

-- ============================================================================
-- SISTEMA DE STASH
-- ============================================================================
Config.Stash = {
    Enabled = true,
    MaxSlots = 50,
    MaxWeight = 100000, -- 100kg
}

-- ============================================================================
-- SISTEMA DE TABLET
-- ============================================================================
Config.Tablet = {
    Enabled = true,
    RequiresBossGrade = 4, -- Grado mínimo para gestión avanzada
    ShowOrderNotifications = true,
}

-- ============================================================================
-- SISTEMA DE TUNESHOP
-- ============================================================================
Config.Tuneshop = {
    Enabled = true,
    AllowPublicAccess = true, -- Cualquiera puede comprar
    RequirePaymentUpfront = true, -- Pagar antes de instalar
    PaymentMethods = {'bank', 'cash'}, -- Métodos de pago disponibles
}

-- ============================================================================
-- SISTEMA DE ÓRDENES
-- ============================================================================
Config.Orders = {
    MaxPendingOrders = 20,        -- Máximo de órdenes pendientes por taller
    AutoDeleteAfterDays = 7,      -- Eliminar órdenes pendientes después de X días
    DeleteCompletedAfterDays = 30, -- Eliminar órdenes completadas después de X días
    InstallTime = 2000,           -- Tiempo por modificación (ms)
}

-- ============================================================================
-- PERMISOS
-- ============================================================================
Config.DefaultPermissions = {
    CreatorAccess = {
        ace = 'command',  -- ACE permission
        minGrade = 4,               -- O grado mínimo
    },
    
    ManagementAccess = function(Player, shop)
        if shop.ownership_type == 'job' and shop.job_name then
            if Player.PlayerData.job.name ~= shop.job_name then
                return false
            end
            
            if Player.PlayerData.job.grade.level < (shop.boss_grade or 4) then
                return false
            end
            
            return true
        end
        
        return false
    end,
    
    EmployeeAccess = function(Player, shop)
        if shop.ownership_type == 'job' and shop.job_name then
            if Player.PlayerData.job.name ~= shop.job_name then
                return false
            end
            
            if Player.PlayerData.job.grade.level < (shop.minimum_grade or 0) then
                return false
            end
            
            return true
        end
        
        return false
    end,
}

-- ============================================================================
-- ITEMS USABLES
-- ============================================================================
Config.Items = {
    repairkit = {
        enabled = true,
        label = 'Kit de Reparación',
        time = 10000, -- 10 segundos
        repairAmount = 'partial', -- 'full' o 'partial'
    },
    
    advanced_repairkit = {
        enabled = true,
        label = 'Kit de Reparación Avanzado',
        time = 15000, -- 15 segundos
        repairAmount = 'full',
    },
    
    sponge = {
        enabled = true,
        label = 'Esponja',
        time = 5000, -- 5 segundos
        cleanVehicle = true,
    },
}

-- ============================================================================
-- NOTIFICACIONES
-- ============================================================================
Config.Notifications = {
    NewOrderReceived = true,  -- Notificar a mecánicos cuando hay nueva orden
    OrderCompleted = true,    -- Notificar al cliente cuando se completa
    EmployeeHired = true,     -- Notificar cuando se contrata empleado
    EmployeeFired = true,     -- Notificar cuando se despide empleado
}

-- ============================================================================
-- CONFIGURACIÓN DE BLIPS
-- ============================================================================
Config.DefaultBlip = {
    sprite = 446,   -- Icono de mecánico
    color = 5,      -- Amarillo
    scale = 0.8,
    label = 'Mechanic Shop',
}

-- ============================================================================
-- CONFIGURACIÓN AVANZADA
-- ============================================================================
Config.Advanced = {
    -- Guardar vehículos automáticamente después de modificaciones
    AutoSaveVehicles = true,
    
    -- Permitir preview de modificaciones sin aplicar
    AllowPreview = true,
    
    -- Sistema de cámaras en tuneshop
    EnableCameraSystem = true,
    
    -- Animaciones de instalación
    EnableInstallAnimations = true,
    
    -- Sonidos
    EnableSounds = true,
    
    -- Efectos visuales
    EnableVisualEffects = true,
}

-- ============================================================================
-- TALLERES POR DEFECTO (Opcional - Se pueden crear desde el creator)
-- ============================================================================
Config.DefaultShops = {
    -- Ejemplo:
    -- ['bennys'] = {
    --     shop_name = 'Benny\'s Original Motor Works',
    --     job_name = 'mechanic',
    --     minimum_grade = 0,
    --     boss_grade = 4,
    --     ownership_type = 'job',
    --     config_data = {
    --         blip = {
    --             enabled = true,
    --             sprite = 446,
    --             color = 5,
    --             scale = 0.8,
    --             label = 'Benny\'s Motor Works'
    --         },
    --         features = {
    --             enable_tuneshop = true,
    --             enable_stash = true,
    --             enable_carlift = true,
    --             enable_tablet = true,
    --         },
    --         locations = {
    --             duty = {
    --                 {x = -205.6992, y = -1310.6377, z = 31.2958, heading = 0.0}
    --             },
    --             stash = {
    --                 {x = -222.4713, y = -1329.7834, z = 31.2958, heading = 0.0}
    --             },
    --             tablet = {
    --                 {x = -212.5278, y = -1318.8529, z = 31.2958, heading = 0.0}
    --             },
    --             tuneshop = {
    --                 {x = -212.0, y = -1324.0, z = 31.3, heading = 0.0}
    --             },
    --             carlift = {
    --                 {x = -215.0, y = -1325.0, z = 31.3, heading = 0.0}
    --             },
    --         },
    --     },
    -- },
}

-- ============================================================================
-- SISTEMA DE LOGS (Webhooks Discord - Opcional)
-- ============================================================================
Config.Webhooks = {
    Enabled = false,
    
    orders = '', -- Webhook para órdenes
    employees = '', -- Webhook para empleados
    money = '', -- Webhook para transacciones
    admin = '', -- Webhook para acciones de admin
}

-- ============================================================================
-- INTEGRACIONES EXTERNAS
-- ============================================================================
Config.Integrations = {
    -- qb-phone para notificaciones
    qb_phone = false,
    
    -- qs-smartphone para notificaciones
    qs_smartphone = false,
    
    -- cd_dispatch para llamadas de grúa
    cd_dispatch = false,
    
    -- ps-dispatch para llamadas de grúa
    ps_dispatch = false,
}

return Config