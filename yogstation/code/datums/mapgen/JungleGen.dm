#define BIOME_TOXIC "toxic"
#define BIOME_BARREN "barren"

#define LOW_HUMIDITY "low_humidity"
#define MED_HUMIDITY "med_humidity"
#define HIGH_HUMIDITY "high_humidity"

#define LOW_DENSITY "low_density"
#define MED_DENSITY "med_density"
#define HIGH_DENSITY "high_density"

#define CA_INITIAL_CLOSED_CHANCE "initial_closed_chance"
#define CA_SMOOTHING_INTERATIONS "smoothing_iterations"
#define CA_BIRTH_LIMIT "birth_limit"
#define CA_DEATH_LIMIT "death_limit"

#define WORLEY_REG_SIZE "reg_size"
#define WORLEY_THRESHOLD "threshold"
#define WORLEY_NODE_PER_REG "node_per_reg"

/datum/map_generator/jungleland

	var/list/possible_biomes = list(
		BIOME_BARREN = list(	LOW_HUMIDITY = /datum/biome/jungleland/barren_rocks,
						MED_HUMIDITY = /datum/biome/jungleland/dry_swamp, 
						HIGH_HUMIDITY = /datum/biome/jungleland/dying_forest),

		BIOME_TOXIC = list(	LOW_HUMIDITY = /datum/biome/jungleland/toxic_pit,
						MED_HUMIDITY = /datum/biome/jungleland/toxic_pit,
						HIGH_HUMIDITY = /datum/biome/jungleland/jungle)
	)
	///Used to select "zoom" level into the perlin noise, higher numbers result in slower transitions
	var/perlin_zoom = 65

	var/list/cellular_preferences = list(
		LOW_DENSITY = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 2.5,
			WORLEY_NODE_PER_REG = 75),

		MED_DENSITY = list(
			CA_INITIAL_CLOSED_CHANCE = 45,
			CA_SMOOTHING_INTERATIONS = 20,
			CA_BIRTH_LIMIT = 4,
			CA_DEATH_LIMIT = 3),

		HIGH_DENSITY = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 5.5,
			WORLEY_NODE_PER_REG = 25)
		)

	var/list/ore_preferences = list(
		ORE_IRON = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1.5,
			WORLEY_NODE_PER_REG = 50),

		ORE_URANIUM = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1,
			WORLEY_NODE_PER_REG = 50),

		ORE_TITANIUM = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1.5,
			WORLEY_NODE_PER_REG = 50),

		ORE_BLUESPACE = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 10,
			WORLEY_NODE_PER_REG = 50),

		ORE_PLASMA = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 8,
			WORLEY_NODE_PER_REG = 50),

		ORE_GOLD = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1,
			WORLEY_NODE_PER_REG = 50),

		ORE_SILVER = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1.5,
			WORLEY_NODE_PER_REG = 50),

		ORE_DIAMOND = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 9,
			WORLEY_NODE_PER_REG = 50)
		)
//creates a 2d map of every single ore vein on the map
/datum/map_generator/jungleland/proc/generate_ores(list/turfs)
	var/list/ore_strings = list(
		ORE_BLUESPACE  = rustg_worley_generate("[ore_preferences[ORE_BLUESPACE][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_BLUESPACE][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_BLUESPACE][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),
		ORE_DIAMOND  = rustg_worley_generate("[ore_preferences[ORE_DIAMOND][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_DIAMOND][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_DIAMOND][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),

		ORE_PLASMA  = rustg_worley_generate("[ore_preferences[ORE_PLASMA][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_PLASMA][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_PLASMA][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),
		ORE_GOLD  = rustg_worley_generate("[ore_preferences[ORE_GOLD][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_GOLD][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_GOLD][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),
		ORE_URANIUM  = rustg_worley_generate("[ore_preferences[ORE_URANIUM][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_URANIUM][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_URANIUM][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),
		ORE_TITANIUM  = rustg_worley_generate("[ore_preferences[ORE_TITANIUM][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_TITANIUM][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_TITANIUM][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),
		ORE_SILVER  = rustg_worley_generate("[ore_preferences[ORE_SILVER][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_SILVER][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_SILVER][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"),
		ORE_IRON  = rustg_worley_generate("[ore_preferences[ORE_IRON][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_IRON][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_IRON][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"1",
										"2"))
	//order of generation, ordered from rarest to most common
	var/list/generation_queue = list(
		ORE_IRON,
		ORE_SILVER,
		ORE_TITANIUM,
		ORE_URANIUM,
		ORE_GOLD,
		ORE_PLASMA,
		ORE_DIAMOND,
		ORE_BLUESPACE
	)
	var/return_list[world.maxx * world.maxy] 


	for(var/t in turfs)
		var/turf/gen_turf = t
		var/generated = FALSE
		for(var/ore in generation_queue)
			if(ore_strings[ore][world.maxx * (gen_turf.y - 1) + gen_turf.x] == "1")
				continue
			return_list[world.maxx * (gen_turf.y - 1) + gen_turf.x] = ore
			generated = TRUE
			break

		if(!generated)
			return_list[world.maxx * (gen_turf.y - 1) + gen_turf.x] = ORE_EMPTY

		CHECK_TICK

	return return_list
		
/datum/map_generator/jungleland/generate_terrain(list/turfs)
	var/start_time = REALTIMEOFDAY
	var/list/ore_map = generate_ores(turfs)
	
	

	var/toxic_seed = rand(0, 50000)
	var/humid_seed = rand(0, 50000)
	var/list/density_strings = list()
	density_strings[LOW_DENSITY] = rustg_worley_generate("[cellular_preferences[LOW_DENSITY][WORLEY_REG_SIZE]]",
								 				"[cellular_preferences[LOW_DENSITY][WORLEY_THRESHOLD]]",
												"[cellular_preferences[LOW_DENSITY][WORLEY_NODE_PER_REG]]", 
												"[world.maxx]",
												"1",
												"2")

	density_strings[MED_DENSITY] = rustg_cnoise_generate("[cellular_preferences[MED_DENSITY][CA_INITIAL_CLOSED_CHANCE]]",
									 			"[cellular_preferences[MED_DENSITY][CA_SMOOTHING_INTERATIONS]]",
												"[cellular_preferences[MED_DENSITY][CA_BIRTH_LIMIT]]", 
												"[cellular_preferences[MED_DENSITY][CA_DEATH_LIMIT]]",
												"[world.maxx]",
												"[world.maxy]")

	density_strings[HIGH_DENSITY] = rustg_worley_generate("[cellular_preferences[HIGH_DENSITY][WORLEY_REG_SIZE]]",
								 				"[cellular_preferences[HIGH_DENSITY][WORLEY_THRESHOLD]]",
												"[cellular_preferences[HIGH_DENSITY][WORLEY_NODE_PER_REG]]", 
												"[world.maxx]",
												"1",
												"2")
	var/toxic_string = rustg_dbp_generate("[toxic_seed]","60","75","[world.maxx]","-0.05","1.1")
	var/list/humid_strings = list()
	humid_strings[HIGH_HUMIDITY] = rustg_dbp_generate("[humid_seed]","60","75","[world.maxx]","-0.1","1.1")
	humid_strings[MED_HUMIDITY] = rustg_dbp_generate("[humid_seed]","60","75","[world.maxx]","-0.3","-0.1")

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/toxic_pick = text2num(toxic_string[world.maxx * (gen_turf.y - 1) + gen_turf.x]) ? BIOME_TOXIC : BIOME_BARREN

		var/humid_pick = text2num(humid_strings[HIGH_HUMIDITY][world.maxx * (gen_turf.y - 1) + gen_turf.x]) ? HIGH_HUMIDITY : text2num(humid_strings[MED_HUMIDITY][world.maxx * (gen_turf.y - 1) + gen_turf.x]) ? MED_HUMIDITY : LOW_HUMIDITY

		var/datum/biome/jungleland/selected_biome = possible_biomes[toxic_pick][humid_pick]

		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		var/turf/GT = selected_biome.generate_turf(gen_turf,density_strings)
		if(istype(GT,/turf/open/floor/plating/dirt/jungleland))
			var/turf/open/floor/plating/dirt/jungleland/J = GT
			J.ore_present = ore_map[world.maxx * (gen_turf.y - 1) + gen_turf.x]
		var/area/jungleland/jungle_area = selected_biome.this_area 
		var/area/old_area = GT.loc
		old_area.contents -= GT 
		jungle_area.contents += GT
		GT.change_area(old_area,jungle_area)
		CHECK_TICK

	for(var/biome in subtypesof(/datum/biome/jungleland))
		var/datum/biome/jungleland/selected_biome = SSmapping.biomes[biome] 
		selected_biome.this_area.reg_in_areas_in_z()

	var/message = "Jungle land finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, "<span class='boldannounce'>[message]</span>")
	log_world(message)
