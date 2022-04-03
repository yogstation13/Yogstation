/area/pregen
	name = "Pregenerated Space"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "pregen"
	map_generator = /datum/map_generator/jungleland
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/turf/open/floor/plating/dirt/jungleland
	name = "generic jungle land turf"
	desc = "pain"
	icon = 'yogstation/icons/turf/floors/jungle.dmi'
	icon_state = "jungle"

	var/can_spawn_ore = TRUE
	var/ore_present = ORE_EMPTY

/turf/open/floor/plating/dirt/jungleland/proc/spawn_rock()
	if(ore_present == ORE_EMPTY && !can_spawn_ore)
		return
	can_spawn_ore = FALSE
	add_overlay(image(icon='yogstation/icons/obj/jungle.dmi',icon_state="dug_spot",layer=BELOW_OBJ_LAYER))
	var/ore_type = GLOB.jungle_ores[ore_present]
	new ore_type(src)

/turf/open/floor/plating/dirt/jungleland/barren_rocks
	icon_state = "barren_rocks"

/turf/open/floor/plating/dirt/jungleland/toxic_rocks
	icon_state = "toxic_rocks"

/turf/open/floor/plating/dirt/jungleland/dry_swamp
	icon_state = "dry_swamp"

/turf/open/floor/plating/dirt/jungleland/toxic_pit
	icon_state = "toxic_pit"

/turf/open/floor/plating/dirt/jungleland/dying_forest
	icon_state = "dying_forest"

/turf/open/floor/plating/dirt/jungleland/jungle
	icon_state = "jungle"

/turf/open/floor/plating/dirt/jungleland/iron 
	icon_state = "iron"
	
/turf/open/floor/plating/dirt/jungleland/silver
	icon_state = "silver"

/turf/open/floor/plating/dirt/jungleland/titanium
	icon_state = "titanium"

/turf/open/floor/plating/dirt/jungleland/gold
	icon_state = "gold"

/turf/open/floor/plating/dirt/jungleland/uranium
	icon_state = "uranium"

/turf/open/floor/plating/dirt/jungleland/plasma
	icon_state = "plasma"

/turf/open/floor/plating/dirt/jungleland/diamond
	icon_state = "diamond"

/turf/open/floor/plating/dirt/jungleland/bluespace
	icon_state = "bluespace"

/turf/open/floor/plating/dirt/jungleland/nothing
	icon_state = "nothing"

/turf/open/water/toxic_pit
	name = "sulphuric pit"
	color = "#003a00"


