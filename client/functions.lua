
 QBCore = exports["qb-core"]:GetCoreObject()
function DrawMarkers(coords)
	DrawMarker(3, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 2.0, 2.0, 2.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)


 end
-- local function log(text)
-- 	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
-- end
-- local Missions = {}
-- local D = {}
-- RegisterNetEvent("jerico-missions:client:GetMission", function(MissionData)
-- 	local Player = QBCore.Functions.GetPlayerData().citizenid
-- 	Missions = MissionData
-- end)

-- QBCore.Functions.CreateClientCallback("jerico-missions:CB:CreateBlip", function(cb, coords, text)
-- 	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
-- 	SetBlipSprite(blip, 535)
-- 	SetBlipColour(blip, 1)
-- 	SetBlipDisplay(blip, 4)
-- 	SetBlipAlpha(blip, 250)
-- 	SetBlipScale(blip, 0.8)
-- 	SetBlipAsShortRange(blip, false)
-- 	PulseBlip(blip)
-- 	BeginTextCommandSetBlipName("STRING")
-- 	AddTextComponentString(text)
-- 	EndTextCommandSetBlipName(blip)
-- 	cb(blip)
-- end)

-- RegisterNetEvent("jerico-missions:CB:GivePedSync", function()
-- 	local Player = PlayerPedId()
-- 	local PlayerC = QBCore.Functions.GetPlayerData().citizenid
-- 	for k,v in pairs(Missions[PlayerC][Missions[PlayerC].Mission.Type].NPC) do

-- 		local el = npc[k]
-- 		local netID = NetworkGetNetworkIdFromEntity(el.ID)
-- 		local src = NetToPed(netID)

-- 		local _, grouphash = AddRelationshipGroup(`HATE_PLAYER`)
-- 		 local _, grouphash2 = AddRelationshipGroup(`FRIENDS_NPC`)
-- 		SetPedRelationshipGroupDefaultHash(src, grouphash2)
-- 		SetPedRelationshipGroupHash(Player, grouphash)
-- 		GiveWeaponToPed(src,`WEAPON_SMG`,1,false,true)

-- 		--SetPedAsCop(src,true)
-- 		SetRelationshipBetweenGroups(5, grouphash2, grouphash)
-- 		SetEntityCanBeDamagedByRelationshipGroup(src, true, grouphash)
-- 		SetPedFleeAttributes(src, 0, false)
-- 		SetPedCombatAttributes(src, 46, 1)
-- 		SetPedCombatAbility(src, 100)
-- 		SetPedCombatMovement(src, 2)
-- 		SetPedCombatRange(src, 3)
-- 		SetPedKeepTask(src, true)
-- 		SetPedDropsWeaponsWhenDead(src, false)
-- 		SetPedArmour(src, 100)
-- 		SetPedAccuracy(src, 60)
-- 		SetEntityInvincible(src, false)
-- 		SetPedAlertness(src, 3)
-- 		SetPedRandomProps(src)
-- 		SetPedAllowedToDuck(src, true)
-- 		SetAllRandomPedsFlee(src, false)
-- 		SetPedCanCowerInCover(src, true)
-- 		TaskCombatPed(src, Player, 0, 16)
-- 		Wait(200)
-- 		exports["qb-target"]:AddTargetEntity(src, {
-- 			options = {
-- 				{
-- 					icon = "fas fa-sack-dollar",
-- 					label = "Search Keys",
-- 					action = function(entity)
-- 						TriggerServerEvent('n',1)
-- 					end,
-- 					canInteract = function(entity)
-- 						if IsEntityAPed(entity) then
-- 							return IsEntityDead(entity)
-- 						end
-- 					end,
-- 				},
-- 			},
-- 			distance = 2.5,
-- 		})
-- 	end
-- cb(true)

-- end)

-- QBCore.Functions.CreateClientCallback("jerico-missions:CB:CreateZone", function(cb,coords)
-- if D.IS_FIXED then
-- 	local c
-- 	if coords == "table" then
-- 		c = vector3(coords.coords.x,coords.coords.y,coordz.coords.z)
-- 	else
-- 		c = coords.coords
-- 	end
-- 		local Zone = BoxZone:Create(c, coords.height, coords.width, {
-- 			name = math.random(1000,9999),
-- 			heading = 0,
-- 			debugPoly = true,
-- 		})
-- 		Zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
-- 			if isPointInside then
-- 				TriggerServerEvent("jerico-missions:SB:IsInside",Zone.name,isPointInside)
-- 			end
-- 		end)
-- 		cb(Zone)
-- 	end
-- end)

-- QBCore.Functions.CreateClientCallback("jerico-missions:CB:GetClosestEntityBone", function(cb,netid)
-- 	while not NetworkDoesNetworkIdExist(netid) do
-- 		Wait(1000)
-- 		print("ADD")
-- 	end
-- 	local d = NetToEnt(netid)
-- 	Wait(1000)

-- 	local boneCoords1 = GetWorldPositionOfEntityBone(d, GetEntityBoneIndexByName(d,"door_dside_f"))
-- 	cb(boneCoords1)
-- end)
-- RegisterNetEvent("jerico-missions:CB:TaskVehicleWander",function(cb)
-- 	print("Clear")
-- 	local Player = QBCore.Functions.GetPlayerData().citizenid
-- if Missions[Player].Mission.IS_MOVABLE then
-- local v = NetToVeh(Missions[Player].Vehicle.NetID)
-- print(v)
-- 	TaskVehicleDriveWander(	GetPedInVehicleSeat(v,-1),v,120,1342)
-- end

-- end)
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
		true,
		false
	)
	exports["qb-target"]:AddTargetEntity(NPC, {
		options = {
			{
				type = "client",
				event = "jerico-missions:client:OpenMenu",
				icon = "fas fa-box-circle-check",
				label = "Comprar Drogas",
			},
		},
		distance = 2.0,
	})
	BlockPedDeadBodyShockingEvents(NPC, true)
	SetBlockingOfNonTemporaryEvents(NPC, true)
	TaskStandGuard(NPC,GetEntityCoords(NPC),180,"WORLD_VEHICLE_POLICE_BIKE")
end)
