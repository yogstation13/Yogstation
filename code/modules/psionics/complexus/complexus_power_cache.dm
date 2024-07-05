/datum/psi_complexus/proc/rebuild_power_cache()
	if(rebuild_power_cache)

		melee_powers =         list()
		ranged_powers =        list()
		manifestation_powers = list()
		powers_by_faculty =    list()

		for(var/faculty in ranks)
			var/relevant_rank = get_rank(faculty)
			var/datum/psionic_faculty/faculty_decl = SSpsi.get_faculty(faculty)
			for(var/P in faculty_decl.powers)
				var/datum/psionic_power/power = P
				if(relevant_rank >= power.min_rank)
					LAZYADD(powers_by_faculty[power.faculty], power)
					if(power.use_ranged)
						if(!ranged_powers[faculty]) 
							ranged_powers[faculty] = list()
						LAZYADD(ranged_powers[faculty], power)
					if(power.use_melee)
						LAZYADD(melee_powers[faculty], power)
					if(power.use_manifest)
						manifestation_powers += power
		rebuild_power_cache = FALSE

/datum/psi_complexus/proc/get_powers_by_faculty(faculty)
	rebuild_power_cache()
	return powers_by_faculty[faculty]

/datum/psi_complexus/proc/get_melee_powers(faculty)
	rebuild_power_cache()
	return melee_powers[faculty]

/datum/psi_complexus/proc/get_ranged_powers(faculty)
	rebuild_power_cache()
	return ranged_powers[faculty]

/datum/psi_complexus/proc/get_manifestations()
	rebuild_power_cache()
	return manifestation_powers
