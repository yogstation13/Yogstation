//adds and removes the shadowlands overlay based on Z level
/datum/component/shadowlands
	dupe_mode = COMPONENT_DUPE_UNIQUE
	///The mob that gets the overlay applied to it
	var/mob/living/owner

/datum/component/shadowlands/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	owner = parent

/datum/component/shadowlands/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(update_fullscreen))
	update_fullscreen()

/datum/component/shadowlands/UnregisterFromParent()
	if(owner)
		owner.clear_fullscreen("shadowlands")
	UnregisterSignal(parent, COMSIG_MOVABLE_Z_CHANGED)
	return ..()

/datum/component/shadowlands/proc/update_fullscreen()
	if(!owner)
		return

	var/turf/location = get_turf(owner)
	if(!(is_centcom_level(location.z) || is_reserved_level(location.z)))
		owner.overlay_fullscreen("shadowlands", /atom/movable/screen/fullscreen/shadowlands)
	else
		owner.clear_fullscreen("shadowlands")

//the fullscreen in question
/atom/movable/screen/fullscreen/shadowlands
	icon_state = "shadowlands"
	layer = CURSE_LAYER
	plane = FULLSCREEN_PLANE
