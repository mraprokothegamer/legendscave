fx_version 'cerulean'
game 'gta5'

name 'ls_waterdispenser'
author 'legendscave'
description 'Emergency water dispenser - drink from water coolers/dispensers to restore thirst (Qbox + ox)'
version '1.0.0'
repository 'https://github.com/mraprokothegamer/legendscave'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/sounds/pour.wav',
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
}
