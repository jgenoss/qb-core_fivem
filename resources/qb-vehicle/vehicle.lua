local QBCore = exports['qb-core']:GetCoreObject()

-- =============================================================================
-- CLASE VEHICLE - SISTEMA COMPLETO DE CONTROL VEHICULAR
-- =============================================================================
-- Versión: 2.0 Ultra-Completa
-- Autor: Jose's Advanced Vehicle Systems
-- Descripción: Clase completa con TODAS las nativas disponibles de FiveM/GTA V
-- =============================================================================

Vehicle = {}
Vehicle.__index = Vehicle

-- =============================================================================
-- TABLAS DE MAPEO Y CONFIGURACIÓN
-- =============================================================================

local ModTypes = {
    Spoilers = 0, FrontBumper = 1, RearBumper = 2, SideSkirt = 3, Exhaust = 4,
    Frame = 5, Grille = 6, Hood = 7, Fender = 8, RightFender = 9, Roof = 10,
    Engine = 11, Brakes = 12, Transmission = 13, Horns = 14, Suspension = 15,
    Armor = 16, Turbo = 18, Xenon = 22, FrontWheels = 23, BackWheels = 24,
    PlateHolder = 25, VanityPlates = 26, TrimA = 27, Ornaments = 28, Dashboard = 29,
    Dial = 30, DoorSpeaker = 31, Seats = 32, SteeringWheel = 33, Shifter = 34,
    Plaques = 35, Speakers = 36, Trunk = 37, Hydro = 38, EngineBlock = 39,
    AirFilter = 40, Struts = 41, ArchCover = 42, Aerials = 43, TrimB = 44,
    Tank = 45, Windows = 46, Livery = 48
}

local LockStates = {
    [0] = "None",
    [1] = "Unlocked",
    [2] = "Locked",
    [3] = "Lockout",
    [4] = "LockedPlayer",
    [7] = "LockedCanBeDamaged"
}

local VehicleClasses = {
    [0] = "Compacts", [1] = "Sedans", [2] = "SUVs", [3] = "Coupes",
    [4] = "Muscle", [5] = "SportsClassics", [6] = "Sports", [7] = "Super",
    [8] = "Motorcycles", [9] = "OffRoad", [10] = "Industrial", [11] = "Utility",
    [12] = "Vans", [13] = "Cycles", [14] = "Boats", [15] = "Helicopters",
    [16] = "Planes", [17] = "Service", [18] = "Emergency", [19] = "Military",
    [20] = "Commercial", [21] = "Trains", [22] = "OpenWheel"
}

local VehicleFlags = {
    [0] = "SMALL_WORKER", [1] = "BIG", [2] = "NO_BOOT", [3] = "ONLY_DURING_OFFICE_HOURS",
    [4] = "DELIVERY", [5] = "BOOSTED", [6] = "HAS_LIVERY", [7] = "HAS_ROOF_LIVERY",
    [8] = "NO_RESPRAY", [9] = "DONT_SPAWN_IN_CARGEN", [10] = "HAS_INTERIOR_LIGHTS",
    [31] = "LAW_ENFORCEMENT", [36] = "RICH_CAR", [43] = "IS_ELECTRIC", [48] = "IS_OFFROAD_VEHICLE"
}

-- =============================================================================
-- CONSTRUCTOR
-- =============================================================================
function Vehicle:new(vehEntity)
    if not DoesEntityExist(vehEntity) then
        print("^1[ERROR]^7 Vehicle:new() - Entity no existe")
        return nil
    end
    
    local Object = {
        Handle = vehEntity,
        Data = {},
        LastUpdate = GetGameTimer()
    }
    setmetatable(Object, self)
    return Object
end

-- =============================================================================
-- GETTERS: LECTURA COMPLETA DE DATOS
-- =============================================================================

function Vehicle:GetVal()
    if not DoesEntityExist(self.Handle) then return nil end
    SetVehicleModKit(self.Handle, 0)

    local driver = GetPedInVehicleSeat(self.Handle, -1)
    local playerData = QBCore.Functions.GetPlayerData() or {}
    
    -- =========================================================================
    -- 1. INFORMACIÓN BÁSICA Y CLASIFICACIÓN
    -- =========================================================================
    self.Data.Info = {
        Owner       = playerData.citizenid or nil,
        Plate       = GetVehicleNumberPlateText(self.Handle),
        PlateIndex  = GetVehicleNumberPlateTextIndex(self.Handle),
        Class       = GetVehicleClass(self.Handle),
        ClassName   = VehicleClasses[GetVehicleClass(self.Handle)] or "Unknown",
        Type        = GetVehicleType(self.Handle),
        Model       = GetEntityModel(self.Handle),
        DisplayName = GetDisplayNameFromVehicleModel(GetEntityModel(self.Handle)),
        MaxHealth   = GetEntityMaxHealth(self.Handle),
        ColorCombo  = GetVehicleColourCombination(self.Handle),
        DirtLevel   = GetVehicleDirtLevel(self.Handle),
        IsModelValid = IsThisModelACar(GetEntityModel(self.Handle))
    }

    -- =========================================================================
    -- 2. FLAGS DEL VEHÍCULO (Características del Modelo)
    -- =========================================================================
    self.Data.Flags = {
        IsLawEnforcement = GetVehicleHasFlag(self.Handle, 31),
        IsRichCar       = GetVehicleHasFlag(self.Handle, 36),
        IsElectric      = GetVehicleHasFlag(self.Handle, 43),
        IsOffRoad       = GetVehicleHasFlag(self.Handle, 48),
        HasLivery       = GetVehicleHasFlag(self.Handle, 6),
        HasRoofLivery   = GetVehicleHasFlag(self.Handle, 7),
        NoRespray       = GetVehicleHasFlag(self.Handle, 8),
        HasInteriorLights = GetVehicleHasFlag(self.Handle, 10),
        ActiveFlags     = {}
    }
    
    -- Detectar todos los flags activos
    for i = 0, 60 do
        if GetVehicleHasFlag(self.Handle, i) then
            table.insert(self.Data.Flags.ActiveFlags, {
                Index = i,
                Name = VehicleFlags[i] or "UNKNOWN_FLAG_" .. i
            })
        end
    end

    -- =========================================================================
    -- 3. SEGURIDAD (Bloqueos, Alarma, Armas)
    -- =========================================================================
    local lockId = GetVehicleDoorLockStatus(self.Handle)
    self.Data.Security = {
        Locked          = (lockId == 2 or lockId == 4),
        LockMode        = LockStates[lockId] or "Unknown",
        LockStatus      = lockId,
        AlarmActive     = IsVehicleAlarmActivated(self.Handle),
        AlarmTimeLeft   = GetVehicleAlarmTimeLeft(self.Handle),
        HasAlarmMod     = IsToggleModOn(self.Handle, 36),
        Seatbelt        = (driver ~= 0) and not GetPedConfigFlag(driver, 32, true) or false,
        WeaponsDisabled = IsVehicleWeaponDisabled(self.Handle),
        IsStolen        = IsVehicleStolen(self.Handle),
        CanBeLockpicked = GetVehicleDoorLockStatus(self.Handle) == 4
    }

    -- =========================================================================
    -- 4. MOTOR Y MECÁNICA AVANZADA
    -- =========================================================================
    self.Data.Mechanical = {
        EngineOn    = GetIsVehicleEngineRunning(self.Handle),
        Health      = {
            Engine      = GetVehicleEngineHealth(self.Handle),
            Body        = GetVehicleBodyHealth(self.Handle),
            Tank        = GetVehiclePetrolTankHealth(self.Handle),
            MaxHealth   = GetEntityMaxHealth(self.Handle)
        },
        Fluids      = {
            Fuel        = GetVehicleFuelLevel(self.Handle),
            Oil         = GetVehicleOilLevel(self.Handle),
            Temperature = GetVehicleEngineTemperature(self.Handle) -- CFX Native
        },
        Electrics   = {
            Battery     = true -- No hay getter directo, asumido si arranca
        },
        Damage      = {
            CauseHash       = GetVehicleCauseOfDestruction(self.Handle),
            IsUndriveable   = not IsVehicleDriveable(self.Handle, false),
            CanEngineStart  = GetVehicleEngineHealth(self.Handle) > 0,
            IsOnAllWheels   = IsVehicleOnAllWheels(self.Handle),
            IsInBurnout     = IsVehicleInBurnout(self.Handle),
            IsStuck         = IsVehicleStuckOnRoof(self.Handle)
        }
    }

    -- =========================================================================
    -- 5. RENDIMIENTO Y FÍSICA
    -- =========================================================================
    self.Data.Performance = {
        -- Dashboard (Visual)
        DashboardSpeed  = GetVehicleDashboardSpeed(self.Handle) * 3.6, -- km/h
        DashboardRPM    = GetVehicleDashboardRpm(self.Handle),
        DashboardGear   = GetVehicleDashboardCurrentGear(self.Handle),
        
        -- Real (Físico)
        CurrentSpeed    = GetEntitySpeed(self.Handle) * 3.6, -- km/h
        CurrentRPM      = GetVehicleCurrentRpm(self.Handle), -- RPM real
        CurrentGear     = GetVehicleCurrentGear(self.Handle), -- Marcha actual
        NextGear        = GetVehicleNextGear(self.Handle), -- Próxima marcha
        HighGear        = GetVehicleHighGear(self.Handle), -- Marcha más alta disponible
        
        -- Características de Rendimiento
        Acceleration    = GetVehicleAcceleration(self.Handle),
        TopSpeedMod     = GetVehicleTopSpeedModifier(self.Handle),
        EstimatedMaxSpeed = GetVehicleEstimatedMaxSpeed(self.Handle) * 3.6, -- km/h
        
        -- Clase del Vehículo (Stats)
        ClassMaxSpeed       = GetVehicleClassMaxSpeed(GetVehicleClass(self.Handle)) * 3.6,
        ClassMaxAccel       = GetVehicleClassMaxAcceleration(GetVehicleClass(self.Handle)),
        ClassMaxBraking     = GetVehicleClassMaxBraking(GetVehicleClass(self.Handle)),
        ClassMaxTraction    = GetVehicleClassMaxTraction(GetVehicleClass(self.Handle)),
        ClassMaxAgility     = GetVehicleClassMaxAgility(GetVehicleClass(self.Handle))
    }

    -- =========================================================================
    -- 6. HANDLING DINÁMICO (CFX Natives)
    -- =========================================================================
    self.Data.Handling = {
        Mass            = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fMass'),
        BrakeForce      = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fBrakeForce'),
        BrakeBiasFront  = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fBrakeBiasFront'),
        SteeringLock    = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fSteeringLock'),
        TractionCurveMax = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fTractionCurveMax'),
        TractionCurveMin = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fTractionCurveMin'),
        Suspension      = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fSuspensionForce'),
        AntiRollBarForce = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fAntiRollBarForce'),
        DriveInertia    = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fDriveInertia'),
        ClutchChangeUp  = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fClutchChangeRateScaleUpShift'),
        ClutchChangeDown = GetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fClutchChangeRateScaleDownShift'),
        CentreOfMass    = GetVehicleHandlingVector(self.Handle, 'CHandlingData', 'vecCentreOfMassOffset'),
        ModelFlags      = GetVehicleHandlingInt(self.Handle, 'CHandlingData', 'strModelFlags')
    }

    -- =========================================================================
    -- 7. FÍSICA Y GRAVEDAD
    -- =========================================================================
    self.Data.Physics = {
        GravityAmount   = 1.0, -- No hay getter, se almacena cuando se setea
        HasReducedGrip  = false, -- No hay getter, se almacena cuando se setea
        SteerBias       = 0.0, -- No hay getter, se almacena cuando se setea
        IsStuck         = IsVehicleStuckOnRoof(self.Handle),
        IsStuckTimer    = IsVehicleStuckTimerUp(self.Handle, 0, 3000)
    }

    -- =========================================================================
    -- 8. DASHBOARD DETALLADO (Instrumentos)
    -- =========================================================================
    self.Data.Dashboard = {
        Speed       = GetVehicleDashboardSpeed(self.Handle) * 3.6,
        RPM         = GetVehicleDashboardRpm(self.Handle),
        Fuel        = GetVehicleDashboardFuel(self.Handle),
        Temp        = GetVehicleDashboardTemp(self.Handle),
        OilTemp     = GetVehicleDashboardOilTemp(self.Handle),
        OilPressure = GetVehicleDashboardOilPressure(self.Handle),
        Vacuum      = GetVehicleDashboardVacuum(self.Handle),
        Boost       = GetVehicleDashboardBoost(self.Handle),
        Gear        = GetVehicleDashboardCurrentGear(self.Handle)
    }

    -- =========================================================================
    -- 9. LUCES E ILUMINACIÓN
    -- =========================================================================
    local _, lightState, highBeams = GetVehicleLightsState(self.Handle)
    local ind = GetVehicleIndicatorLights(self.Handle)
    
    self.Data.Lights = {
        AreOn       = lightState == 1,
        HighBeams   = highBeams == 1,
        Interior    = IsVehicleInteriorLightOn(self.Handle),
        Taxi        = IsTaxiLightOn(self.Handle),
        SearchLight = IsVehicleSearchlightOn(self.Handle),
        Siren       = IsVehicleSirenOn(self.Handle),
        Indicators  = {
            Left    = (ind == 1 or ind == 3),
            Right   = (ind == 2 or ind == 3),
            Both    = (ind == 3)
        },
        Neon = {
            Left    = IsVehicleNeonLightEnabled(self.Handle, 0),
            Right   = IsVehicleNeonLightEnabled(self.Handle, 1),
            Front   = IsVehicleNeonLightEnabled(self.Handle, 2),
            Back    = IsVehicleNeonLightEnabled(self.Handle, 3),
            Color   = { GetVehicleNeonLightsColour(self.Handle) }
        },
        XenonColor  = GetVehicleXenonLightsColour(self.Handle),
        XenonEnabled = IsToggleModOn(self.Handle, 22)
    }

    -- =========================================================================
    -- 10. AUDIO Y RADIO
    -- =========================================================================
    self.Data.Audio = {
        RadioOn     = IsVehicleRadioOn(self.Handle),
        RadioLoud   = false, -- No hay getter, se almacena cuando se setea
        HornActive  = IsHornActive(self.Handle),
        SirenOn     = IsVehicleSirenOn(self.Handle)
    }

    -- =========================================================================
    -- 11. PUERTAS Y VENTANAS
    -- =========================================================================
    self.Data.Doors = {}
    for i = 0, 5 do
        self.Data.Doors[i] = {
            Open        = GetVehicleDoorAngleRatio(self.Handle, i) > 0.1,
            Angle       = GetVehicleDoorAngleRatio(self.Handle, i),
            Broken      = IsVehicleDoorDamaged(self.Handle, i),
            FullyOpen   = GetVehicleDoorAngleRatio(self.Handle, i) > 0.9
        }
    end

    self.Data.Windows = {}
    for i = 0, 7 do -- Hasta 8 ventanas posibles
        self.Data.Windows[i] = {
            Intact      = IsVehicleWindowIntact(self.Handle, i),
            Status      = IsVehicleWindowIntact(self.Handle, i) and "Intact" or "Broken"
        }
    end

    -- =========================================================================
    -- 12. NEUMÁTICOS Y RUEDAS
    -- =========================================================================
    self.Data.Tyres = {}
    local numWheels = GetVehicleNumberOfWheels(self.Handle)
    
    for i = 0, numWheels - 1 do
        self.Data.Tyres[i] = {
            Burst           = IsVehicleTyreBurst(self.Handle, i, false),
            TotallyBurst    = IsVehicleTyreBurst(self.Handle, i, true),
            Health          = GetTyreHealth(self.Handle, i),
            WearMultiplier  = GetTyreWearMultiplier(self.Handle, i),
            CanBurst        = GetVehicleTyresCanBurst(self.Handle)
        }
    end
    
    self.Data.Tyres.SmokeColor = { GetVehicleTyreSmokeColor(self.Handle) }
    self.Data.Tyres.DriftEnabled = GetDriftTyresEnabled(self.Handle)

    -- =========================================================================
    -- 13. MODOS ESPECIALES (Avión/Submarino/Boost)
    -- =========================================================================
    self.Data.Special = {
        -- Aviones
        LandingGear         = GetLandingGearState(self.Handle),
        IsPlane             = IsThisModelAPlane(GetEntityModel(self.Handle)),
        IsHeli              = IsThisModelAHeli(GetEntityModel(self.Handle)),
        
        -- Submarinos
        IsSubmarine         = IsVehicleInSubmarineMode(self.Handle),
        
        -- Paracaídas (Ruiner)
        ParachuteActive     = IsVehicleParachuteActive(self.Handle),
        
        -- Drift
        DriftTyres          = GetDriftTyresEnabled(self.Handle),
        
        -- Boost/Rocket
        RocketBoostActive   = IsVehicleRocketBoostActive(self.Handle),
        
        -- Nitro
        NitroActive         = false, -- Custom, no hay native
        NitroPercent        = 100.0  -- Custom
    }

    -- =========================================================================
    -- 14. TUNING Y MODIFICACIONES
    -- =========================================================================
    self.Data.Mods = {}
    self.Data.Mods.WheelType = GetVehicleWheelType(self.Handle)
    self.Data.Mods.WindowTint = GetVehicleWindowTint(self.Handle)
    self.Data.Mods.Livery = GetVehicleLivery(self.Handle)
    self.Data.Mods.RoofLivery = GetVehicleRoofLivery(self.Handle)

    for name, index in pairs(ModTypes) do
        if index == 18 or index == 22 then
            self.Data.Mods[name] = IsToggleModOn(self.Handle, index)
        else
            local modValue = GetVehicleMod(self.Handle, index)
            local modCount = GetNumVehicleMods(self.Handle, index)
            self.Data.Mods[name] = {
                Current = modValue,
                Max = modCount
            }
        end
    end

    -- =========================================================================
    -- 15. COLORES
    -- =========================================================================
    local pR, pG, pB = GetVehicleCustomPrimaryColour(self.Handle)
    local sR, sG, sB = GetVehicleCustomSecondaryColour(self.Handle)
    local pearl, wheelCol = GetVehicleExtraColours(self.Handle)
    local primCol, secCol = GetVehicleColours(self.Handle)

    self.Data.Colors = {
        Primary     = {r = pR, g = pG, b = pB},
        Secondary   = {r = sR, g = sG, b = sB},
        PrimaryID   = primCol,
        SecondaryID = secCol,
        Pearlescent = pearl,
        Wheels      = wheelCol,
        Dashboard   = GetVehicleDashboardColour(self.Handle),
        Interior    = GetVehicleInteriorColour(self.Handle),
        Combo       = GetVehicleColourCombination(self.Handle)
    }

    -- =========================================================================
    -- 16. EXTRAS
    -- =========================================================================
    self.Data.Extras = {}
    for i = 0, 20 do
        if DoesExtraExist(self.Handle, i) then
            self.Data.Extras[i] = IsVehicleExtraTurnedOn(self.Handle, i)
        end
    end

    -- =========================================================================
    -- 17. ARMAS DEL VEHÍCULO
    -- =========================================================================
    if driver ~= 0 then
        local _, weaponHash = GetCurrentPedVehicleWeapon(driver)
        self.Data.Weapons = {
            Disabled        = IsVehicleWeaponDisabled(self.Handle),
            CurrentHash     = weaponHash,
            HasWeapons      = DoesVehicleHaveWeapons(self.Handle)
        }
    else
        self.Data.Weapons = {
            Disabled        = IsVehicleWeaponDisabled(self.Handle),
            CurrentHash     = 0,
            HasWeapons      = DoesVehicleHaveWeapons(self.Handle)
        }
    end

    -- =========================================================================
    -- 18. VEHÍCULOS ESPECIALES (Tren/Bote)
    -- =========================================================================
    if self.Data.Info.Type == "train" then
        self.Data.Train = {
            Speed           = GetTrainSpeed(self.Handle),
            IsEngine        = IsThisModelATrainEngine(GetEntityModel(self.Handle)),
            CarriageIndex   = GetTrainCarriageIndex(self.Handle)
        }
    elseif self.Data.Info.Type == "boat" then
        self.Data.Boat = {
            BoomPosition    = GetBoatBoomPositionRatio(self.Handle),
            IsAnchored      = IsBoatAnchoredAndFrozen(self.Handle)
        }
    end

    self.LastUpdate = GetGameTimer()
    return self.Data
end

-- =============================================================================
-- SETTERS: APLICACIÓN COMPLETA DE CAMBIOS
-- =============================================================================

function Vehicle:SetVal(data)
    if not DoesEntityExist(self.Handle) then return end
    SetVehicleModKit(self.Handle, 0)

    -- =========================================================================
    -- 1. INFORMACIÓN GENERAL
    -- =========================================================================
    if data.Info then
        if data.Info.Plate then SetVehicleNumberPlateText(self.Handle, data.Info.Plate) end
        if data.Info.PlateIndex then SetVehicleNumberPlateTextIndex(self.Handle, data.Info.PlateIndex) end
        if data.Info.DirtLevel then SetVehicleDirtLevel(self.Handle, data.Info.DirtLevel + 0.0) end
        if data.Info.ColorCombo then SetVehicleColourCombination(self.Handle, data.Info.ColorCombo) end
    end

    -- =========================================================================
    -- 2. FLAGS DEL VEHÍCULO
    -- =========================================================================
    if data.Flags then
        for flagIndex, value in pairs(data.Flags) do
            if type(flagIndex) == "number" then
                SetVehicleHasFlag(self.Handle, flagIndex, value)
            end
        end
    end

    -- =========================================================================
    -- 3. SEGURIDAD
    -- =========================================================================
    if data.Security then
        if data.Security.LockMode then 
            SetVehicleDoorsLocked(self.Handle, data.Security.LockMode)
        elseif data.Security.Locked ~= nil then 
            SetVehicleDoorsLocked(self.Handle, data.Security.Locked and 2 or 1) 
        end
        
        if data.Security.AlarmStart then StartVehicleAlarm(self.Handle) end
        if data.Security.AlarmStop then SetVehicleAlarm(self.Handle, false) end
        if data.Security.AlarmTime then SetVehicleAlarmTimeLeft(self.Handle, data.Security.AlarmTime) end

        local driver = GetPedInVehicleSeat(self.Handle, -1)
        if driver ~= 0 and data.Security.Seatbelt ~= nil then
            SetPedConfigFlag(driver, 32, not data.Security.Seatbelt)
        end

        if data.Security.WeaponsDisabled ~= nil then
            SetVehicleWeaponsDisabled(self.Handle, data.Security.WeaponsDisabled)
        end
    end

    -- =========================================================================
    -- 4. MOTOR Y MECÁNICA
    -- =========================================================================
    if data.Mechanical then
        local m = data.Mechanical
        if m.EngineOn ~= nil then SetVehicleEngineOn(self.Handle, m.EngineOn, true, true) end
        
        if m.Health then
            if m.Health.Engine then SetVehicleEngineHealth(self.Handle, m.Health.Engine + 0.0) end
            if m.Health.Body then SetVehicleBodyHealth(self.Handle, m.Health.Body + 0.0) end
            if m.Health.Tank then SetVehiclePetrolTankHealth(self.Handle, m.Health.Tank + 0.0) end
        end
        
        if m.Fluids then
            if m.Fluids.Fuel then SetVehicleFuelLevel(self.Handle, m.Fluids.Fuel + 0.0) end
            if m.Fluids.Oil then SetVehicleOilLevel(self.Handle, m.Fluids.Oil + 0.0) end
            if m.Fluids.Temperature then SetVehicleEngineTemperature(self.Handle, m.Fluids.Temperature + 0.0) end
        end
        
        if m.Damage then
            if m.Damage.Undriveable ~= nil then SetVehicleUndriveable(self.Handle, m.Damage.Undriveable) end
        end
    end

    -- =========================================================================
    -- 5. RENDIMIENTO
    -- =========================================================================
    if data.Performance then
        if data.Performance.CurrentGear then SetVehicleCurrentGear(self.Handle, data.Performance.CurrentGear) end
        if data.Performance.NextGear then SetVehicleNextGear(self.Handle, data.Performance.NextGear) end
        if data.Performance.HighGear then SetVehicleHighGear(self.Handle, data.Performance.HighGear) end
        if data.Performance.TopSpeedMod then SetVehicleTopSpeedModifier(self.Handle, data.Performance.TopSpeedMod) end
        if data.Performance.PowerIncrease then SetVehicleCheatPowerIncrease(self.Handle, data.Performance.PowerIncrease) end
    end

    -- =========================================================================
    -- 6. HANDLING DINÁMICO (CFX Natives)
    -- =========================================================================
    if data.Handling then
        if data.Handling.Mass then 
            SetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fMass', data.Handling.Mass) 
        end
        if data.Handling.BrakeForce then 
            SetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fBrakeForce', data.Handling.BrakeForce) 
        end
        if data.Handling.SteeringLock then 
            SetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fSteeringLock', data.Handling.SteeringLock) 
        end
        if data.Handling.TractionCurveMax then 
            SetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fTractionCurveMax', data.Handling.TractionCurveMax) 
        end
        if data.Handling.Suspension then 
            SetVehicleHandlingFloat(self.Handle, 'CHandlingData', 'fSuspensionForce', data.Handling.Suspension) 
        end
        if data.Handling.CentreOfMass then
            SetVehicleHandlingVector(self.Handle, 'CHandlingData', 'vecCentreOfMassOffset', data.Handling.CentreOfMass)
        end
    end

    -- =========================================================================
    -- 7. FÍSICA
    -- =========================================================================
    if data.Physics then
        if data.Physics.GravityAmount then 
            SetVehicleGravityAmount(self.Handle, data.Physics.GravityAmount) 
        end
        if data.Physics.ReduceGrip ~= nil then 
            SetVehicleReduceGrip(self.Handle, data.Physics.ReduceGrip) 
        end
        if data.Physics.ReduceTraction ~= nil then
            SetVehicleReduceTraction(self.Handle, data.Physics.ReduceTraction)
        end
        if data.Physics.SteerBias then 
            SetVehicleSteerBias(self.Handle, data.Physics.SteerBias) 
        end
    end

    -- =========================================================================
    -- 8. LUCES Y NEONES
    -- =========================================================================
    if data.Lights then
        local l = data.Lights
        if l.On ~= nil then SetVehicleLights(self.Handle, l.On and 2 or 1) end
        if l.HighBeams ~= nil then SetVehicleFullbeam(self.Handle, l.HighBeams) end
        if l.Interior ~= nil then SetVehicleInteriorlight(self.Handle, l.Interior) end
        if l.Taxi ~= nil then SetTaxiLights(self.Handle, l.Taxi) end
        if l.SearchLight ~= nil then SetVehicleSearchlight(self.Handle, l.SearchLight, false) end
        if l.Siren ~= nil then SetVehicleSiren(self.Handle, l.Siren) end
        
        if l.Indicators then
            if l.Indicators.Left ~= nil then SetVehicleIndicatorLights(self.Handle, 1, l.Indicators.Left) end
            if l.Indicators.Right ~= nil then SetVehicleIndicatorLights(self.Handle, 0, l.Indicators.Right) end
        end

        if l.Neon then
            if l.Neon.Left ~= nil then SetVehicleNeonLightEnabled(self.Handle, 0, l.Neon.Left) end
            if l.Neon.Right ~= nil then SetVehicleNeonLightEnabled(self.Handle, 1, l.Neon.Right) end
            if l.Neon.Front ~= nil then SetVehicleNeonLightEnabled(self.Handle, 2, l.Neon.Front) end
            if l.Neon.Back ~= nil then SetVehicleNeonLightEnabled(self.Handle, 3, l.Neon.Back) end
            if l.Neon.Color then
                local r, g, b = table.unpack(l.Neon.Color)
                SetVehicleNeonLightsColour(self.Handle, r, g, b)
            end
        end
        
        if l.XenonColor then SetVehicleXenonLightsColour(self.Handle, l.XenonColor) end
        if l.XenonEnabled ~= nil then ToggleVehicleMod(self.Handle, 22, l.XenonEnabled) end
    end

    -- =========================================================================
    -- 9. AUDIO
    -- =========================================================================
    if data.Audio then
        if data.Audio.RadioEnabled ~= nil then SetVehicleRadioEnabled(self.Handle, data.Audio.RadioEnabled) end
        if data.Audio.Loud ~= nil then SetVehicleRadioLoud(self.Handle, data.Audio.Loud) end
        if data.Audio.Horn then
            StartVehicleHorn(self.Handle, data.Audio.Horn.Duration or 1000, data.Audio.Horn.Mode or 0, false)
        end
    end

    -- =========================================================================
    -- 10. PUERTAS Y VENTANAS
    -- =========================================================================
    if data.Doors then
        for k, v in pairs(data.Doors) do
            local idx = tonumber(k)
            if idx then
                if v == "open" or v == true then 
                    SetVehicleDoorOpen(self.Handle, idx, false, false) 
                end
                if v == "close" or v == false then 
                    SetVehicleDoorShut(self.Handle, idx, false) 
                end
                if v == "broken" then 
                    SetVehicleDoorBroken(self.Handle, idx, true) 
                end
                if type(v) == "table" and v.Angle then
                    -- Ángulo custom
                    SetVehicleDoorControl(self.Handle, idx, 1, v.Angle)
                end
            end
        end
    end

    if data.Windows then
        for k, v in pairs(data.Windows) do
            local idx = tonumber(k)
            if idx then
                if v == "up" or v == true then RollUpWindow(self.Handle, idx) end
                if v == "down" or v == false then RollDownWindow(self.Handle, idx) end
                if v == "smash" then SmashVehicleWindow(self.Handle, idx) end
                if v == "remove" then RemoveVehicleWindow(self.Handle, idx) end
                if v == "fix" then FixVehicleWindow(self.Handle, idx) end
            end
        end
        if data.Windows.PopWindscreen then PopOutVehicleWindscreen(self.Handle) end
    end

    -- =========================================================================
    -- 11. NEUMÁTICOS
    -- =========================================================================
    if data.Tyres then
        for k, v in pairs(data.Tyres) do
            local idx = tonumber(k)
            if idx then
                if v == "burst" then SetVehicleTyreBurst(self.Handle, idx, true, 1000.0) end
                if v == "fix" then SetVehicleTyreFixed(self.Handle, idx) end
                if type(v) == "table" then
                    if v.Burst then SetVehicleTyreBurst(self.Handle, idx, true, 1000.0) end
                    if v.Fix then SetVehicleTyreFixed(self.Handle, idx) end
                end
            end
        end
        
        if data.Tyres.SmokeColor then
            local r, g, b = table.unpack(data.Tyres.SmokeColor)
            SetVehicleTyreSmokeColor(self.Handle, r, g, b)
        end
        
        if data.Tyres.CanBurst ~= nil then
            SetVehicleTyresCanBurst(self.Handle, data.Tyres.CanBurst)
        end
        
        if data.Tyres.DriftEnabled ~= nil then
            SetDriftTyresEnabled(self.Handle, data.Tyres.DriftEnabled)
        end
    end

    -- =========================================================================
    -- 12. MODOS ESPECIALES
    -- =========================================================================
    if data.Special then
        if data.Special.LandingGear ~= nil then 
            ControlLandingGear(self.Handle, data.Special.LandingGear) 
        end
        
        if data.Special.Submarine ~= nil and data.Special.Submarine then
            SetVehicleSubmersible(self.Handle, true)
        end
        
        if data.Special.ParachuteActive ~= nil then
            SetVehicleParachuteActive(self.Handle, data.Special.ParachuteActive)
        end
        
        if data.Special.DriftTyres ~= nil then
            SetDriftTyresEnabled(self.Handle, data.Special.DriftTyres)
        end
        
        if data.Special.RocketBoostPercent then
            SetVehicleRocketBoostPercentage(self.Handle, data.Special.RocketBoostPercent)
        end
        
        if data.Special.RocketBoostActive ~= nil then
            SetVehicleRocketBoostActive(self.Handle, data.Special.RocketBoostActive)
        end
    end

    -- =========================================================================
    -- 13. TUNING Y MODIFICACIONES
    -- =========================================================================
    if data.Mods then
        if data.Mods.WheelType then SetVehicleWheelType(self.Handle, data.Mods.WheelType) end
        if data.Mods.WindowTint then SetVehicleWindowTint(self.Handle, data.Mods.WindowTint) end
        
        for k, v in pairs(data.Mods) do
            local idx = ModTypes[k]
            if idx then
                if idx == 18 or idx == 22 then 
                    ToggleVehicleMod(self.Handle, idx, v)
                elseif type(v) == "number" then 
                    SetVehicleMod(self.Handle, idx, v, false)
                elseif type(v) == "table" and v.Current then
                    SetVehicleMod(self.Handle, idx, v.Current, false)
                end
            end
        end
        
        if data.Mods.Livery then
            SetVehicleLivery(self.Handle, data.Mods.Livery)
            SetVehicleMod(self.Handle, 48, data.Mods.Livery, false)
        end
        
        if data.Mods.RoofLivery then
            SetVehicleRoofLivery(self.Handle, data.Mods.RoofLivery)
        end
    end

    -- =========================================================================
    -- 14. COLORES
    -- =========================================================================
    if data.Colors then
        if data.Colors.Primary then 
            local c = data.Colors.Primary
            SetVehicleCustomPrimaryColour(self.Handle, c.r, c.g, c.b) 
        end
        if data.Colors.Secondary then 
            local c = data.Colors.Secondary
            SetVehicleCustomSecondaryColour(self.Handle, c.r, c.g, c.b) 
        end
        
        if data.Colors.PrimaryID and data.Colors.SecondaryID then
            SetVehicleColours(self.Handle, data.Colors.PrimaryID, data.Colors.SecondaryID)
        end
        
        local pearl = data.Colors.Pearlescent or GetVehicleExtraColours(self.Handle)
        local wheel = data.Colors.Wheels or select(2, GetVehicleExtraColours(self.Handle))
        SetVehicleExtraColours(self.Handle, pearl, wheel)

        if data.Colors.Dashboard then SetVehicleDashboardColour(self.Handle, data.Colors.Dashboard) end
        if data.Colors.Interior then SetVehicleInteriorColour(self.Handle, data.Colors.Interior) end
        if data.Colors.Combo then SetVehicleColourCombination(self.Handle, data.Colors.Combo) end
    end

    -- =========================================================================
    -- 15. EXTRAS
    -- =========================================================================
    if data.Extras then
        for k, v in pairs(data.Extras) do
            local idx = tonumber(k)
            if idx and DoesExtraExist(self.Handle, idx) then
                SetVehicleExtra(self.Handle, idx, not v and 1 or 0)
            end
        end
    end

    -- =========================================================================
    -- 16. ARMAS
    -- =========================================================================
    if data.Weapons then
        if data.Weapons.Disabled ~= nil then
            SetVehicleWeaponsDisabled(self.Handle, data.Weapons.Disabled)
        end
    end
end

-- =============================================================================
-- FUNCIONES DE UTILIDAD AVANZADAS
-- =============================================================================

-- Reparación completa del vehículo
function Vehicle:Repair()
    if not DoesEntityExist(self.Handle) then return end
    SetVehicleFixed(self.Handle)
    SetVehicleDirtLevel(self.Handle, 0.0)
    SetVehicleDeformationFixed(self.Handle)
    SetVehicleUndriveable(self.Handle, false)
    SetVehicleEngineOn(self.Handle, true, true, false)
    SetVehicleBodyHealth(self.Handle, 1000.0)
    SetVehicleEngineHealth(self.Handle, 1000.0)
    SetVehiclePetrolTankHealth(self.Handle, 1000.0)
    SetVehicleOilLevel(self.Handle, 100.0)
    
    -- Reparar todas las ruedas
    for i = 0, GetVehicleNumberOfWheels(self.Handle) - 1 do
        SetVehicleTyreFixed(self.Handle, i)
    end
    
    -- Reparar todas las ventanas
    for i = 0, 7 do
        FixVehicleWindow(self.Handle, i)
    end
end

-- Eliminar vehículo
function Vehicle:Delete()
    if DoesEntityExist(self.Handle) then
        SetEntityAsMissionEntity(self.Handle, true, true)
        DeleteVehicle(self.Handle)
    end
end

-- Modificar potencia del motor
function Vehicle:SetPower(multiplier)
    SetVehicleCheatPowerIncrease(self.Handle, multiplier or 1.0)
end

-- Expulsar ped del asiento
function Vehicle:EjectPed(seat)
    local ped = GetPedInVehicleSeat(self.Handle, seat or -1)
    if ped and ped ~= 0 then 
        TaskLeaveVehicle(ped, self.Handle, 0) 
    end
end

-- Limitar velocidad máxima
function Vehicle:LimitSpeed(maxSpeedKmh)
    local maxSpeedMps = maxSpeedKmh / 3.6
    SetEntityMaxSpeed(self.Handle, maxSpeedMps)
end

-- Aplicar daño en un punto específico
function Vehicle:ApplyDamage(x, y, z, damage, radius, focused)
    SetVehicleDamage(self.Handle, x, y, z, damage or 200.0, radius or 100.0, focused or true)
end

-- Explotar vehículo
function Vehicle:Explode(isAudible, isInvisible)
    ExplodeVehicle(self.Handle, isAudible ~= false, isInvisible or false)
end

-- Hacer saltar todas las ruedas
function Vehicle:BurstAllTyres()
    for i = 0, GetVehicleNumberOfWheels(self.Handle) - 1 do
        SetVehicleTyreBurst(self.Handle, i, true, 1000.0)
    end
end

-- Romper todas las ventanas
function Vehicle:SmashAllWindows()
    for i = 0, 7 do
        SmashVehicleWindow(self.Handle, i)
    end
end

-- Abrir todas las puertas
function Vehicle:OpenAllDoors()
    for i = 0, 5 do
        SetVehicleDoorOpen(self.Handle, i, false, false)
    end
end

-- Cerrar todas las puertas
function Vehicle:CloseAllDoors()
    for i = 0, 5 do
        SetVehicleDoorShut(self.Handle, i, false)
    end
end

-- Activar luces de emergencia (intermitentes)
function Vehicle:EmergencyLights(enable)
    SetVehicleIndicatorLights(self.Handle, 1, enable)
    SetVehicleIndicatorLights(self.Handle, 0, enable)
end

-- Hacer invencible al vehículo
function Vehicle:SetInvincible(toggle)
    SetEntityInvincible(self.Handle, toggle)
    SetVehicleCanBeVisiblyDamaged(self.Handle, not toggle)
    SetVehicleTyresCanBurst(self.Handle, not toggle)
end

-- Teletransportar vehículo
function Vehicle:Teleport(x, y, z, heading)
    SetEntityCoords(self.Handle, x, y, z, false, false, false, true)
    if heading then
        SetEntityHeading(self.Handle, heading)
    end
end

-- Congelar vehículo
function Vehicle:Freeze(toggle)
    FreezeEntityPosition(self.Handle, toggle)
end

-- Hacer vehículo visible/invisible
function Vehicle:SetVisible(toggle)
    SetEntityVisible(self.Handle, toggle, false)
end

-- Sistema de tracking/loop automático
function Vehicle:StartTracking(interval)
    self.TrackingActive = true
    Citizen.CreateThread(function()
        while self.TrackingActive and DoesEntityExist(self.Handle) do
            self:GetVal()
            Citizen.Wait(interval or 500)
        end
    end)
end

function Vehicle:StopTracking()
    self.TrackingActive = false
end

-- Obtener información resumida (para debugging)
function Vehicle:GetSummary()
    if not DoesEntityExist(self.Handle) then return "Vehicle not found" end
    
    local data = self:GetVal()
    return string.format(
        "Vehicle: %s | Plate: %s | Health: %.0f/%.0f | Speed: %.1f km/h | Fuel: %.1f%% | Locked: %s",
        data.Info.DisplayName,
        data.Info.Plate,
        data.Mechanical.Health.Engine,
        data.Info.MaxHealth,
        data.Performance.CurrentSpeed,
        data.Mechanical.Fluids.Fuel,
        tostring(data.Security.Locked)
    )
end

-- Clonar propiedades de otro vehículo
function Vehicle:CloneFrom(sourceVehicle)
    if not DoesEntityExist(sourceVehicle) then return false end
    
    local source = Vehicle:new(sourceVehicle)
    local sourceData = source:GetVal()
    
    self:SetVal(sourceData)
    return true
end

-- Exportar datos a JSON (para guardar)
function Vehicle:ExportJSON()
    return json.encode(self:GetVal())
end

-- Importar datos desde JSON
function Vehicle:ImportJSON(jsonString)
    local success, data = pcall(json.decode, jsonString)
    if success then
        self:SetVal(data)
        return true
    end
    return false
end

-- =============================================================================
-- EXPORTS PARA OTROS SCRIPTS
-- =============================================================================

-- Crear instancia de vehículo
exports('CreateVehicleObject', function(vehicle)
    return Vehicle:new(vehicle)
end)

-- Obtener datos de vehículo
exports('GetVehicleData', function(vehicle)
    local veh = Vehicle:new(vehicle)
    return veh and veh:GetVal() or nil
end)

-- Aplicar datos a vehículo
exports('SetVehicleData', function(vehicle, data)
    local veh = Vehicle:new(vehicle)
    if veh then
        veh:SetVal(data)
        return true
    end
    return false
end)

-- =============================================================================
-- COMANDO DE DEBUG (Remover en producción)
-- =============================================================================

RegisterCommand('vehinfo', function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    
    if veh ~= 0 then
        local vehicle = Vehicle:new(veh)
        print("^2=================================^7")
        print(vehicle:GetSummary())
        print("^2=================================^7")
        
        -- Guardar datos completos en archivo (opcional)
        -- TriggerServerEvent('vehicle:saveDebugData', vehicle:ExportJSON())
    else
        print("^1No estás en un vehículo^7")
    end
end)

return Vehicle