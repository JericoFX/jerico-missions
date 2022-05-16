local QBCore = exports["qb-core"]:GetCoreObject()
local Num = 0
local SelectedMission = {}
local chance
local Missions = {}
setmetatable(Missions, self)

function log(text)
	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end

function Missions:Init(id, src, cid)
	local Player = QBCore.Functions.GetPlayer(src)
	self.__index = self

	self.Id = id
	self.PlayerID = src
	self.cid = Player.PlayerData.citizenid
	self.Mission = {}
	if not self.Mission[self.cid] then
		self.Mission[self.cid] = {}
	end
	self.Mission[self.cid].Mission = Config.Missions[id]
	if self.Mission[self.cid].Mission.IS_FIXED then
		self.Mission[self.cid].Mission.Type = "FIXED"
	else
		self.Mission[self.cid].Mission.Type = "MOVABLE"
	end
	--- Set the Mission Taked so no one else can spawn it
	self.Mission[self.cid].Mission.TAKED = true
	--- Save the Vehicle Information
	--- @ID Server side Entity number
	--- @Plate Server side Plate Vehicle
	--- @NetID NetworkID of the vehicle, you can send this to the client and catch it with a NetToVeh()
	self.Mission[self.cid].Vehicle = { ID = nil, Plate = "", NetID = 0 }
	--- Save the NPC to send it to the Client and give the weapons
	self.Mission[self.cid].Npc = {}
	--- Handle the blips
	self.Mission[self.cid].Blip = 0
	--- Handling the PolyZone created on the client side
	self.Mission[self.cid].EndMission = {}
	--- Handle all the states of the Mission
	--- @1 Just Started
	--- @2 NPC Taked Down
	--- @3 Marker created
	--- @4 Inside PolyZone
	--- @5 Mission Ended
	self.Mission[self.cid].Track = "1"

	Missions:CreateBlip(self.PlayerID)
	Missions:CreateVehicle()
	Missions:SpawnPeds()
	return self
end

function Missions:CreateBlip(src)
	if self.Mission[self.cid].Mission.Type == "FIXED" then
		QBCore.Functions.TriggerClientCallback("jerico-missions:CB:CreateBlip", src, function(blip)
			self.Mission[self.cid].Blip = blip
		end, self.Mission[self.cid].Mission.BLIP_INFO.BLIP_COORDINATE, self.Mission[self.cid].Mission.NAME)
	end
end

function Missions:CreateVehicle(src)
	self.Mission[self.cid].Vehicle.ID = CreateVehicle(
		self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_TO_SPAWN,
		self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE,
		true,
		true
	)
	SetVehicleNumberPlateText(self.Mission[self.cid].Vehicle.ID, "JERE" .. math.random(1000, 9999))
	repeat
		Wait(10)
	until DoesEntityExist(self.Mission[self.cid].Vehicle.ID)
	self.Mission[self.cid].Vehicle.NetID = NetworkGetNetworkIdFromEntity(self.Mission[self.cid].Vehicle.ID)
	self.Mission[self.cid].Vehicle.Plate = GetVehicleNumberPlateText(self.Mission[self.cid].Vehicle.ID)
end

function Missions:SpawnPeds()
	for k, v in pairs(self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].NPC) do
		local Ped = CreatePed(1, k, v.x, v.y, v.z, v.w, true, false)
		Wait(200)
		self.Mission[self.cid].Npc[#self.Mission[self.cid].Npc + 1] = {
			ID = Ped,
			hash = k,
			NetID = NetworkGetNetworkIdFromEntity(Ped),
		}
	end
	for i = 1, #self.Mission[self.cid].Npc do
		Num = i
		repeat
			Wait(10)
		until DoesEntityExist(self.Mission[self.cid].Npc[i].ID)
	end
	QBCore.Functions.TriggerClientCallback("jerico-missions:CB:GivePedSync", self.PlayerID, function(cb)
		if cb then
			return true
		end
	end, self.Mission[self.cid].Npc)
	Missions:GetPedsHealth()
end

function Missions:GetPedsHealth()
	local s = true
	while s do
		Wait(1000)
		for i = 1, #self.Mission[self.cid].Npc do
			if GetEntityHealth(self.Mission[self.cid].Npc[i].ID) == 0 then
				QBCore.Functions.TriggerClientCallback("jerico-missions:CB:CreateZone", self.PlayerID, function(cb)
					if cb then
						self.Mission[self.cid].EndMission = cb
					end
				end, self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].END_MISSION_COORDS, self.cid)
				s = false
			end
		end
		if not s then
			break
		end
	end
end
function Missions:UpdateZone(Name, Inside)
	if self.Mission[self.cid].EndMission.name == Name then
		print(self.Mission[self.cid].EndMission.isInside)
		self.Mission[self.cid].EndMission.isInside = Inside
	end
end
RegisterServerEvent("jerico-missions:SB:IsInside", function(ZoneName, isInside)
	Missions:UpdateZone(ZoneName, isInside)
end)
RegisterServerEvent("jerico-missions:server:AddItemsInVehicle", function(cid, sid)
	TriggerClientEvent("jerico-missions:server:AddItemsInVehicle", source, cid, sid)
end)
function Missions:DeleteAll()
	if self.Mission[self.cid].Vehicle.ID == nil then
		return
	end
	DeleteEntity(self.Mission[self.cid].Vehicle.ID)
	if #self.Npc > 0 then
		for k, v in ipairs(self.Mission[self.cid].Npc) do
			if DoesEntityExist(self.Mission[self.cid].Npc[k].ID) then
				DeleteEntity(self.Mission[self.cid].Npc[k].ID)
			end
		end
	end
end

QBCore.Functions.CreateCallback("jerico-missions:SB:GetMissions", function(source, cb)
	local Data = {}
	for k, v in ipairs(Config.Missions) do
		local el = Config.Missions[k]
		Data[#Data + 1] = { name = el.NAME, id = k }
	end
	cb(Data)
end)
RegisterServerEvent("jerico-missions:SB:SelectMission", function(id)
	local src = source
	if not Config.Missions[id.id] then
		TriggerClientEvent("QBCore:Notify", source, "Error on mission ID", "error")
	end

	SelectedMission = Missions:Init(id.id, src)
end)

function Missions:SetVehicle()
	TriggerClientEvent("jerico-missions:client:GetKey", self.PlayerID, self.Mission[self.cid].Vehicle.Plate)
	TriggerClientEvent("QBCore:Notify", source, "YESSS")
end

local number = 1
RegisterServerEvent("n", function()
	chance = math.random(number, Num)
	print(chance, number, Num)
	if chance == Num then
		Missions:SetVehicle()
		number = 1
	end
	number = number + 1
end)

function Missions:AddItemsInTrunk()
	local items = {}
	for k, item in pairs(self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].ITEMS_IN_CAR) do
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
	self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].ITEMS_IN_CAR = items
	Wait(200)
	TriggerEvent(
		"inventory:server:addTrunkItems",
		self.Mission[self.cid].Vehicle,
		self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].ITEMS_IN_CAR
	)
end

AddEventHandler("onResourceStop", function(resource)
	if not GetCurrentResourceName() == resource then
		return
	end
	Missions:DeleteAll()
end)
