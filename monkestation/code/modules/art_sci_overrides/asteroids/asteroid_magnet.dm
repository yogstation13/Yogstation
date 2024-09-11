#define STATUS_OKAY "OK"
#define MAX_COLLISIONS_BEFORE_ABORT 10

/obj/machinery/asteroid_magnet
	name = "asteroid magnet computer"
	desc = "Control panel for the asteroid magnet."
	icon_state = "asteroid_magnet"
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE

	/// Every Asteroid Template defined, [Asteroid] = [Weight]
	var/static/list/datum/map_template/asteroid/available_templates
	/// All templates in the "map".
	var/list/datum/map_template/asteroid/templates_on_map
	/// The map that stores asteroids
	var/datum/cartesian_plane/map
	/// The currently selected template
	var/datum/map_template/asteroid/selected_template

	/// Center turf X, set in mapping
	VAR_PRIVATE/center_x = 0
	/// Center turf Y, set in mapping
	VAR_PRIVATE/center_y = 0
	/// The center turf
	VAR_PRIVATE/turf/center_turf
	/// The size (chebyshev) of the available area, set in mapping
	var/area_size = 0

	var/coords_x = 0
	var/coords_y = 0

	var/ping_result = "Awaiting first ping"

	/// Status of the user interface
	var/status = STATUS_OKAY
	/// Boolean to keep track of state and protect against double summoning
	var/summon_in_progress = FALSE
	/// Are we currently automatically pinging the target?
	var/Auto_pinging = FALSE


	/// The cooldown between uses.
	COOLDOWN_DECLARE(summon_cd)

/obj/machinery/asteroid_magnet/Initialize(mapload)
	. = ..()
	if(mapload)
		if(!center_x || !center_y)
			stack_trace("Asteroid magnet does not have X or Y coordinates, deleting.")
			return INITIALIZE_HINT_QDEL

		if(!area_size)
			stack_trace("Asteroid magnet does not have a valid size, deleting.")
			return INITIALIZE_HINT_QDEL

	center_turf = locate(center_x, center_y, z)
	available_templates = typecacheof(/datum/map_template/asteroid, ignore_root_path = TRUE)
	for(var/datum/map_template/asteroid/roid as anything in available_templates)
		if(roid.asteroid_weight)
			available_templates[roid] = roid.asteroid_weight
		else
			available_templates[roid] = 100
	templates_on_map = list()

	GenerateMap()

/obj/machinery/asteroid_magnet/proc/ping(coords_x, coords_y)
	var/datum/map_template/asteroid/T = map.return_coordinate(coords_x, coords_y)
	if(T && !T.found)
		T.found = TRUE
		ping_result = "LOCATED"
		return

	var/datum/map_template/asteroid/closest
	var/lowest_dist = INFINITY
	for(var/datum/map_template/asteroid/asteroid as anything in templates_on_map)
		// Get the euclidean distance between the ping and the asteroid.
		var/dist = sqrt(((asteroid.x - coords_x) ** 2) + ((asteroid.y - coords_y) ** 2))
		if(dist < lowest_dist)
			closest = asteroid
			lowest_dist = dist

	if(closest)
		var/dx = closest.x - coords_x
		var/dy = closest.y - coords_y
		// Get the angle as 0 - 180 degrees
		var/angle = arccos(dy / sqrt((dx ** 2) + (dy ** 2)))
		if(dx < 0) // If the X-axis distance is negative, put it between 181 and 359. 180 and 360/0 are impossible, as that requires X == 0.
			angle = 360 - angle
		var/human_angle = round(angle, 0.01)
		switch(human_angle) //Generic Direction, Sub-cardinals, then Cardinals
			if(0.01 to 44.99)
				ping_result = "NORTH-NORTH-EAST"
			if(45.01 to 89.99)
				ping_result = "EAST-NORTH-EAST"
			if(90.01 to 134.99)
				ping_result = "EAST-SOUTH-EAST"
			if(135.01 to 179.99)
				ping_result = "SOUTH-SOUTH-EAST"
			if(180.01 to 224.99)
				ping_result = "SOUTH-SOUTH-WEST"
			if(225.01 to 269.99)
				ping_result = "WEST-SOUTH-WEST"
			if(270.01 to 314.99)
				ping_result = "WEST-NORTH-WEST"
			if(315.01 to 359.99)
				ping_result = "NORTH-NORTH-WEST"
			if(45)
				ping_result = "NORTH-EAST"
			if(135)
				ping_result = "SOUTH-EAST"
			if(225)
				ping_result = "SOUTH-WEST"
			if(315)
				ping_result = "NORTH-WEST"
			if(0)
				ping_result = "NORTH"
			if(90)
				ping_result = "EAST"
			if(180)
				ping_result = "SOUTH"
			if(270)
				ping_result = "WEST"
		ping_result += ": AZIMUTH [human_angle]"
	else
		ping_result = "LOCATING NEW ASTEROID FIELD[ellipsis()]"
		COOLDOWN_START(src,summon_cd,3 MINUTE)
		GenerateMap(FALSE)

/// Test to see if we should clear the magnet area.
/// Returns FALSE if it can clear, returns a string error message if it can't.
/obj/machinery/asteroid_magnet/proc/check_for_magnet_errors(datum/map_template/asteroid/template)
	. = FALSE
	if(summon_in_progress)
		return "ERROR: ASTEROID ALREADY BEING SUMMONED"

	if(!COOLDOWN_FINISHED(src, summon_cd))
		return "ERROR: MAGNET COOLING DOWN"

	if(isnull(template))
		return "ERROR: ASTEROID NOT DETECTED"

	if(template.summoned)
		return "ERROR: ASTEROID ALREADY SUMMONED"

	for(var/mob/M as mob in range(area_size + 1, center_turf))
		if(isliving(M))
			return "ERROR: HEAT SIGNATURES DETECTED IN MAGNET RANGE"

/// Performs a full summoning sequence, including putting up boundaries, clearing out the area, and bringing in the new asteroid.
/obj/machinery/asteroid_magnet/proc/summon_sequence(datum/map_template/asteroid/template)
	var/magnet_error = check_for_magnet_errors(template)
	if(magnet_error)
		status = magnet_error
		updateUsrDialog()
		return

	var/area/station/cargo/mining/asteroid_magnet/A = get_area(center_turf)

	summon_in_progress = TRUE
	A.area_flags |= NOTELEPORT // We dont want people getting nuked during the generation sequence
	status = "Summoning[ellipsis()]"
	available_templates -= template
	updateUsrDialog()

	var/time = world.timeofday
	var/list/forcefields = PlaceForcefield()
	CleanupTemplate()
	PlaceTemplate(template)

	time = (world.timeofday + 20 SECONDS) - time
	if(time > 0)
		addtimer(CALLBACK(src, PROC_REF(_FinishSummonSequence), template, forcefields), time)
	else
		_FinishSummonSequence(template, forcefields)
	return

/obj/machinery/asteroid_magnet/proc/_FinishSummonSequence(datum/map_template/asteroid/template, list/forcefields)
	QDEL_LIST(forcefields)

	var/area/station/cargo/mining/asteroid_magnet/A = get_area(center_turf)
	A.area_flags &= ~NOTELEPORT // Annnnd done
	summon_in_progress = FALSE
	template.summoned = TRUE
	COOLDOWN_START(src, summon_cd, 1.5 MINUTE)
	status = STATUS_OKAY
	updateUsrDialog()

/// Summoning part of summon_sequence()
/obj/machinery/asteroid_magnet/proc/PlaceTemplate(datum/map_template/asteroid/template)
	PRIVATE_PROC(TRUE)
	template.load(center_turf,TRUE)

/// Places the forcefield boundary during summon_sequence
/obj/machinery/asteroid_magnet/proc/PlaceForcefield()
	PRIVATE_PROC(TRUE)
	. = list()
	var/list/turfs = RANGE_TURFS(area_size, center_turf) ^ RANGE_TURFS(area_size + 1, center_turf)
	for(var/turf/T as anything in turfs)
		. += new /obj/effect/forcefield/asteroid_magnet(T)


/// Cleanup our currently loaded mining template
/obj/machinery/asteroid_magnet/proc/CleanupTemplate()
	PRIVATE_PROC(TRUE)

	var/list/turfs_to_destroy = ReserveTurfsForAsteroidGeneration(center_turf, area_size, baseturf_only = FALSE)
	for(var/turf/T as anything in turfs_to_destroy)
		CHECK_TICK
		for(var/atom/movable/AM as anything in T)
			CHECK_TICK
			if(isdead(AM) || iscameramob(AM) || iseffect(AM) || !(ismob(AM) || isobj(AM)))
				continue
			qdel(AM)

		T.ChangeTurf(/turf/baseturf_bottom)


/// Generates the random map for the magnet.
/obj/machinery/asteroid_magnet/proc/GenerateMap(initial = TRUE)
	PRIVATE_PROC(TRUE)
	if(initial)
		map = new(-100, 100, -100, 100)
	// Generate common templates
	if(length(available_templates))
		for(var/i in 1 to 12)
			var/datum/map_template/asteroid/possible = pick_weight(available_templates)
			if(possible.size > area_size)
				continue
			InsertTemplateToMap(possible)

/obj/machinery/asteroid_magnet/proc/InsertTemplateToMap(path)
	PRIVATE_PROC(TRUE)

	var/collisions = 0
	var/datum/map_template/asteroid/template
	var/x
	var/y

	template = new path(center_turf, area_size)
	templates_on_map += template

	do
		x = rand(-100, 100)
		y = rand(-100, 100)

		if(map.return_coordinate(x, y))
			collisions++
		else
			map.set_coordinate(x, y, template)
			template.x = x
			template.y = y
			break

	while (collisions <= MAX_COLLISIONS_BEFORE_ABORT)

/obj/machinery/asteroid_magnet/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AsteroidMagnet")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/asteroid_magnet/ui_data(mob/user)
	. = ..()
	var/list/data = list()

	data["coords_x"] = coords_x
	data["coords_y"] = coords_y
	data["ping_result"] = ping_result
	data["Auto_pinging"] = Auto_pinging

	var/list/asteroid_data = list()
	for(var/datum/map_template/asteroid/asteroid as anything in templates_on_map)
		if(!asteroid.found)
			continue
		asteroid_data += list(list(
			"name" = "[asteroid.name] ([asteroid.x] [asteroid.y])",
			"ref" = REF(asteroid),
			"size" = asteroid.size,
			"rarity" = asteroid.asteroid_weight,
		))
	data["asteroids"] = asteroid_data

	return data

/obj/machinery/asteroid_magnet/ui_act(action, list/params) // im sorry for this code
	. = ..()
	if (.)
		return

	var/list/map_offsets = map.return_offsets()
	var/list/map_bounds = map.return_bounds()
	switch(action)
		if("Change X Coordinates")
			var/amount = params["Position_Change"]
			if(amount == 0) // if position change is zero, we are trying to reset the coordinates instead of changing them
				coords_x = 0
				if(Auto_pinging)
					ping(coords_x, coords_y)
				return

			coords_x = WRAP(coords_x + map_offsets[1] + amount, map_bounds[1] + map_offsets[1], map_bounds[2] + map_offsets[1])
			coords_x -= map_offsets[1]
			if(Auto_pinging)
				ping(coords_x, coords_y)

		if("Change Y Coordinates")
			var/amount = params["Position_Change"]
			if(amount == 0) // if position change is zero, we are trying to reset the coordinates instead of changing them
				coords_y = 0
				if(Auto_pinging)
					ping(coords_x, coords_y)
				return

			coords_y = WRAP(coords_y + map_offsets[2] + amount, map_bounds[3] + map_offsets[2], map_bounds[4] + map_offsets[2])
			coords_y -= map_offsets[2]
			if(Auto_pinging)
				ping(coords_x, coords_y)

		if("TogglePinging")
			Auto_pinging = !Auto_pinging

		if("ping")
			ping(coords_x, coords_y)

		if("select")
			var/datum/map_template/asteroid/asteroid = locate(params["asteroid_reference"]) in templates_on_map
			templates_on_map -= asteroid
			selected_template = asteroid
			summon_sequence(selected_template)


#undef MAX_COLLISIONS_BEFORE_ABORT
#undef STATUS_OKAY
