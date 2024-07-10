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
	if(!psi && !tried_species)
		tried_species = TRUE
		var/datum/species/dude = dna.species
		var/latency_chance = dude.latency_chance
		if(HAS_TRAIT(dude, TRAIT_PSIONICALLY_TUNED))
			latency_chance = min(latency_chance + 15, 100)
		else if(HAS_TRAIT(dude, TRAIT_PSIONICALLY_DEAFENED))
			latency_chance = 0
		if(prob(latency_chance))
			set_psi_rank(pick(dude.possible_faculties), dude.starting_psi_level)
