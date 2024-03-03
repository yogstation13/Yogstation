/turf/closed
	layer = CLOSED_TURF_LAYER
	plane = WALL_PLANE
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	flags_1 = RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	turf_flags = IS_SOLID
	rad_insulation = RAD_MEDIUM_INSULATION

/turf/closed/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/closed/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/closed/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && (mover.pass_flags & PASSCLOSEDTURF))
		return TRUE
