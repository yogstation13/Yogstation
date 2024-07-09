/datum/psi_complexus/proc/rebuild_power_cache()
	if(rebuild_power_cache)

		learned_powers =         list()
		powers_by_faculty =    list()

		for(var/faculty in ranks)
			var/relevant_rank = get_rank(faculty)
			var/datum/psionic_faculty/faculty_decl = SSpsi.get_faculty(faculty)
			for(var/P in faculty_decl.powers)
				var/datum/psionic_power/power = P
				if(!power.min_rank) //if a minimum rank wasn't set, it's probably either bad coding or a parent used for typepathing, so don't include it
					continue

				if(relevant_rank >= power.min_rank)
					LAZYADD(powers_by_faculty[power.faculty], power)
					LAZYADD(learned_powers, power)
		rebuild_power_cache = FALSE

/datum/psi_complexus/proc/get_powers_by_faculty(faculty)
	rebuild_power_cache()
	return powers_by_faculty[faculty]
