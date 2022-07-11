#define NOON_DIVISOR 1.6 
#define LIGHTING_GRANULARITY 3.4
#define UPDATES_IN_QUARTER_DAY 5


/area/pregen
	name = "Pregenerated Space"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "pregen"
	map_generator = /datum/map_generator/jungleland
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = TRUE

/area/jungleland
	name = "Jungleland"
	dynamic_lighting = DYNAMIC_LIGHTING_ENABLED
	outdoors = TRUE
	has_gravity = TRUE
	always_unpowered = TRUE
	poweralm = FALSE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE

	var/daynight_cycle = TRUE
	var/update_interval = 60 SECONDS
	var/updates = 0 
	var/cached_luminosity = 0

/area/jungleland/proc/finish_generation()
	INVOKE_ASYNC(src,.proc/daynight_cycle)

/area/jungleland/proc/daynight_cycle()
	set waitfor = FALSE
	updates += 1
	//whew that's quite a bit of math! it's quite simple once you get it tho, think of (current_inteval/update_interval) as x, sin(x * arcsin(1)) turns sin()'s period from 2*PI to 4,
	//working with integers is nicer, all the other stuff is mostly fluff to make it so it takes 10 update_interval to go from day to night and back.
	var/new_luminosity = CEILING( (LIGHTING_GRANULARITY  *sin( ( updates * arcsin(1) ) / UPDATES_IN_QUARTER_DAY) ) ,1 )/NOON_DIVISOR
	
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_JUNGLELAND_DAYNIGHT_NEXT_PHASE,updates,new_luminosity)
	
	if(new_luminosity != cached_luminosity)
		if(new_luminosity > 0 && cached_luminosity < 0)
			for(var/mob/M in contents)
				to_chat(M,span_alertwarning("The dawn lights the whole jungle in new glorious light... a new day begins!"))
		if(new_luminosity < 0 && cached_luminosity > 0)
			for(var/mob/M in contents)
				to_chat(M,span_alertwarning("You can see the stars high in the sky... the night begins!"))
		var/counter = 0	
		for(var/turf/open/T in src)
			T.set_light(1,new_luminosity) // we do not use dynamic light, because they are so insanely slow, it's just.. not worth it.
			if(counter == 255)
				CHECK_TICK
				counter = 0
			counter++
		cached_luminosity = new_luminosity

	addtimer(CALLBACK(src,.proc/daynight_cycle), update_interval, TIMER_UNIQUE | TIMER_OVERRIDE)

/turf/open/floor/plating/dirt/jungleland
	name = "generic jungle land turf"
	desc = "pain"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "jungle"
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	var/can_spawn_ore = TRUE
	var/ore_present = ORE_EMPTY

/turf/open/floor/plating/dirt/jungleland/proc/spawn_rock()
	if(ore_present == ORE_EMPTY || !can_spawn_ore)
		return
	can_spawn_ore = FALSE
	add_overlay(image(icon='yogstation/icons/obj/jungle.dmi',icon_state="dug_spot",layer=BELOW_OBJ_LAYER))
	var/datum/ore_patch/ore = GLOB.jungle_ores[ ore_present ]
	ore.spawn_at(src)

/turf/open/floor/plating/dirt/jungleland/tool_act(mob/living/user, obj/item/I, tool_type)
	if(tool_type != TOOL_MINING)
		return ..()
	
	if(ore_present == ORE_EMPTY)
		return ..()

	if(!can_spawn_ore)
		return ..()

	I.play_tool_sound(user)	
	if(!do_after(user,10 SECONDS * I.toolspeed,FALSE, src))
		return ..()

	spawn_rock()
	
/turf/open/floor/plating/dirt/jungleland/ex_act(severity, target)
	if(can_spawn_ore && prob( (severity/3)*100  ))	
		spawn_rock()
/turf/open/floor/plating/dirt/jungleland/barren_rocks
	icon_state = "barren_rocks"

/turf/open/floor/plating/dirt/jungleland/toxic_rocks
	icon_state = "toxic_rocks"

/turf/open/floor/plating/dirt/jungleland/dry_swamp
	icon_state = "dry_swamp"

/turf/open/floor/plating/dirt/jungleland/toxic_pit
	icon_state = "toxic_pit"

/turf/open/floor/plating/dirt/jungleland/dry_swamp1
	icon_state = "dry_swamp1"

/turf/open/floor/plating/dirt/jungleland/dying_forest
	icon_state = "dying_forest"

/turf/open/floor/plating/dirt/jungleland/jungle
	icon_state = "jungle"

/turf/open/water/toxic_pit
	name = "sulphuric pit"
	color = "#00c167"
	slowdown = 2
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE

/turf/open/water/toxic_pit/Entered(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/humie = AM 
	var/chance = ((humie.wear_suit ? 100 - humie.wear_suit.armor.bio : 100)  +  (humie.head ? 100 - humie.head.armor.bio : 100) )/2
	if(prob(chance * 0.33))
		humie.apply_status_effect(/datum/status_effect/toxic_buildup)

/turf/open/floor/wood/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plating/ashplanet/rocky/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plating/jungle_baseturf
	baseturfs = /turf/open/floor/plating/dirt/jungleland/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plating/jungle_baseturf/dying
	baseturfs = /turf/open/floor/plating/dirt/jungleland/dying_forest

/turf/open/indestructible/grass/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/floor/plasteel/jungle
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
