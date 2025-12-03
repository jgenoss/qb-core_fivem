-- ============================================================================
-- QB-MECHANIC-PRO - Shared Configuration
-- Sistema de auto-detección de frameworks e integraciones
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Función de auto-detección
-- ----------------------------------------------------------------------------
local function checkDependencies(resourceTable)
    for resourceName, frameworkId in pairs(resourceTable) do
        local state = GetResourceState(resourceName)
        if state:find('started') ~= nil then
            print('^2[QB-MECHANIC-PRO]^0 Detected: ' .. resourceName)
            return frameworkId
        end
    end
    return false
end

-- ----------------------------------------------------------------------------
-- Detección de Framework
-- ----------------------------------------------------------------------------
local frameworks = {
    ['es_extended'] = 'esx',
    ['qb-core'] = 'qbcore',
    ['qbx_core'] = 'qbox'
}

-- ----------------------------------------------------------------------------
-- Detección de Inventario
-- ----------------------------------------------------------------------------
local inventorySystems = {
    ['ox_inventory'] = 'ox_inventory',
    ['qb-inventory'] = 'qb-inventory',
    ['qs-inventory'] = 'qs-inventory',
    ['ps-inventory'] = 'ps-inventory',
    ['codem-inventory'] = 'codem-inventory',
    ['origen_inventory'] = 'origin-inventory'
}

-- ----------------------------------------------------------------------------
-- Detección de Sistema de Sociedad
-- ----------------------------------------------------------------------------
local function getSocietySystems()
    local systems = {}
    
    if Config.Framework == 'qbox' then
        systems = {
            ['Renewed-Banking'] = 'Renewed-Banking',
            ['qs-banking'] = 'qs-banking',
            ['okokBanking'] = 'okokbanking'
        }
    elseif Config.Framework == 'esx' then
        systems = {
            ['esx_society'] = 'esx_addonaccount',
            ['esx_addonaccount'] = 'esx_addonaccount',
            ['Renewed-Banking'] = 'Renewed-Banking',
            ['qs-banking'] = 'qs-banking',
            ['okokBanking'] = 'okokbanking'
        }
    else  -- QBCore
        systems = {
            ['qb-core'] = 'qb-core',
            ['qb-management'] = 'qb-management',
            ['qb-banking'] = 'qb-banking',
            ['Renewed-Banking'] = 'Renewed-Banking',
            ['qs-banking'] = 'qs-banking',
            ['okokBanking'] = 'okokbanking'
        }
    end
    
    return systems
end

-- ----------------------------------------------------------------------------
-- Detección de Sistema de Interacción
-- ----------------------------------------------------------------------------
local interactSystems = {
    ['ox_target'] = 'ox_target',
    ['qb-target'] = 'qb-target',
    ['qs-textui'] = 'qs-textui',
    ['ox_lib'] = 'ox_lib'  -- Para textui
}

-- ============================================================================
-- CONFIGURACIÓN PRINCIPAL
-- ============================================================================
Config = {}

-- ----------------------------------------------------------------------------
-- Sistema de Debug
-- ----------------------------------------------------------------------------
Config.Debug = false  -- Activar para ver logs detallados

-- ----------------------------------------------------------------------------
-- Auto-detección de sistemas
-- ----------------------------------------------------------------------------
Config.Framework = checkDependencies(frameworks) or 'qbcore'
Config.Inventory = checkDependencies(inventorySystems) or 'qb-inventory'
Config.Interact = checkDependencies(interactSystems) or 'ox_target'
Config.UseSociety = true
Config.SocietySystem = checkDependencies(getSocietySystems()) or 'qb-core'

-- ----------------------------------------------------------------------------
-- Configuración de interacción
-- ----------------------------------------------------------------------------
Config.UseTarget = Config.Interact == 'ox_target' or Config.Interact == 'qb-target'
Config.TargetResource = Config.Interact
Config.InteractionDistance = 2.5  -- Metros

-- ----------------------------------------------------------------------------
-- Permisos por defecto
-- ----------------------------------------------------------------------------
Config.DefaultPermissions = {
    -- Grados que pueden acceder al creator (admin command)
    CreatorAccess = {
        ace = 'command.mechanic_creator',  -- ACE permission
        groups = {'admin', 'god'}          -- Grupos permitidos
    },
    
    -- Grados que pueden gestionar talleres
    ManagementAccess = function(player, shop)
        if not shop.job_name then return true end  -- Public shop
        if player.job.name ~= shop.job_name then return false end
        return player.job.grade.level >= (shop.boss_grade or 3)
    end
}

-- ----------------------------------------------------------------------------
-- Sistema de comisiones
-- ----------------------------------------------------------------------------
Config.Commissions = {
    -- Porcentaje que recibe el mecánico al completar orden
    MechanicShare = 0.15,  -- 15%
    
    -- Porcentaje que va a la sociedad
    SocietyShare = 0.85,   -- 85%
}

-- ----------------------------------------------------------------------------
-- Configuración de órdenes
-- ----------------------------------------------------------------------------
Config.Orders = {
    -- Tiempo máximo para cancelar orden (minutos)
    CancelTimeout = 60,
    
    -- Permitir múltiples órdenes por vehículo
    AllowMultipleOrders = false,
    
    -- Requiere vehículo presente para instalar
    RequireVehiclePresent = true,
    
    -- Distancia máxima del vehículo al taller
    MaxVehicleDistance = 50.0,
}

-- ----------------------------------------------------------------------------
-- Sistema de modificaciones de vehículos
-- ----------------------------------------------------------------------------
Config.VehicleMods = {
    -- Categorías disponibles en tuneshop
    Categories = {
        {id = 'performance', label = 'Performance', icon = 'fa-tachometer-alt'},
        {id = 'cosmetic', label = 'Cosmético', icon = 'fa-paint-brush'},
        {id = 'wheels', label = 'Ruedas', icon = 'fa-circle'},
        {id = 'lighting', label = 'Iluminación', icon = 'fa-lightbulb'},
    },
    
    -- Mods de performance
    Performance = {
        {id = 'engine', modIndex = 11, label = 'Motor', maxLevel = 4, pricePerLevel = 5000},
        {id = 'brakes', modIndex = 12, label = 'Frenos', maxLevel = 3, pricePerLevel = 3000},
        {id = 'transmission', modIndex = 13, label = 'Transmisión', maxLevel = 3, pricePerLevel = 4000},
        {id = 'suspension', modIndex = 15, label = 'Suspensión', maxLevel = 4, pricePerLevel = 2500},
        {id = 'turbo', modIndex = 18, label = 'Turbo', toggle = true, price = 25000},
    },
    
    -- Mods cosméticos
    Cosmetic = {
        {id = 'spoiler', modIndex = 0, label = 'Spoiler'},
        {id = 'fbumper', modIndex = 1, label = 'Parachoques Delantero'},
        {id = 'rbumper', modIndex = 2, label = 'Parachoques Trasero'},
        {id = 'skirts', modIndex = 3, label = 'Faldones'},
        {id = 'exhaust', modIndex = 4, label = 'Escape'},
        {id = 'hood', modIndex = 7, label = 'Capó'},
        {id = 'grille', modIndex = 6, label = 'Parrilla'},
    }
}

-- ----------------------------------------------------------------------------
-- Precios de servicios básicos
-- ----------------------------------------------------------------------------
Config.Services = {
    RepairBody = 500,      -- Reparar carrocería
    RepairEngine = 1000,   -- Reparar motor
    RepairAll = 1500,      -- Reparación completa
    Wash = 50,             -- Lavado
    Tow = 250,             -- Remolque
}

-- ----------------------------------------------------------------------------
-- Configuración de Carlift
-- ----------------------------------------------------------------------------
Config.Carlift = {
    Enabled = true,
    RaiseHeight = 3.0,     -- Metros de elevación
    AnimationSpeed = 0.05, -- Velocidad de animación
    Models = {
        main = 'prop_carjack',
        arm = 'prop_car_exhaust_01'
    }
}

-- ----------------------------------------------------------------------------
-- Sistema de estadísticas
-- ----------------------------------------------------------------------------
Config.Statistics = {
    -- Actualizar stats cada X minutos
    UpdateInterval = 5,
    
    -- Mantener historial de X días
    HistoryDays = 30,
    
    -- Top rankings
    TopShopsCount = 10,
}

-- ----------------------------------------------------------------------------
-- Mensajes de log
-- ----------------------------------------------------------------------------
if Config.Debug then
    print('^2========================================^0')
    print('^2[QB-MECHANIC-PRO] Configuration Loaded^0')
    print('^3Framework:^0 ' .. Config.Framework)
    print('^3Inventory:^0 ' .. Config.Inventory)
    print('^3Interact:^0 ' .. Config.Interact)
    print('^3Society:^0 ' .. Config.SocietySystem)
    print('^2========================================^0')
end

return Config
