fx_version 'cerulean'
game 'gta5'

name 'ls_waterdispenser'
author 'legendscave'
description 'Existing Rockstar water coolers — free drink, Prop cup + auto-hiding NUI'
version '2.3.4'

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

-- prop.lua MUST load before main.lua (defines global Prop)
client_scripts {
    'client/hud.lua',
    'client/prop.lua',
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
