lua54 'yes'
fx_version 'cerulean'
game 'gta5'

author 'Pug'
description 'Pug Development'
version '4.0.4'

client_script {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/client.lua',
    'client/open.lua',
    'client/menus.lua',
    'client/teams.lua',
    'client/dui_logic.lua',
    '@ox_lib/init.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
	'server/server.lua',
    'server/sv_lobby.lua',
    'server/sv_scoreboard.lua',
    'server/sv_teams.lua',
    'server/sv_ranks.lua',
    'server/sv_ctf.lua',
}

shared_script {
    'config/config-framework.lua',
    'config/config.lua',
    'config/translations/english.lua',
    'config/translations/spanish.lua',
    'config/translations/chinese.lua',
    'config/translations/polish.lua',
    'config/translations/japanese.lua',
    'config/translations/french.lua',
    'config/config-gamemodes.lua',
    'config/config-weapons.lua',
    'config/config-capture_the_flag.lua',
    'config/config-maps_and_spawns.lua',
    'config/config-prestige.lua',
}

ui_page 'html/index.html'
files {
    'html/*.html',
    'html/sounds/*',
    'html/*.css',
    'html/*.js',
    'html/weapon_icons/*.png',
    'html_dui/prestige_icons/*.png',
    'html_dui/index.html',
    '**/weaponcomponents.meta',
	'**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/pedpersonality.meta',
	'**/weapons.meta',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'


escrow_ignore {
    'config/config-framework.lua',
    'config/translations/english.lua',
    'config/translations/spanish.lua',
    'config/translations/chinese.lua',
    'config/translations/polish.lua',
    'config/translations/japanese.lua',
    'config/translations/french.lua',
    'config/config.lua',
    'config/config-gamemodes.lua',
    'config/config-weapons.lua',
    'config/config-capture_the_flag.lua',
    'config/config-maps_and_spawns.lua',
    'config/config-prestige.lua',
    'client/teams.lua',
    'client/open.lua',
    'client/menus.lua',
    'server/sv_lobby.lua',
    '[ARCADE-MLO]/int_arcade/client.lua',
    '[ARCADE-MLO]/int_arcade/fxmanifest.lua',
    '[ARCADE-MLO]/int_arcade/stream/*',
}
dependency '/assetpacks'