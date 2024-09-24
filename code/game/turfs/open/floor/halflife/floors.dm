/turf/open/floor/plating/indoor
	gender = PLURAL
	name = "flooring"
	baseturfs = /turf/open/floor/plating/ground/dirt
	icon = 'icons/turf/halflifefloor/floors.dmi'
	attachment_holes = FALSE
	var/has_alternate_states = FALSE //for damage, alts etc.
	var/alternate_states = 1
	var/has_base_states = FALSE //for starting variety (mainly wood)
	var/base_states = 1

/turf/open/floor/plating/indoor/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	return

/turf/open/floor/plating/indoor/break_tile()
	return //unbreakable

/turf/open/floor/plating/indoor/burn_tile()
	return //unburnable

/turf/open/floor/plating/indoor/MakeSlippery(wet_setting, min_wet_time, wet_time_to_add, max_wet_time, permanent)
	return

/turf/open/floor/plating/indoor/MakeDry()
	return

/turf/open/floor/plating/indoor/can_have_cabling()
	return

/turf/open/floor/plating/indoor/wood
	name = "wood floor"
	icon_state = "wood"
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/plating/indoor/woodc
	name = "wood floor"
	icon_state = "wood_common"
	alternate_states = 7
	footstep = FOOTSTEP_WOOD
	barefootstep = FOOTSTEP_WOOD_BAREFOOT
	clawfootstep = FOOTSTEP_WOOD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	has_alternate_states = TRUE 
	has_base_states = TRUE 

/turf/open/floor/plating/indoor/grimy
	icon_state = "grimy"

/turf/open/floor/plating/indoor/showroom
	icon_state = "showroomfloor"

/turf/open/floor/plating/indoor/greentile
	icon_state = "greentile"

/turf/open/floor/plating/indoor/grooved
	icon_state = "grooved"

/turf/open/floor/plating/indoor/grooved2
	icon_state = "grooved2"

/turf/open/floor/plating/indoor/tiled9
	icon_state = "tiled9"

/turf/open/floor/plating/indoor/tiled10
	icon_state = "tiled10"


/turf/open/floor/plating/indoor/concrete
	icon_state = "concrete_big"
	desc = "Concrete slabs."
	has_alternate_states = TRUE
	alternate_states = 1
	footstep = FOOTSTEP_CONCRETE

/turf/open/floor/plating/indoor/concrete/bricks
	icon_state = "concrete_bricks"
	has_alternate_states = TRUE 
	has_base_states = TRUE
	alternate_states = 8

/turf/open/floor/plating/indoor/checkered
	icon_state = "checker_large"
	alternate_states = 3
	has_alternate_states = TRUE 
	has_base_states = TRUE

/turf/open/floor/plating/indoor/cafeteria
	icon_state = "cafe_large"
	alternate_states = 3
	has_alternate_states = TRUE 
	has_base_states = TRUE



/turf/open/floor/plating/indoor/tile
	icon_state = "grey"
	alternate_states = 8
	has_alternate_states = TRUE 
	has_base_states = TRUE

/turf/open/floor/plating/indoor/tile/navy
	icon_state = "navy"
	alternate_states = 3
	has_alternate_states = TRUE 
	has_base_states = TRUE



/turf/open/floor/plating/indoor/metal
	footstep = FOOTSTEP_PLATING 
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	icon_state = "steel_tiles"
	desc = "Metal flooring."

/turf/open/floor/plating/indoor/metal/plate
	icon_state = "steel_solid"

/turf/open/floor/plating/indoor/metal/grate
	icon_state = "steel_grate"

/turf/open/floor/plating/indoor/metal/pipe
	icon_state = "pipe_straight"

/turf/open/floor/plating/indoor/metal/pipe/corner
	icon_state = "pipe_corner"

/turf/open/floor/plating/indoor/metal/pipe/intersection
	icon_state = "pipe_intersection"

/turf/open/floor/plating/indoor/metal/plate
	icon_state = "steel_solid"

/turf/open/floor/plating/indoor/metal/grate
	icon_state = "steel_grate"

/turf/open/floor/plating/indoor/metal/grate/border
	icon_state = "steel_grate_border"

/turf/open/floor/plating/indoor/metal/grate/border/warning
	icon_state = "steel_grate_warning"

/turf/open/floor/plating/indoor/metal/walkway
	icon_state = "steel_walkway"

/turf/open/floor/plating/indoor/metal/walkway/corner
	icon_state = "steel_walkway_corner"

/turf/open/floor/plating/indoor/metal/walkway/end
	icon_state = "steel_walkway_end"

/turf/open/floor/plating/indoor/carpet
	name = "carpet"
	desc = "carpeted wooden flooring."
	icon_state = "carpet_fancy_red"
	footstep = FOOTSTEP_CARPET
	barefootstep = FOOTSTEP_CARPET_BAREFOOT
	clawfootstep = FOOTSTEP_CARPET_BAREFOOT
	has_alternate_states = FALSE
	flags_1 = NONE
	bullet_bounce_sound = null
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	tiled_dirt = FALSE
	has_base_states = FALSE

/turf/open/floor/plating/indoor/carpet/blue
	icon_state = "carpet_fancy_blue"

/turf/open/floor/plating/indoor/carpet/green
	icon_state = "carpet_fancy_green"

/turf/open/floor/plating/indoor/carpet/violet
	icon_state = "carpet_fancy_violet"

/turf/open/floor/plating/indoor/carpet/shaggy
	icon_state = "carpet_red"


/turf/open/floor/plating/indoor/carpet/shaggy/blue
	icon_state = "carpet_blue"


/turf/open/floor/plating/indoor/carpet/shaggy/green
	icon_state = "carpet_green"


/turf/open/floor/plating/indoor/carpet/shaggy/violet
	icon_state = "carpet_violet"
