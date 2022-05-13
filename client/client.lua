local Missions = {}

CreateThread(function()
	QBCore.Functions.LoadModel("s_m_m_autoshop_02")
	NPC = CreatePed(
		1,
		`s_m_m_autoshop_02`,
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

---Add Items in Vehicle, Citizenid and ServerID
---@param c string
---@param s number
function Missions:AddVehicleItems(c, s)
	if self.SID == s and self.cid == c and GetVehiclePedIsIn(PlayerPedId(), false) == self.Vehicle.ID then
		local items = {}
		for k, item in pairs(self.MissionID.FIXED.ITEMS_IN_CAR) do
			local itemInfo = QBCore.Shared.Items[item.name:lower()]
			items[item.slot] = {
				name = itemInfo["name"],
				amount = tonumber(item.amount),
				info = item.info,
				label = itemInfo["label"],
				description = itemInfo["description"] and itemInfo["description"] or "",
				weight = itemInfo["weight"],
				type = itemInfo["type"],
				unique = itemInfo["unique"],
				useable = itemInfo["useable"],
				image = itemInfo["image"],
				slot = item.slot,
			}
		end
		self.MissionID.FIXED.ITEMS_IN_CAR = items
		Wait(200)
		TriggerServerEvent("inventory:server:addTrunkItems", self.Vehicle.Plate, self.MissionID.FIXED.ITEMS_IN_CAR)
	end
end

RegisterNetEvent("jerico-missions:client:GetKey", function(plate)
print("LLEGO ",plate)
		TriggerEvent("vehiclekeys:client:SetOwner", plate)
		--Types: success,primary,error,police,ambulance
	--	QBCore.Functions.Notify("You Recive the Key", "success", 3000)
end)

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
