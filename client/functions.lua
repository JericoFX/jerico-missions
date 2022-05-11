QBCore = exports["qb-core"]:GetCoreObject()

function addBlip(coords, text)
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
	return blip
end

function log(text)
	print(json.encode(text, { pretty = true, indent = "  ", align_keys = true }))
end

function SpawnVehicle(vehicle, vehiclepos)
	local Plate, veh1
	QBCore.Functions.SpawnVehicle(vehicle, function(veh)
		SetVehicleNumberPlateText(veh, "JERE" .. math.random(1000, 9999))
		SetVehicleDoorsLocked(veh, 2)
		Plate = QBCore.Functions.GetPlate(veh)
		TriggerEvent("vehiclekeys:client:SetOwner", Plate)
		veh1 = veh
	end, vehiclepos, true, false)
	return veh1, Plate
end

function SpawnPeds(npc)
	local Data = {}
end
