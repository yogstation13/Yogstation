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
						MED_HUMIDITY = /datum/biome/jungleland/toxic_pit, //dry swamp is kind of like a beach?
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
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/iron),

		ORE_URANIUM = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/uranium),

		ORE_TITANIUM = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1.5,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/titanium),

		ORE_BLUESPACE = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 10,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/bluespace),

		ORE_PLASMA = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 8,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/plasma),

		ORE_GOLD = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/gold),

		ORE_SILVER = list(
			WORLEY_REG_SIZE = 5,
			WORLEY_THRESHOLD = 1.5,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/silver),

		ORE_DIAMOND = list(
			WORLEY_REG_SIZE = 15,
			WORLEY_THRESHOLD = 9,
			WORLEY_NODE_PER_REG = 50,
			ORE_TURF = /turf/open/floor/plating/dirt/jungleland/diamond)
		)
//creates a 2d map of every single ore vein on the map
/datum/map_generator/jungleland/proc/generate_ores(list/turfs)
	var/list/ore_strings = list(
		ORE_BLUESPACE  = rustg_worley_generate("[ore_preferences[ORE_BLUESPACE][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_BLUESPACE][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_BLUESPACE][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),
		ORE_DIAMOND  = rustg_worley_generate("[ore_preferences[ORE_DIAMOND][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_DIAMOND][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_DIAMOND][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),

		ORE_PLASMA  = rustg_worley_generate("[ore_preferences[ORE_PLASMA][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_PLASMA][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_PLASMA][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),
		ORE_GOLD  = rustg_worley_generate("[ore_preferences[ORE_GOLD][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_GOLD][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_GOLD][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),
		ORE_URANIUM  = rustg_worley_generate("[ore_preferences[ORE_URANIUM][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_URANIUM][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_URANIUM][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),
		ORE_TITANIUM  = rustg_worley_generate("[ore_preferences[ORE_TITANIUM][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_TITANIUM][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_TITANIUM][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),
		ORE_SILVER  = rustg_worley_generate("[ore_preferences[ORE_SILVER][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_SILVER][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_SILVER][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"),
		ORE_IRON  = rustg_worley_generate("[ore_preferences[ORE_IRON][WORLEY_REG_SIZE]]",
										"[ore_preferences[ORE_IRON][WORLEY_THRESHOLD]]",
										"[ore_preferences[ORE_IRON][WORLEY_NODE_PER_REG]]",
										"[world.maxx]",
										"[world.maxy]"))
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
												"[world.maxy]")

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
												"[world.maxy]")

	for(var/t in turfs) //Go through all the turfs and generate them
		var/turf/gen_turf = t
		var/gen_x = gen_turf.x / perlin_zoom
		var/gen_y = gen_turf.y / perlin_zoom
		var/toxicity = text2num(rustg_noise_get_at_coordinates("[toxic_seed]", "[gen_x]", "[gen_y]"))
		var/humidity = text2num(rustg_noise_get_at_coordinates("[humid_seed]", "[gen_x]", "[gen_y]"))
		var/toxic_pick = toxicity > 0.4 ? BIOME_TOXIC : BIOME_BARREN

		var/humid_pick = humidity > 0.4 ? HIGH_HUMIDITY : (humidity > 0.2 ? MED_HUMIDITY : LOW_HUMIDITY)

		var/datum/biome/selected_biome = possible_biomes[toxic_pick][humid_pick]

		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		var/GT = selected_biome.generate_turf(gen_turf,density_strings)
		if(istype(GT,/turf/open/floor/plating/dirt/jungleland))
			var/turf/open/floor/plating/dirt/jungleland/J = GT
			J.ore_present = ore_map[world.maxx * (gen_turf.y - 1) + gen_turf.x]
		CHECK_TICK

	var/message = "Jungle land finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, "<span class='boldannounce'>[message]</span>")
	log_world(message)
