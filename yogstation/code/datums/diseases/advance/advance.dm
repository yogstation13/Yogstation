/datum/disease/advance/Refresh(new_name)
	. = ..()
	if(affected_mob.dna)
		var/datum/species/S
		properties["resistance"] += S.virus_resistance_boost
		properties["stealth"] += S.virus_stealth_boost
		properties["stage_rate"] += S.virus_stage_rate_boost
		properties["transmittable"] += S.virus_transmittable_boost
	AssignProperties() //this is a bit inefficent because its called twice but modularization amiright?