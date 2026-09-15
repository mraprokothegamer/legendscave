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

-- ox_inventory looks these up as exports['legends-cave-medical']['useDoctorTablet'].
-- fxmanifest `exports` binds the global functions; client Lua also registers them at runtime.
exports {
    'useDoctorTablet',
    'useTreatmentPill'
}

files {
    'html/index.html',
    'html/assets/*.png',
    'html/sounds/*.wav',
    'html/**/*',
    'installation/ox_items.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
