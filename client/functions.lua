QBCore = exports["qb-core"]:GetCoreObject()

local function log(text)
	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end
QBCore.Functions.CreateClientCallback("jerico-missions:CB:CreateBlip", function(cb, coords, text)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
	SetBlipSprite(blip, 535)
	SetBlipColour(blip, 1)
	SetBlipDisplay(blip, 4)
	SetBlipAlpha(blip, 250)
	SetBlipScale(blip, 0.8)
	SetBlipAsShortRange(blip, false)
	PulseBlip(blip)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
	cb(blip)
end)

QBCore.Functions.CreateClientCallback("jerico-missions:CB:GivePedSync", function(cb, npc) 
	local Player = PlayerPedId()
	for k,v in pairs(npc) do

		local el = npc[k]
		local src = NetToPed(el.NetID)
		local _, grouphash = AddRelationshipGroup("HATE_PLAYER")
		 local _, grouphash2 = AddRelationshipGroup("FRIENDS_NPC")

		SetPedRelationshipGroupHash(src, grouphash2)
		GiveWeaponToPed(src,`WEAPON_SMG`,1,false,true)
		SetPedRelationshipGroupHash(Player, grouphash)
		SetRelationshipBetweenGroups(5, grouphash2, grouphash)
		SetEntityCanBeDamagedByRelationshipGroup(src, true, grouphash)
		SetPedFleeAttributes(src, 0, false)
		SetPedCombatAttributes(src, 46, 1)
		SetPedCombatAbility(src, 100)
		SetPedCombatMovement(src, 2)
		SetPedCombatRange(src, 3)
		SetPedKeepTask(src, true)
		SetPedDropsWeaponsWhenDead(src, false)
		SetPedArmour(src, 100)
		SetPedAccuracy(src, 60)
		SetEntityInvincible(src, false)
		SetPedAlertness(src, 3)
		SetPedAllowedToDuck(src, true)
		SetAllRandomPedsFlee(src, false)
		SetPedCanCowerInCover(src, true)
		Wait(200)
		exports["qb-target"]:AddTargetEntity(src, {
			options = {
				{
					icon = "fas fa-sack-dollar",
					label = "Search Keys",
					action = function(entity)
						TriggerServerEvent('n',1)
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
	end
cb(true)

end)

QBCore.Functions.CreateClientCallback("jerico-missions:CB:CreateBlip", function(cb,coords)
		local Zone = BoxZone:Create(coords, 6.6, 10.2, {
			name = "drug_test",
			heading = 0,
			debugPoly = true,
		})
		Zone:onPointInOut(PolyZone.getPlayerPosition, function(isPointInside, point)
			if isPointInside then
				TriggerServerEvent("jerico-missions:SB:IsInside",Zone.name)
			end
		end)
		cb(Zone)
end)