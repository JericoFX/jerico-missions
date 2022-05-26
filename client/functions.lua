
 QBCore = exports["qb-core"]:GetCoreObject()
function DrawMarkers(coords)
	DrawMarker(3, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
 end

RegisterNetEvent("jerico-missions:client:OpenMenu", function()
	local Data = {}
	local p = promise.new()
	QBCore.Functions.TriggerCallback("jerico-missions:SB:GetMissions", function(menu)
		for _, v in ipairs(menu) do
			Data[#Data + 1] = {
				header = "Mision",
				txt = v.name,
				params = {
					isServer = true,
					event = "jerico-missions:server:CreateMission",
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



CreateThread(function()
	Wait(200)
	QBCore.Functions.LoadModel("a_m_m_beach_01")
	NPC = CreatePed(
		1,`a_m_m_beach_01`,
		vector4(1058.85, 3035.84, 41.72, 289.57),
		false,
		false
	)
	exports["qb-target"]:AddTargetEntity(NPC, {
		options = {
			{
				type = "client",
				event = "jerico-missions:client:OpenMenu",
				icon = "fas fa-box-circle-check",
				label = "Comprobar Misiones",
			},
		},
		distance = 2.0,
	})
	BlockPedDeadBodyShockingEvents(NPC, true)
	SetBlockingOfNonTemporaryEvents(NPC, true)
	
end)
