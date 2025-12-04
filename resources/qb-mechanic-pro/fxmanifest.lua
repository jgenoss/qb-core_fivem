fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jose - Mechanic System Pro'
description 'Sistema profesional de talleres mecánicos con gestión multi-propietario'
version '1.0.0'

-- ============================================================================
-- SHARED SCRIPTS
-- ============================================================================
shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

-- ============================================================================
-- CLIENT SCRIPTS
-- ============================================================================
client_scripts {
    -- Custom frameworks (editables por el usuario)
    'client/custom/frameworks/*.lua',
    
    -- Core modules
    'client/modules/workshop.lua',
    'client/modules/creator.lua',
    'client/modules/tuneshop.lua',
    'client/modules/tablet.lua',
    'client/modules/carlift.lua',
    'client/modules/flatbed.lua',     -- ← NUEVO
    'client/modules/towing.lua',      -- ← NUEVO
    'client/modules/service_items.lua', -- ← NUEVO
    
    -- Entrada principal (debe ir al final)
    'client/client.lua'
}

-- ============================================================================
-- SERVER SCRIPTS
-- ============================================================================
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/init.lua',
    -- Custom integrations (editables por el usuario)
    'server/custom/society/*.lua',
    'server/custom/inventory/*.lua',
    
    -- Core modules
    'server/modules/database.lua',
    'server/modules/shops.lua',
    'server/modules/employees.lua',
    'server/modules/orders.lua',      -- ← CRÍTICO
    'server/modules/statistics.lua',
    
    -- Entrada principal (debe ir al final)
    'server/server.lua'
}

-- ============================================================================
-- UI FILES
-- ============================================================================
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/**',
    'html/js/**',
    'html/assets/**',
}

-- ============================================================================
-- DATA FILES
-- ============================================================================
files {
    'data/carcols_gen9.meta',
    'data/carmodcols_gen9.meta'
}

data_file 'CARCOLS_GEN9_FILE' 'data/carcols_gen9.meta'
data_file 'CARMODCOLS_GEN9_FILE' 'data/carmodcols_gen9.meta'

-- ============================================================================
-- DEPENDENCIES
-- ============================================================================
dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql'
}

-- ============================================================================
-- ESCROW CONFIGURATION (Descomenta para proteger con escrow)
-- ============================================================================
-- escrow_ignore {
--     'shared/**',
--     'locales/**',
--     'client/custom/**',
--     'server/custom/**',
--     'html/**',
--     'data/**',
--     'install.sql',
--     'README.md'
-- }