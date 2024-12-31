/datum/antagonist/blob/infection/apply_innate_effects(mob/mob_override)
	. = ..()
	var/mob/target = mob_override || owner.current
	ADD_TRAIT(target, TRAIT_BLOB_ALLY, type)
