-- ============================================================================
-- CONFIGURACIÓN DE ÓRDENES
-- ============================================================================
Config.Orders = {
    MaxVehicleDistance = 50.0,          -- Distancia máxima para detectar vehículo
    MechanicCommission = 0.10,          -- 10% de comisión para el mecánico
    EnableOrderNotifications = true,     -- Notificar a mecánicos cuando hay nueva orden
    OrderTimeout = 7,                    -- Días antes de borrar órdenes pendientes
}

-- ============================================================================
-- CONFIGURACIÓN DE CARLIFT
-- ============================================================================
Config.Carlift = {
    Enabled = true,
    RaiseHeight = 3.0,                   -- Altura en metros
    AnimationSpeed = 0.02,               -- Velocidad de animación
    RequireOnDuty = true,                -- Requiere estar en servicio
}

-- ============================================================================
-- CONFIGURACIÓN DE MODIFICACIONES DE VEHÍCULOS
-- ============================================================================
Config.VehicleMods = {
    Categories = {
        {id = 'performance', label = 'Performance', icon = 'fa-gauge-high'},
        {id = 'cosmetic', label = 'Cosmetic', icon = 'fa-spray-can'},
        {id = 'wheels', label = 'Wheels', icon = 'fa-circle'},
        {id = 'lighting', label = 'Lighting', icon = 'fa-lightbulb'},
    },
    
    Performance = {
        {id = 'engine', label = 'Engine', modType = 11, maxLevel = 4, basePrice = 5000},
        {id = 'brakes', label = 'Brakes', modType = 12, maxLevel = 3, basePrice = 3000},
        {id = 'transmission', label = 'Transmission', modType = 13, maxLevel = 3, basePrice = 4000},
        {id = 'suspension', label = 'Suspension', modType = 15, maxLevel = 4, basePrice = 2500},
        {id = 'armor', label = 'Armor', modType = 16, maxLevel = 5, basePrice = 7500},
        {id = 'turbo', label = 'Turbo', modType = 18, toggle = true, basePrice = 15000},
    },
    
    Cosmetic = {
        {id = 'spoiler', label = 'Spoiler', modType = 0, basePrice = 1000},
        {id = 'fbumper', label = 'Front Bumper', modType = 1, basePrice = 1500},
        {id = 'rbumper', label = 'Rear Bumper', modType = 2, basePrice = 1500},
        {id = 'skirts', label = 'Side Skirts', modType = 3, basePrice = 1200},
        {id = 'exhaust', label = 'Exhaust', modType = 4, basePrice = 1000},
        {id = 'grille', label = 'Grille', modType = 6, basePrice = 800},
        {id = 'hood', label = 'Hood', modType = 7, basePrice = 2000},
        {id = 'roof', label = 'Roof', modType = 10, basePrice = 1500},
    },
}

-- ============================================================================
-- PERMISOS POR DEFECTO
-- ============================================================================
Config.DefaultPermissions = {
    CreatorAccess = {
        ace = 'mechanic.creator',       -- ACE permission para el creator
        minGrade = 4,                    -- Grado mínimo si no tiene ACE
    },
    
    ManagementAccess = function(Player, shop)
        if shop.ownership_type == 'job' and shop.job_name then
            if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                return Player.PlayerData.job.name == shop.job_name and 
                       Player.PlayerData.job.grade.level >= (shop.boss_grade or 3)
            elseif Config.Framework == 'esx' then
                return Player.job.name == shop.job_name and 
                       Player.job.grade >= (shop.boss_grade or 3)
            end
        end
        return false
    end,
    
    InstallAccess = function(Player, shop)
        if shop.ownership_type == 'job' and shop.job_name then
            if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
                return Player.PlayerData.job.name == shop.job_name and 
                       Player.PlayerData.job.grade.level >= (shop.minimum_grade or 0)
            elseif Config.Framework == 'esx' then
                return Player.job.name == shop.job_name and 
                       Player.job.grade >= (shop.minimum_grade or 0)
            end
        end
        return true -- Public shops
    end,
}

-- ============================================================================
-- NOTIFICACIONES
-- ============================================================================
Config.Notifications = {
    Type = 'qbcore',  -- 'qbcore', 'esx', 'ox_lib', 'custom'
    Duration = 5000,
    Position = 'top-right',
}

-- ============================================================================
-- DEBUG MODE
-- ============================================================================
Config.Debug = false  -- Activar logs detallados en consola