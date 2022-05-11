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

/turf/open/ComponentInitialize()
	. = ..()
	if(wet)
		AddComponent(/datum/component/wet_floor, wet, INFINITY, 0, INFINITY, TRUE)

//direction is direction of travel of A
/turf/open/zPassIn(atom/movable/A, direction, turf/source)
	return (direction == DOWN)

//direction is direction of travel of A
/turf/open/zPassOut(atom/movable/A, direction, turf/destination)
	return (direction == UP)

//direction is direction of travel of air
/turf/open/zAirIn(direction, turf/source)
	return (direction == DOWN)

//direction is direction of travel of air
/turf/open/zAirOut(direction, turf/source)
	return (direction == UP)

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
	if(ismob(AM))
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

/turf/open/indestructible/necropolis/Initialize()
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/necropolis/air
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/indestructible/carpet
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/open/indestructible/carpet)
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/indestructible/carpet/black
	icon = 'icons/turf/floors/carpet_black.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/blue
	icon = 'goon/icons/turfs/carpet_blue.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/green
	icon = 'goon/icons/turfs/carpet_green.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/cyan
	icon = 'icons/turf/floors/carpet_cyan.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/orange
	icon = 'icons/turf/floors/carpet_orange.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/purple
	icon = 'goon/icons/turfs/carpet_purple.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/red
	icon = 'icons/turf/floors/carpet_red.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/royal
	name = "carpet"
	desc = "Soft velvet carpeting. Feels good between your toes."
	icon = 'icons/turf/floors/carpet_royalblue.dmi'
	icon_state = "carpet"
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/open/indestructible/carpet/royal)
	flags_1 = NONE
	bullet_bounce_sound = null
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE

/turf/open/indestructible/carpet/royal/black
	icon = 'icons/turf/floors/carpet_royalblack.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/royal/green
	icon = 'icons/turf/floors/carpet_exoticgreen.dmi'
	icon_state = "carpet"

/turf/open/indestructible/carpet/royal/purple
	icon = 'icons/turf/floors/carpet_exoticpurple.dmi'
	icon_state = "carpet"

/turf/open/indestructible/grass
	name = "grass patch"
	desc = "Yep, it's grass."
	icon_state = "grass"
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
	slowdown = 2
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
	light_power = -0.15
	light_range = 2
	light_color = "#AAD84B"
	color = "#53003f"

/turf/open/floor/grass/fairy/Initialize()
	. = ..()
	icon_state = "fairygrass[rand(1,4)]"
	update_icon()

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
	smooth = SMOOTH_TRUE
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
	CanAtmosPass = ATMOS_PASS_NO
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

/turf/open/indestructible/brazil/necropolis/Initialize()
	. = ..()
	if(prob(12))
		icon_state = "necro[rand(2,3)]"

/turf/open/indestructible/brazil/lostit
	smooth = SMOOTH_TRUE | SMOOTH_BORDER | SMOOTH_MORE
	canSmoothWith = list(/turf/open/indestructible/brazil/lostit)
	icon = 'yogstation/icons/turf/floors/ballpit_smooth.dmi'
	icon_state = "smooth"

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
	set_excited(FALSE)
	update_visuals()

	current_cycle = times_fired
	ImmediateCalculateAdjacentTurfs()
	for(var/i in atmos_adjacent_turfs)
		var/turf/open/enemy_tile = i
		var/datum/gas_mixture/enemy_air = enemy_tile.return_air()
		if(!get_excited() && air.compare(enemy_air))
			//testing("Active turf found. Return value of compare(): [is_active]")
			set_excited(TRUE)
			SSair.active_turfs |= src

/turf/open/proc/GetHeatCapacity()
	. = air.heat_capacity()

/turf/open/proc/GetTemperature()
	. = air.return_temperature()

/turf/open/proc/TakeTemperature(temp)
	air.set_temperature(air.return_temperature() + temp)
	air_update_turf()

/turf/open/proc/freon_gas_act()
	for(var/obj/I in contents)
		if(I.resistance_flags & FREEZE_PROOF)
			return
		if(!(I.obj_flags & FROZEN))
			I.make_frozen_visual()
	for(var/mob/living/L in contents)
		if(L.bodytemperature <= 50)
			L.apply_status_effect(/datum/status_effect/freon)
	MakeSlippery(TURF_WET_PERMAFROST, 50)
	return 1

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

/turf/open/handle_slip(mob/living/carbon/C, knockdown_amount, obj/O, lube, stun_amount, force_drop)
	if(C.movement_type & FLYING)
		return 0
	if(has_gravity(src))
		var/obj/buckled_obj
		if(C.buckled)
			buckled_obj = C.buckled
			if(!(lube&GALOSHES_DONT_HELP)) //can't slip while buckled unless it's lube.
				return 0
		else
			if(!(lube&SLIP_WHEN_CRAWLING) && (!(C.mobility_flags & MOBILITY_STAND) || !(C.status_flags & CANKNOCKDOWN))) // can't slip unbuckled mob if they're lying or can't fall.
				return 0
			if(C.m_intent == MOVE_INTENT_WALK && (lube&NO_SLIP_WHEN_WALKING))
				return 0
		if(!(lube&SLIDE_ICE))
			to_chat(C, span_notice("You slipped[ O ? " on the [O.name]" : ""]!"))
			playsound(C.loc, 'sound/misc/slip.ogg', 50, 1, -3)

		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "slipped", /datum/mood_event/slipped)
		if(force_drop)
			for(var/obj/item/I in C.held_items)
				C.accident(I)

		var/olddir = C.dir
		C.moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
		if(!(lube & SLIDE_ICE))
			C.Knockdown(knockdown_amount)
			C.Stun(stun_amount)
			C.stop_pulling()
		else
			C.Knockdown(20)
		if(buckled_obj)
			buckled_obj.unbuckle_mob(C)
			lube |= SLIDE_ICE

		if(lube&SLIDE)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 4), 1, FALSE, CALLBACK(C, /mob/living/carbon/.proc/spin, 1, 1))
		else if(lube&SLIDE_ICE)
			if(C.force_moving) //If we're already slipping extend it
				qdel(C.force_moving)
			new /datum/forced_movement(C, get_ranged_target_turf(C, olddir, 1), 1, FALSE)	//spinning would be bad for ice, fucks up the next dir
		return 1

/turf/open/proc/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent)
	AddComponent(/datum/component/wet_floor, wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)

/turf/open/proc/MakeDry(wet_setting = TURF_WET_WATER, immediate = FALSE, amount = INFINITY)
	SEND_SIGNAL(src, COMSIG_TURF_MAKE_DRY, wet_setting, immediate, amount)

/turf/open/get_dumping_location()
	return src

/turf/open/proc/ClearWet()//Nuclear option of immediately removing slipperyness from the tile instead of the natural drying over time
	qdel(GetComponent(/datum/component/wet_floor))

/turf/open/rad_act(pulse_strength)
	. = ..()
	if (air.get_moles(/datum/gas/carbon_dioxide) && air.get_moles(/datum/gas/oxygen))
		pulse_strength = min(pulse_strength,air.get_moles(/datum/gas/carbon_dioxide)*1000,air.get_moles(/datum/gas/oxygen)*2000) //Ensures matter is conserved properly
		air.set_moles(/datum/gas/carbon_dioxide, max(air.get_moles(/datum/gas/carbon_dioxide)-(pulse_strength * 0.001),0))
		air.set_moles(/datum/gas/oxygen, max(air.get_moles(/datum/gas/oxygen)-(pulse_strength * 0.002),0))
		air.adjust_moles(/datum/gas/pluoxium, pulse_strength * 0.004)
		air_update_turf()
	if (air.get_moles(/datum/gas/hydrogen))
		pulse_strength = min(pulse_strength, air.get_moles(/datum/gas/hydrogen) * 1000)
		air.set_moles(/datum/gas/hydrogen, max(air.get_moles(/datum/gas/hydrogen) - (pulse_strength * 0.001), 0))
		air.adjust_moles(/datum/gas/tritium, pulse_strength * 0.001)
		air_update_turf()
