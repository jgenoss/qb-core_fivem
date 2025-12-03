--[[
    ═══════════════════════════════════════════════════════════
    HUD ULTIMATE v13.2 - SERVER
    Gestión server-side para HUD y sistema vehicular
    ═══════════════════════════════════════════════════════════
]]

local QBCore = exports['qb-core']:GetCoreObject()

-- ═══════════════════════════════════════════════════════════
-- 📊 ALMACENAMIENTO DE DATOS VEHICULARES (OPCIONAL)
-- ═══════════════════════════════════════════════════════════

-- Tabla temporal de datos vehiculares por placa
-- NOTA: Para persistencia permanente, conectar con MySQL
local vehicleDatabase = {}

--[[
    Guardar datos del vehículo
    @param plate string - Placa del vehículo
    @param data table - Datos a guardar
]]
local function SaveVehicleData(plate, data)
    if not plate or not data then return end
    
    vehicleDatabase[plate] = {
        oil = data.oil or 100,
        coolant = data.coolant or 100,
        temp = data.temp or 20,
        battery = data.battery or 100,
        odometer = data.odometer or 0,
        engineSeized = data.engineSeized or false,
        lastUpdate = os.time()
    }
    
    -- TODO: Aquí puedes agregar guardado a MySQL si quieres persistencia
    -- exports['oxmysql']:execute('UPDATE vehicles SET vehicle_data = ? WHERE plate = ?', {
    --     json.encode(vehicleDatabase[plate]),
    --     plate
    -- })
end

--[[
    Cargar datos del vehículo
    @param plate string - Placa del vehículo
    @return table - Datos del vehículo o nil
]]
local function LoadVehicleData(plate)
    if not plate then return nil end
    
    -- TODO: Aquí puedes cargar desde MySQL si tienes persistencia
    -- local result = exports['oxmysql']:fetchSync('SELECT vehicle_data FROM vehicles WHERE plate = ?', {plate})
    -- if result[1] then
    --     return json.decode(result[1].vehicle_data)
    -- end
    
    return vehicleDatabase[plate]
end

-- ═══════════════════════════════════════════════════════════
-- 💰 COMANDOS DE DINERO
-- ═══════════════════════════════════════════════════════════

QBCore.Commands.Add('cash', 'Ver dinero en efectivo', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local cashamount = Player.PlayerData.money.cash
    TriggerClientEvent('QBCore:Notify', source, 'Efectivo: $'..cashamount, 'success')
end)

QBCore.Commands.Add('bank', 'Ver dinero en banco', {}, false, function(source, _)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    local bankamount = Player.PlayerData.money.bank
    TriggerClientEvent('QBCore:Notify', source, 'Banco: $'..bankamount, 'success')
end)

-- ═══════════════════════════════════════════════════════════
-- 🧠 GESTIÓN DE ESTRÉS (Server-side para seguridad)
-- ═══════════════════════════════════════════════════════════

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Validación de seguridad
    amount = tonumber(amount)
    if not amount or amount < 0 or amount > 100 then 
        print('^1[HUD] Intento de manipular estrés detectado: ' .. GetPlayerName(src) .. ' (ID: ' .. src .. ')^0')
        return 
    end
    
    local newStress = (Player.PlayerData.metadata['stress'] or 0) + amount
    newStress = math.max(0, math.min(100, newStress))
    
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    
    -- Log para debug
    if Config and Config.DebugMode then
        print(string.format('^3[HUD] %s ganó %d de estrés. Total: %d^0', 
            GetPlayerName(src), amount, newStress))
    end
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Validación de seguridad
    amount = tonumber(amount)
    if not amount or amount < 0 or amount > 100 then 
        print('^1[HUD] Intento de manipular estrés detectado: ' .. GetPlayerName(src) .. ' (ID: ' .. src .. ')^0')
        return 
    end
    
    local newStress = (Player.PlayerData.metadata['stress'] or 0) - amount
    newStress = math.max(0, math.min(100, newStress))
    
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
    
    -- Log para debug
    if Config and Config.DebugMode then
        print(string.format('^2[HUD] %s redujo %d de estrés. Total: %d^0', 
            GetPlayerName(src), amount, newStress))
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🚗 EVENTOS DE VEHÍCULOS
-- ═══════════════════════════════════════════════════════════

--[[
    Guardar estado del vehículo cuando el jugador se baja
]]
RegisterNetEvent('hud:server:SaveVehicleData', function(plate, data)
    local src = source
    
    if not plate or not data then 
        print('^1[HUD] Intento de guardar datos inválidos: ' .. GetPlayerName(src) .. '^0')
        return 
    end
    
    SaveVehicleData(plate, data)
    
    if Config and Config.DebugMode then
        print(string.format('^2[HUD] Datos de vehículo guardados - Placa: %s | Aceite: %.1f%% | Temp: %d°C^0', 
            plate, data.oil or 0, data.temp or 0))
    end
end)

--[[
    Cargar estado del vehículo cuando el jugador se sube
]]
RegisterNetEvent('hud:server:LoadVehicleData', function(plate)
    local src = source
    
    if not plate then return end
    
    local data = LoadVehicleData(plate)
    
    if data then
        TriggerClientEvent('hud:client:LoadVehicleData', src, plate, data)
        
        if Config and Config.DebugMode then
            print(string.format('^2[HUD] Datos de vehículo cargados - Placa: %s^0', plate))
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 👮 COMANDOS ADMINISTRATIVOS
-- ═══════════════════════════════════════════════════════════

--[[
    Comando: /adminvehreset [id]
    Resetea el vehículo de un jugador (solo admins)
]]
QBCore.Commands.Add('adminvehreset', 'Resetear vehículo de un jugador (Admin)', {
    {name = 'id', help = 'ID del jugador'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', source, 'ID inválido', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado', 'error')
        return
    end
    
    TriggerClientEvent('hud:client:AdminResetVehicle', targetId)
    
    TriggerClientEvent('QBCore:Notify', source, 
        'Vehículo de ' .. GetPlayerName(targetId) .. ' reseteado', 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 
        'Un admin ha reseteado tu vehículo', 'success')
    
    print(string.format('^3[HUD] %s reseteó el vehículo de %s^0', 
        GetPlayerName(source), GetPlayerName(targetId)))
end, 'admin')

--[[
    Comando: /adminvehinfo [id]
    Ver información del vehículo de un jugador (solo admins)
]]
QBCore.Commands.Add('adminvehinfo', 'Ver info del vehículo de un jugador (Admin)', {
    {name = 'id', help = 'ID del jugador'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', source, 'ID inválido', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado', 'error')
        return
    end
    
    TriggerClientEvent('hud:client:AdminRequestVehicleInfo', targetId, source)
end, 'admin')

--[[
    Respuesta del cliente con la información del vehículo
]]
RegisterNetEvent('hud:server:AdminSendVehicleInfo', function(adminId, vehicleInfo)
    local src = source
    
    if not vehicleInfo then
        TriggerClientEvent('QBCore:Notify', adminId, 'El jugador no está en un vehículo', 'error')
        return
    end
    
    local message = string.format(
        '🚗 VEHÍCULO DE %s:\n' ..
        '━━━━━━━━━━━━━━━━━━━\n' ..
        '🛢️ Aceite: %.1f%%\n' ..
        '💧 Refrigerante: %.1f%%\n' ..
        '🌡️ Temperatura: %d°C\n' ..
        '🔋 Batería: %.1f%%\n' ..
        '🔧 Motor: %.1f/100\n' ..
        '💀 Gripado: %s',
        GetPlayerName(src),
        vehicleInfo.oil or 0,
        vehicleInfo.coolant or 0,
        vehicleInfo.temp or 0,
        vehicleInfo.battery or 0,
        vehicleInfo.engineHealth or 0,
        vehicleInfo.engineSeized and 'SÍ ⚠️' or 'NO ✅'
    )
    
    TriggerClientEvent('chat:addMessage', adminId, {
        color = {52, 152, 219},
        multiline = true,
        args = {'[HUD ADMIN]', message}
    })
end)

--[[
    Comando: /adminsetoil [id] [cantidad]
    Establecer nivel de aceite de un jugador (solo admins)
]]
QBCore.Commands.Add('adminsetoil', 'Establecer aceite del vehículo (Admin)', {
    {name = 'id', help = 'ID del jugador'},
    {name = 'cantidad', help = 'Cantidad de aceite (0-100)'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', source, 'ID inválido', 'error')
        return
    end
    
    if not amount or amount < 0 or amount > 100 then
        TriggerClientEvent('QBCore:Notify', source, 'Cantidad inválida (0-100)', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado', 'error')
        return
    end
    
    TriggerClientEvent('hud:client:AdminSetOil', targetId, amount)
    
    TriggerClientEvent('QBCore:Notify', source, 
        string.format('Aceite de %s establecido a %.1f%%', GetPlayerName(targetId), amount), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 
        string.format('Un admin estableció tu aceite a %.1f%%', amount), 'info')
    
    print(string.format('^3[HUD] %s estableció aceite de %s a %.1f%%^0', 
        GetPlayerName(source), GetPlayerName(targetId), amount))
end, 'admin')

--[[
    Comando: /admintoggleseize [id]
    Toggle motor gripado de un jugador (solo admins)
]]
QBCore.Commands.Add('admintoggleseize', 'Toggle motor gripado (Admin)', {
    {name = 'id', help = 'ID del jugador'}
}, true, function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('QBCore:Notify', source, 'ID inválido', 'error')
        return
    end
    
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', source, 'Jugador no encontrado', 'error')
        return
    end
    
    TriggerClientEvent('hud:client:AdminToggleSeize', targetId)
    
    TriggerClientEvent('QBCore:Notify', source, 
        'Motor gripado de ' .. GetPlayerName(targetId) .. ' alternado', 'success')
    
    print(string.format('^3[HUD] %s alternó motor gripado de %s^0', 
        GetPlayerName(source), GetPlayerName(targetId)))
end, 'admin')

-- ═══════════════════════════════════════════════════════════
-- 🛠️ ITEMS PARA MECÁNICOS (OPCIONAL)
-- ═══════════════════════════════════════════════════════════

--[[
    Item: motor_oil
    Permite cambiar aceite del vehículo
]]
QBCore.Functions.CreateUseableItem('motor_oil', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('hud:client:UseMotorOil', source)
end)

--[[
    Item: coolant
    Permite rellenar refrigerante
]]
QBCore.Functions.CreateUseableItem('coolant', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('hud:client:UseCoolant', source)
end)

--[[
    Item: car_battery
    Permite reemplazar batería
]]
QBCore.Functions.CreateUseableItem('car_battery', function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    
    TriggerClientEvent('hud:client:UseCarBattery', source)
end)

--[[
    Evento: Jugador usó aceite
]]
RegisterNetEvent('hud:server:UsedMotorOil', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Remover item
    Player.Functions.RemoveItem('motor_oil', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['motor_oil'], 'remove')
    
    TriggerClientEvent('QBCore:Notify', src, 'Aceite cambiado exitosamente', 'success')
    
    print(string.format('^2[HUD] %s usó aceite de motor^0', GetPlayerName(src)))
end)

--[[
    Evento: Jugador usó refrigerante
]]
RegisterNetEvent('hud:server:UsedCoolant', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Remover item
    Player.Functions.RemoveItem('coolant', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['coolant'], 'remove')
    
    TriggerClientEvent('QBCore:Notify', src, 'Refrigerante rellenado exitosamente', 'success')
    
    print(string.format('^2[HUD] %s usó refrigerante^0', GetPlayerName(src)))
end)

--[[
    Evento: Jugador usó batería
]]
RegisterNetEvent('hud:server:UsedCarBattery', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Remover item
    Player.Functions.RemoveItem('car_battery', 1)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['car_battery'], 'remove')
    
    TriggerClientEvent('QBCore:Notify', src, 'Batería reemplazada exitosamente', 'success')
    
    print(string.format('^2[HUD] %s usó batería de coche^0', GetPlayerName(src)))
end)

-- ═══════════════════════════════════════════════════════════
-- 📊 ESTADÍSTICAS Y LOGS
-- ═══════════════════════════════════════════════════════════

--[[
    Comando: /hudstats
    Muestra estadísticas del servidor (solo admins)
]]
QBCore.Commands.Add('hudstats', 'Ver estadísticas del HUD (Admin)', {}, false, function(source, args)
    local totalVehicles = 0
    local seizedEngines = 0
    
    for plate, data in pairs(vehicleDatabase) do
        totalVehicles = totalVehicles + 1
        if data.engineSeized then
            seizedEngines = seizedEngines + 1
        end
    end
    
    local message = string.format(
        '📊 ESTADÍSTICAS HUD v13.2\n' ..
        '━━━━━━━━━━━━━━━━━━━━━━\n' ..
        '🚗 Vehículos registrados: %d\n' ..
        '💀 Motores gripados: %d\n' ..
        '👥 Jugadores online: %d',
        totalVehicles,
        seizedEngines,
        #GetPlayers()
    )
    
    TriggerClientEvent('chat:addMessage', source, {
        color = {46, 204, 113},
        multiline = true,
        args = {'[HUD STATS]', message}
    })
end, 'admin')

-- ═══════════════════════════════════════════════════════════
-- 🔄 LIMPIEZA PERIÓDICA
-- ═══════════════════════════════════════════════════════════

--[[
    Limpiar datos de vehículos antiguos cada hora
]]
CreateThread(function()
    while true do
        Wait(3600000) -- 1 hora
        
        local currentTime = os.time()
        local cleaned = 0
        
        for plate, data in pairs(vehicleDatabase) do
            -- Eliminar datos de vehículos no actualizados en 24 horas
            if currentTime - (data.lastUpdate or 0) > 86400 then
                vehicleDatabase[plate] = nil
                cleaned = cleaned + 1
            end
        end
        
        if cleaned > 0 then
            print(string.format('^3[HUD] Limpieza automática: %d vehículos eliminados^0', cleaned))
        end
    end
end)

-- ═══════════════════════════════════════════════════════════
-- 🔧 FUNCIONES DE UTILIDAD
-- ═══════════════════════════════════════════════════════════

--[[
    Obtener todos los datos de vehículos (para exports)
    @return table - Tabla de datos vehiculares
]]
local function GetAllVehicleData()
    return vehicleDatabase
end

--[[
    Obtener datos de un vehículo específico (para exports)
    @param plate string - Placa del vehículo
    @return table - Datos del vehículo o nil
]]
local function GetVehicleDataByPlate(plate)
    return vehicleDatabase[plate]
end

--[[
    Resetear datos de un vehículo (para exports)
    @param plate string - Placa del vehículo
]]
local function ResetVehicleDataByPlate(plate)
    if vehicleDatabase[plate] then
        vehicleDatabase[plate] = nil
        print(string.format('^2[HUD] Datos de vehículo reseteados - Placa: %s^0', plate))
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
-- 📤 EXPORTS
-- ═══════════════════════════════════════════════════════════

exports('GetAllVehicleData', GetAllVehicleData)
exports('GetVehicleDataByPlate', GetVehicleDataByPlate)
exports('ResetVehicleDataByPlate', ResetVehicleDataByPlate)
exports('SaveVehicleData', SaveVehicleData)
exports('LoadVehicleData', LoadVehicleData)

-- ═══════════════════════════════════════════════════════════
-- ✅ MENSAJE DE INICIO
-- ═══════════════════════════════════════════════════════════

CreateThread(function()
    Wait(1000)
    print('^2╔═══════════════════════════════════════════╗^0')
    print('^2║  HUD ULTIMATE v13.2 - SERVER CARGADO     ║^0')
    print('^2║  💰 Comandos de dinero                    ║^0')
    print('^2║  🧠 Sistema de estrés                     ║^0')
    print('^2║  🚗 Gestión vehicular                     ║^0')
    print('^2║  👮 Comandos administrativos               ║^0')
    print('^2║  🛠️ Sistema de items mecánicos            ║^0')
    print('^2╚═══════════════════════════════════════════╝^0')
    print('^3Comandos administrativos:^0')
    print('^2  /adminvehreset [id]^0 - Resetear vehículo')
    print('^2  /adminvehinfo [id]^0 - Ver info del vehículo')
    print('^2  /adminsetoil [id] [0-100]^0 - Establecer aceite')
    print('^2  /admintoggleseize [id]^0 - Toggle motor gripado')
    print('^2  /hudstats^0 - Ver estadísticas del servidor')
    print('^3Items mecánicos disponibles:^0')
    print('^2  motor_oil^0 - Cambiar aceite')
    print('^2  coolant^0 - Rellenar refrigerante')
    print('^2  car_battery^0 - Reemplazar batería')
end)

-- ═══════════════════════════════════════════════════════════
-- 🔚 FIN DEL SCRIPT
-- ═══════════════════════════════════════════════════════════