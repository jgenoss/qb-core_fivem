--[[
    ═══════════════════════════════════════════════════════════
    SISTEMA DE SIMULACIÓN VEHICULAR ULTRA-REALISTA v13.2
    Maneja toda la lógica de simulación independiente del HUD
    ═══════════════════════════════════════════════════════════
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- ═══════════════════════════════════════════════════════════
-- 📦 VARIABLES LOCALES
-- ═══════════════════════════════════════════════════════════

local vehicleData = {}
local activeSmoke = {}

-- Cache de ped
local cachedPed = 0
local cachedPedTime = 0

local function GetCachedPed()
    local currentTime = GetGameTimer()
    if currentTime - cachedPedTime > 1000 then
        cachedPed = PlayerPedId()
        cachedPedTime = currentTime
    end
    return cachedPed
end

-- ═══════════════════════════════════════════════════════════
-- 🔧 FUNCIONES AUXILIARES BÁSICAS
-- ═══════════════════════════════════════════════════════════

local function GetWindCooling(speed)
    speed = speed or 0
    if speed <= 0 then return 0 end
    if speed >= 150 then return CONFIG.WIND_COOLING[150] or -2.5 end
    
    local speeds = {0, 20, 40, 60, 80, 100, 120, 150}
    local lowerSpeed, upperSpeed = 0, 20
    
    for i = 1, #speeds - 1 do
        if speed >= speeds[i] and speed < speeds[i + 1] then
            lowerSpeed = speeds[i]
            upperSpeed = speeds[i + 1]
            break
        end
    end
    
    local lowerCooling = CONFIG.WIND_COOLING[lowerSpeed] or 0
    local upperCooling = CONFIG.WIND_COOLING[upperSpeed] or 0
    local ratio = (speed - lowerSpeed) / (upperSpeed - lowerSpeed)
    
    return lowerCooling + (upperCooling - lowerCooling) * ratio
end

local function GetAmbientTemp()
    local hour = GetClockHours()
    local baseTemp = CONFIG.TEMP_AMBIENT_BASE or 20
    local modifier = 1.0
    
    if hour >= 22 or hour < 6 then
        modifier = CONFIG.TIME_EFFECTS.NIGHT or 0.7
    elseif hour >= 6 and hour < 10 then
        modifier = CONFIG.TIME_EFFECTS.MORNING or 0.9
    elseif hour >= 10 and hour < 16 then
        modifier = CONFIG.TIME_EFFECTS.MIDDAY or 1.3
    elseif hour >= 16 and hour < 20 then
        modifier = CONFIG.TIME_EFFECTS.AFTERNOON or 1.1
    else
        modifier = CONFIG.TIME_EFFECTS.EVENING or 0.8
    end
    
    return baseTemp * modifier
end

local function GetWeatherEffect()
    local weather = GetPrevWeatherTypeHashName()
    local effect = CONFIG.WEATHER_EFFECTS[weather]
    
    if not effect then
        return { tempMod = 1.0, cooling = 1.0 }
    end
    
    return effect
end

local function GetSurfaceType(vehicle)
    if not vehicle or vehicle == 0 then return "ASPHALT" end
    
    local coords = GetEntityCoords(vehicle)
    local rayHandle = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 3.0, 1, vehicle, 0)
    local _, hit, _, _, materialHash = GetShapeTestResult(rayHandle)
    
    if not hit then return "ASPHALT" end
    
    if materialHash == 1288448767 or materialHash == 581794674 then
        return "SAND"
    elseif materialHash == -840216541 or materialHash == -1286696947 then
        return "GRASS"
    elseif materialHash == -1942898710 then
        return "SNOW"
    elseif materialHash == 1333033863 or materialHash == -1595148316 then
        return "DIRT"
    elseif materialHash == -1915425863 then
        return "GRAVEL"
    else
        return "ASPHALT"
    end
end

local function GetSlopeEffect(vehicle)
    if not vehicle or vehicle == 0 then return 1.0 end
    
    local fwd = GetEntityForwardVector(vehicle)
    local coords = GetEntityCoords(vehicle)
    
    local frontCoords = coords + fwd * 5.0
    local _, groundZ = GetGroundZFor_3dCoord(frontCoords.x, frontCoords.y, frontCoords.z, false)
    
    local heightDiff = groundZ - coords.z
    local slope = math.abs(heightDiff / 5.0)
    
    if heightDiff > 0 then
        return 1.0 + (slope * 2.0)
    else
        return 1.0
    end
end

local function GetPassengerCount(vehicle)
    if not vehicle or vehicle == 0 then return 0 end
    
    local count = 0
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    
    for i = -1, maxSeats - 1 do
        if not IsVehicleSeatFree(vehicle, i) then
            count = count + 1
        end
    end
    
    return count
end

local function IsACActive(vehicle)
    if not vehicle or vehicle == 0 then return false end
    
    local hour = GetClockHours()
    if (hour >= 10 and hour < 18) and GetPassengerCount(vehicle) > 0 then
        return true
    end
    return false
end

local function GetAltitude(coords)
    if not coords then return 0 end
    return coords.z or 0
end

local function GetCoolantEvaporation(temp)
    temp = temp or 0
    
    if temp < (CONFIG.COOLANT_EVAPORATION_TEMP_THRESHOLD or 100) then
        return 0
    end
    
    local temps = {100, 105, 110, 115, 120, 125, 130}
    
    for i = 1, #temps - 1 do
        if temp >= temps[i] and temp < temps[i + 1] then
            local lowerRate = CONFIG.COOLANT_EVAPORATION_RATE[temps[i]] or 0
            local upperRate = CONFIG.COOLANT_EVAPORATION_RATE[temps[i + 1]] or 0
            local ratio = (temp - temps[i]) / (temps[i + 1] - temps[i])
            return lowerRate + (upperRate - lowerRate) * ratio
        end
    end
    
    if temp >= 130 then
        return CONFIG.COOLANT_EVAPORATION_RATE[130] or 0.100
    end
    
    return 0
end

local function GetOilConsumptionMultiplier(engineHealth)
    engineHealth = engineHealth or 1000
    
    local healths = {1000, 900, 800, 700, 600, 500, 400, 300, 200, 100}
    
    for i = 1, #healths - 1 do
        if engineHealth >= healths[i + 1] and engineHealth < healths[i] then
            local lowerMult = CONFIG.OIL_CONSUMPTION_BY_DAMAGE[healths[i]] or 1.0
            local upperMult = CONFIG.OIL_CONSUMPTION_BY_DAMAGE[healths[i + 1]] or 1.0
            local ratio = (engineHealth - healths[i + 1]) / (healths[i] - healths[i + 1])
            return lowerMult + (upperMult - lowerMult) * ratio
        end
    end
    
    if engineHealth >= 1000 then
        return CONFIG.OIL_CONSUMPTION_BY_DAMAGE[1000] or 1.0
    end
    
    if engineHealth <= 100 then
        return CONFIG.OIL_CONSUMPTION_BY_DAMAGE[100] or 30.0
    end
    
    return 1.0
end

local function GetOilConsumptionByTemp(temp)
    temp = temp or 60
    
    local temps = {60, 80, 90, 100, 105, 110, 115, 120, 125, 130, 135, 140}
    
    if temp <= 60 then
        return CONFIG.OIL_CONSUMPTION_BY_TEMP[60] or 1.0
    end
    
    if temp >= 140 then
        return CONFIG.OIL_CONSUMPTION_BY_TEMP[140] or 100.0
    end
    
    for i = 1, #temps - 1 do
        if temp >= temps[i] and temp < temps[i + 1] then
            local lowerTemp = temps[i]
            local upperTemp = temps[i + 1]
            local lowerMult = CONFIG.OIL_CONSUMPTION_BY_TEMP[lowerTemp] or 1.0
            local upperMult = CONFIG.OIL_CONSUMPTION_BY_TEMP[upperTemp] or 1.0
            
            local ratio = (temp - lowerTemp) / (upperTemp - lowerTemp)
            return lowerMult + (upperMult - lowerMult) * ratio
        end
    end
    
    return 1.0
end

-- ═══════════════════════════════════════════════════════════
-- 🔧 SISTEMA DE DAÑO DE MOTOR
-- ═══════════════════════════════════════════════════════════

local function GetEngineDamageLevel(engineHealth)
    engineHealth = engineHealth or 1000
    
    local thresholds = CONFIG.ENGINE_DAMAGE_THRESHOLDS
    
    if engineHealth >= thresholds.PERFECT then
        return 0
    elseif engineHealth >= thresholds.LIGHT then
        return 1
    elseif engineHealth >= thresholds.MODERATE then
        return 2
    elseif engineHealth >= thresholds.SEVERE then
        return 3
    elseif engineHealth >= thresholds.CRITICAL then
        return 4
    else
        return 5
    end
end

local function GetEngineDamageEffects(damageLevel)
    damageLevel = math.max(0, math.min(4, damageLevel or 0))
    return CONFIG.ENGINE_DAMAGE_EFFECTS[damageLevel] or CONFIG.ENGINE_DAMAGE_EFFECTS[0]
end

local function ApplyEngineDamageEffects(vehicle, vData, engHealth)
    if not vehicle or vehicle == 0 or not vData then return end
    
    local damageLevel = GetEngineDamageLevel(engHealth)
    local effects = GetEngineDamageEffects(damageLevel)
    
    vData.IsEngineDamage = (damageLevel > 0)
    vData.engineDamageLevel = damageLevel
    
    -- ✅ CORRECCIÓN: Usar valor almacenado en lugar de función inexistente
    if effects.powerLoss > 0 then
        -- Calcular nueva potencia basada en el multiplicador almacenado
        local basePower = vData.powerMultiplier or 1.0
        local newPower = math.max(0.1, basePower - effects.powerLoss)
        
        -- Aplicar y guardar
        SetVehicleEnginePowerMultiplier(vehicle, newPower)
        vData.powerMultiplier = newPower
        
        -- Debug opcional
        if CONFIG.IsDebug() then
            print(string.format('^3[VEHICLE] Potencia ajustada: %.2f -> %.2f (Daño nivel %d)^0', 
                basePower, newPower, damageLevel))
        end
    else
        -- Motor sin daño - restaurar potencia completa
        if vData.powerMultiplier ~= 1.0 then
            SetVehicleEnginePowerMultiplier(vehicle, 1.0)
            vData.powerMultiplier = 1.0
        end
    end
    
    -- Incremento de temperatura por daño
    if effects.tempIncrease > 0 then
        vData.temp = vData.temp + (effects.tempIncrease / 60)
    end
    
    return effects
end

-- ═══════════════════════════════════════════════════════════
-- 🔥 SISTEMA DE ACEITE REALISTA
-- ═══════════════════════════════════════════════════════════

local function GetOilEffects(oilLevel)
    oilLevel = math.max(0, math.min(100, oilLevel or 100))
    
    local stages = {5, 10, 30, 50, 80, 100}
    local lowerStage, upperStage = 5, 10
    
    for i = 1, #stages - 1 do
        if oilLevel >= stages[i] and oilLevel < stages[i + 1] then
            lowerStage = stages[i]
            upperStage = stages[i + 1]
            break
        end
    end
    
    if oilLevel >= 100 then
        return CONFIG.OIL_EFFECTS[100]
    end
    
    local lowerEffects = CONFIG.OIL_EFFECTS[lowerStage]
    local upperEffects = CONFIG.OIL_EFFECTS[upperStage]
    
    if not lowerEffects or not upperEffects then
        return CONFIG.OIL_EFFECTS[100]
    end
    
    local ratio = (oilLevel - lowerStage) / (upperStage - lowerStage)
    
    return {
        powerLoss = lowerEffects.powerLoss + (upperEffects.powerLoss - lowerEffects.powerLoss) * ratio,
        tempIncrease = lowerEffects.tempIncrease + (upperEffects.tempIncrease - lowerEffects.tempIncrease) * ratio,
        damageRate = lowerEffects.damageRate + (upperEffects.damageRate - lowerEffects.damageRate) * ratio,
        seizeChance = lowerEffects.seizeChance + (upperEffects.seizeChance - lowerEffects.seizeChance) * ratio,
        smokeLevel = math.floor(lowerEffects.smokeLevel + (upperEffects.smokeLevel - lowerEffects.smokeLevel) * ratio),
        description = lowerEffects.description or "Unknown"
    }
end

local function ApplyEngineSmoke(vehicle, smokeLevel)
    if not vehicle or vehicle == 0 then return end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    
    if activeSmoke[plate] and activeSmoke[plate].level ~= smokeLevel then
        if activeSmoke[plate].particle then
            StopParticleFxLooped(activeSmoke[plate].particle, false)
        end
        activeSmoke[plate] = nil
    end
    
    if smokeLevel == 0 then
        if activeSmoke[plate] then
            if activeSmoke[plate].particle then
                StopParticleFxLooped(activeSmoke[plate].particle, false)
            end
            activeSmoke[plate] = nil
        end
        return
    end
    
    if activeSmoke[plate] and activeSmoke[plate].level == smokeLevel then
        return
    end
    
    local smokeConfig = CONFIG.SMOKE_PARTICLES[smokeLevel]
    if not smokeConfig then return end
    
    local boneIndex = GetEntityBoneIndexByName(vehicle, "engine")
    if boneIndex == -1 then return end
    
    local bonePos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
    
    local particleDict = "core"
    RequestNamedPtfxAsset(particleDict)
    local timeout = GetGameTimer() + 3000
    while not HasNamedPtfxAssetLoaded(particleDict) and GetGameTimer() < timeout do
        Wait(10)
    end
    
    if not HasNamedPtfxAssetLoaded(particleDict) then
        return
    end
    
    UseParticleFxAsset(particleDict)
    local particle = StartParticleFxLoopedAtCoord(
        "exp_grd_bzgas_smoke",
        bonePos.x, bonePos.y, bonePos.z + 0.5,
        0.0, 0.0, 0.0,
        smokeConfig.scale,
        false, false, false, false
    )
    
    if particle then
        activeSmoke[plate] = {
            level = smokeLevel,
            particle = particle
        }
    end
end

local function CleanupVehicleSmoke(vehicle)
    if not vehicle or vehicle == 0 then return end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    if activeSmoke[plate] then
        if activeSmoke[plate].particle then
            StopParticleFxLooped(activeSmoke[plate].particle, false)
        end
        activeSmoke[plate] = nil
    end
end

-- ═══════════════════════════════════════════════════════════
-- 📊 GESTIÓN DE DATOS DEL VEHÍCULO
-- ═══════════════════════════════════════════════════════════

local function GetVehicleData(vehicle)
    if not vehicle or vehicle == 0 then return nil end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    
    if not vehicleData[plate] then
        vehicleData[plate] = {
            oil = 100,
            coolant = 100,
            temp = GetAmbientTemp(),
            battery = 100,
            odometer = 0,
            lastUpdate = GetGameTimer(),
            radiatorFanActive = false,
            engineSeized = false,
            onFire = false,
            shutdownProtection = false,
            lastOilWarning = 0,
            lastSeizureNotify = 0,
            lastEngineState = false,
            IsEngineDamage = false,
            engineDamageLevel = 0,
            lastDamageCheck = 0,
            powerMultiplier = 1.0,
        }
    end
    
    return vehicleData[plate]
end

-- Export para acceso desde otros scripts
exports('GetVehicleData', GetVehicleData)

-- ═══════════════════════════════════════════════════════════
-- 🛡️ THREAD: PROTECCIÓN ACTIVA DE MOTOR GRIPADO v13.2
-- ═══════════════════════════════════════════════════════════

CreateThread(function()
    local ped, vehicle

    while true do
        local waitTime = 500
        
        ped = GetCachedPed()
        if not ped or ped == 0 then 
            Wait(waitTime)
            goto continue 
        end
        
        vehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
        
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local vData = GetVehicleData(vehicle)
            if not vData then 
                Wait(waitTime)
                goto continue 
            end
            
            if vData.engineSeized then
                waitTime = 0
                
                local engineRunning = GetIsVehicleEngineRunning(vehicle)
                
                if engineRunning ~= vData.lastEngineState then
                    if engineRunning == true then
                        print('^1[VEHICLE] 🚨 INTENTO DE ENCENDIDO DETECTADO - BLOQUEANDO^0')
                        
                        SetVehicleEngineOn(vehicle, false, true, true)
                        SetVehicleUndriveable(vehicle, true)
                        SetVehicleEngineHealth(vehicle, 0)
                        SetVehicleForwardSpeed(vehicle, 0.0)
                        
                        if GetGameTimer() - vData.lastSeizureNotify > 2000 then
                            QBCore.Functions.Notify('☠️ MOTOR GRIPADO - NO PUEDE ENCENDER', 'error', 5000)
                            QBCore.Functions.Notify('Los pistones están soldados al cilindro', 'error', 5000)
                            
                            PlaySoundFromEntity(-1, "Crash", vehicle, "DLC_EXEC_ARC_MAC_SOUNDS", true, 0)
                            
                            vData.lastSeizureNotify = GetGameTimer()
                        end
                    end
                    vData.lastEngineState = engineRunning
                end
                
                DisableControlAction(0, 71, true)
                DisableControlAction(0, 72, true)
                DisableControlAction(0, 86, true)
                
                if engineRunning then
                    SetVehicleEngineOn(vehicle, false, true, true)
                end
                
                if IsVehicleDriveable(vehicle) then
                    SetVehicleUndriveable(vehicle, true)
                end
                
                if GetVehicleEngineHealth(vehicle) > 0 then
                    SetVehicleEngineHealth(vehicle, 0)
                end
            else
                vData.lastEngineState = GetIsVehicleEngineRunning(vehicle)
            end
        end
        
        ::continue::
        Wait(waitTime)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🔥 HOOK: DETECCIÓN AL ENTRAR AL VEHÍCULO
-- ═══════════════════════════════════════════════════════════

AddEventHandler('baseevents:enteredVehicle', function(vehicle, seat, displayName, netId)
    if seat ~= -1 then return end
    
    CreateThread(function()
        Wait(500)
        
        local vData = GetVehicleData(vehicle)
        if vData and vData.engineSeized then
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineHealth(vehicle, 0)
            
            QBCore.Functions.Notify('☠️ Este vehículo tiene el motor gripado', 'error', 5000)
            QBCore.Functions.Notify('No puede encender - Necesita reemplazo de motor', 'error', 5000)
            print('^1[VEHICLE] Motor gripado detectado al entrar al vehículo^0')
        end
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- ⚙️ THREAD: SIMULACIÓN ULTRA-REALISTA
-- ═══════════════════════════════════════════════════════════

CreateThread(function()
    local ped, vehicle
    local updateFactor = 0.5
    
    while true do
        Wait(500)
        
        ped = GetCachedPed()
        if not ped or ped == 0 then goto continue end
        
        vehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
        
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local vehClass = GetVehicleClass(vehicle)
            
            if vehClass ~= 13 then
                local vData = GetVehicleData(vehicle)
                if not vData then goto continue end
                
                local engineRunning = GetIsVehicleEngineRunning(vehicle)
                local engHealth = math.max(0, GetVehicleEngineHealth(vehicle) or 0)
                local rpm = math.max(0, math.min(1, GetVehicleCurrentRpm(vehicle) or 0))
                local speed = math.max(0, GetEntitySpeed(vehicle) * (CONFIG.SPEED_MULTIPLIER or 3.6))
                
                -- 🌡️ Ambiente
                local ambientTemp = GetAmbientTemp()
                local weatherEffect = GetWeatherEffect()
                local vehClassEffect = CONFIG.VEHICLE_CLASS_EFFECTS[vehClass] or { heat = 1.0, cooling = 1.0 }
                local surfaceEffect = CONFIG.SURFACE_EFFECTS[GetSurfaceType(vehicle)] or 1.0
                local slopeEffect = GetSlopeEffect(vehicle)
                local passengerLoad = 1.0 + (GetPassengerCount(vehicle) * 0.1)
                local acActive = IsACActive(vehicle)
                local coords = GetEntityCoords(vehicle)
                local altitude = GetAltitude(coords)
                local altitudeEffect = 1.0 + math.max(0, (altitude - (CONFIG.ALTITUDE_THRESHOLD or 500)) / 1000)
                
                if not engineRunning then
                    -- Motor apagado
                    if vData.temp > ambientTemp then
                        local cooldown = CONFIG.TEMP_COOLDOWN_RATE or 0.8
                        
                        if speed > 10 then
                            cooldown = cooldown + (speed / 50)
                        end
                        
                        cooldown = cooldown * (weatherEffect.cooling or 1.0)
                        vData.temp = math.max(ambientTemp, vData.temp - cooldown)
                    end
                    
                    vData.battery = math.max(0, vData.battery - (CONFIG.BATTERY_DRAIN_OFF or 0.001))
                    vData.radiatorFanActive = false
                    vData.shutdownProtection = false
                    
                    CleanupVehicleSmoke(vehicle)
                    
                    if vData.onFire and vData.temp < 80 then
                        StopEntityFire(vehicle)
                        vData.onFire = false
                    end
                else
                    -- Motor encendido
                    local isDamaged = engHealth < 600
                    local isCriticallyDamaged = engHealth < 300
                    local isHighRPM = rpm > 0.7
                    local isMoving = speed > 5
                    
                    -- 🔥 SISTEMA DE ACEITE REALISTA
                    local oilEffects = GetOilEffects(vData.oil)
                
                    if oilEffects.tempIncrease > 0 then
                        local tempIncreasePerSec = (oilEffects.tempIncrease / 60) * updateFactor
                        vData.temp = vData.temp + tempIncreasePerSec
                    end
                    
                    if oilEffects.damageRate > 0 and engHealth > 0 then
                        local damage = oilEffects.damageRate * updateFactor
                        
                        if isHighRPM then
                            damage = damage * 1.5
                        end
                        
                        if vData.temp > (CONFIG.TEMP_CRITICAL or 120) then
                            damage = damage * 1.3
                        end
                        
                        local newHealth = math.max(0, engHealth - damage)
                        SetVehicleEngineHealth(vehicle, newHealth)
                    end
                    
                    -- Pérdida de potencia
                    local totalPowerLoss = oilEffects.powerLoss
                    
                    -- Penalización por temperatura
                    if vData.temp > 100 then
                        local tempExcess = vData.temp - 100
                        totalPowerLoss = totalPowerLoss + (tempExcess * (CONFIG.POWER_LOSS_PER_TEMP or 0.005))
                    end
                    
                    -- Penalización por daño mecánico
                    if engHealth < 500 then
                        totalPowerLoss = totalPowerLoss + ((500 - engHealth) / 1000)
                    end
                    
                    -- ✅ CORRECCIÓN: Calcular y aplicar potencia final
                    local targetPower = math.max(0.1, 1.0 - totalPowerLoss)
                    
                    -- Inicializar si no existe
                    if not vData.powerMultiplier then
                        vData.powerMultiplier = 1.0
                    end
                    
                    -- Solo actualizar si cambió significativamente (optimización)
                    local powerDiff = math.abs(vData.powerMultiplier - targetPower)
                    if powerDiff > 0.01 then
                        SetVehicleEnginePowerMultiplier(vehicle, targetPower)
                        vData.powerMultiplier = targetPower
                        
                        if CONFIG.IsDebug() then
                            print(string.format('^3[VEHICLE] Potencia: %.2f | Aceite: %.1f%% | Temp: %d°C | Motor: %d^0', 
                                targetPower, vData.oil, math.floor(vData.temp), math.floor(engHealth)))
                        end
                    end
                    
                    local finalPower = math.max(0.1, 1.0 - totalPowerLoss)
                    SetVehicleEnginePowerMultiplier(vehicle, finalPower)
                    
                    -- Humo
                    if oilEffects.smokeLevel > 0 then
                        ApplyEngineSmoke(vehicle, oilEffects.smokeLevel)
                    else
                        CleanupVehicleSmoke(vehicle)
                    end
                    
                    -- Chance de gripaje
                    if oilEffects.seizeChance > 0 and not vData.engineSeized then
                        local randomRoll = math.random()
                        
                        if randomRoll < oilEffects.seizeChance then
                            vData.engineSeized = true
                            SetVehicleEngineOn(vehicle, false, true, true)
                            SetVehicleUndriveable(vehicle, true)
                            SetVehicleEngineHealth(vehicle, 0)
                            SetVehicleForwardSpeed(vehicle, 0.0)
                            
                            QBCore.Functions.Notify('☠️ MOTOR GRIPADO - DESTRUCCIÓN TOTAL', 'error', 8000)
                            QBCore.Functions.Notify('🔧 Pistones soldados por fricción sin aceite', 'error', 8000)
                            QBCore.Functions.Notify('⚠️ El vehículo NO puede encender nunca más', 'error', 8000)
                            
                            print('^1╔═══════════════════════════════════════╗^0')
                            print('^1║     ☠️ MOTOR GRIPADO - CATASTRÓFICO     ║^0')
                            print('^1╠═══════════════════════════════════════╣^0')
                            print('^1║ Aceite: ' .. string.format("%.1f", vData.oil) .. '%                          ║^0')
                            print('^1║ Chance: ' .. string.format("%.2f", oilEffects.seizeChance * 100) .. '%/seg                    ║^0')
                            print('^1║ Temperatura: ' .. math.floor(vData.temp) .. '°C                    ║^0')
                            print('^1╚═══════════════════════════════════════╝^0')
                            
                            ApplyEngineSmoke(vehicle, 4)
                            
                            if vData.temp > 130 then
                                StartEntityFire(vehicle)
                                vData.onFire = true
                            end
                        end
                    end
                    
                    if vData.oil <= 0 and not vData.engineSeized and engineRunning then
                        vData.engineSeized = true
                        SetVehicleEngineOn(vehicle, false, true, true)
                        SetVehicleUndriveable(vehicle, true)
                        SetVehicleEngineHealth(vehicle, 0)
                        SetVehicleForwardSpeed(vehicle, 0.0)
                        
                        QBCore.Functions.Notify('💀 SIN ACEITE - MOTOR DESTRUIDO', 'error', 10000)
                        QBCore.Functions.Notify('⚠️ GRIPADO PERMANENTEMENTE', 'error', 10000)
                        print('^1[VEHICLE] 💀 Motor completamente gripado - 0% aceite^0')
                        
                        ApplyEngineSmoke(vehicle, 4)
                        StartEntityFire(vehicle)
                        vData.onFire = true
                    end
                    
                    -- Protección térmica
                    if vData.temp >= (CONFIG.ENGINE_SHUTDOWN_TEMP or 125) and not vData.shutdownProtection then
                        vData.shutdownProtection = true
                        SetVehicleEngineOn(vehicle, false, true, true)
                        QBCore.Functions.Notify('🌡️ PROTECCIÓN TÉRMICA - Motor apagado!', 'error', 5000)
                        print('^3[VEHICLE] Apagado por sobrecalentamiento: ' .. math.floor(vData.temp) .. '°C^0')
                    end
                    
                    -- Incendio
                    if vData.temp >= (CONFIG.ENGINE_FIRE_TEMP or 135) and not vData.onFire then
                        vData.onFire = true
                        StartEntityFire(vehicle)
                        QBCore.Functions.Notify('🔥 MOTOR INCENDIADO!', 'error', 5000)
                        print('^1[VEHICLE] Motor en llamas: ' .. math.floor(vData.temp) .. '°C^0')
                        SetVehicleEngineHealth(vehicle, math.max(0, engHealth - 200))
                    end
                    
                    -- Fundición
                    if vData.temp >= (CONFIG.TEMP_MELTDOWN or 130) and engHealth > 50 then
                        SetVehicleEngineHealth(vehicle, math.max(0, engHealth - (CONFIG.DAMAGE_PER_SECOND_OVERHEATING or 15)))
                        
                        if math.random(100) < 10 then
                            QBCore.Functions.Notify('💥 MOTOR FUNDIDO!', 'error', 5000)
                        end
                    end
                    
                    -- Daño sin refrigerante
                    if vData.coolant < 10 and vData.temp > 100 and engHealth > 0 then
                        SetVehicleEngineHealth(vehicle, math.max(0, engHealth - (CONFIG.DAMAGE_PER_SECOND_NO_COOLANT or 20)))
                    end
                    
                    -- 🌡️ GENERACIÓN DE CALOR
                    local heatGeneration = 0
                    
                    if isMoving then
                        heatGeneration = (CONFIG.TEMP_DRIVING_BASE or 0.6) * (rpm * 1.5)
                        if isHighRPM then
                            heatGeneration = heatGeneration * 1.4
                        end
                    else
                        heatGeneration = CONFIG.TEMP_IDLE_BASE or 0.4
                        if vData.temp > (CONFIG.TEMP_OPTIMAL or 90) then
                            heatGeneration = heatGeneration * 1.3
                        end
                    end
                    
                    heatGeneration = heatGeneration * (vehClassEffect.heat or 1.0)
                    heatGeneration = heatGeneration * surfaceEffect
                    heatGeneration = heatGeneration * slopeEffect
                    heatGeneration = heatGeneration * passengerLoad
                    heatGeneration = heatGeneration * altitudeEffect
                    heatGeneration = heatGeneration * (weatherEffect.tempMod or 1.0)
                    heatGeneration = math.min(heatGeneration, 2.5)
                    
                    if isDamaged then
                        local damagePenalty = 1.0 + ((1000 - engHealth) / 1000)
                        heatGeneration = heatGeneration * damagePenalty
                    end
                    
                    if vData.coolant < 20 then
                        heatGeneration = heatGeneration * (CONFIG.TEMP_NO_COOLANT_MULTIPLIER or 3.0)
                    end
                    
                    if acActive then
                        heatGeneration = heatGeneration * (1.0 + (CONFIG.AC_HEAT_LOAD or 0.15))
                    end
                    
                    -- ❄️ ENFRIAMIENTO
                    local totalCooling = 0
                    
                    local windCooling = GetWindCooling(speed)
                    windCooling = windCooling * (vehClassEffect.cooling or 1.0)
                    windCooling = windCooling * (weatherEffect.cooling or 1.0)
                    
                    if vData.coolant > 50 then
                        windCooling = windCooling * 1.5
                    elseif vData.coolant < 20 then
                        windCooling = windCooling * 0.3
                    end
                    
                    totalCooling = totalCooling + windCooling
                    
                    if vData.temp > (CONFIG.RADIATOR_FAN_THRESHOLD or 95) and vData.battery > 10 then
                        vData.radiatorFanActive = true
                        totalCooling = totalCooling + (CONFIG.RADIATOR_FAN_COOLING or -0.5)
                        vData.battery = vData.battery - 0.05
                    else
                        vData.radiatorFanActive = false
                    end
                    
                    if vData.coolant > 50 and not isDamaged and vData.temp > (CONFIG.TEMP_OPTIMAL or 90) + 10 then
                        local thermostatCooling = (vData.temp - (CONFIG.TEMP_OPTIMAL or 90)) * 0.05
                        totalCooling = totalCooling - thermostatCooling
                    end
                    
                    local tempChange = heatGeneration + totalCooling
                    vData.temp = vData.temp + tempChange
                    
                    local minTemp = CONFIG.TEMP_MIN_RUNNING or 60
                    local maxTemp = CONFIG.TEMP_MAX or 150
                    
                    if vData.temp < minTemp then
                        vData.temp = minTemp
                    end
                    
                    if vData.temp > maxTemp then
                        vData.temp = maxTemp
                    end
                    
                    -- 🛢️ CONSUMO DE ACEITE REALISTA
                    local oilConsumption = 0

                    if not isMoving then
                        oilConsumption = CONFIG.OIL_CONSUMPTION_IDLE or 0.0015
                    elseif isHighRPM then
                        oilConsumption = CONFIG.OIL_CONSUMPTION_HIGH_RPM or 0.018
                    else
                        oilConsumption = CONFIG.OIL_CONSUMPTION_NORMAL or 0.006
                    end

                    local damageMultiplier = GetOilConsumptionMultiplier(engHealth)
                    oilConsumption = oilConsumption * damageMultiplier

                    local tempMultiplier = GetOilConsumptionByTemp(vData.temp)
                    oilConsumption = oilConsumption * tempMultiplier

                    if speed > 120 and rpm > 0.8 then
                        oilConsumption = oilConsumption * (CONFIG.OIL_CONSUMPTION_AGGRESSIVE_DRIVING or 1.8)
                    elseif speed > 150 and rpm > 0.85 then
                        oilConsumption = oilConsumption * (CONFIG.OIL_CONSUMPTION_RACING or 2.5)
                    end

                    if vehClass == 6 or vehClass == 7 then
                        oilConsumption = oilConsumption * 1.4
                    elseif vehClass == 10 or vehClass == 11 then
                        oilConsumption = oilConsumption * 1.3
                    elseif vehClass == 8 then
                        oilConsumption = oilConsumption * 0.6
                    end

                    if vData.temp > (CONFIG.TEMP_CRITICAL or 120) then
                        local criticalTempPenalty = (vData.temp - 120) * 0.5
                        oilConsumption = oilConsumption * (1.0 + criticalTempPenalty)
                    end

                    if speed > 40 and speed < 80 and rpm < 0.6 and engHealth > 800 then
                        oilConsumption = oilConsumption * 0.85
                    end

                    oilConsumption = math.max(0.0001, math.min(oilConsumption, 2.0))
                    vData.oil = math.max(0, vData.oil - oilConsumption)
                    
                    -- 💧 CONSUMO DE REFRIGERANTE
                    local coolantConsumption = 0

                    if not isMoving then
                        coolantConsumption = CONFIG.COOLANT_CONSUMPTION_IDLE or 0.002
                    else
                        coolantConsumption = CONFIG.COOLANT_CONSUMPTION_NORMAL or 0.008
                    end

                    if isDamaged then
                        local damageMultiplier = 1.0 + ((1000 - engHealth) / 500)
                        coolantConsumption = coolantConsumption * damageMultiplier
                    end

                    if vData.temp > (CONFIG.COOLANT_EVAPORATION_TEMP_THRESHOLD or 100) then
                        local evaporationRate = GetCoolantEvaporation(vData.temp)
                        coolantConsumption = coolantConsumption + evaporationRate
                    end

                    if vData.temp > (CONFIG.TEMP_CRITICAL or 120) then
                        coolantConsumption = coolantConsumption * 3.0
                    end

                    if vData.temp > 100 then
                        local tempExcess = vData.temp - 100
                        local tempMultiplier = 1.0 + (tempExcess * 0.05)
                        tempMultiplier = math.min(tempMultiplier, 3.0)
                        coolantConsumption = coolantConsumption * tempMultiplier
                    end

                    vData.coolant = math.max(0, vData.coolant - coolantConsumption)
                    
                    -- 🔋 BATERÍA
                    if vData.battery < 100 then
                        vData.battery = math.min(100, vData.battery + (CONFIG.BATTERY_CHARGE_RATE or 0.05))
                    end
                    
                    if acActive then
                        vData.battery = vData.battery - (CONFIG.BATTERY_DRAIN_AC or 0.005)
                    end
                    
                    -- 📏 ODÓMETRO
                    if isMoving then
                        local distanceKm = speed / 3600
                        vData.odometer = vData.odometer + distanceKm
                    end
                end
                
                -- 📤 EMITIR EVENTO CON DATOS ACTUALIZADOS
                TriggerEvent(VEHICLE_EVENTS.UPDATE_VEHICLE_DATA, {
                    inVehicle = true,
                    vehicle = vehicle,
                    data = vData,
                    speed = speed,
                    rpm = rpm,
                    engineHealth = engHealth,
                    engineOn = engineRunning
                })
            end
        else
            -- No en vehículo o no conductor
            TriggerEvent(VEHICLE_EVENTS.UPDATE_VEHICLE_DATA, {
                inVehicle = false,
                vehicle = 0,
                data = nil
            })
        end
        
        ::continue::
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🚨 THREAD: ALERTAS INTELIGENTES
-- ═══════════════════════════════════════════════════════════

CreateThread(function()
    local lastAlerts = {
        lowOil = 0,
        criticalOil = 0,
        lowCoolant = 0,
        overheating = 0,
        critical = 0
    }
    
    while true do
        Wait(5000)
        
        local ped = GetCachedPed()
        if not ped or ped == 0 then goto skip_alerts end
        
        local vehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
        
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped then
            local vData = GetVehicleData(vehicle)
            if not vData then goto skip_alerts end
            
            local engineRunning = GetIsVehicleEngineRunning(vehicle)
            local currentTime = GetGameTimer()
            local engHealth = GetVehicleEngineHealth(vehicle)
            
            if engineRunning and not vData.engineSeized then
                ApplyEngineDamageEffects(vehicle, vData, engHealth)

                if vData.IsEngineDamage and GetGameTimer() - vData.lastDamageCheck > 10000 then
                    local level = vData.engineDamageLevel
                    
                    if level == 1 then
                        QBCore.Functions.Notify('⚠️ Motor levemente dañado', 'warning', 3000)
                    elseif level == 2 then
                        QBCore.Functions.Notify('🟠 Motor moderadamente dañado - Potencia reducida', 'warning', 4000)
                    elseif level == 3 then
                        QBCore.Functions.Notify('🔴 Motor severamente dañado - Riesgo de falla', 'error', 5000)
                    elseif level >= 4 then
                        QBCore.Functions.Notify('☠️ Motor críticamente dañado - Gripaje inminente', 'error', 6000)
                    end
                    
                    vData.lastDamageCheck = GetGameTimer()
                end

                local oilEffects = GetOilEffects(vData.oil)
                
                if vData.oil < 30 and vData.oil > 10 and currentTime - lastAlerts.lowOil > 30000 then
                    QBCore.Functions.Notify(oilEffects.description .. ' | Aceite: ' .. math.floor(vData.oil) .. '% - Potencia: -' .. math.floor(oilEffects.powerLoss * 100) .. '%', 'warning', 5000)
                    lastAlerts.lowOil = currentTime
                end
                
                if vData.oil <= 10 and currentTime - lastAlerts.criticalOil > 15000 then
                    QBCore.Functions.Notify('🛢️ ' .. oilEffects.description .. ' | ' .. math.floor(vData.oil) .. '% | Gripaje: ' .. string.format("%.1f", oilEffects.seizeChance * 100) .. '%/seg', 'error', 8000)
                    lastAlerts.criticalOil = currentTime
                end
                
                if vData.coolant < 20 and currentTime - lastAlerts.lowCoolant > 30000 then
                    QBCore.Functions.Notify('⚠️ REFRIGERANTE BAJO: ' .. math.floor(vData.coolant) .. '%', 'warning', 5000)
                    lastAlerts.lowCoolant = currentTime
                end
                
                if vData.temp > (CONFIG.TEMP_WARNING or 105) and currentTime - lastAlerts.overheating > 30000 then
                    QBCore.Functions.Notify('🌡️ SOBRECALENTAMIENTO: ' .. math.floor(vData.temp) .. '°C', 'error', 5000)
                    lastAlerts.overheating = currentTime
                end
                
                if vData.temp > (CONFIG.TEMP_CRITICAL or 120) and currentTime - lastAlerts.critical > 20000 then
                    QBCore.Functions.Notify('🔥 TEMPERATURA CRÍTICA: ' .. math.floor(vData.temp) .. '°C - ¡APAGA EL MOTOR!', 'error', 8000)
                    lastAlerts.critical = currentTime
                end
            end
        end
        
        ::skip_alerts::
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🎮 COMANDOS DE DEBUG
-- ═══════════════════════════════════════════════════════════

RegisterCommand('vehreset', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        vehicleData[plate] = {
            oil = 100,
            coolant = 100,
            temp = GetAmbientTemp(),
            battery = 100,
            odometer = 0,
            radiatorFanActive = false,
            engineSeized = false,
            onFire = false,
            shutdownProtection = false,
            lastEngineState = false,
            IsEngineDamage = false,
            engineDamageLevel = 0,
            powerMultiplier = 1.0,
        }
        
        SetVehicleEngineHealth(vehicle, 1000)
        SetVehicleBodyHealth(vehicle, 1000)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, false, false)
        SetVehicleEnginePowerMultiplier(vehicle, 1.0)
        
        CleanupVehicleSmoke(vehicle)
        
        if IsEntityOnFire(vehicle) then
            StopEntityFire(vehicle)
        end
        
        QBCore.Functions.Notify('✅ Vehículo completamente restaurado', 'success')
        print('^2[VEHICLE] Vehículo reseteado completamente^0')
    end
end, false)

RegisterCommand('vehinfo', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        local vData = GetVehicleData(vehicle)
        if not vData then 
            print('^1[VEHICLE] No se pudo obtener datos del vehículo^0')
            return
        end
        
        local engineOn = GetIsVehicleEngineRunning(vehicle)
        local engHealth = GetVehicleEngineHealth(vehicle)
        local speed = GetEntitySpeed(vehicle) * CONFIG.SPEED_MULTIPLIER
        local oilEffects = GetOilEffects(vData.oil)
        
        print('^3╔═══════════════════════════════════════════╗^0')
        print('^3║          VEHICLE DEBUG v13.2             ║^0')
        print('^3╠═══════════════════════════════════════════╣^0')
        
        print('^6│ ESTADO MOTOR^0')
        print('^2│ Motor: ^0' .. (engineOn and '🟢 ENCENDIDO' or '🔴 APAGADO'))
        print('^2│ Salud Motor: ^0' .. math.floor(engHealth) .. '/1000')
        print('^2│ Gripado: ^0' .. (vData.engineSeized and '🔴 SÍ' or '🟢 NO'))
        print('^2│ En Fuego: ^0' .. (vData.onFire and '🔥 SÍ' or '🟢 NO'))
        
        print('^6│ SISTEMA DE ACEITE v13.2^0')
        print('^2│ Nivel: ^0' .. string.format("%.1f", vData.oil) .. '% ' .. oilEffects.description)
        print('^2│ Pérdida de Potencia: ^0-' .. math.floor(oilEffects.powerLoss * 100) .. '%')
        print('^2│ Chance Gripaje: ^0' .. string.format("%.2f", oilEffects.seizeChance * 100) .. '%/seg')
        
        print('^3╚═══════════════════════════════════════════╝^0')
    else
        print('^1[VEHICLE] No estás en un vehículo^0')
    end
end, false)

RegisterCommand('vehsetoil', function(source, args)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then 
        print('^1[VEHICLE] No estás en un vehículo^0')
        return 
    end
    
    local vData = GetVehicleData(vehicle)
    if not vData then return end
    
    local targetOil = tonumber(args[1]) or 0
    vData.oil = math.max(0, math.min(100, targetOil))
    
    local effects = GetOilEffects(vData.oil)
    
    print('^3╔═══════════════════════════════════╗^0')
    print('^3║   TEST DE ACEITE: ' .. math.floor(vData.oil) .. '%            ║^0')
    print('^3╠═══════════════════════════════════╣^0')
    print('^2│ Estado: ^0' .. effects.description)
    print('^2│ Pérdida de potencia: ^0-' .. math.floor(effects.powerLoss * 100) .. '%')
    print('^2│ Chance gripaje: ^0' .. string.format("%.2f", effects.seizeChance * 100) .. '%/seg')
    print('^3╚═══════════════════════════════════╝^0')
    
    QBCore.Functions.Notify('Aceite establecido a ' .. math.floor(vData.oil) .. '%', 'success')
end, false)

RegisterCommand('vehtoggleseize', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        QBCore.Functions.Notify('No estás en un vehículo', 'error')
        return
    end
    
    local vData = GetVehicleData(vehicle)
    if not vData then return end
    
    vData.engineSeized = not vData.engineSeized
    
    if vData.engineSeized then
        vData.oil = 0
        vData.powerMultiplier = 0.1
        SetVehicleEngineOn(vehicle, false, true, true)
        SetVehicleUndriveable(vehicle, true)
        SetVehicleEngineHealth(vehicle, 0)
        
        QBCore.Functions.Notify('☠️ TEST: Motor gripado', 'error')
        print('^1[VEHICLE] Motor gripado para pruebas^0')
    else
        vData.oil = 100
        vData.temp = GetAmbientTemp()
        vData.powerMultiplier = 1.0
        SetVehicleEngineHealth(vehicle, 1000)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEnginePowerMultiplier(vehicle, 1.0)
        
        QBCore.Functions.Notify('✅ TEST: Motor reparado', 'success')
        print('^2[VEHICLE] Motor desgripado para pruebas^0')
    end
end, false)

-- ═══════════════════════════════════════════════════════════
-- 🔗 INTEGRACIÓN CON SERVIDOR
-- Agregar al final de client/vehicle.lua
-- ═══════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════
-- 📤 GUARDAR/CARGAR DATOS DEL VEHÍCULO
-- ═══════════════════════════════════════════════════════════

--[[
    Hook: Al salir del vehículo, guardar datos en servidor
]]
AddEventHandler('baseevents:leftVehicle', function(vehicle, seat, displayName, netId)
    if seat ~= -1 then return end
    
    local vData = GetVehicleData(vehicle)
    if vData then
        local plate = GetVehicleNumberPlateText(vehicle)
        TriggerServerEvent('hud:server:SaveVehicleData', plate, vData)
    end
end)

--[[
    Hook: Al entrar al vehículo, cargar datos desde servidor
]]
AddEventHandler('baseevents:enteredVehicle', function(vehicle, seat, displayName, netId)
    if seat ~= -1 then return end
    
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerServerEvent('hud:server:LoadVehicleData', plate)
end)

--[[
    Evento: Recibir datos del servidor al entrar al vehículo
]]
RegisterNetEvent('hud:client:LoadVehicleData', function(plate, data)
    if not plate or not data then return end
    
    vehicleData[plate] = data
    
    print(string.format('^2[VEHICLE] Datos cargados desde servidor - Placa: %s | Aceite: %.1f%%^0', 
        plate, data.oil or 100))
end)

-- ═══════════════════════════════════════════════════════════
-- 👮 COMANDOS ADMINISTRATIVOS (CLIENT-SIDE)
-- ═══════════════════════════════════════════════════════════

--[[
    Admin: Resetear vehículo
]]
RegisterNetEvent('hud:client:AdminResetVehicle', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        local plate = GetVehicleNumberPlateText(vehicle)
        vehicleData[plate] = {
            oil = 100,
            coolant = 100,
            temp = GetAmbientTemp(),
            battery = 100,
            odometer = 0,
            radiatorFanActive = false,
            engineSeized = false,
            onFire = false,
            shutdownProtection = false,
            lastEngineState = false,
            IsEngineDamage = false,
            engineDamageLevel = 0,
        }
        
        SetVehicleEngineHealth(vehicle, 1000)
        SetVehicleBodyHealth(vehicle, 1000)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleEngineOn(vehicle, true, false, false)
        SetVehicleEnginePowerMultiplier(vehicle, 1.0)
        
        CleanupVehicleSmoke(vehicle)
        
        if IsEntityOnFire(vehicle) then
            StopEntityFire(vehicle)
        end
        
        QBCore.Functions.Notify('✅ Un admin ha reseteado tu vehículo', 'success')
    else
        QBCore.Functions.Notify('No estás en un vehículo', 'error')
    end
end)

--[[
    Admin: Solicitud de información del vehículo
]]
RegisterNetEvent('hud:client:AdminRequestVehicleInfo', function(adminId)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        TriggerServerEvent('hud:server:AdminSendVehicleInfo', adminId, nil)
        return
    end
    
    local vData = GetVehicleData(vehicle)
    local engHealth = GetVehicleEngineHealth(vehicle)
    
    if vData then
        local vehicleInfo = {
            oil = vData.oil,
            coolant = vData.coolant,
            temp = vData.temp,
            battery = vData.battery,
            engineHealth = engHealth / 10,
            engineSeized = vData.engineSeized
        }
        
        TriggerServerEvent('hud:server:AdminSendVehicleInfo', adminId, vehicleInfo)
    end
end)

--[[
    Admin: Establecer nivel de aceite
]]
RegisterNetEvent('hud:client:AdminSetOil', function(amount)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('No estás en un vehículo', 'error')
        return
    end
    
    local vData = GetVehicleData(vehicle)
    if vData then
        vData.oil = math.max(0, math.min(100, amount))
        QBCore.Functions.Notify('Aceite establecido a ' .. math.floor(vData.oil) .. '%', 'success')
    end
end)

--[[
    Admin: Toggle motor gripado
]]
RegisterNetEvent('hud:client:AdminToggleSeize', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('No estás en un vehículo', 'error')
        return
    end
    
    local vData = GetVehicleData(vehicle)
    if vData then
        vData.engineSeized = not vData.engineSeized
        
        if vData.engineSeized then
            vData.oil = 0
            SetVehicleEngineOn(vehicle, false, true, true)
            SetVehicleUndriveable(vehicle, true)
            SetVehicleEngineHealth(vehicle, 0)
            QBCore.Functions.Notify('☠️ Motor gripado por admin', 'error')
        else
            vData.oil = 100
            vData.temp = GetAmbientTemp()
            SetVehicleEngineHealth(vehicle, 1000)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleEnginePowerMultiplier(vehicle, 1.0)
            QBCore.Functions.Notify('✅ Motor reparado por admin', 'success')
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🛠️ ITEMS MECÁNICOS
-- ═══════════════════════════════════════════════════════════

--[[
    Usar: motor_oil
]]
RegisterNetEvent('hud:client:UseMotorOil', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('Debes estar en un vehículo', 'error')
        return
    end
    
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        QBCore.Functions.Notify('Debes ser el conductor', 'error')
        return
    end
    
    local vData = GetVehicleData(vehicle)
    if not vData then return end
    
    if vData.oil >= 90 then
        QBCore.Functions.Notify('El aceite ya está lleno', 'error')
        return
    end
    
    -- Animación de reparación
    QBCore.Functions.Progressbar('using_motor_oil', 'Cambiando aceite...', 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 16,
    }, {}, {}, function()
        -- Success
        vData.oil = 100
        TriggerServerEvent('hud:server:UsedMotorOil')
    end, function()
        -- Cancel
        QBCore.Functions.Notify('Cancelado', 'error')
    end)
end)

--[[
    Usar: coolant
]]
RegisterNetEvent('hud:client:UseCoolant', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('Debes estar en un vehículo', 'error')
        return
    end
    
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        QBCore.Functions.Notify('Debes ser el conductor', 'error')
        return
    end
    
    local vData = GetVehicleData(vehicle)
    if not vData then return end
    
    if vData.coolant >= 90 then
        QBCore.Functions.Notify('El refrigerante ya está lleno', 'error')
        return
    end
    
    -- Animación de reparación
    QBCore.Functions.Progressbar('using_coolant', 'Rellenando refrigerante...', 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 16,
    }, {}, {}, function()
        -- Success
        vData.coolant = 100
        TriggerServerEvent('hud:server:UsedCoolant')
    end, function()
        -- Cancel
        QBCore.Functions.Notify('Cancelado', 'error')
    end)
end)

--[[
    Usar: car_battery
]]
RegisterNetEvent('hud:client:UseCarBattery', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify('Debes estar en un vehículo', 'error')
        return
    end
    
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        QBCore.Functions.Notify('Debes ser el conductor', 'error')
        return
    end
    
    local vData = GetVehicleData(vehicle)
    if not vData then return end
    
    if vData.battery >= 90 then
        QBCore.Functions.Notify('La batería ya está cargada', 'error')
        return
    end
    
    -- Animación de reparación
    QBCore.Functions.Progressbar('using_battery', 'Reemplazando batería...', 20000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'mini@repair',
        anim = 'fixing_a_player',
        flags = 16,
    }, {}, {}, function()
        -- Success
        vData.battery = 100
        TriggerServerEvent('hud:server:UsedCarBattery')
    end, function()
        -- Cancel
        QBCore.Functions.Notify('Cancelado', 'error')
    end)
end)

print('^2[VEHICLE] Integración client-server cargada^0')

print('^2╔═══════════════════════════════════════════╗^0')
print('^2║  VEHICLE SIMULATION v13.2 CARGADO        ║^0')
print('^2║  🔥 Sistema de Aceite Realista            ║^0')
print('^2║  🛡️ Sistema Anti-Bypass Motor Gripado    ║^0')
print('^2╚═══════════════════════════════════════════╝^0')