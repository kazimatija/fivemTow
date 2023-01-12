fx_version 'cerulean'
game 'gta5'

name "Brazzers Towing"
author "Brazzers Development | MannyOnBrazzers#6826"
version "1.0"

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
	-- '@ox_lib/init.lua', -- IF YOU USING OX UNCOMMENT THIS
	'shared/*.lua',
}

escrow_ignore {
    'client/*.lua',
	'server/*.lua',
	'shared/*.lua',
	'README/*lua',
}