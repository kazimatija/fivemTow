fx_version 'cerulean'
game 'gta5'

name "Brazzers Towing"
author "Brazzers Development | MannyOnBrazzers#6826"
version "1.0.1"

lua54 'yes'

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua',
    '@Renewed-Lib/init.lua',
    'shared/*.lua',
}

escrow_ignore {
    'client/job.lua',
    'client/open.lua',
    'server/job.lua',
    'server/open.lua',
    'shared/*.lua',
}
