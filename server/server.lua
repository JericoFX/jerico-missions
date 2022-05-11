local QBCore = exports["qb-core"]:GetCoreObject()
local Data = { Veh = {} }
local MissionTrack = {}
local Cache = {}
function log(text)
	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end

RegisterServerEvent("jerico-missions:server:UpdateValue", function(data)
	local src = source
	local P = QBCore.Function.GetPlayer(src)
		
	for k, v in pairs(data) do
		if not MissionTrack[P.PlayerData.citizenid] then
			MissionTrack[P.PlayerData.citizenid] = v
		end
	end
end)
RegisterServerEvent("jerico-missions:server:UpdateMission", function(state, value)
	local src = source
	local P = QBCore.Function.GetPlayer(src)
	if not MissionTrack[P.PlayerData.citizenid][state] then
		log("ERROR STATE NOT REGISTERED")
		return
	end
	MissionTrack[P.PlayerData.citizenid][state] = value
end)

QBCore.Functions.CreateCallback("jerico-missions:server:SpawnVehicle", function(source, cb, vehicle, vehiclepos)
	Data.Veh.VehicleID = CreateVehicle(vehicle, vehiclepos.x, vehiclepos.y, vehiclepos.z, 180, true, true)

	SetVehicleNumberPlateText(Data.Veh.VehicleID, "JERE" .. math.random(1000, 9999))
	Data.Veh.Plate = GetVehicleNumberPlateText(Data.Veh.VehicleID)
	Wait(200)
	if DoesEntityExist(Data.Veh.VehicleID) then
		Data.Veh.NetID = NetworkGetNetworkIdFromEntity(Data.Veh.VehicleID)
		cb(Data.Veh)
	else
		cb(0)
	end
end)

RegisterServerEvent("jerico-missions:server:AddItemsInVehicle", function(cid, sid)
	TriggerClientEvent("jerico-missions:server:AddItemsInVehicle", source, cid, sid)
end)

QBCore.Functions.CreateCallback("jerico-missions:server:GetState",function(source,cb,cid) 
	if MissionTrack[cid] then
		cb(MissionTrack[cid].state)	
	end
end)

-- QBCore.Functions.CreateCallback("jerico-missions:server:SpawnPeds", function(source, cb, npc)
-- 	local found = false
-- 	print("llego")
-- 	for model, coords in pairs(npc) do
-- 		local ped = CreatePed(1, model, coords.x, coords.y, 180, true, false)

-- 		SetPedRandomProps(ped)
-- 		Data[#Data + 1] = {
-- 			source = ped,
-- 			ID = NetworkGetNetworkIdFromEntity(ped),
-- 			hash = model,
-- 		}
-- 	end

-- 	for i = 1, #Data do
-- 		local el = Data[i]
-- 		while not DoesEntityExist(el.source) do
-- 			Wait(25)
-- 		end
-- 		Wait(100)
-- 		if DoesEntityExist(el.source) then
-- 			found = true
-- 		end
-- 	end
-- 	if found then
-- 		cb(Data)
-- 	else
-- 		cb(0)
-- 	end
-- end)
