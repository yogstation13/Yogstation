/datum/species/jelly/slime/on_species_loss(mob/living/carbon/C)
	UnregisterSignal(C, COMSIG_ALT_CLICK_ON, .proc/handle_altclick)
	..()

/datum/species/jelly/slime/on_species_gain(mob/living/carbon/C)
	..()
	// Guess what I'm doing
	// using component signals on something that isn't a component
	// maybe we shouldn't call them component signals if they can be used for other things, maybe...
	// hmmm.... what if we called it an event handler like any sane environment.
	RegisterSignal(C, COMSIG_ALT_CLICK_ON, .proc/handle_altclick)

/datum/species/jelly/slime/proc/handle_altclick(mob/living/carbon/human/M, mob/living/carbon/human/target)
	if(M && M.mind && swap_body && swap_body.can_swap(target))
		swap_body.swap_to_dupe(M.mind, target)
		return TRUE
