local Missions = {}
local p
setmetatable(Missions, self)
local Mision
local num = 1
local chance = 0
local NPC

function Missions:Init(id)
	self.__index = self
	if Config.Missions[id] then
		self.id = id
	end

	self.SID = GetPlayerServerId(PlayerId())
	self.cid = QBCore.Functions.GetPlayerData().citizenid
	self.MissionID = Config.Missions[id]
	self.MissionID.TAKED = true
	self.blip = 0
	self.Vehicle = { ID = 0, Plate = "" }
	self.NPC = {}
	self.NPC_MISSION = NPC
	self.EndMission = { Zone = nil, IsInside = false }
	Missions:CreateBlips() -- Create the blips for the selected mission
	Missions:SpawnPeds() -- Spawn the peds
	---
	Missions:SpawnHandler()
	Missions:SpawnVehicle()
	Missions:UpdateValue({state = "Inicio",vehicle = self.Vehicle,cid = self.cid,src = self.SID})

	return self
end

function Missions:UpdateValue(state)
		TriggerServerEvent("jerico-missions:server:UpdateValue",state)
end
function Missions:UpdateMissionState(state,value)
	TriggerServerEvent("jerico-missions:server:UpdateMission",state,value)
end
function Missions:CreateBlips()
	if self.MissionID.HAS_BLIP then
		self.blip = addBlip(self.MissionID.BLIP_INFO.BLIP_COORDINATE, self.MissionID.NAME)
	end
end

function Missions:SpawnHandler()
		QBCore.Functions.LoadModel(self.MissionID.FIXED.NPC_MISSION[1].name)
		self.NPC_MISSION = CreatePed(
			1,
			self.MissionID.FIXED.NPC_MISSION[1].name,
			self.MissionID.FIXED.NPC_MISSION[1].coords.x,
			self.MissionID.FIXED.NPC_MISSION[1].coords.y,
			self.MissionID.FIXED.NPC_MISSION[1].coords.z,
			self.MissionID.FIXED.NPC_MISSION[1].coords.w,
			true,
			false
		)
		exports["qb-target"]:AddTargetEntity(self.NPC_MISSION, {
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
end
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
end)
RegisterCommand("goto",function(source) 
	local coo = vector3(1072.41, 3037.8, 41.29)
	local closeVeh,closeDist = QBCore.Functions.GetClosestVehicle()

	local min,max = GetModelDimensions(GetEntityModel(closeVeh))
	TaskGoStraightToCoord(NPC,GetWorldPositionOfEntityBone(closeVeh,GetEntityBoneIndexByName(closeVeh,"door_pside_r")),1.5,-1,180,0.5)

while #(GetEntityCoords(NPC)-GetWorldPositionOfEntityBone(closeVeh,GetEntityBoneIndexByName(closeVeh,"door_pside_r")) ) > 2 do
	print "far"
	Wait(500)
end

--
print("DOne")
RequestAnimDict("amb@world_human_welding@male@idle_a")
while not HasAnimDictLoaded("amb@world_human_welding@male@idle_a") do
	Citizen.Wait(10)
end
Wait(500)
TaskLookAtEntity(NPC,closeVeh,-1,2048,3)

TaskStartScenarioInPlace(NPC,"WORLD_HUMAN_WELDING",0,true)
--TaskPlayAnim(NPC,"amb@world_human_welding@male@idle_a","welding_base_dockworker", 5.0, -5, -1, 16, false, false, false, false)
Wait(2000)
ClearPedTasks(NPC)
--SetVehicleDoorBroken(closeVeh,3,false)
SetVehicleDoorsLocked(closeVeh,1)
TaskGoStraightToCoord(NPC,vector3(1058.85, 3035.84, 41.72),1.5,-1, 289.57,0.5)
end)
RegisterNetEvent("openMenu",function() 
	local Data = {}
	for k,v in ipairs(Config.Missions) do
		local el = Config.Missions[k]
Data[#Data+1] = {
	header = "Mision",
	txt = el.NAME,
	params = {
			event = "MissionSelected",
			args = {
					id = k,
			}
	}
}
	end
-- https://github.com/qbcore-framework/qb-menu/blob/main/README.md
local MenuData = {
				{
						header = "Select Mission",
						isMenuHeader = true, 
				},
				Data[1]
		}
exports["qb-menu"]:openMenu(MenuData)

end)
RegisterNetEvent("MissionSelected",function(data) 
if Config.Missions[data.id] then
	CreateThread(function()
		p = promise.new()
		Mision = Missions:Init(data.id)
		p:resolve(Mision)
		Citizen.Await(p)
		chance = math.random(num,#Mision.NPC)
	end)
end
end)

RegisterCommand("om",function(source) 
TriggerEvent("openMenu")

end)
function Missions:SpawnVehicle()
	QBCore.Functions.SpawnVehicle(self.MissionID.FIXED.VEHICLE_TO_SPAWN, function(veh)
		SetVehicleNumberPlateText(veh, "JERE" .. math.random(1000, 9999))
		SetVehicleDoorsLocked(veh, 2)
		self.Vehicle.Plate = QBCore.Functions.GetPlate(veh)

		self.Vehicle.ID = veh
	end, self.MissionID.FIXED.VEHICLE_COORDINATE, true, false)

end

function Missions:SpawnPeds()
		local Player = PlayerPedId()
			local Data = {}
			for k,v in pairs(self.MissionID.FIXED.NPC) do
				RequestModel(k)
				while not HasModelLoaded(k) do
					Wait(0)
				end
				Wait(200)
				local newPed = CreatePed(1,k,v.x,v.y,v.z,v.w,true,false)
				SetEntityAsMissionEntity(newPed, true, true)
				NetworkRegisterEntityAsNetworked(newPed)
				local netID = PedToNet(newPed)
				NetworkSetNetworkIdDynamic(netID, false)
				SetNetworkIdCanMigrate(netID, true)
				SetNetworkIdExistsOnAllMachines(netID, true)
				local _, grouphash = AddRelationshipGroup("HATE_PLAYER")
				local _, grouphash2 = AddRelationshipGroup("FRIENDS_NPC")
				SetPedRelationshipGroupHash(newPed, grouphash2)
				GiveWeaponToPed(newPed,`WEAPON_SMG`,250,false,true)
				SetPedRelationshipGroupHash(Player, grouphash)
				SetRelationshipBetweenGroups(5, grouphash2, grouphash)
				SetEntityCanBeDamagedByRelationshipGroup(newPed, true, grouphash)
				SetPedFleeAttributes(newPed, 0, false)
				SetPedCombatAttributes(newPed, 46, 1)
				SetPedCombatAbility(newPed, 100)
				SetPedCombatMovement(newPed, 2)
				SetPedCombatRange(newPed, 3)
				SetPedKeepTask(newPed, true)
				SetPedDropsWeaponsWhenDead(newPed, false)
				SetPedArmour(newPed, 100)
				SetPedAccuracy(newPed, 60)
				SetEntityInvincible(newPed, false)
				SetPedAlertness(newPed, 3)
				SetPedAllowedToDuck(newPed, true)
				SetAllRandomPedsFlee(newPed, false)
				SetPedCanCowerInCover(newPed, true)
				Data[#Data+1] = newPed
				Wait(200)
				exports["qb-target"]:AddTargetEntity(newPed, {
					options = {
						{
						--	event = "test",
							icon = "fas fa-sack-dollar",
							label = "Search Keys",
							action = function(entity)
								TriggerEvent('jerico-missions:client:GetKey',1)
							end,
							canInteract = function(entity)
								if IsEntityAPed(entity) and not QBCore.Functions.HasItem("sandwich") then
									return IsEntityDead(entity)
								end
							end,
						},
					},
					distance = 2.5,
				})
			end
			
		self.NPC = Data
		print()
end

function Missions:CreateBoxEnd()
	if self.MissionID.IS_FIXED then
		if self.EndMission.Zone == nil then
			self.EndMission.Zone = BoxZone:Create(self.MissionID.FIXED.END_MISSION_COORDS.coords, 6.6, 10.2, {
				name = "drug_test",
				heading = 0,
				debugPoly = true,
			})
		end
		self.EndMission.Zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
			self.EndMission.IsInside = isPointInside
			if isPointInside then
				TriggerServerEvent("jerico-missions:server:AddItemsInVehicle", self.cid, self.SID)
			else
			end
		end)
	end
end

function Missions:ForceVehicleDoor(bool)
	local guille = bool
	while guille do
		if #self.NPC > 0 then
			for i = 1, #self.NPC do
				local el = self.NPC[i]
				if IsEntityDead(el) then
					SetVehicleDoorsLocked(self.Vehicle.ID, 1)
				
					guille = not guille
					break
				end
			end
		end
		Wait(3000)
	end
end



function Missions:DeleteAll()
	if self.Vehicle.ID > 0 then
		QBCore.Functions.DeleteVehicle(self.Vehicle.ID)
	end
	if #self.NPC > 0 then
		for k,v in ipairs(self.NPC) do
			local el = self.NPC[k]
			DeleteEntity(el)
		end
	end
end
---Add Items in Vehicle
---@param c Citizenid
---@param s Server ID
function Missions:AddVehicleItems(c,s)
	if self.SID == s and self.cid == c and GetVehiclePedIsIn(PlayerPedId(),false) == self.Vehicle.ID then
		print(self.SID,s,self.cid, c)
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

RegisterNetEvent("jerico-missions:server:AddItemsInVehicle", function(citizend, sid)
	Missions:AddVehicleItems(citizend,sid)
end)
---Get the key of the player
---@param n number
---@param p PlayerId

RegisterNetEvent("jerico-missions:client:GetKey",function(n)

if chance == num then
	TriggerEvent("vehiclekeys:client:SetOwner", Mision.Vehicle.Plate)
	--Types: success,primary,error,police,ambulance
	QBCore.Functions.Notify("You Recive the Key", "success", 3000)
	Missions:CreateBoxEnd()
	num = 0
end
num = num + 1
end)

CreateThread(function() 
	Wait(200)
	local _,hash = GetCurrentPedWeapon(PlayerPedId(),true)
	SetPedInfiniteAmmo(PlayerPedId(),hash)

end)

AddEventHandler("onResourceStop", function(resource)
	if not GetCurrentResourceName() == resource then
		return
	end
	Missions:DeleteAll()
end)

RegisterCommand("dvp",function (source,args)
	local Peds = QBCore.Functions.GetPeds()
	for k,v in ipairs(Peds) do
		local el = Peds[k]
		DeleteEntity(el)
	end
end)