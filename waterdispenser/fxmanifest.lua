fx_version 'cerulean'
game 'gta5'

name 'waterdispenser'
author 'legendscave'
description 'Production-ready emergency water dispensers for Qbox/ESX with ox_target, 17mov_Hud, and immersive NUI'
version '2.0.5'

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

-- Framework (auto-detected): qbx_core | qb-core | es_extended + esx_status
-- HUD (configured): 17mov_Hud recommended for Qbox
