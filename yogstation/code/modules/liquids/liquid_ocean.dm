GLOBAL_LIST_INIT(initalized_ocean_areas, list())
/area/ocean
	name = "Ocean"

	icon = 'yogstation/icons/obj/effects/liquid.dmi'
	base_icon_state = "ocean"
	icon_state = "ocean"
	alpha = 120

	requires_power = TRUE
	always_unpowered = TRUE

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE

	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE

/area/ocean/Initialize(mapload)
	. = ..()
	GLOB.initalized_ocean_areas += src

/area/ocean/dark
	base_lighting_alpha = 0

/area/ruin/ocean
	has_gravity = TRUE

/area/ruin/ocean/listening_outpost
	unique = TRUE

/area/ruin/ocean/bunker
	unique = TRUE

/area/ruin/ocean/bioweapon_research
	unique = TRUE

/area/ruin/ocean/mining_site
	unique = TRUE

/area/ocean/near_station_powered
	requires_power = FALSE

/turf/open/openspace/ocean
	name = "ocean"
	planetary_atmos = TRUE
	baseturfs = /turf/open/openspace/ocean
	var/replacement_turf = /turf/open/floor/plating/ocean

/turf/open/openspace/ocean/Initialize()
	. = ..()
	ChangeTurf(replacement_turf, null, CHANGETURF_IGNORE_AIR)

/turf/open/floor/plating
	///do we still call parent but dont want other stuff?
	var/overwrites_attack_by = FALSE

/turf/open/floor/plating/ocean
	plane = FLOOR_PLANE
	layer = TURF_LAYER
	force_no_gravity = FALSE
	gender = PLURAL
	name = "ocean sand"
	baseturfs = /turf/open/floor/plating/ocean
	icon = 'yogstation/icons/turf/floors/seafloor.dmi'
	icon_state = "seafloor"
	base_icon_state = "seafloor"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	planetary_atmos = TRUE
	initial_gas_mix = OCEAN_DEFAULT_ATMOS

	upgradable = FALSE
	attachment_holes = FALSE

	resistance_flags = INDESTRUCTIBLE

	overwrites_attack_by = TRUE

	var/static/obj/effect/abstract/ocean_overlay/static_overlay
	var/static/list/ocean_reagents = list(/datum/reagent/water = 10)
	var/ocean_temp = T20C
	var/list/ocean_turfs = list()
	var/list/open_turfs = list()

	///are we captured, this is easier than having to run checks on turfs for vents
	var/captured = FALSE

	var/rand_variants = 0
	var/rand_chance = 30

	/// Itemstack to drop when dug by a shovel
	var/obj/item/stack/dig_result = /obj/item/stack/ore/glass
	/// Whether the turf has been dug or not
	var/dug = FALSE

	/// do we build a catwalk or plating with rods
	var/catwalk = FALSE

/turf/open/floor/plating/ocean/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(movable_entered))
	RegisterSignal(src, COMSIG_TURF_MOB_FALL, PROC_REF(mob_fall))
	if(!static_overlay)
		static_overlay = new(null, ocean_reagents)

	vis_contents += static_overlay
	light_color = static_overlay.color
	SSliquids.unvalidated_oceans |= src
	SSliquids.ocean_turfs |= src

	if(rand_variants && prob(rand_chance))
		var/random = rand(1,rand_variants)
		icon_state = "[base_icon_state][random]"
		base_icon_state = "[base_icon_state][random]"


/turf/open/floor/plating/ocean/Destroy()
	. = ..()
	UnregisterSignal(src, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOB_FALL))
	SSliquids.active_ocean_turfs -= src
	SSliquids.ocean_turfs -= src
	for(var/turf/open/floor/plating/ocean/listed_ocean as anything in ocean_turfs)
		listed_ocean.rebuild_adjacent()

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	if(..())
		return
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		if (R.get_amount() < 2)
			to_chat(user, span_warning("You need two rods to make a [catwalk ? "catwalk" : "plating"]!"))
			return
		else
			to_chat(user, span_notice("You begin constructing a [catwalk ? "catwalk" : "plating"]..."))
			if(do_after(user, 30, target = src))
				if (R.get_amount() >= 2 && !catwalk)
					place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
					playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
					R.use(2)
					to_chat(user, span_notice("You reinforce the [src]."))
				else if(R.get_amount() >= 2 && catwalk)
					new /obj/structure/lattice/catwalk(src)
					playsound(src, 'sound/items/deconstruct.ogg', 80, TRUE)
					R.use(2)
					to_chat(user, span_notice("You build a catwalk over the [src]."))

/// Drops itemstack when dug and changes icon
/turf/open/floor/plating/ocean/proc/getDug()
	dug = TRUE
	new dig_result(src, 5)

/// If the user can dig the turf
/turf/open/floor/plating/ocean/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_warning("Looks like someone has dug here already!"))


/turf/open/floor/plating/ocean/proc/assume_self()
	if(!atmos_adjacent_turfs)
		immediate_calculate_adjacent_turfs()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			if(isclosedturf(directional_turf))
				RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction), TRUE)
				continue
			else if(!(directional_turf in atmos_adjacent_turfs))
				var/obj/machinery/door/found_door = locate(/obj/machinery/door) in directional_turf
				if(found_door)
					RegisterSignal(found_door, COMSIG_ATOM_DOOR_OPEN, TYPE_PROC_REF(/turf/open/floor/plating/ocean, door_opened))
				RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed), TRUE)
				continue
			else
				open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	SSliquids.unvalidated_oceans -= src

/turf/open/floor/plating/ocean/proc/door_opened(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/door/found_door = source
	var/turf/turf = get_turf(found_door)

	if(turf.can_atmos_pass())
		turf.add_liquid_list(ocean_reagents, FALSE, ocean_temp)

/turf/open/floor/plating/ocean/proc/process_turf()
	for(var/direction in open_turfs)
		var/turf/directional_turf = get_step(src, direction)
		if(isspaceturf(directional_turf) || istype(directional_turf, /turf/open/floor/plating/ocean))
			RegisterSignal(directional_turf, COMSIG_TURF_DESTROY, PROC_REF(add_turf_direction), TRUE)
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return
		else if(!(directional_turf in atmos_adjacent_turfs))
			RegisterSignal(directional_turf, COMSIG_TURF_UPDATE_AIR, PROC_REF(add_turf_direction_non_closed), TRUE)
			open_turfs -= direction
			if(!open_turfs.len)
				SSliquids.active_ocean_turfs -= src
			return

		directional_turf.add_liquid_list(ocean_reagents, FALSE, ocean_temp)

/turf/open/floor/plating/ocean/proc/rebuild_adjacent()
	ocean_turfs = list()
	open_turfs = list()
	for(var/direction in GLOB.cardinals)
		var/turf/directional_turf = get_step(src, direction)
		if(istype(directional_turf, /turf/open/floor/plating/ocean))
			ocean_turfs |= directional_turf
		else
			open_turfs.Add(direction)

	if(open_turfs.len)
		SSliquids.active_ocean_turfs |= src
	else if(src in SSliquids.active_ocean_turfs)
		SSliquids.active_ocean_turfs -= src

/turf/open/floor/plating/ocean/attackby(obj/item/C, mob/user, params)
	. = ..()

	if(C.tool_behaviour == TOOL_SHOVEL || C.tool_behaviour == TOOL_MINING)
		if(!can_dig(user))
			return TRUE

		if(!isturf(user.loc))
			return

		balloon_alert(user, "digging...")

		if(C.use_tool(src, user, 40, volume=50))
			if(!can_dig(user))
				return TRUE
			getDug()
			SSblackbox.record_feedback("tally", "pick_used_mining", 1, C.type)
			return TRUE

/obj/effect/abstract/ocean_overlay
	icon = 'yogstation/icons/obj/effects/liquid.dmi'
	icon_state = "ocean"
	base_icon_state = "ocean"
	plane = AREA_PLANE //Same as weather, etc.
	layer = ABOVE_MOB_LAYER
	vis_flags = NONE
	mouse_opacity = FALSE
	alpha = 120

/obj/effect/abstract/ocean_overlay/Initialize(mapload, list/ocean_contents)
	. = ..()
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/obj/effect/abstract/ocean_overlay/proc/mix_colors(list/ocean_contents)
	var/datum/reagents/fake_reagents = new
	fake_reagents.add_reagent_list(ocean_contents)
	color = mix_color_from_reagents(fake_reagents.reagent_list)
	qdel(fake_reagents)
	if(istype(loc, /area/ocean))
		var/area/area_loc = loc
		area_loc.base_lighting_color = color

/turf/open/floor/plating/ocean/proc/mob_fall(datum/source, mob/M)
	SIGNAL_HANDLER
	var/turf/T = source
	playsound(T, 'yogstation/sound/effects/splash.ogg', 50, 0)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		to_chat(C, span_userdanger("You fall in the water!"))

/turf/open/floor/plating/ocean/proc/movable_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/turf/T = source
	if(isobserver(AM))
		return //ghosts, camera eyes, etc. don't make water splashy splashy
	if(prob(30))
		var/sound_to_play = pick(list(
			'yogstation/sound/effects/water_wade1.ogg',
			'yogstation/sound/effects/water_wade2.ogg',
			'yogstation/sound/effects/water_wade3.ogg',
			'yogstation/sound/effects/water_wade4.ogg'
			))
		playsound(T, sound_to_play, 50, 0)
	if(isliving(AM))
		var/mob/living/arrived = AM
		if(!arrived.has_status_effect(/datum/status_effect/ocean_affected))
			arrived.apply_status_effect(/datum/status_effect/ocean_affected)

	SEND_SIGNAL(AM, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_WASH)

/turf/open/floor/plating/ocean/proc/add_turf_direction(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

	if(istype(direction_turf, /turf/open/floor/plating/ocean))
		return

	open_turfs.Add(get_dir(src, direction_turf))

	if(!(src in SSliquids.active_ocean_turfs))
		SSliquids.active_ocean_turfs |= src

/turf/open/floor/plating/ocean/proc/add_turf_direction_non_closed(datum/source)
	SIGNAL_HANDLER
	var/turf/direction_turf = source

	if(!(direction_turf in atmos_adjacent_turfs))
		return

	open_turfs.Add(get_dir(src, direction_turf))

	if(!(src in SSliquids.active_ocean_turfs))
		SSliquids.active_ocean_turfs |= src
