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

		BIOME_TOXIC = list(	LOW_HUMIDITY = /datum/biome/jungleland/toxic_rocks,
						MED_HUMIDITY = /datum/biome/jungleland/toxic_pit,
						HIGH_HUMIDITY = /datum/biome/jungleland/jungle),
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
	


/datum/map_generator/jungleland/generate_terrain(list/turfs)
	var/start_time = REALTIMEOFDAY

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

		var/humid_pick = humidity > 0.5 ? HIGH_HUMIDITY : (humidity > 0.25 ? MED_HUMIDITY : LOW_HUMIDITY)

		var/datum/biome/selected_biome = possible_biomes[toxic_pick][humid_pick]

		selected_biome = SSmapping.biomes[selected_biome] //Get the instance of this biome from SSmapping
		selected_biome.generate_turf(gen_turf,density_strings)
		CHECK_TICK

	var/message = "Jungle land finished in [(REALTIMEOFDAY - start_time)/10]s!"
	to_chat(world, "<span class='boldannounce'>[message]</span>")
	log_world(message)
