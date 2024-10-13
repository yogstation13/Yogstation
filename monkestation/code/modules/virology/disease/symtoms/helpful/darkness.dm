/datum/symptom/darkness
	name = "Nocturnal Regeneration"
	desc = "The virus is able to mend the host's flesh when in conditions of low light, repairing physical damage. More effective against brute damage."
	max_multiplier = 8
	stage = 3
	max_chance = 33
	var/passive_message = span_notice("You feel tingling on your skin as light passes over it.")

/datum/symptom/darkness/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	switch(round(multiplier))
		if(4, 5, 6, 7, 8)
			if(!CanHeal(mob))
				return
			if(passive_message_condition(mob))
				to_chat(mob, passive_message)
			Heal(mob, multiplier)
		else
			multiplier = min(multiplier + 0.1, max_multiplier)

/datum/symptom/darkness/proc/CanHeal(mob/living/carbon/mob)
	var/light_amount = 0
	if(isturf(mob.loc)) //else, there's considered to be no light
		var/turf/mob_turf = mob.loc
		light_amount = min(1, mob_turf.get_lumcount()) - 0.5
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			return power

/datum/symptom/darkness/proc/Heal(mob/living/carbon/victim, actual_power)
	var/heal_amt = 2 * actual_power
	var/list/parts = victim.get_damaged_bodyparts(brute = TRUE, burn = TRUE, required_bodytype = BODYTYPE_ORGANIC)
	if(!length(parts))
		return
	if(prob(5))
		to_chat(victim, span_notice("The darkness soothes and mends your wounds."))
	var/brute_heal = heal_amt / length(parts)
	var/burn_heal = brute_heal * 0.5
	victim.heal_overall_damage(brute = brute_heal, burn = burn_heal, required_bodytype = BODYTYPE_ORGANIC)
	return TRUE

/datum/symptom/darkness/proc/passive_message_condition(mob/living/victim)
	if(victim.getBruteLoss() || victim.getFireLoss())
		return TRUE
	return FALSE
