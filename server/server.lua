local QBCore = exports["qb-core"].GetCoreObject()
local CurrentMission = {}
function CheckResource()
    return GetInvokingResource() == "jerico-missions" or GetInvokingResource() == "qb-core"
end
QBCore.Functions.CreateCallback("jerico-missions:server:SpawnVehicle", function(source, cb, id, type)
    if not CheckResource() then
        print "WHAT HAPPEND"
        return
    end
    local Player = QBCore.Functions.GetPlayer(source).PlayerData.citizenid
    local CreateAutomobile = GetHashKey("CREATE_AUTOMOBILE")
    if CurrentMission[Player] then
        local v = Citizen.InvokeNative(CreateAutomobile, GetHashKey(CurrentMission[Player][type].VEHICLE_TO_SPAWN), CurrentMission[Player][type].VEHICLE_COORDINATE, 180.0, true, false)
        while not DoesEntityExist(v) do
            Wait(25)
            print "Waiting"
        end
        if DoesEntityExist(v) then
            CurrentMission[Player].Vehicle = v
            local netId = NetworkGetNetworkIdFromEntity(v)
            cb(netId)
        else
            cb(0)
        end
    else
        print "NO NO NO"
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
    --[[	if #(PC - Config.NPC.coords.xyz) > 3.0 then
            print(#(PC - Config.NPC.coords.xyz))
            print("The fuck are you?")
            return
             CHECK IF THE PLAYER IS NEAR THE NPC TO START THE MISSION!
        end]]
    if CurrentMission[Player.PlayerData.citizenid] then
        print(CurrentMission[Player.PlayerData.citizenid])
        TriggerClientEvent("QBCore:Notify", src, "Player Already in a mission or Mission is already taken")
        return
    end
    if not Config.Missions[id.id] then
        TriggerClientEvent("QBCore:Notify", src, "Error: No mission with the id: " .. id.id .. " Found in Config.lua")
        return
    end
    if not CurrentMission[Player.PlayerData.citizenid] then
        CurrentMission[Player.PlayerData.citizenid] = {}
        CurrentMission[Player.PlayerData.citizenid] = Config.Missions[id.id]
    end
    Config.Missions[id.id].TAKED = true
    TriggerClientEvent("jerico-missions:client:CreateMissionConfig", src, id.id, Player.PlayerData.citizenid)
end)

--AddEventHandler("onResourceStop", function(resource)
--    local src = source
--    print(src)
--    local Player = QBCore.Functions.GetPlayer(src).PlayerData.citizenid
--    if not GetCurrentResourceName() == resource then
--        return
--    end
--    if CurrentMission[Player] then
--        if CurrentMission[Player].Vehicle then
--            DeleteEntity(CurrentMission[Player].Vehicle)
--        end
--    end
--
--end)