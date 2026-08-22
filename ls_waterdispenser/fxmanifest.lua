fx_version 'cerulean'
game 'gta5'

name 'ls_waterdispenser'
author 'legendscave'
description 'Water dispensers with ox_target, Qbox, cup prop, NUI fill, and paid thirst refill'
version '2.0.6'

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
