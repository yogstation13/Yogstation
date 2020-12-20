/obj/machinery/door/poddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blastdoor.dmi'
	icon_state = "closed"
	var/id = null
	layer = BLASTDOOR_LAYER
	closingLayer = CLOSED_BLASTDOOR_LAYER
	sub_door = TRUE
	explosion_block = 3
	heat_proof = TRUE
	safe = FALSE
	max_integrity = 600
	armor = list("melee" = 50, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70)
	resistance_flags = FIRE_PROOF
	damage_deflection = 70
	poddoor = TRUE
	var/special = FALSE // Prevents ERT or whatever from breaking into their shutters
	var/constructionstate = INTACT // Decounstruction Stuff

/obj/machinery/door/poddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/poddoor/ert
	name = "ERT Armory door"
	desc = "A heavy duty blast door that only opens for dire emergencies."
	special = TRUE
	
/obj/machinery/door/poddoor/deathsquad
	name = "ERT Mech Bay door"
	desc = "A heavy duty blast door that only opens for extreme emergencies."
	special = TRUE

//special poddoors that open when emergency shuttle docks at centcom
/obj/machinery/door/poddoor/shuttledock
	special = TRUE
	var/checkdir = 4	//door won't open if turf in this dir is `turftype`
	var/turftype = /turf/open/space
	air_tight = 1

/obj/machinery/door/poddoor/shuttledock/proc/check()
	var/turf/T = get_step(src, checkdir)
	if(!istype(T, turftype))
		INVOKE_ASYNC(src, .proc/open)
	else
		INVOKE_ASYNC(src, .proc/close)

/obj/machinery/door/poddoor/incinerator_toxmix
	name = "combustion chamber vent"
	id = INCINERATOR_TOXMIX_VENT

/obj/machinery/door/poddoor/incinerator_atmos_main
	name = "turbine vent"
	id = INCINERATOR_ATMOS_MAINVENT

/obj/machinery/door/poddoor/incinerator_atmos_aux
	name = "combustion chamber vent"
	id = INCINERATOR_ATMOS_AUXVENT

/obj/machinery/door/poddoor/incinerator_syndicatelava_main
	name = "turbine vent"
	id = INCINERATOR_SYNDICATELAVA_MAINVENT

/obj/machinery/door/poddoor/incinerator_syndicatelava_aux
	name = "combustion chamber vent"
	id = INCINERATOR_SYNDICATELAVA_AUXVENT

/obj/machinery/door/poddoor/Bumped(atom/movable/AM)
	if(density)
		return 0
	else
		return ..()

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/poddoor/ex_act(severity, target)
	if(severity == 3)
		return
	..()

/obj/machinery/door/poddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/blastdoor.ogg', 30, 1)

/obj/machinery/door/poddoor/update_icon()
	if(density)
		icon_state = "closed"
	else
		icon_state = "open"
	SSdemo.mark_dirty(src)

/obj/machinery/door/poddoor/try_to_activate_door(mob/user)
	return

/obj/machinery/door/poddoor/try_to_crowbar(obj/item/I, mob/user)
	if(stat & NOPOWER)
		open(1)

/obj/machinery/door/poddoor/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(special && W.tool_behaviour == TOOL_SCREWDRIVER) // No Cheesing
		to_chat(user, "<span class='warning'>This door appears to have a different screw.</span>")
		return


	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		if(density)
			to_chat(user, "<span class='warning'>You need to open [src] before opening its maintenance panel.</span>")
			return
		else if(default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance hatch of [src].</span>")
			return TRUE

	if(panel_open)
		if(W.tool_behaviour == TOOL_MULTITOOL && constructionstate == INTACT)
			if(id != null)
				to_chat(user, "<span class='warning'>This door is already linked. Unlink it first!</span>")
				return

			if(!multitool_check_buffer(user, W))
				return
				
			var/obj/item/multitool/P = W	
			id = P.buffer
			to_chat(user, "<span class='notice'>You link the button to the [src].</span>")
			return

		if(W.tool_behaviour == TOOL_WIRECUTTER)
			if(id != null)
				to_chat(user, "<span class='notice'>You start to unlink the door.</span>")
				if(do_after(user, 10 SECONDS, target = src))
					to_chat(user, "<span class='notice'>You unlink the door.</span>")
					id = null
			else
				to_chat(user, "<span class='warning'>This door is already unlinked.</span>")

			return

		if(W.tool_behaviour == TOOL_WELDER && constructionstate == INTACT)
			to_chat(user, "<span class='notice'>You start to remove the outer plasteel cover.</span>")
			playsound(src.loc, 'sound/items/welder.ogg', 50, 1)
			if(do_after(user, 10 SECONDS, target = src))
				to_chat(user, "<span class='notice'>You remove the outer plasteel cover.</span>")
				constructionstate = CUT_COVER
				id = null // Effectivley breaks the door
				new /obj/item/stack/sheet/plasteel(loc, 5)
				return
		else
			to_chat(user, "<span class='warning'>The cover is already off.</span>")
		
		if(W.tool_behaviour == TOOL_CROWBAR && constructionstate == CUT_COVER)
			to_chat(user, "<span class='notice'>You start to remove all of the internal components</span>")
			if(do_after(user, 15 SECONDS, target = src))
				if(istype(src, /obj/machinery/door/poddoor/shutters)) // Simplified Code 
					new /obj/item/stack/sheet/plasteel(loc, 5)
					new /obj/item/electronics/airlock(loc)
					new /obj/item/stack/cable_coil/red(loc, 5)
				else
					new /obj/item/stack/sheet/plasteel(loc, 15)
					new /obj/item/electronics/airlock(loc)
					new /obj/item/stack/cable_coil/red(loc, 10)

				qdel(src)

		if(istype(W, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/P = W
			if(P.use(5))
				to_chat(user, "<span class='warning'>You need 5 plasteel sheets to put the plating back on.</span>")
				return
			
			constructionstate = INTACT
			return

/obj/machinery/door/poddoor/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='<span class='notice'>The maintenance panel is [panel_open ? "opened" : "closed"].</span>"
		
