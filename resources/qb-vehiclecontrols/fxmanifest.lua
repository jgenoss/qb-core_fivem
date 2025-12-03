fx_version 'cerulean'
game 'gta5'

author 'Jose - Vehicle Control System'
description 'Sistema avanzado de control vehicular con menú radial para QBCore'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client.lua'
}

-- LÍNEA AGREGADA: Esto asegura que el script de cliente gestione los callbacks NUI
nui_script 'client.lua' 

server_scripts {
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

dependencies {
    'qb-core'
}

lua54 'yes'