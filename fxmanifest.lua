fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game "gta5"
lua54 'yes'

ui_page 'build/index.html'
-- ui_page 'http://localhost:3000/' --for dev

shared_script '@ox_lib/init.lua'

server_script {
    '@bl_bridge/imports/server.lua',
    'server/init.lua'
}

client_script {
    '@bl_bridge/imports/client.lua',
    'client/init.lua',
}

files {
    'client/modules/**',
    'data/**',
    'build/**',
}

data_file 'DLC_ITYP_REQUEST' 'stream/lev_briefcase.ytyp'