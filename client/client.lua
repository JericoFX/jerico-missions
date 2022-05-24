local Missions = {}
setmetatable(Missions, self)
local CurrentMission = {}
function Missions:Init(id, cid, data)
	local p = promise.new()
	local Player = QBCore.Functions.GetPlayerData().citizenid
	self.__index = self
	self.Id = id
	self.Citizenid = Player
	if not self.Citizenid == cid then
		QBCore.Functions.Notify("Error CID doesnt match", "error")
		return
	end
	self.MissionData = {}
	if not self.MissionData[self.Citizenid] then
		self.MissionData[self.Citizenid] = {}
	end

	self.MissionData[self.Citizenid] = Config.Missions[id]
	self.MissionData[self.Citizenid].Type = "FIXED"
	if self.MissionData[self.Citizenid].IS_MOVABLE then
		self.MissionData[self.Citizenid].Type = "MOVABLE"
	end
	self.MissionData[self.Citizenid].Temp_blip = nil
	self.MissionData[self.Citizenid].D = data
	self.MissionData[self.Citizenid].Blip = nil
	self.MissionData[self.Citizenid].Zone = nil
	self.MissionData[self.Citizenid].Vehicle = { ID = 0, Plate = "" }
	self.MissionData[self.Citizenid].Npc = {}
	self.MissionData[self.Citizenid].ID = PlayerId()
	self.MissionData[self.Citizenid].PlayerPed = PlayerPedId()
	p:resolve(self)
	if self.MissionData[self.Citizenid].Type == "MOVABLE" then
		Missions:CreateVehicle()
	else
		Missions:AddBlip()
		Missions:CreateVehicle()
	end

	return Citizen.Await(p)
end

function Missions:CreateVehicle()
	local Player = QBCore.Functions.GetPlayerData().citizenid
	QBCore.Functions.TriggerCallback("jerico-missions:server:SpawnVehicle", function(net)
		Missions:TempBlip()
		while not NetworkDoesNetworkIdExist(net) do
			Wait(1000)
		end
		if not CurrentMission[Player] then
			CurrentMission[Player] = {}
			CurrentMission[Player].Vehicle = { ID = 0, Plate = "" }
		end
		self.MissionData[self.Citizenid].Vehicle.ID = NetworkGetEntityFromNetworkId(net)
		self.MissionData[self.Citizenid].Vehicle.Plate = GetVehicleNumberPlateText(
			self.MissionData[self.Citizenid].Vehicle.ID
		)
		CurrentMission[Player].Vehicle.ID = NetworkGetEntityFromNetworkId(net)
		CurrentMission[Player].Vehicle.Plate = GetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(net))

		Missions:SpawnPeds()
		Missions:AddBlip()
	end, self.Id, self.MissionData[self.Citizenid].Type)
end

function Missions:TempBlip()
	self.MissionData[self.Citizenid].Temp_blip = AddBlipForCoord(
		self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].VEHICLE_COORDINATE
	)
	SetBlipSprite(self.MissionData[self.Citizenid].Temp_blip, 535)
	SetBlipColour(self.MissionData[self.Citizenid].Temp_blip, 1)
	SetBlipDisplay(self.MissionData[self.Citizenid].Temp_blip, 4)
	SetBlipAlpha(self.MissionData[self.Citizenid].Temp_blip, 250)
	SetBlipScale(self.MissionData[self.Citizenid].Temp_blip, 0.8)
	SetBlipAsShortRange(self.MissionData[self.Citizenid].Temp_blip, false)
	PulseBlip(self.MissionData[self.Citizenid].Temp_blip)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(self.MissionData[self.Citizenid].NAME)
	EndTextCommandSetBlipName(self.MissionData[self.Citizenid].Temp_blip)
end

function Missions:SpawnPeds()
	if self.MissionData[self.Citizenid].Type == "MOVABLE" then
		for k, v in pairs(self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].NPC) do
			RequestModel(k)
			while not HasModelLoaded(k) do
				Wait(100)
				print("loading?")
			end
			local Ped = CreatePedInsideVehicle(self.MissionData[self.Citizenid].Vehicle.ID, 1, k, v, true, false)
			NetworkRegisterEntityAsNetworked(Ped)
			SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Ped), true)
			SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Ped), true)
			GiveWeaponToPed(Ped, GetHashKey("WEAPON_SMG"), 1, false, true)
			SetPedRelationshipGroupDefaultHash(Ped, GetHashKey("COP"))
			SetPedRelationshipGroupHash(Ped, GetHashKey("COP"))
			SetPedAsCop(Ped, true)
			SetEntityCanBeDamagedByRelationshipGroup(Ped, true, grouphash)
			SetPedFleeAttributes(Ped, 0, false)
			SetPedCombatAttributes(Ped, 46, 1)
			SetPedCombatAbility(Ped, 100)
			SetPedCombatMovement(Ped, 2)
			SetPedCombatRange(Ped, 3)
			SetPedKeepTask(Ped, true)
			SetPedDropsWeaponsWhenDead(Ped, false)
			SetPedArmour(Ped, 100)
			SetPedAccuracy(Ped, 60)
			SetEntityInvincible(Ped, false)
			SetPedAlertness(Ped, 3)
			SetPedAllowedToDuck(Ped, true)
			SetAllRandomPedsFlee(Ped, false)
			SetPedCanCowerInCover(Ped, true)
			Wait(200)
			TaskVehicleDriveWander(
				GetPedInVehicleSeat(self.MissionData[self.Citizenid].Vehicle.ID, -1),
				self.MissionData[self.Citizenid].Vehicle.ID,
				1.0,
				536871740
			)
			TriggerEvent("vehiclekeys:client:SetOwner", self.MissionData[self.Citizenid].Vehicle.Plate)
			self.MissionData[self.Citizenid].Npc[#self.MissionData[self.Citizenid].Npc + 1] = Ped
		end
	else
		for k, v in ipairs(self.MissionData[self.Citizenid].NPC) do
			QBCore.Functions.LoadModel(k)
			local Ped = CreatePed(1, k, v.x, v.y, v.z, v.w, true, false)
			NetworkRegisterEntityAsNetworked(Ped)
			SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Ped), true)
			SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Ped), true)
			SetPedRelationshipGroupDefaultHash(Ped, GetHashKey("HATES_PLAYER"))
			SetPedAsCop(Ped, true)
			GiveWeaponToPed(Ped, "WEAPON_SMG", 1, false, true)
			SetEntityCanBeDamagedByRelationshipGroup(Ped, true, grouphash)
			SetPedFleeAttributes(Ped, 0, false)
			SetPedCombatAttributes(Ped, 46, 1)
			SetPedCombatAbility(Ped, 100)
			SetPedCombatMovement(Ped, 2)
			SetPedCombatRange(Ped, 3)
			SetPedKeepTask(Ped, true)
			SetPedDropsWeaponsWhenDead(Ped, false)
			SetPedArmour(Ped, 100)
			SetPedAccuracy(Ped, 60)
			SetEntityInvincible(Ped, false)
			SetPedAlertness(Ped, 3)
			SetPedAllowedToDuck(Ped, true)
			SetAllRandomPedsFlee(Ped, false)
			SetPedCanCowerInCover(Ped, true)
			Wait(200)
			exports["qb-target"]:AddTargetEntity(Ped, {
				options = {
					{
						icon = "fas fa-sack-dollar",
						label = "Search Keys",
						action = function(_)
							TriggerServerEvent("n", 1)
						end,
						canInteract = function(entity)
							if IsEntityAPed(entity) then
								return IsEntityDead(entity)
							end
						end,
					},
				},
				distance = 2.5,
			})
			self.MissionData[self.Citizenid].Npc[#self.MissionData[self.Citizenid].Npc + 1] = Ped
		end
	end
end
---@public
function Missions:AddBlip()
	if self.MissionData[self.Citizenid].Type == "MOVABLE" then
		if self.MissionData[self.Citizenid].Blip == nil then
			while not DoesEntityExist(self.MissionData[self.Citizenid].Vehicle.ID) do
				Wait(200)
			end
			RemoveBlip(self.MissionData[self.Citizenid].Temp_blip)
			local blip = AddBlipForEntity(self.MissionData[self.Citizenid].Vehicle.ID)
			SetBlipSprite(blip, 535)
			SetBlipColour(blip, 1)
			SetBlipDisplay(blip, 4)
			SetBlipAlpha(blip, 250)
			SetBlipScale(blip, 0.8)
			SetBlipAsShortRange(blip, false)
			PulseBlip(blip)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(self.MissionData[self.Citizenid].NAME)
			EndTextCommandSetBlipName(blip)
			self.MissionData[self.Citizenid].Blip = blip
		else
			RemoveBlip(self.MissionData[self.Citizenid].Blip)
			Missions:AddBlip()
		end
	else
		if self.MissionData[self.Citizenid].Blip == nil then
			local Coords = self.MissionData[self.Citizenid].BLIP_INFO.BLIP_COORDINATE
			local blip = AddBlipForCoord(Coords.x, Coords.y, Coords.z)
			SetBlipSprite(blip, 535)
			SetBlipColour(blip, 1)
			SetBlipDisplay(blip, 4)
			SetBlipAlpha(blip, 250)
			SetBlipScale(blip, 0.8)
			SetBlipAsShortRange(blip, false)
			PulseBlip(blip)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(self.MissionData[self.Citizenid].NAME)
			EndTextCommandSetBlipName(blip)
			self.MissionData[self.Citizenid].Blip = blip
		else
			RemoveBlip(self.MissionData[self.Citizenid].Blip)
		end
	end
end
RegisterNetEvent("jerico-missions:client:CreateMissionConfig", function(ID, citizenid, cid)
	if cid == nil or cid == "" then
		print("Exploit?")
		return
	end
	Missions:Init(ID, citizenid, cid)
end)

CreateThread(function()
	Wait(200)
	local _, hash = GetCurrentPedWeapon(PlayerPedId(), true)
	SetPedInfiniteAmmo(PlayerPedId(), hash)
end)

RegisterCommand("dvp", function(source, args)
	local Peds = QBCore.Functions.GetPeds()
	local Veh = QBCore.Functions.GetVehicles()
	for i = 1, #Veh do
		local el = Veh[i]
		DeleteEntity(el)
	end

	for k, _ in ipairs(Peds) do
		local el = Peds[k]
		DeleteEntity(el)
	end
end)
local n = 1
local c = true

function Missions:HandlePedsMovable(a1, a2)
	CreateThread(function()
		if self.MissionData[self.Citizenid].Vehicle.ID == a1 or self.MissionData[self.Citizenid].Vehicle.ID == a2 then
			if GetVehicleBodyHealth(self.MissionData[self.Citizenid].Vehicle.ID) <= 800.0 then
				for i = 1, #self.MissionData[self.Citizenid].Npc do
					local el = self.MissionData[self.Citizenid].Npc[i]
					if not IsEntityDead(el) then
						TaskLeaveVehicle(el, self.MissionData[self.Citizenid].Vehicle.ID, 0)
						TaskCombatPed(el, self.MissionData[self.Citizenid].PlayerPed, 0, 16)
					end
				end
			end
		end
		for i = 1, #self.MissionData[self.Citizenid].Npc do
			local el = self.MissionData[self.Citizenid].Npc[i]
			if a1 == el or a2 == el then
				if IsEntityDead(el) then
					if n == #self.MissionData[self.Citizenid].Npc then
						QBCore.Functions.Notify("Take The vehicle and deliver the cargo")
						Missions:FinalStep()
						while c do
							Wait(0)
							DrawMarkers(
								self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].END_MISSION_COORDS.coords
							)
							if not c then
								break
							end
						end
					end
					n = n + 1
				end
			end
		end
	end)
end

function Missions:FinalStep()
	local b = true
	if self.MissionData[self.Citizenid].Blip ~= nil then
		RemoveBlip(self.MissionData[self.Citizenid].Blip)
		self.MissionData[self.Citizenid].Blip = nil
		SetNewWaypoint(
			self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].END_MISSION_COORDS.coords.xy
		)
	end
	if self.MissionData[self.Citizenid].Zone == nil then
		self.MissionData[self.Citizenid].Zone = BoxZone:Create(
			self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].END_MISSION_COORDS.coords,
			self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].END_MISSION_COORDS.height,
			self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].END_MISSION_COORDS.width,
			{
				name = math.random(1000, 9999),
				heading = 0,
				debugPoly = true,
			}
		)
		self.MissionData[self.Citizenid].Zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
			if isPointInside then
				if
					GetVehiclePedIsIn(self.MissionData[self.Citizenid].PlayerPed, true)
					== self.MissionData[self.Citizenid].Vehicle.ID
				then
					Wait(500)
					QBCore.Functions.Notify("Grab the items in the back of the vehicle", "success", 3000)
					FreezeEntityPosition(self.MissionData[self.Citizenid].Vehicle.ID, true)
					TaskLeaveVehicle(
						self.MissionData[self.Citizenid].PlayerPed,
						self.MissionData[self.Citizenid].Vehicle.ID
					)
					local d1, d2 = GetModelDimensions(GetEntityModel(self.MissionData[self.Citizenid].Vehicle.ID))
					local Trunk = GetOffsetFromEntityInWorldCoords(
						self.MissionData[self.Citizenid].Vehicle.ID,
						0.0,
						d1.y - 0.2,
						0.0
					)
					local Distance = #(GetEntityCoords(self.MissionData[self.Citizenid].PlayerPed - Trunk))

					while b do
						Wait(0)
						if Distance < 1.0 then
							QBCore.Functions.DrawText3D(Trunk.x, Trunk.y, Trunk.z, "Press G to grab the items")
							if IsControlJustReleased(0, 47) then
								c = false
								QBCore.Functions.Progressbar(
									"TakeMissionCargo",
									"Taking Items ..",
									math.random(4000, 6000),
									false,
									true,
									{
										disableMovement = true,
										disableCarMovement = true,
										disableMouse = true,
										disableCombat = true,
									},
									{},
									{},
									{},

									function()
										ClearPedTasks(PlayerPedId())
										TriggerServerEvent(
											"jerico-missions:server:AddItemsInTrunk",
											self.Citizenid,
											self.MissionData[self.Citizenid].D,
											self.MissionData[self.Citizenid].Type,
											self.MissionData[self.Citizenid].Vehicle.Plate
										)
										Missions:Delete()
										self.MissionData[self.Citizenid].Zone:destroy()
										self.MissionData[self.Citizenid] = nil
										b = false
									end,
									function()
										ClearPedTasks(PlayerPedId())
										self.MissionData[self.Citizenid].Zone:destroy()
										self.MissionData[self.Citizenid] = nil
										b = false
										Missions:Delete()
									end
								)
							end
						end
						if not b then
							break
						end
					end

					--Types: success,primary,error,police,ambulance
				end
			end
		end)
	end
end
function Missions:Delete()
	if self.MissionData then
		if self.MissionData[self.Citizenid] then
			if self.MissionData[self.Citizenid].Vehicle then
				DeleteVehicle(self.MissionData[self.Citizenid].Vehicle.ID)
			end
			for i = 1, #self.MissionData[self.Citizenid].Npc do
				local el = self.MissionData[self.Citizenid].Npc[i]
				DeleteEntity(el)
			end
		end
	end
end

AddEventHandler("onResourceStop", function(resource)
	if not GetCurrentResourceName() == resource then
		return
	end
	collectgarbage()
	Missions:Delete()
end)

AddEventHandler("gameEventTriggered", function(name, args)
	if name == "CEventNetworkEntityDamage" then
		Missions:HandlePedsMovable(args[1], args[2])
	end
end)
