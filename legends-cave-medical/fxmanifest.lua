fx_version 'cerulean'
game 'gta5'

author 'Legends Cave'
description 'Legends Cave weather-based EMS patient scanner'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/assets/skeletal-scan.png',
    'installation/ox_items.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
