
/datum/symptom/deaf
	name = "Dead Ear Syndrome"
	desc = "Kills the infected's aural senses."
	stage = 4
	max_multiplier = 5
	badness = EFFECT_DANGER_HINDRANCE

/datum/symptom/deaf/activate(mob/living/carbon/mob)
	var/obj/item/organ/internal/ears/ears = mob.get_organ_slot(ORGAN_SLOT_EARS)
	if(!ears)
		return //cutting off your ears to cure the deafness: the ultimate own
	to_chat(mob, span_userdanger("Your ears pop and begin ringing loudly!"))
	ears.deaf = min(20, ears.deaf + 15)

	if(prob(multiplier * 5))
		if(ears.damage < ears.maxHealth)
			to_chat(mob, span_userdanger("Your ears pop painfully and start bleeding!"))
			// Just absolutely murder me man
			ears.apply_organ_damage(ears.maxHealth)
			mob.emote("scream")
			ADD_TRAIT(mob, TRAIT_DEAF, type)

/datum/symptom/deaf/deactivate(mob/living/carbon/mob)
	REMOVE_TRAIT(mob, TRAIT_DEAF, type)
