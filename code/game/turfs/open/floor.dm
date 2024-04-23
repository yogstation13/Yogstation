/// Anything above a lattice should go here.
/turf/open/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	base_icon_state = "floor"
	baseturfs = /turf/open/floor/plating

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	flags_1 =  CAN_BE_DIRTY_1
	turf_flags = IS_SOLID
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR
	canSmoothWith = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_OPEN_FLOOR

	overfloor_placed = TRUE

	thermal_conductivity = 0.040
	heat_capacity = 10000

	tiled_dirt = TRUE
	damaged_dmi = 'icons/turf/damaged.dmi'
	var/icon_state_regular_floor = "floor" //used to remember what icon state the tile should have by default
	var/icon_regular_floor = 'icons/turf/floors.dmi' //used to remember what icon the tile should have by default
	var/icon_plating = "plating"

	var/floor_tile = null //tile that this floor drops

/turf/open/floor/Initialize(mapload)
	. = ..()
	if(mapload && prob(33))
		MakeDirty()
	if(is_station_level(z))
		GLOB.station_turfs += src

/turf/open/floor/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/burnt_states()
	return list()

/turf/open/floor/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	..()

/turf/open/floor/ex_act(severity, target)
	var/shielded = is_shielded()
	..()
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return
	if(target != null)
		severity = 3

	switch(severity)
		if(EXPLODE_DEVASTATE)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(EXPLODE_HEAVY)
			switch(pick(1,2;75,3))
				if(1)
					if (!ispath(baseturf_at_depth(2), /turf/open/floor))
						attempt_lattice_replacement()
					else
						ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
				if(2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/metal(src)
		if(EXPLODE_LIGHT)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		return 1

/turf/open/floor/blob_act(obj/structure/blob/B)
	return

/turf/open/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/proc/gets_drilled()
	return

/turf/open/floor/proc/attempt_drilled()
	return

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/turf/open/floor/proc/make_plating(force = FALSE)
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ChangeTurf(path, new_baseturf, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.setDir(old_dir)
	W.update_appearance()
	return W

/turf/open/floor/attackby(obj/item/object, mob/living/user, params)
	if(!object || !user)
		return TRUE
	. = ..()
	if(.)
		return .
	if(overfloor_placed && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
		return TRUE
	if(underfloor_accessibility >= UNDERFLOOR_INTERACTABLE && istype(object, /obj/item/stack/tile))
		try_replace_tile(object, user, params)
	return FALSE

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	if(istype(I, /obj/item/jawsoflife/jimmy) || istype(I, /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp))
		to_chat(user,"[I] cannot pry tiles.")
		return
	if(overfloor_placed && pry_tile(I, user))
		return TRUE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/crowbar/CB = user.is_holding_item_of_type(/obj/item/crowbar)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE, force_plating)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, span_notice("You remove the broken plating."))
	else
		if(user && !silent)
			to_chat(user, span_notice("You remove the floor tile."))
		if(make_tile)
			spawn_tile()
	return make_plating(force_plating)

/turf/open/floor/proc/has_tile()
	return floor_tile

/turf/open/floor/proc/spawn_tile()
	if(!has_tile())
		return null
	return new floor_tile(src)

/turf/open/floor/singularity_pull(S, current_size)
	..()
	var/sheer = FALSE
	switch(current_size)
		if(STAGE_THREE)
			if(prob(30))
				sheer = TRUE
		if(STAGE_FOUR)
			if(prob(50))
				sheer = TRUE
		if(STAGE_FIVE to INFINITY)
			if(prob(70))
				sheer = TRUE
	if(sheer)
		if(has_tile())
			remove_tile(null, TRUE, TRUE, TRUE)

/turf/open/floor/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/clockwork)

/turf/open/floor/honk_act()
	ChangeTurf(/turf/open/floor/mineral/bananium)

/turf/open/floor/acid_melt()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.construction_mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 20, "cost" = 16)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 16)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 33)
		if(RCD_WINDOWGRILLE)
			return list("mode" = RCD_WINDOWGRILLE, "delay" = 10, "cost" = 4)
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 20, "cost" = 25)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 20, "cost" = 25)
		if(RCD_FURNISHING)
			return list("mode" = RCD_FURNISHING, "delay" = the_rcd.furnish_delay, "cost" = the_rcd.furnish_cost)
		if(RCD_CONVEYOR)
			return list("mode" = RCD_CONVEYOR, "delay" = 5, "cost" = 5)
		if(RCD_SWITCH)
			return list("mode" = RCD_SWITCH, "delay" = 1, "cost" = 1)
	return FALSE

/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a wall."))
			place_on_top(/turf/closed/wall)
			return TRUE
		if(RCD_AIRLOCK)
			if((locate(/obj/machinery/door/airlock) in src) || (locate(/obj/machinery/door/window) in src)) // Have to ignore firelocks
				to_chat(user, span_notice("There is already a door here"))
				return FALSE
			if(ispath(the_rcd.airlock_type, /obj/machinery/door/window))
				to_chat(user, span_notice("You build a windoor."))
				var/obj/machinery/door/window/new_window = new the_rcd.airlock_type(src, user.dir)
				if(the_rcd.airlock_electronics)
					new_window.req_access = the_rcd.airlock_electronics.accesses.Copy()
					new_window.req_one_access = the_rcd.airlock_electronics.one_access
					new_window.unres_sides = the_rcd.airlock_electronics.unres_sides
				new_window.autoclose = TRUE
				new_window.update_appearance(UPDATE_ICON)
				return TRUE
			to_chat(user, span_notice("You build an airlock."))
			var/obj/machinery/door/airlock/new_airlock = new the_rcd.airlock_type(src)
			new_airlock.electronics = new /obj/item/electronics/airlock(new_airlock)
			if(the_rcd.airlock_electronics)
				new_airlock.electronics.accesses = the_rcd.airlock_electronics.accesses.Copy()
				new_airlock.electronics.one_access = the_rcd.airlock_electronics.one_access
				new_airlock.electronics.unres_sides = the_rcd.airlock_electronics.unres_sides
			
			if(new_airlock.electronics.one_access)
				new_airlock.req_one_access = new_airlock.electronics.accesses

			else
				new_airlock.req_access = new_airlock.electronics.accesses

			if(new_airlock.electronics.unres_sides)
				new_airlock.unres_sides = new_airlock.electronics.unres_sides
			new_airlock.autoclose = TRUE
			new_airlock.update_appearance(UPDATE_ICON)

			return TRUE
		if(RCD_DECONSTRUCT)
			if(ScrapeAway(flags = CHANGETURF_INHERIT_AIR) == src)
				return FALSE
			to_chat(user, span_notice("You deconstruct [src]."))
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/grille) in src)
				return FALSE
			to_chat(user, span_notice("You construct the grille."))
			var/obj/structure/grille/new_grille = new(src)
			new_grille.anchored = TRUE
			return TRUE
		if(RCD_MACHINE)
			if(locate(/obj/structure/frame/machine) in src)
				return FALSE
			var/obj/structure/frame/machine/new_machine = new(src)
			new_machine.state = 2
			new_machine.icon_state = "box_1"
			new_machine.anchored = TRUE
			return TRUE
		if(RCD_COMPUTER)
			if(locate(/obj/structure/frame/computer) in src)
				return FALSE
			var/obj/structure/frame/computer/new_computer = new(src)
			new_computer.anchored = TRUE
			new_computer.state = 1
			new_computer.setDir(the_rcd.computer_dir)
			return TRUE
		if(RCD_FURNISHING)
			if(locate(the_rcd.furnish_type) in src)
				return FALSE
			var/atom/new_furnish = new the_rcd.furnish_type(src)
			new_furnish.setDir(user.dir)
			return TRUE
		if(RCD_CONVEYOR)
			if(locate(/obj/machinery/conveyor) in src)
				return FALSE
			if(get_turf(user) == src)
				return FALSE
			var/obj/machinery/conveyor/new_conveyor = new /obj/machinery/conveyor(src)
			new_conveyor.setDir(user.dir)
			if(the_rcd.linked_switch_id)
				new_conveyor.id = the_rcd.linked_switch_id // link the conveyor if possible
			return TRUE
		if(RCD_SWITCH)
			if(locate(/obj/machinery/conveyor_switch) in src)
				return FALSE
			new /obj/machinery/conveyor_switch(src)
			return TRUE
	return FALSE
