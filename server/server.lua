local QBCore = exports["qb-core"].GetCoreObject()
local CurrentMission = {}
local Chance = 1
local random = math.random
local function uuid()
	local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
	return string.gsub(template, "[xy]", function(c)
		local v = (c == "x") and random(0, 0xf) or random(8, 0xb)
		return string.format("%x", v)
	end)
end
function CheckResource()
	return GetInvokingResource() == "jerico-missions" or GetInvokingResource() == "qb-core"
end
QBCore.Functions.CreateCallback("jerico-missions:server:SpawnVehicle", function(source, cb, id, type, escolt)
	if not CheckResource() then
		print("WHAT HAPPEND")
		return
	end

	local e = nil
	local Player = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
	local CreateAutomobile = GetHashKey("CREATE_AUTOMOBILE")
	if CurrentMission[Player] then
		local v = Citizen.InvokeNative(
			CreateAutomobile,
			GetHashKey(CurrentMission[Player][type].VEHICLE_TO_SPAWN),
			CurrentMission[Player][type].VEHICLE_COORDINATE,
			180.0,
			true,
			false
		)

		while not DoesEntityExist(v) do
			Wait(25)
			print("Waiting")
		end
		if escolt == "table" then
			e = Citizen.InvokeNative(
				CreateAutomobile,
				GetHashKey(CurrentMission[Player][type].VEHICLE_ESCOLT_SPAWN),
				escolt.x,
				escolt.y,
				escolt.z,
				180.0,
				true,
				false
			)
			while not DoesEntityExist(e) do
				Wait(25)
				print("Waiting")
			end
			if DoesEntityExist(v) and DoesEntityExist(e) then
				CurrentMission[Player].Vehicle = e
				local netIdV = NetworkGetNetworkIdFromEntity(v)
				local netIdE = NetworkGetNetworkIdFromEntity(e)
				cb(netIdV, netIdE)
			else
				cb(0)
			end
		else
			if DoesEntityExist(v) then
				CurrentMission[Player].Vehicle = v
				local netIdV = NetworkGetNetworkIdFromEntity(v)

				cb(netIdV)
			else
				cb(0)
			end
		end
	else
		print("NO NO NO")
	end
end)

QBCore.Functions.CreateCallback("jerico-missions:SB:GetMissions", function(source, cb)
	local Data = {}
	for k, v in ipairs(Config.Missions) do
		local el = Config.Missions[k]
		if not el.TAKED then
			Data[#Data + 1] = { name = el.NAME, id = k }
			el.TAKED = true
		else
			Data[#Data + 1] = { name = "No Mission Available", id = nil }
		end
	end
	cb(Data)
end)

RegisterNetEvent("jerico-missions:server:CreateMission", function(id)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local PC = GetEntityCoords(GetPlayerPed(src))
	local randomID = uuid()
	if CurrentMission[Player.PlayerData.citizenid] then
		print(CurrentMission[Player.PlayerData.citizenid])
		TriggerClientEvent("QBCore:Notify", src, "Player Already in a mission or Mission is already taken")
		return
	end
	if not Config.Missions[id.id] then
		TriggerClientEvent("QBCore:Notify", src, "Error: No mission with the id: " .. id.id .. " Found in Config.lua")
		return
	end
	if not CurrentMission[Player.PlayerData.citizenid] or CurrentMission[Player.PlayerData.citizenid] == nil then
		CurrentMission[Player.PlayerData.citizenid] = {}
		CurrentMission[Player.PlayerData.citizenid] = Config.Missions[id.id]
		CurrentMission[Player.PlayerData.citizenid].D = randomID

		Player.Functions.SetMetaData("jerico-missions", { id = id.id, uid = randomID, taked = true })
	end
	Config.Missions[id.id].TAKED = true
	TriggerClientEvent("jerico-missions:client:CreateMissionConfig", src, id.id, Player.PlayerData.citizenid, randomID)
end)
RegisterNetEvent("jerico-missions:server:AddItemsInTrunk", function(cid, d, type, plate)
	if CurrentMission[cid] then
		if CurrentMission[cid].D == d then
			local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
			local meta = Player.PlayerData.metadata["jerico-missions"]
			if meta.uid == d then
				for k, v in pairs(CurrentMission[cid][type].ITEMS_IN_CAR) do
					Player.Functions.AddItem(k, v)
					Config.Missions[Player.PlayerData.metadata["jerico-missions"].id].TAKED = false
					CurrentMission[cid] = nil
					Player.Functions.SetMetaData("jerico-missions", { id = nil, uid = nil, taked = false })
				end
			end
		else
			print("Exploit Detected?")
		end
	end
end)

QBCore.Functions.CreateCallback("jerico-missions:server:GetRID", function(source, cb, rid)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.metadata["jerico-missions"].uid == rid then
		cb(true)
	end
	cb(false)
end)
