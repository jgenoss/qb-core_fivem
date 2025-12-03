fx_version 'cerulean'
game 'gta5'

author 'JGenoss'
description 'Sistema Profesional de Tiendas con UI Moderna'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/app.js',
    'html/style.css'
}

shared_script 'config.lua'

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'oxmysql',
    'qb-core'
}