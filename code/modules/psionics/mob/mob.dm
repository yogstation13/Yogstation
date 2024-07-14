/mob/living
	var/datum/psi_complexus/psi

/mob/living/Login()
	. = ..()
	if(psi)
		psi.update(TRUE)
		if(!psi.suppressed)
			psi.show_auras()

/mob/living/Destroy()
	QDEL_NULL(psi)
	. = ..()

/mob/living/proc/set_psi_rank(faculty, rank, take_larger, defer_update, temporary)
	if(isipc(src))
		return
	if(!psi)
		psi = new(src)
	var/current_rank = psi.get_rank(faculty)
	if(current_rank != rank && (!take_larger || current_rank < rank))
		psi.set_rank(faculty, rank, defer_update, temporary)

/mob/living/carbon/human
	/// Whether or not it's tried to apply the species based latency
	var/tried_species = FALSE

/mob/living/carbon/human/Login() //happens here because psi sorta relies on the thing having a mind
	. = ..()
	if(HAS_TRAIT(src, TRAIT_PSIONICALLY_DEAFENED) || HAS_TRAIT(src, TRAIT_PSIONICALLY_IMMUNE))
		return
	if(!psi && !tried_species)
		tried_species = TRUE
		var/datum/species/dude = dna.species
		if(HAS_TRAIT(src, TRAIT_PSIONICALLY_TUNED))
			dude.latency_chance += 15

		var/list/latencies = dude.possible_faculties
		latencies = latencies.Copy()
		if(!length(latencies))
			return

		if(prob(dude.latency_chance))
			set_psi_rank(pick_n_take(latencies), dude.starting_psi_level)
			
		if(!length(latencies) || !HAS_TRAIT(src, TRAIT_PSIONICALLY_TUNED))
			return

		if(prob(dude.latency_chance * 0.1)) //really low chance of getting two if you're tuned
			set_psi_rank(pick(latencies), dude.starting_psi_level)

