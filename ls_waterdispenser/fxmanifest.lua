fx_version 'cerulean'
game 'gta5'

name 'ls_waterdispenser'
author 'legendscave'
description 'Drink from existing water coolers (ox_target + NUI + cup)'
version '2.4.1'

lua54 'yes'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/validate.lua',
}

client_scripts {
    'client/hud.lua',
    'client/main.lua',
}

server_scripts {
    'server/framework.lua',
    'server/main.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
}
