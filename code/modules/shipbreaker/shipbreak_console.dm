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

/obj/machinery/computer/shipbreaker/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/shipbreaker/LateInitialize()
	linked = GLOB.areas_by_type[mapped_start_area]
	bottom_left = locate(linked.x, linked.y, src.z)
	for(var/ship in subtypesof(ship_type))
		var/datum/map_template/shipbreaker/s = new ship
		possible_ships+= s

/obj/machinery/computer/shipbreaker/proc/spawn_ship()
	area_clear_check()
	if(!spawn_area_clear)
		say("ERROR: SHIPBREAKING ZONE NOT CLEAR, PLEASE REMOVE ALL REMAINING SHIP PARTS")
		return
	var/datum/map_template/shipbreaker/ship_to_spawn = pick(possible_ships)

	ship_to_spawn.load(bottom_left)

/obj/machinery/computer/shipbreaker/proc/area_clear_check()
	for(var/turf/t in linked)
		if(((istype(t, /turf/open/floor/plating/snowed/smoothed))))
			spawn_area_clear = TRUE

		else if(!isspaceturf(t))
			spawn_area_clear = FALSE
			return
	for(var/obj/s in linked)
		if(isstructure(s) || ismachinery(s))
			spawn_area_clear = FALSE
			return
	
	spawn_area_clear = TRUE

/obj/machinery/computer/shipbreaker/proc/clear_floor_plating()
	for(var/turf/t in linked)
		if(((!istype(t, /turf/open/floor/plating/snowed/smoothed))))
			t.ScrapeAway()
			

/obj/machinery/computer/shipbreaker/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShipbreakerConsole", name)
		ui.open()


/obj/machinery/computer/shipbreaker/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE

	switch(action)
		if("spawn_ship")
			spawn_ship()
			return
		if("clear_floor_plating")
			clear_floor_plating()
			return
