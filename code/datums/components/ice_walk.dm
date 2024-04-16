/datum/component/ice_walk
	var/mob/living/carbon/freezefoot

/datum/component/ice_walk/Initialize()
	RegisterSignals(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(frostwalk))
	freezefoot = parent

/datum/component/ice_walk/proc/frostwalk()
	if(!freezefoot.resting && !freezefoot.buckled) //s l i d e
		var/turf/open/OT = get_turf(freezefoot)
		if(isopenturf(OT))
			OT.MakeSlippery(TURF_WET_PERMAFROST, 10 SECONDS)
