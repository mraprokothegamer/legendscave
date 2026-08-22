fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'legendscave-jukebox'
author 'Augustus'
description 'Local prop jukebox — ox_target existing speakers, YouTube via xSound, NUI progress'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
}

dependencies {
    'ox_target',
    'xsound',
}
