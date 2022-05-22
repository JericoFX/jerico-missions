local Missions = {}
setmetatable(Missions, self)
local CurrentMission = {}
function Missions:Init(id, cid)
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
    self.MissionData[self.Citizenid].Blip = nil

    self.MissionData[self.Citizenid].Vehicle = { ID = 0, Plate = "" }
    self.MissionData[self.Citizenid].Npc = {}
    self.MissionData[self.Citizenid].ID = PlayerId()
    self.MissionData[self.Citizenid].PlayerPed = PlayerPedId()
    p:resolve(self)
    if  self.MissionData[self.Citizenid].Type == "MOVABLE" then
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
        while not NetworkDoesNetworkIdExist(net) do
            Wait(1000)
        end
        if not CurrentMission[Player] then
            CurrentMission[Player] = {}
            CurrentMission[Player].Vehicle = { ID = 0, Plate = "" }
        end
        self.MissionData[self.Citizenid].Vehicle.ID = NetworkGetEntityFromNetworkId(net)
        self.MissionData[self.Citizenid].Vehicle.Plate = GetVehicleNumberPlateText(self.MissionData[self.Citizenid].Vehicle.ID)
        CurrentMission[Player].Vehicle.ID = NetworkGetEntityFromNetworkId(net)
        CurrentMission[Player].Vehicle.Plate = GetVehicleNumberPlateText(NetworkGetEntityFromNetworkId(net))
        print("VEHICULO NPC: "..NetworkGetEntityFromNetworkId(net))

        Missions:AddBlip()
        Missions:SpawnPeds()
        Wait(200)
        print("MI VEHICULO: "..GetVehiclePedIsIn(PlayerPedId(),true))

    end, self.Id, self.MissionData[self.Citizenid].Type)
end
function Missions:SpawnPeds()
    if self.MissionData[self.Citizenid].Type == "MOVABLE" then
        for k, v in pairs(self.MissionData[self.Citizenid][self.MissionData[self.Citizenid].Type].NPC) do
            RequestModel(k)
            while not HasModelLoaded(k) do
                Wait(100)
                print "loading?"
            end
            local Ped = CreatePedInsideVehicle(self.MissionData[self.Citizenid].Vehicle.ID, 1, k, v, true, false)
            NetworkRegisterEntityAsNetworked(Ped)
            SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(Ped), true)
            SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(Ped), true)
            GiveWeaponToPed(Ped, GetHashKey("WEAPON_SMG"), 1, false, true)
            SetPedRelationshipGroupDefaultHash(Ped, GetHashKey('COP'))
            SetPedRelationshipGroupHash(Ped, GetHashKey('COP'))
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
            TaskVehicleDriveWander(GetPedInVehicleSeat(self.MissionData[self.Citizenid].Vehicle.ID, -1), self.MissionData[self.Citizenid].Vehicle.ID, 100.0, 536871740)
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
            --local _, grouphash = AddRelationshipGroup("HATE_PLAYER")
            --  local _, grouphash2 = AddRelationshipGroup("FRIENDS_NPC")
            SetPedRelationshipGroupDefaultHash(Ped, GetHashKey('COP'))
            SetPedAsCop(Ped, true)
            GiveWeaponToPed(Ped, "WEAPON_SMG", 1, false, true)
            --  SetPedRelationshipGroupHash(self.PlayerPedId, grouphash)
            --    SetRelationshipBetweenGroups(5, grouphash2, grouphash)
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
                            TriggerServerEvent('n', 1)
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
            print(self.MissionData[self.Citizenid].Vehicle.ID)
            local blip = AddBlipForEntity(self.MissionData[self.Citizenid].Vehicle.ID)
            --SetBlipSprite(blip, 535)
            --SetBlipColour(blip, 1)
            --SetBlipDisplay(blip, 4)
            --SetBlipAlpha(blip, 250)
            --SetBlipScale(blip, 0.8)
            --SetBlipAsShortRange(blip, false)
            --PulseBlip(blip)
            --BeginTextCommandSetBlipName("STRING")
            --AddTextComponentString(self.MissionData[self.Citizenid].NAME)
            --EndTextCommandSetBlipName(blip)
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
RegisterNetEvent("jerico-missions:client:CreateMissionConfig", function(ID, citizenid)

    Missions:Init(ID, citizenid)
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
function Missions:HandlePedsMovable()
    print(GetVehicleBodyHealth(self.MissionData[self.Citizenid].Vehicle.ID))
    if (GetVehicleBodyHealth(self.MissionData[self.Citizenid].Vehicle.ID) < 800.0) then
        for i = 1, #self.MissionData[self.Citizenid].Npc do
            local el = self.MissionData[self.Citizenid].Npc[i]
            TaskLeaveVehicle(el,self.MissionData[self.Citizenid].Vehicle.ID,0)
            while IsPedInVehicle(el,self.MissionData[self.Citizenid].Vehicle.ID,false) do
                      Wait(1000)
            end
            TaskCombatPed(el, self.PlayerPedId, 0, 16)
        end
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
    Missions:Delete()
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name == "CEventNetworkEntityDamage" then
        local Player = QBCore.Functions.GetPlayerData().citizenid
        if CurrentMission[Player] then
            print(args[1],args[2])
            if CurrentMission[Player].Vehicle.ID == args[1] or CurrentMission[Player].Vehicle.ID == args[2] then
                Missions:HandlePedsMovable()
            end
        end

        --local miVeh = args[1]
        --local otherVeh = args[2]

        --  print(json.encode(args,{indent=true}))
    end

end)
