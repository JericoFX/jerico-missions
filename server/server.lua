local QBCore = exports["qb-core"]:GetCoreObject()
local CT = CreateThread
local Num = 0
local Missions = {}
local SelectedMission = {}

local chance

local Missions = {}

setmetatable(Missions, self)
---Function to pass a table or a text and will show it on the console
---@param text any
---@return string
function log(text)
    return print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end


---Init
---@param id number
---@param src number
function Missions:Init(id, src)
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
    Config.Missions[id].TAKED = true
    ---
    self.Mission[self.cid].Mission.TAKED = true
    self.Mission[self.cid].Mission.NPC_END = nil
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

function Missions:CreateVehicle()
    CT(function()
        if self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type] == "FIXED" then
            self.Mission[self.cid].Vehicle.ID = CreateVehicle(
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_TO_SPAWN,
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE.x,
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE.y,
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE.z,
                    180,
                    true,
                    false
            )
            SetVehicleNumberPlateText(self.Mission[self.cid].Vehicle.ID, "JERE" .. math.random(1000, 9999))
            while not DoesEntityExist(self.Mission[self.cid].Vehicle.ID) do
                Wait(100)
                print("No")
            end

            Wait(200)
            if DoesEntityExist(self.Mission[self.cid].Vehicle.ID) then
                self.Mission[self.cid].Vehicle.NetID = NetworkGetNetworkIdFromEntity(self.Mission[self.cid].Vehicle.ID)
                self.Mission[self.cid].Vehicle.Plate = GetVehicleNumberPlateText(self.Mission[self.cid].Vehicle.ID)
                Wait(200)
                TriggerClientEvent("vehiclekeys:client:SetOwner", self.PlayerID, self.Mission[self.cid].Vehicle.Plate)
            end
        else
            self.Mission[self.cid].Vehicle.ID = CreateVehicle(
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_TO_SPAWN,
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE.x,
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE.y,
                    self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].VEHICLE_COORDINATE.z,
                    180,
                    true,
                    false
            )
            SetVehicleNumberPlateText(self.Mission[self.cid].Vehicle.ID, "JERE" .. math.random(1000, 9999))
            while not DoesEntityExist(self.Mission[self.cid].Vehicle.ID) do
                Wait(100)
                print("No")
            end

            Wait(200)
            if DoesEntityExist(self.Mission[self.cid].Vehicle.ID) then
                self.Mission[self.cid].Vehicle.NetID = NetworkGetNetworkIdFromEntity(self.Mission[self.cid].Vehicle.ID)
                self.Mission[self.cid].Vehicle.Plate = GetVehicleNumberPlateText(self.Mission[self.cid].Vehicle.ID)
              --  Wait(200)
               -- TriggerClientEvent("vehiclekeys:client:SetOwner", self.PlayerID, self.Mission[self.cid].Vehicle.Plate)
            end
        end
    end)
end

function Missions:SpawnPeds()
    CT(function()
        if self.Mission[self.cid].Mission.Type == "FIXED" then
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
            end

            QBCore.Functions.TriggerClientCallback("jerico-missions:CB:GivePedSync", self.PlayerID, function(cb)
                if cb then
                    return true
                end
            end, self.Mission[self.cid].Npc)
        else
        --[[    while not DoesEntityExist(self.Mission[self.cid].Vehicle.ID) do
                Wait(100)
                print("No")
            end]]
            for k, v in pairs(self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].NPC) do
                local Ped = CreatePedInsideVehicle(self.Mission[self.cid].Vehicle.ID, 1, k, v, true, false)
                Wait(200)
                self.Mission[self.cid].Npc[#self.Mission[self.cid].Npc + 1] = {
                    ID = Ped,
                    hash = k,
                    NetID = NetworkGetNetworkIdFromEntity(Ped),
                }
            end
            for i = 1, #self.Mission[self.cid].Npc do
                Num = i
            end

            QBCore.Functions.TriggerClientCallback("jerico-missions:CB:GivePedSync", self.PlayerID, function(cb)
                if cb then
                    return true
                end
            end, self.Mission[self.cid].Npc)
        end
    end)
    Missions:GetPedsHealth()
end

function Missions:GetPedsHealth()
    CT(function()
        local s = true
        while s do
            Wait(1000)

            for i = 1, #self.Mission[self.cid].Npc do
                if GetEntityHealth(self.Mission[self.cid].Npc[i].ID) == 0 then
                    QBCore.Functions.TriggerClientCallback(
                            "jerico-missions:CB:CreateZone",
                            self.PlayerID,
                            function(cb)
                                if cb then
                                    self.Mission[self.cid].EndMission = cb
                                end
                            end,
                            self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].END_MISSION_COORDS,
                            self.cid
                    )
                    s = false
                end
            end

            if not s then
                break
            end
        end
    end)
end

function Missions:UpdateZone(Name, Inside)
    if self.Mission[self.cid].EndMission.name == Name then
        self.Mission[self.cid].EndMission.isInside = Inside
        Missions:FinalStep()
    end
end

function Missions:SpawnMovableCar()
end

RegisterServerEvent("jerico-missions:SB:IsInside", function(ZoneName, isInside)
    Missions:UpdateZone(ZoneName, isInside)
end)

function Missions:FinalStep()
    CT(function()
        if self.Mission[self.cid].EndMission.isInside then
            if GetVehiclePedIsIn(GetPlayerPed(self.PlayerID)) == self.Mission[self.cid].Vehicle.ID then
                Wait(200)
                FreezeEntityPosition(self.Mission[self.cid].Vehicle.ID)
                TaskLeaveVehicle(self.PlayerID, self.Mission[self.cid].Vehicle.ID, 0)
                if self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].SPAWN_NPC_AT_END_OF_MISSION then
                    self.Mission[self.cid].Mission.NPC_END = CreatePed(
                            1,
                            self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].NPC_END_MISSION.name,
                            self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].NPC_END_MISSION.coords.x,
                            self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].NPC_END_MISSION.coords.y,
                            self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].NPC_END_MISSION.coords.z
                    )
                    while not DoesEntityExist(self.Mission[self.cid].Mission.NPC_END) do
                        Wait(10)
                    end
                    print("209")
                    local NPC_COORDS = GetEntityCoords(self.Mission[self.cid].Mission.NPC_END)
                    -- local VEHICLE_COORDS = GetEntityCoords(self.Mission[self.cid].Vehicle.ID)
                    QBCore.Functions.TriggerClientCallback(
                            "jerico-missions:CB:GetClosestEntityBone",
                            self.PlayerID,
                            function(coords)
                                print("Callback")
                                if coords then
                                    TaskGoStraightToCoord(
                                            self.Mission[self.cid].Mission.NPC_END,
                                            coords,
                                            1.0,
                                            -1,
                                            GetEntityHeading(self.Mission[self.cid].Vehicle.ID),
                                            0.1
                                    )
                                end
                                while #(coords - NPC_COORDS) > 3.0 do
                                    Wait(100)
                                end
                                SetVehicleDoorBroken(self.Mission[self.cid].Vehicle.ID, 2, false)
                            end,
                            self.Mission[self.cid].Vehicle.NetID
                    )

                    ClearPedTasksImmediately(self.Mission[self.cid].Mission.NPC_AT_END)
                    Missions:AddItemsInTrunk()
                else
                    Missions:AddItemsInTrunk()
                end
            end
        end
    end)
end

RegisterServerEvent("jerico-missions:server:AddItemsInVehicle", function(cid, sid)
    TriggerClientEvent("jerico-missions:server:AddItemsInVehicle", source, cid, sid)
end)

function Missions:DeleteAll()
    if self.Mission then
        if self.Mission[self.cid].Vehicle.ID > 0 and self.Mission[self.cid].Vehicle.ID ~= nil then
            DeleteEntity(self.Mission[self.cid].Vehicle.ID)
        end
        if self.Mission[self.cid].NPC_END ~= nil then
            DeleteEntity(self.Mission[self.cid].NPC_END)
        end
        if #self.Mission[self.cid].Npc > 0 then
            for k, v in ipairs(self.Mission[self.cid].Npc) do
                if DoesEntityExist(self.Mission[self.cid].Npc[k].ID) then
                    DeleteEntity(self.Mission[self.cid].Npc[k].ID)
                end
            end
        end
    end
end
function Missions:SOmething()
    log(Config.Missions)
end

RegisterCommand("a", function(source, args)
    Missions:SOmething()
end)
QBCore.Functions.CreateCallback("jerico-missions:SB:GetMissions", function(source, cb)
    local Data = {}
    for k, v in ipairs(Config.Missions) do
        local el = Config.Missions[k]
        --Data[#Data + 1] = { name = el.NAME, id = k }
        if not el.TAKED then
            Data[#Data + 1] = { name = el.NAME, id = k }
        else
            Data[#Data + 1] = { name = "No Mission Available", id = nil }
        end
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
-- CreateThread(function()
-- 	SelectedMission = Missions:Init(1, src)
-- end)
function Missions:SetVehicle()
    TriggerClientEvent("vehiclekeys:client:SetOwner", self.PlayerID, self.Mission[self.cid].Vehicle.Plate)

    TriggerClientEvent("QBCore:Notify", source, "Keys Found for the vehicle " .. self.Mission[self.cid].Vehicle.Plate)
end

local number = 1

RegisterServerEvent("n", function()
    chance = math.random(number, Num)

    if chance == Num then
        Missions:SetVehicle()

        number = 1
    else
        TriggerClientEvent("QBCore:Notify", source, "Keys not found", "error")
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
            self.Mission[self.cid].Vehicle.Plate,
            self.Mission[self.cid].Mission[self.Mission[self.cid].Mission.Type].ITEMS_IN_CAR
    )
end

AddEventHandler("onResourceStop", function(resource)
    if not GetCurrentResourceName() == resource then
        return
    end

    Missions:DeleteAll()
end)
