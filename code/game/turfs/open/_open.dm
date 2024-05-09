/turf/open
	plane = FLOOR_PLANE

	FASTDMM_PROP(\
		pipe_astar_cost = 1.5\
	)

	var/slowdown = 0 //negative for faster, positive for slower

	var/postdig_icon_change = FALSE
	var/postdig_icon
	var/wet

	var/footstep = null
	var/barefootstep = null
	var/clawfootstep = null
	var/heavyfootstep = null
	
	/// Determines the type of damage overlay that will be used for the tile
	var/damaged_dmi = null
	var/broken = FALSE
	var/burnt = FALSE

/// Returns a list of every turf state considered "broken".
/// Will be randomly chosen if a turf breaks at runtime.
/turf/open/proc/broken_states()
	return list()

/// Returns a list of every turf state considered "burnt".
/// Will be randomly chosen if a turf is burnt at runtime.
/turf/open/proc/burnt_states()
	return list()

/turf/open/break_tile()
	if(isnull(damaged_dmi) || broken)
		return FALSE
	broken = TRUE
	update_appearance()
	return TRUE

/turf/open/burn_tile()
	if(isnull(damaged_dmi) || burnt)
		return FALSE
	burnt = TRUE
	update_appearance()
	return TRUE

/turf/open/update_overlays()
	if(isnull(damaged_dmi))
		return ..()
	. = ..()
	if(broken)
		. += mutable_appearance(damaged_dmi, pick(broken_states()))
	else if(burnt)
		var/list/burnt_states = burnt_states()
		if(burnt_states.len)
			. += mutable_appearance(damaged_dmi, pick(burnt_states))
		else
			. += mutable_appearance(damaged_dmi, pick(broken_states()))

//direction is direction of travel of A
/turf/open/zPassIn(direction)
	if(direction != DOWN)
		return FALSE
	for(var/obj/on_us in contents)
		if(on_us.obj_flags & BLOCK_Z_IN_DOWN)
			return FALSE
	return TRUE

//direction is direction of travel of an atom
/turf/open/zPassOut(direction)
	if(direction != UP)
		return FALSE
	for(var/obj/on_us in contents)
		if(on_us.obj_flags & BLOCK_Z_OUT_UP)
			return FALSE
	return TRUE

//direction is direction of travel of air
/turf/open/zAirIn(direction, turf/source)
	return (direction == DOWN)

//direction is direction of travel of air
/turf/open/zAirOut(direction, turf/source)
	return (direction == UP)

/turf/open/update_icon()
	. = ..()
	update_visuals()

/**
 * Replace an open turf with another open turf while avoiding the pitfall of replacing plating with a floor tile, leaving a hole underneath.
 * This replaces the current turf if it is plating and is passed plating, is tile and is passed tile.
 * It places the new turf on top of itself if it is plating and is passed a tile.
 * It also replaces the turf if it is tile and is passed plating, essentially destroying the over turf.
 * Flags argument is passed directly to ChangeTurf or PlaceOnTop
 */
/turf/open/proc/replace_floor(turf/open/new_floor_path, flags)
	if (!overfloor_placed && initial(new_floor_path.overfloor_placed))
		place_on_top(new_floor_path, flags = flags)
		return
	ChangeTurf(new_floor_path, flags = flags)

/turf/open/indestructible
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = TRUE

/turf/open/indestructible/Melt()
	to_be_destroyed = FALSE
	return src

/turf/open/indestructible/singularity_act()
	return

/turf/open/indestructible/TerraformTurf(path, new_baseturf, flags, defer_change = FALSE, ignore_air = FALSE)
	return

/turf/open/indestructible/plating
	name = "plating"
	icon_state = "plating"
	overfloor_placed = FALSE
	underfloor_accessibility = UNDERFLOOR_INTERACTABLE
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/sound
	name = "squeaky floor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	var/sound

/turf/open/indestructible/sound/Entered(atom/movable/AM)
	..()
	if(sound && ismob(AM))
		playsound(src,sound,50,TRUE)

/turf/open/indestructible/necropolis
	name = "necropolis floor"
	desc = "It's regarding you suspiciously."
	icon = 'icons/turf/floors.dmi'
	icon_state = "necro1"
	baseturfs = /turf/open/indestructible/necropolis
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	footstep = FOOTSTEP_LAVA
	barefootstep = FOOTSTEP_LAVA
	clawfootstep = FOOTSTEP_LAVA
	heavyfootstep = FOOTSTEP_LAVA
	tiled_dirt = FALSE

/turf/open/indestructible/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/necropolis/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/carpet
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet-255"
	base_icon_state = "carpet"
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET
	canSmoothWith = SMOOTH_GROUP_CARPET

/turf/open/indestructible/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet_black-255"
	base_icon_state = "carpet_black"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_BLACK

/turf/open/indestructible/carpet/blue
	icon = 'icons/turf/floors/carpet_blue.dmi'
	icon_state = "carpet_blue-255"
	base_icon_state = "carpet_blue"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_BLUE

/turf/open/indestructible/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet_cyan-255"
	base_icon_state = "carpet_cyan"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_CYAN
	canSmoothWith = SMOOTH_GROUP_CARPET_CYAN

/turf/open/indestructible/carpet/green
	icon = 'icons/turf/floors/carpet_green.dmi'
	icon_state = "carpet_green-255"
	base_icon_state = "carpet_green"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_GREEN
	canSmoothWith = SMOOTH_GROUP_CARPET_GREEN

/turf/open/indestructible/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	icon_state = "carpet_orange-255"
	base_icon_state = "carpet_orange"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ORANGE
	canSmoothWith = SMOOTH_GROUP_CARPET_ORANGE

/turf/open/indestructible/carpet/purple
	icon = 'icons/turf/floors/carpet_purple.dmi'
	icon_state = "carpet_purple-255"
	base_icon_state = "carpet_purple"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_PURPLE
	canSmoothWith = SMOOTH_GROUP_CARPET_PURPLE

/turf/open/indestructible/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	icon_state = "carpet_red-255"
	base_icon_state = "carpet_red"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_RED
	canSmoothWith = SMOOTH_GROUP_CARPET_RED

/turf/open/indestructible/carpet/royalblack
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet_royalblack-255"
	base_icon_state = "carpet_royalblack"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLACK
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLACK

/turf/open/indestructible/carpet/royalblue
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet_royalblue-255"
	base_icon_state = "carpet_royalblue"
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_BLUE
	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_BLUE

// /turf/open/indestructible/carpet/royal/green
// 	icon = 'icons/turf/floors/carpet_green.dmi'
// 	icon_state = "carpet"
// 	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_GREEN
// 	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_GREEN

// /turf/open/indestructible/carpet/royal/purple
// 	icon = 'icons/turf/floors/carpet_purple.dmi'
// 	icon_state = "carpet"
// 	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_CARPET_ROYAL_PURPLE
// 	canSmoothWith = SMOOTH_GROUP_CARPET_ROYAL_PURPLE

/turf/open/indestructible/grass
	name = "grass patch"
	desc = "Yep, it's grass."
	icon_state = "grass1"
	bullet_bounce_sound = null
	footstep = FOOTSTEP_GRASS
	barefootstep = FOOTSTEP_GRASS
	clawfootstep = FOOTSTEP_GRASS
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/indestructible/grass/sand
	name = "sand"
	desc = "Course, rough, irritating, gets everywhere."
	icon = 'icons/turf/floors.dmi'
	icon_state = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/grass/dirt
	name = "dirt"
	desc = "Upon closer examination, it's still dirt."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/grass/dirt/dark
	icon_state = "greenerdirt"

/turf/open/indestructible/grass/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	desc = "Looks cold."
	icon_state = "snow"
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/grass/basalt
	name = "volcanic floor"
	desc = "Feels hot"
	icon = 'icons/turf/floors.dmi'
	icon_state = "basalt"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/grass/water
	name = "water"
	desc = "Shallow water."
	icon = 'icons/turf/floors.dmi'
	icon_state = "riverwater_motion"
	slowdown = 1
	bullet_sizzle = TRUE
	bullet_bounce_sound = null //needs a splashing sound one day.
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/indestructible/grass/beach
	name = "sand"
	icon = 'icons/misc/beach.dmi'
	icon_state = "sand"
	bullet_bounce_sound = null

/turf/open/indestructible/grass/beach/coast_t
	name = "coastline"
	icon_state = "sandwater_t"

/turf/open/indestructible/grass/beach/coast_b
	name = "coastline"
	icon_state = "sandwater_b"

/turf/open/indestructible/grass/beach/water
	name = "water"
	icon_state = "water"
	slowdown = 1
	bullet_sizzle = TRUE
	footstep = FOOTSTEP_WATER
	barefootstep = FOOTSTEP_WATER
	clawfootstep = FOOTSTEP_WATER
	heavyfootstep = FOOTSTEP_WATER

/turf/open/floor/grass/fairy //like grass but fae-er
	name = "fairygrass patch"
	desc = "Something about this grass makes you want to frolic. Or get high."
	icon_state = "fairygrass"
	floor_tile = /obj/item/stack/tile/fairygrass
	light_range = 2
	light_power = 0.80
	light_color = "#33CCFF"
	color = "#33CCFF"

/turf/open/floor/grass/fairy/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_LIGHT_EATER_ACT, PROC_REF(on_light_eater))

/turf/open/floor/grass/fairy/proc/on_light_eater(obj/machinery/light/source, datum/light_eater)
	SIGNAL_HANDLER
	visible_message("Dark energies lash out and corrupt [src].")
	TerraformTurf(/turf/open/floor/grass/fairy/dark)
	return COMPONENT_BLOCK_LIGHT_EATER

/turf/open/floor/grass/fairy/white
	name = "white fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/white
	light_color = "#FFFFFF"
	color = "#FFFFFF"

/turf/open/floor/grass/fairy/red
	name = "red fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/red
	light_color = "#FF3333"
	color = "#FF3333"

/turf/open/floor/grass/fairy/yellow
	name = "yellow fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/yellow
	light_color = "#FFFF66"
	color = "#FFFF66"

/turf/open/floor/grass/fairy/green
	name = "green fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/green
	light_color = "#99FF99"
	color = "#99FF99"

/turf/open/floor/grass/fairy/blue
	floor_tile = /obj/item/stack/tile/fairygrass/blue
	name = "blue fairygrass patch"

/turf/open/floor/grass/fairy/purple
	name = "purple fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/purple
	light_color = "#D966FF"
	color = "#D966FF"

/turf/open/floor/grass/fairy/pink
	name = "pink fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/pink
	light_color = "#FFB3DA"
	color = "#FFB3DA"

/turf/open/floor/grass/fairy/dark
	name = "dark fairygrass patch"
	floor_tile = /obj/item/stack/tile/fairygrass/dark
	light_power = -1
	light_color = "#21007F"
	color = "#21007F"

/turf/open/floor/grass/fairy/dark/on_light_eater(obj/machinery/light/source, datum/light_eater)
	return

/turf/open/floor/grass/fairy/Initialize(mapload)
	. = ..()
	icon_state = "fairygrass[rand(1,4)]"
	update_appearance(UPDATE_ICON)

/turf/open/indestructible/boss //you put stone tiles on this and use it as a base
	name = "necropolis floor"
	icon = 'icons/turf/boss_floors.dmi'
	icon_state = "boss"
	baseturfs = /turf/open/indestructible/boss
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/indestructible/boss/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/hierophant
	icon = 'icons/turf/floors/hierophant_floor.dmi'
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	baseturfs = /turf/open/indestructible/hierophant
	smoothing_flags = SMOOTH_CORNERS
	tiled_dirt = FALSE

/turf/open/indestructible/hierophant/two

/turf/open/indestructible/hierophant/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/open/indestructible/paper
	name = "notebook floor"
	desc = "A floor made of invulnerable notebook paper."
	icon_state = "paperfloor"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null
	tiled_dirt = FALSE

/turf/open/indestructible/binary
	name = "tear in the fabric of reality"
	can_atmos_pass = ATMOS_PASS_NO
	baseturfs = /turf/open/indestructible/binary
	icon_state = "binary"
	footstep = null
	barefootstep = null
	clawfootstep = null
	heavyfootstep = null

/turf/open/indestructible/airblock
	icon_state = "bluespace"
	blocks_air = TRUE
	baseturfs = /turf/open/indestructible/airblock

/turf/open/indestructible/clock_spawn_room
	name = "cogmetal floor"
	desc = "Brass plating that gently radiates heat. For some reason, it reminds you of blood."
	icon_state = "reebe"
	baseturfs = /turf/open/indestructible/clock_spawn_room
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/indestructible/clock_spawn_room/Entered()
	..()
	START_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/clock_spawn_room/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/turf/open/indestructible/clock_spawn_room/process()
	if(!port_servants())
		STOP_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/clock_spawn_room/proc/port_servants()
	. = FALSE
	for(var/mob/living/L in src)
		if(is_servant_of_ratvar(L) && L.stat != DEAD)
			. = TRUE
			L.forceMove(get_turf(pick(GLOB.servant_spawns)))
			visible_message(span_warning("[L] vanishes in a flash of red!"))
			L.visible_message(span_warning("[L] appears in a flash of red!"), \
			"<span class='bold cult'>sas'so c'arta forbici</span><br>[span_danger("You're yanked away from [src]!")]")
			playsound(src, 'sound/magic/enter_blood.ogg', 50, TRUE)
			playsound(L, 'sound/magic/exit_blood.ogg', 50, TRUE)
			flash_color(L, flash_color = "#C80000", flash_time = 10)

/turf/open/indestructible/brazil
	name = ".."
	desc = "..."

/turf/open/indestructible/brazil/Entered()
	..()
	START_PROCESSING(SSfastprocess, src)

/turf/open/indestructible/brazil/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/turf/open/indestructible/brazil/process()
	if(!gtfo())
		STOP_PROCESSING(SSfastprocess, src)

///teleports people back to a safe station turf in case they somehow manage to end up here without the status effect
/turf/open/indestructible/brazil/proc/gtfo()
	. = FALSE
	for(var/mob/living/L in src)
		if(!L.has_status_effect(STATUS_EFFECT_BRAZIL_PENANCE))
			. = TRUE
			to_chat(L, span_velvet("Get out of here, stalker."))
			var/turf/safe_turf = get_safe_random_station_turf(typesof(/area/hallway) - typesof(/area/hallway/secondary)) //teleport back into a main hallway, secondary hallways include botany's techfab room which could trap someone
			if(safe_turf)
				L.forceMove(safe_turf)
				flash_color(L, flash_color = "#000000", flash_time = 10)

/turf/open/indestructible/brazil/space
	icon = 'icons/turf/space.dmi'

/turf/open/indestructible/brazil/space/Initialize(mapload)
	. = ..()
	icon_state = "[rand(1,25)]"
	add_atom_colour(list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0), FIXED_COLOUR_PRIORITY)

/turf/open/indestructible/brazil/narsie
	icon_state = "cult"

/turf/open/indestructible/brazil/necropolis
	icon_state = "necro1"

/turf/open/indestructible/brazil/necropolis/Initialize(mapload)
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/brazil/lostit
	icon = 'yogstation/icons/turf/floors/ballpit_smooth.dmi'
	icon_state = "smooth"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TURF_OPEN + SMOOTH_GROUP_BRAZIL
	canSmoothWith = SMOOTH_GROUP_BRAZIL

/turf/open/indestructible/wiki
	light_range = 2
	light_power = 2

/turf/open/indestructible/wiki/greenscreen
	icon = 'yogstation/icons/turf/floors/wiki.dmi'
	icon_state = "greenscreen"

/turf/open/indestructible/wiki/bluescreen
	icon = 'yogstation/icons/turf/floors/wiki.dmi'
	icon_state = "bluescreen"

/turf/open/indestructible/wiki/whitescreen
	icon = 'yogstation/icons/turf/floors/wiki.dmi'
	icon_state = "whitescreen"

/turf/open/indestructible/wiki/greenscreen/border
	icon = 'yogstation/icons/turf/floors/wiki.dmi'
	icon_state = "greenborder"

/turf/open/indestructible/wiki/title
	icon = 'yogstation/icons/turf/floors/wiki.dmi'
	icon_state = "title"

/turf/open/indestructible/wiki/info
	icon = 'yogstation/icons/turf/floors/wiki.dmi'
	icon_state = "info"

/turf/open/Initalize_Atmos(times_fired)
	if(!blocks_air)
		if(!istype(air,/datum/gas_mixture/turf))
			air = new(2500,src)
		air.copy_from_turf(src)
		update_air_ref(planetary_atmos ? 1 : 2)
	immediate_calculate_adjacent_turfs()

/turf/open/proc/GetHeatCapacity()
	. = air.heat_capacity()

/turf/open/proc/GetTemperature()
	. = air.return_temperature()

/turf/open/proc/TakeTemperature(temp)
	air.set_temperature(air.return_temperature() + temp)

/turf/open/proc/freeze_turf()
	for(var/obj/I in contents)
		if(I.resistance_flags & FREEZE_PROOF)
			return
		if(!(I.obj_flags & FROZEN))
			I.make_frozen_visual()
	for(var/mob/living/L in contents)
		if(L.bodytemperature <= 50)
			L.apply_status_effect(/datum/status_effect/freon)
	MakeSlippery(TURF_WET_PERMAFROST, 50)
	return TRUE

/turf/open/proc/water_vapor_gas_act()
	MakeSlippery(TURF_WET_WATER, min_wet_time = 100, wet_time_to_add = 50)

	for(var/mob/living/simple_animal/slime/M in src)
		M.apply_water()

	wash(CLEAN_WASH)
	for(var/am in src)
		var/atom/movable/movable_content = am
		if(ismopable(movable_content)) // Will have already been washed by the wash call above at this point.
			continue
		movable_content.wash(CLEAN_WASH)
	return TRUE

/turf/open/handle_slip(mob/living/carbon/slipper, knockdown_amount, obj/slippable, lube, paralyze_amount, force_drop)
	if(slipper.movement_type & (FLYING | FLOATING))
		return FALSE
	if(has_gravity(src))
		var/obj/buckled_obj
		if(slipper.buckled)
			buckled_obj = slipper.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return 0
		else
			if(!(lube & SLIP_WHEN_CRAWLING) && (!(slipper.mobility_flags & MOBILITY_STAND)) || !(slipper.status_flags & CANKNOCKDOWN)) // can't slip unbuckled mob if they're lying or can't fall.
				return 0
			if(slipper.m_intent == MOVE_INTENT_WALK && (lube&NO_SLIP_WHEN_WALKING))
				return 0
		if(!(lube&SLIDE_ICE))
			to_chat(slipper, span_notice("You slipped[ slippable ? " on the [slippable.name]" : ""]!"))
			playsound(slipper.loc, 'sound/misc/slip.ogg', 50, TRUE, -3)

		SEND_SIGNAL(slipper, COMSIG_ON_CARBON_SLIP)
		if(force_drop)
			for(var/obj/item/I in slipper.held_items)
				slipper.accident(I)

		var/olddir = slipper.dir
		slipper.moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
		if(!(lube & SLIDE_ICE))
			slipper.Knockdown(knockdown_amount)
			slipper.Paralyze(paralyze_amount)
			slipper.stop_pulling()
		else
			slipper.Knockdown(20)
		if(buckled_obj)
			buckled_obj.unbuckle_mob(slipper)
			lube |= SLIDE_ICE

		var/turf/target = get_ranged_target_turf(slipper, olddir, 4)
		if(lube & SLIDE)
			new /datum/forced_movement(slipper, target, 1, FALSE, CALLBACK(slipper, TYPE_PROC_REF(/mob/living/carbon, spin), 1, 1))
		else if(lube&SLIDE_ICE)
			new /datum/forced_movement(slipper, get_ranged_target_turf(slipper, olddir, 1), 1, FALSE)	//spinning would be bad for ice, fucks up the next dir
		return 1

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/turf/open/rad_act(pulse_strength, collectable_radiation)
	. = ..()
	if (air.get_moles(GAS_CO2) && air.get_moles(GAS_O2) && !(air.get_moles(GAS_HYPERNOB) >= REACTION_OPPRESSION_THRESHOLD) )
		pulse_strength = min(pulse_strength,air.get_moles(GAS_CO2)*1000,air.get_moles(GAS_O2)*2000) //Ensures matter is conserved properly
		air.set_moles(GAS_CO2, max(air.get_moles(GAS_CO2)-(pulse_strength * 0.001),0))
		air.set_moles(GAS_O2, max(air.get_moles(GAS_O2)-(pulse_strength * 0.002),0))
		air.adjust_moles(GAS_PLUOXIUM, pulse_strength * 0.004)
	if (air.get_moles(GAS_H2) && !(air.get_moles(GAS_HYPERNOB) >= REACTION_OPPRESSION_THRESHOLD))
		pulse_strength = min(pulse_strength, air.get_moles(GAS_H2) * 1000)
		air.set_moles(GAS_H2, max(air.get_moles(GAS_H2) - (pulse_strength * 0.001), 0))
		air.adjust_moles(GAS_TRITIUM, pulse_strength * 0.001)

/turf/open/ignite_turf(power, fire_color="red")
	. = ..()
	if(. & SUPPRESS_FIRE)
		return
	if(air.get_moles(GAS_O2) < 1)
		return
	if(turf_fire)
		turf_fire.AddPower(power)
		return
	if(!isgroundlessturf(src))
		new /obj/effect/abstract/turf_fire(src, power, fire_color)

/turf/open/extinguish_turf()
	if(!air)
		return
	if(air.return_temperature() > T20C)
		air.set_temperature(max(air.return_temperature() / 2, T20C))
	air.react(src)
	if(active_hotspot)
		qdel(active_hotspot)
	if(turf_fire)
		qdel(turf_fire)

/turf/open/proc/set_flammability(new_flammability)
	if(isnull(new_flammability))
		flammability = initial(flammability)
		return
	flammability = new_flammability

/// Builds with rods. This doesn't exist to be overriden, just to remove duplicate logic for turfs that want
/// To support floor tile creation
/// I'd make it a component, but one of these things is space. So no.
/turf/open/proc/build_with_rods(obj/item/stack/rods/used_rods, mob/user)
	var/obj/structure/lattice/catwalk_bait = locate(/obj/structure/lattice, src)
	var/obj/structure/lattice/catwalk/existing_catwalk = locate(/obj/structure/lattice/catwalk, src)
	if(existing_catwalk)
		to_chat(user, span_warning("There is already a catwalk here!"))
		return

	if(catwalk_bait)
		if(used_rods.use(1))
			qdel(catwalk_bait)
			to_chat(user, span_notice("You construct a catwalk."))
			playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
			new /obj/structure/lattice/catwalk(src)
		else
			to_chat(user, span_warning("You need two rods to build a catwalk!"))
		return

	if(used_rods.use(1))
		to_chat(user, span_notice("You construct a lattice."))
		playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
		new /obj/structure/lattice(src)
	else
		to_chat(user, span_warning("You need one rod to build a lattice."))

/// Very similar to build_with_rods, this exists to allow consistent behavior between different types in terms of how
/// Building floors works
/turf/open/proc/build_with_floor_tiles(obj/item/stack/tile/plasteel/used_tiles, user)
	var/obj/structure/lattice/lattice = locate(/obj/structure/lattice, src)
	if(!has_valid_support() && !lattice)
		balloon_alert(user, "needs support, place rods!")
		return
	if(!used_tiles.use(1))
		balloon_alert(user, "need a floor tile to build!")
		return

	playsound(src, 'sound/weapons/genhit.ogg', 50, TRUE)
	var/turf/open/floor/plating/new_plating = place_on_top(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
	if(lattice)
		qdel(lattice)
	else
		new_plating.lattice_underneath = FALSE

/turf/open/proc/has_valid_support()
	for (var/direction in GLOB.cardinals)
		if(istype(get_step(src, direction), /turf/open/floor))
			return TRUE
	return FALSE
