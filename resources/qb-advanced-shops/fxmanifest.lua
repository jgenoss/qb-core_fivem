fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/app.js',
    'html/style.css'
}

shared_script 'config.lua'

client_script {
    'client.lua'
}

server_script {
    '@oxmysql/lib/MySQL.lua', -- Esto inyecta la variable global MySQL
    'server.lua'
}

dependency {    
    'oxmysql',
    'qb-shop-ui'
}