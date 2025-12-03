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
    '@ox_lib/init.lua',  -- Para UI components y utils
    'shared/config.lua'
}

-- ============================================================================
-- LOCALES
-- ============================================================================
files {
    'locales/*.lua'
}

-- ============================================================================
-- CLIENT SCRIPTS
-- ============================================================================
client_scripts {
    -- Custom frameworks (editables)
    'client/custom/frameworks/*.lua',
    'client/custom/inventory/*.lua',
    
    -- Core modules (protegibles con escrow)
    'client/modules/workshop.lua',
    'client/modules/creator.lua',
    'client/modules/tuneshop.lua',
    'client/modules/tablet.lua',
    'client/modules/carlift.lua',
    
    -- Entrada principal
    'client/client.lua'
}

-- ============================================================================
-- SERVER SCRIPTS
-- ============================================================================
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    
    -- Custom integrations (editables)
    'server/custom/society/*.lua',
    'server/custom/inventory/*.lua',
    
    -- Core modules (protegibles con escrow)
    'server/modules/database.lua',
    'server/modules/shops.lua',
    'server/modules/employees.lua',
    'server/modules/orders.lua',
    'server/modules/statistics.lua',
    
    -- Entrada principal
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
    'html/assets/**'
}

-- ============================================================================
-- DATA FILES (colores custom, etc)
-- ============================================================================
files {
    'data/carcols_gen9.meta'
}

data_file 'CARCOLS_GEN9_FILE' 'data/carcols_gen9.meta'

-- ============================================================================
-- DEPENDENCIES
-- ============================================================================
dependencies {
    '/onesync',
    'ox_lib',
    'oxmysql'
}

-- ============================================================================
-- ESCROW CONFIGURATION (Descomentar cuando quieras proteger)
-- ============================================================================
-- escrow_ignore {
--     'shared/**',
--     'locales/**',
--     'client/custom/**',
--     'server/custom/**',
--     'html/css/**',
--     'install.sql'
-- }
