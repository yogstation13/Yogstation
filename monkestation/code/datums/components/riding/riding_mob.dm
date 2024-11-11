// Carps move 4x faster when ridden in space
/datum/component/riding/creature/carp/move_delay()
	. = ..()
	var/mob/living/living_parent = parent
	if(!living_parent.has_gravity())
		. *= 0.25
