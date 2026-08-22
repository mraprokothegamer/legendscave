fx_version 'cerulean'
game 'gta5'

name 'waterdispenser'
description 'Auto-detecting water dispensers with ox_target, ESX thirst, and immersive drink animations'
author 'legendscave'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@es_extended/imports.lua',
    'server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'es_extended',
    'esx_status',
}
