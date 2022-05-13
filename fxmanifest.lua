fx_version("cerulean")
game("gta5")

description("JERICO-MISSIONS")
version("0.0.1b")
client_scripts({
	"@PolyZone/client.lua",
	"@PolyZone/BoxZone.lua",
	"client/functions.lua",
	"client/client.lua",
})
server_scripts({ "@oxmysql/lib/MySQL.lua", "server/server.lua", "server/config.lua" })
