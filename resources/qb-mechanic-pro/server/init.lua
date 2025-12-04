-- ============================================================================
-- QB-MECHANIC-PRO - Server Init
-- Carga el Core Object antes que los módulos
-- ============================================================================

QBCore = nil
ESX = nil

if Config.Framework == 'qbcore' or Config.Framework == 'qbox' then
    QBCore = exports['qb-core']:GetCoreObject()
    print('^2[QB-MECHANIC-PRO]^0 QBCore initialized globally.')
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
    print('^2[QB-MECHANIC-PRO]^0 ESX initialized globally.')
end