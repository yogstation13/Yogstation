
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
	outdoors = TRUE

/area/jungleland/Initialize()
	. = ..()
	if(outdoors)
		GLOB.jungleland_daynight_cycle.affected_areas += src

/area/jungleland/explored
	name = "Explored Jungle"

/area/jungleland/ocean
	name = "Toxic Ocean"

/area/jungleland/proper 
	name = "Deep Jungle"

/area/jungleland/toxic_pit 
	name = "Toxic Pit"

/area/jungleland/barren_rocks 
	name = "Barren Rocks"

/area/jungleland/dry_swamp 
	name = "Rocky Beach"

/area/jungleland/dying_forest
	name = "Dying Jungle"

/turf/open/floor/plating/dirt/jungleland
	name = "generic jungle land turf"
	desc = "pain"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "jungle"
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/toxic_pit
	icon_state_regular_floor = "jungle" //used to remember what icon state the tile should have by default
	icon_regular_floor = 'yogstation/icons/turf/floors/jungle.dmi' //used to remember what icon the tile should have by default
	icon_plating = "jungle"
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
	if(tool_type != TOOL_MINING && tool_type != TOOL_SHOVEL)
		return ..()
	
	if(ore_present == ORE_EMPTY)
		return ..()

	if(!can_spawn_ore)
		return ..()

	I.play_tool_sound(user)	
	if(!do_after(user,10 SECONDS * I.toolspeed,src))
		return ..()

	spawn_rock()
	
/turf/open/floor/plating/dirt/jungleland/ex_act(severity, target)
	if(can_spawn_ore && prob( (severity/3)*100  ))	
		spawn_rock()
/turf/open/floor/plating/dirt/jungleland/barren_rocks
	icon_state = "barren_rocks"
	icon_plating = "barren_rocks"
	icon_state_regular_floor = "barren_rocks" 

/turf/open/floor/plating/dirt/jungleland/toxic_rocks
	icon_state = "toxic_rocks"
	icon_plating = "toxic_rocks"
	icon_state_regular_floor = "toxic_rocks" 

/turf/open/floor/plating/dirt/jungleland/dry_swamp
	icon_state = "dry_swamp"
	icon_plating = "dry_swamp"
	icon_state_regular_floor = "dry_swamp" 

/turf/open/floor/plating/dirt/jungleland/toxic_pit
	icon_state = "toxic_pit"
	icon_plating = "toxic_pit"
	icon_state_regular_floor = "toxic_pit" 

/turf/open/floor/plating/dirt/jungleland/dry_swamp1
	icon_state = "dry_swamp1"
	icon_plating = "dry_swamp1"
	icon_state_regular_floor = "dry_swamp1" 

/turf/open/floor/plating/dirt/jungleland/dying_forest
	icon_state = "dying_forest"
	icon_plating = "dying_forest"
	icon_state_regular_floor = "dying_forest" 

/turf/open/floor/plating/dirt/jungleland/jungle
	icon_state = "jungle"
	icon_plating = "jungle"
	icon_state_regular_floor = "jungle" 

/turf/open/water/toxic_pit
	name = "sulphuric pit"
	color = "#00c167"
	slowdown = 2
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/toxic_pit

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

/turf/closed/mineral/ash_rock/jungle
	turf_type = /turf/open/floor/plating/jungle_baseturf
	baseturfs = /turf/open/floor/plating/jungle_baseturf
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS

/turf/open/water/tar_basin
	name = "tar basin"
	color = "#680047"
	slowdown = 4
	initial_gas_mix = JUNGLELAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturfs = /turf/open/water/tar_basin

