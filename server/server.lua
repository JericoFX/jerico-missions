local QBCore = exports["qb-core"]:GetCoreObject()
local Num = 0
local SelectedMission = {}
local chance
local Missions = {}
setmetatable(Missions, self)
function log(text)
	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end

function Missions:Init(id, src)
	self.__index = self
	self.Id = id
	self.PlayerID = src
	self.Mission = Config.Missions[id]
	self.Type = ""

	if self.Mission.IS_FIXED then
		self.Type = "FIXED"
	else
		self.Type = "MOVABLE"
	end
	self.Mission[self.Type].TAKED = true
	self.Vehicle = { ID = 0, Plate = "", NetID = 0 }
	self.Npc = {}
	self.Blip = 0
	self.EndMission = nil

	Missions:CreateBlip(self.PlayerID)
	Missions:CreateVehicle()
	Missions:SpawnPeds()
	return self
end

function Missions:CreateBlip(src)
	if self.Type == "FIXED" then
		QBCore.Functions.TriggerClientCallback("jerico-missions:CB:CreateBlip", src, function(blip)
			self.Blip = blip
		end, self.Mission.BLIP_INFO.BLIP_COORDINATE, self.Mission.NAME)
	end
end

function Missions:CreateVehicle(src)
	self.Vehicle.ID = CreateVehicle(
		self.Mission[self.Type].VEHICLE_TO_SPAWN,
		self.Mission[self.Type].VEHICLE_COORDINATE,
		true,
		true
	)
	SetVehicleNumberPlateText(self.Vehicle.ID, "JERE" .. math.random(1000, 9999))
	repeat
		Wait(10)

	until DoesEntityExist(self.Vehicle.ID)

	self.Vehicle.NetID = NetworkGetNetworkIdFromEntity(self.Vehicle.ID)
	self.Vehicle.Plate = GetVehicleNumberPlateText(self.Vehicle.ID)
end

function Missions:SpawnPeds()
	for k, v in pairs(self.Mission[self.Type].NPC) do
		local Ped = CreatePed(1, k, v.x, v.y, v.z, v.w, true, false)

		Wait(200)

		self.Npc[#self.Npc + 1] = {
			ID = Ped,
			hash = k,
			NetID = NetworkGetNetworkIdFromEntity(Ped),
		}
	end

	for i = 1, #self.Npc do
		Num = i
		repeat
			Wait(10)
		until DoesEntityExist(self.Npc[i].ID)
	end
	QBCore.Functions.TriggerClientCallback("jerico-missions:CB:GivePedSync", self.PlayerID, function(cb)
		if cb then
			return true
		end
	end, self.Npc)
	Missions:GetPedsHealth()
end

function Missions:GetPedsHealth()
	Wait(500)
	while true do
		Wait(1000)
		for i = 1, #self.Npc do
			if GetEntityHealth(self.Npc[i].ID) == 0 then
				QBCore.Functions.TriggerClientCallback("jerico-missions:CB:CreateZone", self.PlayerID, function(cb)
					if cb then
						self.EndMission = cb
					end
				end, self.Mission[self.Type].END_MISSION_COORDS)
				break
			end
		end
	end
end
function Missions:UpdateZone(Name, Inside, cid)
	-- if self.EndMission.Zone[Name] then
	-- 	self.EndMission.Zone[Name].isInside = Inside
	-- end
end
RegisterServerEvent("jerico-missions:SB:IsInside", function(ZoneName, isInside, cid)
	Missions:UpdateZone(ZoneName, isInside, cid)
end)
RegisterServerEvent("jerico-missions:server:AddItemsInVehicle", function(cid, sid)
	TriggerClientEvent("jerico-missions:server:AddItemsInVehicle", source, cid, sid)
end)
function Missions:DeleteAll()
	if DoesEntityExist(self.Vehicle.ID) or self.Vehicle.ID > 0 then
		DeleteEntity(self.Vehicle.ID)
	end
	if #self.Npc > 0 then
		for k, v in ipairs(self.Npc) do
			if DoesEntityExist(self.Npc[k].ID) then
				DeleteEntity(self.Npc[k].ID)
			end
		end
	end
end
AddEventHandler("onResourceStop", function(resource)
	if not GetCurrentResourceName() == resource then
		return
	end
	Missions:DeleteAll()
end)

QBCore.Functions.CreateCallback("jerico-missions:SB:GetMissions", function(source, cb)
	local Data = {}
	for k, v in ipairs(Config.Missions) do
		local el = Config.Missions[k]
		Data[#Data + 1] = { name = el.NAME, id = k }
	end
	cb(Data)
end)
RegisterServerEvent("jerico-missions:SB:SelectMission", function(id)
	if not Config.Missions[id.id] then
		TriggerClientEvent("QBCore:Notify", source, "Error on mission ID", "error")
	end
	SelectedMission = Missions:Init(id.id, source)
end)
function Missions:SetVehicle()
	TriggerClientEvent("jerico-missions:client:GetKey", self.PlayerID, self.Vehicle.Plate)
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
