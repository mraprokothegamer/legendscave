fx_version 'cerulean'
game 'gta5'

name 'waterdispenser'
description 'Auto-detecting water dispensers with ox_target, Qbox/ESX thirst, and immersive drink animations'
author 'legendscave'
version '1.3.0'

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
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server/framework.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
}

-- Requires ONE framework (auto-detected by default):
--   qbx_core  (Qbox)
--   qb-core   (legacy QBCore)
--   es_extended + esx_status  (ESX)
