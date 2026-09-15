fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fivem-hygiene'
description 'APROKO hygiene item exports for ox_inventory (Qbox / qbx_core)'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/ox_inventory.lua',
}

-- Must match client.export = 'fivem-hygiene.<name>' on the items
client_exports {
    'hygiene_soap',
    'hygiene_bodywash',
    'hygiene_deodorant',
    'hygiene_perfume',
}

dependencies {
    'ox_lib',
    'ox_inventory',
}
