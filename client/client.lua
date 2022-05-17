local Missions = {}

CreateThread(function()
	Wait(200)
	print("Carga dale")
	QBCore.Functions.LoadModel("a_c_killerwhale")
	NPC = CreatePed(
		1,
		`a_c_killerwhale`,
		vector4(1058.85, 3035.84, 41.72, 289.57),
		true,
		false
	)
	exports["qb-target"]:AddTargetEntity(NPC, {
		options = {
			{
				type = "client",
				event = "openMenu",
				icon = "fas fa-box-circle-check",
				label = "Comprar Drogas",
			},
		},
		distance = 3.0,
	})
	BlockPedDeadBodyShockingEvents(NPC, true)
	SetBlockingOfNonTemporaryEvents(NPC, true)
	TaskStandGuard(NPC,GetEntityCoords(NPC),180,"WORLD_VEHICLE_POLICE_BIKE")
end)
function log(text)
	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end


RegisterNetEvent("openMenu", function()
	local Data = {}
	local p = promise.new()
	QBCore.Functions.TriggerCallback("jerico-missions:SB:GetMissions", function(menu)
		for k, v in ipairs(menu) do
			Data[#Data + 1] = {
				header = "Mision",
				txt = v.name,
				params = {
					isServer = true,
					event = "jerico-missions:SB:SelectMission",
					args = {
						id = v.id,
					},
				},
			}
		end
		p:resolve(Data)
	end)
	Citizen.Await(p)
	local MenuData = {
		{
			header = "Select Mission",
			isMenuHeader = true,
		},
		Data[1],
	}
	exports["qb-menu"]:openMenu(MenuData)
end)


-- RegisterNetEvent("jerico-missions:client:GetKey", function(plate)
	
-- end)

CreateThread(function()
	Wait(200)
	local _, hash = GetCurrentPedWeapon(PlayerPedId(), true)
	SetPedInfiniteAmmo(PlayerPedId(), hash)
end)

RegisterCommand("dvp", function(source, args)
	local Peds = QBCore.Functions.GetPeds()
	for k, v in ipairs(Peds) do
		local el = Peds[k]
		DeleteEntity(el)
	end
end)
