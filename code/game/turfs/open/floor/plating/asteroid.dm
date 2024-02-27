
/**********************Asteroid**************************/

/turf/open/floor/plating/asteroid //floor piece
	gender = PLURAL
	name = "asteroid sand"
	baseturfs = /turf/open/floor/plating/asteroid
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	base_icon_state = "asteroid"
	icon_plating = "asteroid"
	postdig_icon_change = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/environment_type = "asteroid"
	var/turf_type = /turf/open/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	var/floor_variance = 20 //probability floor has a different icon state
	attachment_holes = FALSE
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	var/dug = FALSE

/turf/open/floor/plating/asteroid/broken_states()
	if(initial(dug))
		return list(icon_state)
	return list("[base_icon_state]_dug")

/turf/open/floor/plating/asteroid/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(0,12)]"

/turf/open/floor/plating/asteroid/proc/getDug()
	new digResult(src, 5)
	if(postdig_icon_change)
		if(!postdig_icon)
			icon_plating = "[environment_type]_dug"
			icon_state = "[environment_type]_dug"
	dug = TRUE
	broken = TRUE
	update_appearance()

/turf/open/floor/plating/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_notice("Looks like someone has dug here already."))

/turf/open/floor/plating/asteroid/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, span_notice("You build a floor."))
			place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
			return TRUE
	return FALSE  

/turf/open/floor/plating/asteroid/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/asteroid/burn_tile()
	return

/turf/open/floor/plating/asteroid/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/plating/asteroid/MakeDry()
	return

/turf/open/floor/plating/asteroid/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!.)
		if(attacking_item.tool_behaviour == TOOL_SHOVEL || attacking_item.tool_behaviour == TOOL_MINING)
			if(!can_dig(user))
				return TRUE

			if(!isturf(user.loc))
				return

			to_chat(user, span_notice("You start digging..."))

			if(attacking_item.use_tool(src, user, 40, volume=50))
				if(!can_dig(user))
					return TRUE
				to_chat(user, span_notice("You dig a hole."))
				getDug()
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, attacking_item.type)
				return TRUE
		else if(istype(attacking_item, /obj/item/storage/bag/ore))
			for(var/obj/item/stack/ore/O in src)
				attacking_item.attackby(O, user, params)

/turf/open/floor/plating/asteroid/ex_act(severity, target)
	. = SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)
	contents_explosion(severity, target)

/turf/open/floor/plating/lavaland_baseturf
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface

/turf/open/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturfs = /turf/open/floor/plating/asteroid/basalt
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	base_icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	floor_variance = 15
	digResult = /obj/item/stack/ore/glass/basalt

/turf/open/floor/plating/asteroid/basalt/lava //lava underneath
	baseturfs = /turf/open/lava/smooth

/turf/open/floor/plating/asteroid/basalt/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light(src)

/turf/open/floor/plating/asteroid/getDug()
	set_light(0)
	return ..()

/proc/set_basalt_light(turf/open/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/lava/smooth/lava_land_surface

/// Used for the lavaland icemoon ruin.
/turf/open/floor/plating/asteroid/basalt/lava_land_surface/no_ruins
	turf_flags = NO_RUINS

/turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	baseturfs = /turf/open/floor/plating/asteroid/airless
	turf_type = /turf/open/floor/plating/asteroid/airless

// / Breathing types. Lungs can access either by these or by a string, which will be considered a gas ID.
#define BREATH_OXY /datum/breathing_class/oxygen
#define BREATH_PLASMA /datum/breathing_class/plasma

/turf/open/floor/plating/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	damaged_dmi = 'icons/turf/snow.dmi'
	baseturfs = /turf/open/floor/plating/asteroid/snow
	icon_state = "snow"
	base_icon_state = "snow"
	icon_plating = "snow"
	initial_gas_mix = FROZEN_ATMOS
	slowdown = 2
	environment_type = "snow"
	flags_1 = NONE
	planetary_atmos = TRUE
	bullet_sizzle = TRUE
	bullet_bounce_sound = null
	digResult = /obj/item/stack/sheet/mineral/snow
	flammability = -5

/turf/open/floor/plating/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message(span_danger("[src] melts away!."))
		slowdown = 0
		burnt = TRUE
		update_appearance()
		return TRUE
	return FALSE

/turf/open/floor/plating/asteroid/snow/burnt_states()
	return list("snow_dug")

/turf/open/floor/plating/asteroid/snow/singularity_act()
	. = ..() //take the wires n shit out
	return 0

/turf/open/floor/plating/asteroid/snow/getDug()
	..()
	slowdown = 0

/turf/open/floor/plating/asteroid/snow/icemoon
	baseturfs = /turf/open/openspace/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	slowdown = 0

/turf/open/floor/plating/asteroid/snow/icemoon/do_not_chasm
	flags_1 = CAN_BE_DIRTY_1
	turf_flags = IS_SOLID | NO_RUST | NO_RUINS

/turf/open/floor/plating/asteroid/snow/icemoon/do_not_scrape
	flags_1 = CAN_BE_DIRTY_1
	turf_flags = IS_SOLID | NO_RUST | NO_CLEARING

/turf/open/floor/plating/asteroid/snow/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/open/lava/plasma/ice_moon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	baseturfs = /turf/open/lava/plasma/ice_moon
	planetary_atmos = TRUE

/turf/open/floor/plating/asteroid/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/asteroid/basalt/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/basalt/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/asteroid/snow/ice
	name = "icy snow"
	desc = "Looks colder."
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = BURNING_COLD
	floor_variance = 0
	icon_state = "snow-ice"
	icon_plating = "snow-ice"
	environment_type = "snow_cavern"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/asteroid/snow/ice/break_tile()
	return FALSE

/turf/open/floor/plating/asteroid/snow/ice/burn_tile()
	return FALSE

/turf/open/floor/plating/asteroid/snow/ice/icemoon
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice/icemoon
	initial_gas_mix = ICEMOON_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/floor/plating/asteroid/snow/ice/icemoon/top_layer
	light_range = 2
	light_power = 0.1

/turf/open/floor/plating/asteroid/snow/ice/burn_tile()
	return FALSE

/turf/open/floor/plating/asteroid/snow/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/plating/asteroid/snow/temperatre
	initial_gas_mix = "o2=22;n2=82;TEMP=255.37"

/turf/open/floor/plating/asteroid/snow/atmosphere
	initial_gas_mix = FROZEN_ATMOS
	planetary_atmos = FALSE
