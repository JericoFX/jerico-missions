Config = Config or {}
Config.NPC = {
	--	hash = `a_m_m_eastsa_01`, coords = vector3(1511.0, 3128.94, 40.53)
}
Config.Missions = {
	[1] = {
		TAKED = false, --Set this to false, the code will change it dynamic
		NAME = "Mission Name", --Name of the Mission
		HAS_BLIP = true, -- The mission will have a blip?
		BLIP_INFO = {
			BLIP_COORDINATE = vector3(1068.14, 3051.61, 41.3), -- if the above is true, just set the coords here
		},
		IS_MOVABLE = false, -- This will spawn a vehicle and you need to chase it
		MOVABLE = {
			VEHICLE_TO_SPAWN = "burrito3", -- Hash of the vehicle to spawn
			VEHICLE_COORDINATE = vector3(2351.85, 3133.65, 48.2), -- Coordinate ov the vehicle to spawn
			HAS_ESCOLT = false, -- The spawn vehicle will have a escolt car?
			VEHICLE_ESCOLT_SPAWN = `adder`, -- if the above is true, this car will spawn and follow the car above.
			SPAWN_PED_ON_VEHICLE_ESCOLT = false, -- Spawn NPC's on the escol cars? (beside the driver)
			AMOUNT_ESCOLT_NPC_IN_VEHICLE = 1, -- How much NPC's beside the driver will spawn in the car?.
			NPC = {
				[`a_f_m_fatbla_01`] =  -1, -- Driver Seat
				[`a_f_m_fatcult_01`] = 0, --
				[`a_f_m_fatwhite_01`] = 1 --
			},
			--- Add the name as Key and the amount as Value
			ITEMS_IN_CAR = {
			["sandwitch"] = 3, --- Add the name as Key and the amount as Value
			["id-card"] = 1
			},
			END_MISSION_COORDS = {
				coords = vector3(1066.91, 3050.3, 41.35),
				width = 10.2,
				height = 6.6,
			},
		},
		IS_FIXED = true, -- if not movable, so is a fixed mission.
		FIXED = {
			VEHICLE_TO_SPAWN = "burrito3", -- Vehicle to spawn on the fixed position.
			VEHICLE_COORDINATE = vector3(1406.75, 3094.19, 40.33), -- Coordinate to spawn the vehicle.
			NPC = {
				[`a_f_m_fatbla_01`] = vector4(1367.72, 3091.22, 40.51, 284.56),
				[`a_f_m_fatcult_01`] = vector4(1361.37, 3103.1, 40.51, 265.25),
				[`a_f_m_fatwhite_01`] = vector4(1405.44, 3102.1, 40.19, 118.02),
			}
,
ITEMS_IN_CAR = {
	["sandwitch"] = 3, --- Add the name as Key and the amount as Value
	["id-card"] = 1
	},
			END_MISSION_COORDS = {
				coords = vector3(1066.91, 3050.3, 41.35),
				width = 10.2,
				height = 6.6,
			},
			TASK_NPC = "asd", -- Animation of the npc doing the mission, to give it more thigs to do.
		},
	},
}
