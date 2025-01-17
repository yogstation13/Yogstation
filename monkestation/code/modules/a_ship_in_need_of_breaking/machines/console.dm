/obj/machinery/computer/shipbreaker
	name = "Shipbreaking Shuttle Console"
	desc = "A computer console used to call a ship for breaking, how original!"
	icon_screen = "holocontrol"


	var/turf/bottom_left

///what area type this holodeck loads into. linked turns into the nearest instance of this area
	var/area/mapped_start_area = /area/shipbreak

///the currently used map template
	var/datum/map_template/shipbreaker/template

///List of ships to spawn.
	var/list/possible_ships = list()

///subtypes of this (but not this itself) are loadable programs
	var/ship_type = /datum/map_template/shipbreaker

///links the shipbreaker zone to the computer
	var/area/shipbreak/linked
///cool variablw
	var/spawn_area_clear = TRUE

	///our overall ship health
	var/ship_health = 0
	///our initial turf count
	var/turf_count = 0

/obj/machinery/computer/shipbreaker/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/shipbreaker/LateInitialize()
	linked = GLOB.areas_by_type[mapped_start_area]
	if(!linked)
		return
	bottom_left = locate(linked.x, linked.y, src.z)
	for(var/ship in subtypesof(ship_type))
		var/datum/map_template/shipbreaker/s = new ship
		possible_ships+= s

/obj/machinery/computer/shipbreaker/proc/spawn_ship()
	area_clear_check()
	if(!spawn_area_clear)
		say("ERROR: SHIPBREAKING ZONE NOT CLEAR, PLEASE REMOVE ALL REMAINING FLOORS, STRUCTURES, AND MACHINERY")
		return

	var/datum/map_template/shipbreaker/ship_to_spawn = pick(possible_ships)

	ship_to_spawn.load(bottom_left)

	setup_health_tracker()
	damage_ship()

/obj/machinery/computer/shipbreaker/proc/area_clear_check()
	for(var/turf/t in linked)
		if(!isspaceturf(t))
			spawn_area_clear = FALSE
			say("FLOORING OR WALL DETECTED")
			return
	for(var/obj/s in linked)
		if(isstructure(s) || ismachinery(s))
			say("MACHINE OR STRUCTURE DETECTED.")
			spawn_area_clear = FALSE
			return

	spawn_area_clear = TRUE

/obj/machinery/computer/shipbreaker/proc/clear_floor_plating()
	for(var/turf/t in linked)
		//if(isfloorturf(t))
		//t.ScrapeAway()
		if(isopenturf(t))
			t.ScrapeAway()



/obj/machinery/computer/shipbreaker/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShipbreakerConsole", name)
		ui.open()

/obj/machinery/computer/shipbreaker/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["health"] = ship_health

	return data

/obj/machinery/computer/shipbreaker/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE

	switch(action)
		if("spawn_ship")
			turf_count = 0
			spawn_ship()
			return
		if("clear_floor_plating")
			clear_floor_plating()
			return

/obj/machinery/computer/shipbreaker/proc/setup_health_tracker()
	for(var/turf/turf in linked)
		if(!isspaceturf(turf))
			turf_count++
			RegisterSignal(turf, COMSIG_TURF_CHANGE, PROC_REF(modify_health))
	ship_health = 100

/obj/machinery/computer/shipbreaker/proc/modify_health(turf/source)
	ship_health -= (100 / turf_count)
	ship_health = max(ship_health, 0)


/obj/machinery/computer/shipbreaker/proc/damage_ship()
	var/list/turfs = list()
	for(var/turf/turf in linked)
		turfs += turf

	var/prob_chance_explode = 100
	if(prob(0))
		prob_chance_explode = 0
	while(prob(prob_chance_explode))
		prob_chance_explode -= 33
		var/turf/picked_turf = pick(turfs)
		explosion(picked_turf, rand(0, 4), rand(0, 4), rand(0, 6), 0, 0 , FALSE, FALSE, TRUE, FALSE, linked)
