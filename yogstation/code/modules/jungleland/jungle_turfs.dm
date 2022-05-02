/area/pregen
	name = "Pregenerated Space"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "pregen"
	map_generator = /datum/map_generator/jungleland
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	has_gravity = TRUE

/turf/open/floor/plating/dirt/jungleland
	name = "generic jungle land turf"
	desc = "pain"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "jungle"

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

/turf/open/water/toxic_pit/Entered(atom/movable/AM)
	. = ..()
	if(!ishuman(AM))
		return
	var/mob/living/carbon/human/humie = AM 
	var/chance = ((humie.wear_suit ? 100 - humie.wear_suit.armor.bio : 100)  +  (humie.head ? 100 - humie.head.armor.bio : 100) )/2
	if(prob(chance * 0.33))
		humie.apply_status_effect(/datum/status_effect/toxic_buildup)
