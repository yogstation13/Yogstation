// How much "space" we give the edge of the map
GLOBAL_LIST_INIT(potentialRandomZlevels, generateMapList(filename = "[global.config.directory]/awaymissionconfig.txt"))
GLOBAL_LIST_INIT(potentialConfigRandomZlevels, generateConfigMapList(directory = "[global.config.directory]/away_missions/"))

/proc/createRandomZlevel(config_gateway = FALSE)
	var/map
	if(config_gateway && GLOB.potentialConfigRandomZlevels?.len)
		map = pick_n_take(GLOB.potentialConfigRandomZlevels)
	else if(GLOB.potentialRandomZlevels?.len)
		map = pick_n_take(GLOB.potentialRandomZlevels)
	else
		return to_chat(world, span_boldannounce("No valid away mission files, loading aborted."))
	to_chat(world, span_boldannounce("Loading away mission..."))
	var/loaded = load_new_z_level(map, "Away Mission", config_gateway)
	to_chat(world, span_boldannounce("Away mission [loaded ? "loaded" : "aborted due to errors"]."))
	if(!loaded)
		message_admins("Away mission [map] loading failed due to errors.")
		log_admin("Away mission [map] loading failed due to errors.")
		createRandomZlevel(config_gateway)

/proc/reset_gateway_spawns(reset = FALSE)
	for(var/obj/machinery/gateway/G in world)
		if(reset)
			G.randomspawns = GLOB.awaydestinations
		else
			G.randomspawns.Add(GLOB.awaydestinations)

/obj/effect/landmark/awaystart
	name = "away mission spawn"
	desc = "Randomly picked away mission spawn points."

/obj/effect/landmark/awaystart/New()
	GLOB.awaydestinations += src
	..()

/obj/effect/landmark/awaystart/Destroy()
	GLOB.awaydestinations -= src
	return ..()

/proc/generateMapList(filename)
	. = list()
	var/list/Lines = world.file2list(filename)

	if(!Lines.len)
		return
	for (var/t in Lines)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (t[1] == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))

		else
			name = lowertext(t)

		if (!name)
			continue

		. += t

/proc/generateConfigMapList(directory)
	var/list/config_maps = list()
	var/list/maps = flist(directory)
	for(var/map_file in maps)
		if(!findtext(map_file, ".dmm"))
			continue
		config_maps += (directory + map_file)
	return config_maps
