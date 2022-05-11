Config = Config or {}
Config.Missions = {
	[1] = {
		TAKED = false, --Set this to false, the code will change it dinamic
		NAME = "Debug Mission", --Name of the Mission
		HAS_BLIP = true, -- The mission will have a blip?
		BLIP_INFO = {
			BLIP_COORDINATE = vector3(1068.14, 3051.61, 41.3), -- if the above is true, just set the coords here
		},
		IS_MOVABLE = false, -- This will spawn a vehicle in a random position and you need to chase it
		MOVABLE = {
			VEHICLE_TO_SPAWN = `police`, -- Hash of the vehicle to spawn
			VEHICLE_COORDINATE = vector3(0, 0, 0), -- Coordinate ov the vehicle to spawn
			HAS_ESCOLT = false, -- The spawn vehicle will have a escolt car?
			VEHICLE_ESCOLT_SPAWN = `adder`, -- if the above is true, this car will spawn and follow the car above.
			SPAWN_PED_ON_VEHICLE_ESCOLT = false, -- Spawn NPC's on the escol cars? (beside the driver)
			AMOUNT_ESCOLT_NPC_IN_VEHICLE = 1, -- How much NPC's beside the driver will spawn in the car?.
			ITEMS_IN_CAR = {
				[1] = { ITEM_NAME = "sandwitch", AMOUNT = math.random(1, 6) }, -- Item name and Amount of item
			},
		},
		IS_FIXED = true, -- if not movable, so is a fixed mission.
		FIXED = {
			VEHICLE_TO_SPAWN = `burrito3`, -- Vehicle to spawn on the fixed position.
			VEHICLE_COORDINATE = vector3(1071.92, 3043.04, 40.89), -- Coordinate to spawn the vehicle.
			NPC = {
				a_f_m_fatbla_01 =  vector4(1069.95, 3065.22, 41.11, 186.7),
				a_f_m_fatcult_01 = vector4(1068.1, 3044.3, 41.37, 159.1),
				a_f_m_fatwhite_01 = vector4(1077.67, 3037.56, 41.12, 277.48)
			},
			NPC_MISSION = {
				{name = `a_c_killerwhale` , coords =  vector4(1241.28, -3297.45, 5.53, 276.63)}
			},
			ITEMS_IN_CAR = {
				[1] = {
						name = "heavyarmor",
						amount = 2,
						info = {},
						type = "item",
						slot = 1,
				},
				[2] = {
						name = "empty_evidence_bag",
						amount = 10,
						info = {},
						type = "item",
						slot = 2,
				},
				[3] = {
						name = "police_stormram",
						amount = 1,
						info = {},
						type = "item",
						slot = 3,
				},
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