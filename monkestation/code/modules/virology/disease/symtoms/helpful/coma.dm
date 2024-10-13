/datum/symptom/coma
	name = "Regenerative Coma"
	desc = "The virus causes the host to fall into a death-like coma when severely damaged, then rapidly fixes the damage."
	max_multiplier = 15
	max_chance = 100
	stage = 3

	var/passive_message = span_notice("The pain from your wounds makes you feel oddly sleepy...")
	var/added_to_mob = FALSE
	var/active_coma = FALSE //to prevent multiple coma procs

/datum/symptom/coma/activate(mob/living/carbon/mob, datum/disease/advanced/disease)
	. = ..()
	if(!added_to_mob && max_multiplier >= 12)
		added_to_mob = TRUE
		ADD_TRAIT(mob, TRAIT_NOCRITDAMAGE, type)

	var/effectiveness = CanHeal(mob)
	if(!effectiveness)
		return
	if(passive_message_condition(mob))
		to_chat(mob, passive_message)
	Heal(mob, effectiveness)
	return

/datum/symptom/coma/side_effect(mob/living/mob)
	if(active_coma)
		uncoma()
	if(!added_to_mob)
		return
	REMOVE_TRAIT(mob, TRAIT_NOCRITDAMAGE, type)

/datum/symptom/coma/proc/CanHeal(mob/living/victim)
	if(HAS_TRAIT(victim, TRAIT_DEATHCOMA))
		return multiplier
	if(victim.IsSleeping())
		return multiplier * 0.25 //Voluntary unconsciousness yields lower healing.
	switch(victim.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			return multiplier * 0.9
		if(SOFT_CRIT)
			return multiplier * 0.5
	if((victim.getBruteLoss() + victim.getFireLoss()) >= 70 && !active_coma)
		to_chat(victim, span_warning("You feel yourself slip into a regenerative coma..."))
		active_coma = TRUE
		addtimer(CALLBACK(src, PROC_REF(coma), victim), 6 SECONDS)
	return FALSE

/datum/symptom/coma/proc/coma(mob/living/victim)
	if(QDELETED(victim) || victim.stat == DEAD)
		return
	victim.fakedeath("regenerative_coma", TRUE)
	addtimer(CALLBACK(src, PROC_REF(uncoma), victim), 30 SECONDS)

/datum/symptom/coma/proc/uncoma(mob/living/victim)
	if(QDELETED(victim) || !active_coma)
		return
	active_coma = FALSE
	victim.cure_fakedeath("regenerative_coma")

/datum/symptom/coma/proc/Heal(mob/living/carbon/victim, actual_power)
	var/list/parts = victim.get_damaged_bodyparts(brute = TRUE, burn = TRUE)
	if(!length(parts))
		return
	var/heal_amt = (4 * actual_power) / length(parts)
	victim.heal_overall_damage(brute = heal_amt, burn = heal_amt)
	if(active_coma && (victim.getBruteLoss() + victim.getFireLoss()) == 0)
		uncoma(victim)
	return TRUE

/datum/symptom/coma/proc/passive_message_condition(mob/living/victim)
	if((victim.getBruteLoss() + victim.getFireLoss()) > 30)
		return TRUE
	return FALSE
