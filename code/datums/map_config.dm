//used for holding information about unique properties of maps
//feed it json files that match the datum layout
//defaults to box
//  -Cyberboss

/datum/map_config
	// Metadata
	var/config_filename = "_maps/yogstation.json"
	var/defaulted = TRUE  // set to FALSE by LoadConfig() succeeding
	// Config from maps.txt
	var/config_max_users = 0
	var/config_min_users = 0
	var/voteweight = 1
	var/votable = FALSE

	// Config actually from the JSON - should default to Box
	var/map_name = "YogStation"
	var/internal_name = "" //if we have a super secret name that isn't just the display one
	var/map_path = "map_files/YogStation"
	var/map_file = "YogStation.dmm"

	var/traits = null
	var/space_ruin_levels = DEFAULT_SPACE_RUIN_LEVELS
	var/space_empty_levels = DEFAULT_SPACE_EMPTY_LEVELS
	/// Boolean that tells us if this is a planetary station. (like IceBoxStation)
	var/planetary = FALSE

	var/minetype = "jungle_and_lavaland"
	var/cryo_spawn = FALSE

	var/allow_custom_shuttles = TRUE
	var/shuttles = list(
		"cargo" = "cargo_box",
		"ferry" = "ferry_fancy",
		"whiteship" = "whiteship_1",
		"emergency" = "emergency_box",
	)
	
	/// List of unit tests that are skipped when running this map
	var/list/skipped_tests

/**
 * Proc that simply loads the default map config, which should always be functional.
 */
/proc/load_default_map_config()
	return new /datum/map_config

/**
 * Proc handling the loading of map configs. Will return the default map config using [/proc/load_default_map_config] if the loading of said file fails for any reason whatsoever, so we always have a working map for the server to run.
 * Arguments:
 * * filename - Name of the config file for the map we want to load. The .json file extension is added during the proc, so do not specify filenames with the extension.
 * * directory - Name of the directory containing our .json - Must be in MAP_DIRECTORY_WHITELIST. We default this to MAP_DIRECTORY_MAPS as it will likely be the most common usecase. If no filename is set, we ignore this.
 * * error_if_missing - Bool that says whether failing to load the config for the map will be logged in log_world or not as it's passed to LoadConfig().
 *
 * Returns the config for the map to load.
 */
/proc/load_map_config(filename = null, directory = null, error_if_missing = TRUE, delete_after)
	var/datum/map_config/config = load_default_map_config()
	var/whiteship = pick("whiteship_1", "whiteship_2", "whiteship_3", "whiteship_4", "whiteship_5")
	config.shuttles["whiteship"] = whiteship
	
	if(filename) // If none is specified, then go to look for next_map.json, for map rotation purposes.

		//Default to MAP_DIRECTORY_MAPS if no directory is passed
		if(directory)
			if(!(directory in MAP_DIRECTORY_WHITELIST))
				log_world("map directory not in whitelist: [directory] for map [filename]")
				return config
		else
			directory = MAP_DIRECTORY_MAPS

		filename = "[directory]/[filename].json"
	else
		filename = PATH_TO_NEXT_MAP_JSON

	
	if (!config.LoadConfig(filename, error_if_missing))
		qdel(config)
		return load_default_map_config()
	return config

#define CHECK_EXISTS(X) if(!istext(json[X])) { log_world("[##X] missing from json!"); return; }
/datum/map_config/proc/LoadConfig(filename, error_if_missing)
	if(!fexists(filename))
		if(error_if_missing)
			log_world("map_config not found: [filename]")
		return

	var/json = file(filename)
	if(!json)
		log_world("Could not open map_config: [filename]")
		return

	json = file2text(json)
	if(!json)
		log_world("map_config is not text: [filename]")
		return

	json = json_decode(json)
	if(!json)
		log_world("map_config is not json: [filename]")
		return

	config_filename = filename

	CHECK_EXISTS("map_name")
	map_name = json["map_name"]
	CHECK_EXISTS("map_path")
	map_path = json["map_path"]
	if("internal_name" in json)
		internal_name = json["internal_name"]

	map_file = json["map_file"]
	// "map_file": "BoxStation.dmm"
	if (istext(map_file))
		if (!fexists("_maps/[map_path]/[map_file]"))
			log_world("Map file ([map_path]/[map_file]) does not exist!")
			return
	// "map_file": ["Lower.dmm", "Upper.dmm"]
	else if (islist(map_file))
		for (var/file in map_file)
			if (!fexists("_maps/[map_path]/[file]"))
				log_world("Map file ([map_path]/[file]) does not exist!")
				return
	else
		log_world("map_file missing from json!")
		return

	if (islist(json["shuttles"]))
		var/list/L = json["shuttles"]
		for(var/key in L)
			var/value = L[key]
			shuttles[key] = value
	else if ("shuttles" in json)
		log_world("map_config shuttles is not a list!")
		return

	traits = json["traits"]
	// "traits": [{"Linkage": "Cross"}, {"Space Ruins": true}]
	if (islist(traits))
		// "Station" is set by default, but it's assumed if you're setting
		// traits you want to customize which level is cross-linked
		for (var/level in traits)
			if (!(ZTRAIT_STATION in level))
				level[ZTRAIT_STATION] = TRUE
	// "traits": null or absent -> default
	else if (!isnull(traits))
		log_world("map_config traits is not a list!")
		return

	var/temp = json["space_ruin_levels"]
	if (isnum(temp))
		space_ruin_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_ruin_levels is not a number!")
		return

	temp = json["space_empty_levels"]
	if (isnum(temp))
		space_empty_levels = temp
	else if (!isnull(temp))
		log_world("map_config space_empty_levels is not a number!")
		return

	if ("minetype" in json)
		minetype = json["minetype"]
	
	if ("planetary" in json)
		planetary = json["planetary"]

	if("cryo_spawn" in json)
		cryo_spawn = json["cryo_spawn"]

	allow_custom_shuttles = json["allow_custom_shuttles"] != FALSE

#ifdef UNIT_TESTS
	// Check for unit tests to skip, no reason to check these if we're not running tests
	for(var/path_as_text in json["ignored_unit_tests"])
		var/path_real = text2path(path_as_text)
		if(!ispath(path_real, /datum/unit_test))
			stack_trace("Invalid path in mapping config for ignored unit tests: \[[path_as_text]\]")
			continue
		LAZYADD(skipped_tests, path_real)
#endif

	defaulted = FALSE
	return TRUE
#undef CHECK_EXISTS

/datum/map_config/proc/GetFullMapPaths()
	if (istext(map_file))
		return list("_maps/[map_path]/[map_file]")
	. = list()
	for (var/file in map_file)
		. += "_maps/[map_path]/[file]"

/datum/map_config/proc/MakeNextMap()
	return config_filename == PATH_TO_NEXT_MAP_JSON || fcopy(config_filename, PATH_TO_NEXT_MAP_JSON)
