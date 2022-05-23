fx_version("cerulean")
game("gta5")
lua54("yes")
description("JERICO-MISSIONS")
version("0.0.1b")
client_scripts({
	"@PolyZone/client.lua",
	"@PolyZone/BoxZone.lua",
	"client/functions.lua",
	"client/client.lua",
})
shared_scripts({
	"shared/config.lua",
})
server_scripts({ "@oxmysql/lib/MySQL.lua", "server/server.lua" })
