/**
 * Gets the mind from a variable, whether it be a mob, or a mind itself.
 * Also works on brains - it will try to fetch the brainmob's mind.
 * If [include_last] is true, then it will also return last_mind for carbons if there isn't a current mind.
 */
/proc/get_mind(target, include_last = FALSE) as /datum/mind
	RETURN_TYPE(/datum/mind)
	if(istype(target, /datum/mind))
		return target
	else if(ismob(target))
		var/mob/mob_target = target
		if(!QDELETED(mob_target.mind))
			return mob_target.mind
		if(include_last && iscarbon(mob_target))
			var/mob/living/carbon/carbon_target = mob_target
			if(!QDELETED(carbon_target.last_mind))
				return carbon_target.last_mind
	else if(istype(target, /obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/brain = target
		if(!QDELETED(brain.brainmob?.mind))
			return brain.brainmob.mind

/proc/is_late_arrival(mob/living/player)
	var/static/cached_result
	if(!isnull(cached_result))
		return cached_result
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_LATE_ARRIVALS) || (STATION_TIME_PASSED() > 1 MINUTES))
		return cached_result = FALSE
	if(QDELETED(player) || !istype(get_area(player), /area/shuttle/arrival))
		return FALSE
	return TRUE
