fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Jose - Vehicle Simulation Expert'
description 'HUD Ultimate v13.2 - Arquitectura Modular Avanzada'
version '13.2.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
}

client_scripts {
    'config.lua',
    'events.lua',
    'client.lua',          -- 🎨 HUD UI (segundo)
    'vehicle.lua'      -- ⚙️ Simulación vehicular (primero)
}

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'stream/*.ytd',
    'stream/*.gfx'
}

dependencies {
    'qb-core',
    'pma-voice'
}