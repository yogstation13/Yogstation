// -- Pain modifiers. --
// Species pain modifiers.
/datum/species/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	if(isnum(species_pain_mod) && species_pain_mod != 1)
		C.set_pain_mod(PAIN_MOD_SPECIES, species_pain_mod)

/datum/species/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	C.unset_pain_mod(PAIN_MOD_SPECIES)

// Eternal youth gives a small bonus pain mod.
/datum/symptom/youth/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	switch(A.stage)
		if(5)
			A.affected_mob.set_pain_mod(name, 0.9)

/datum/symptom/youth/End(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	A.affected_mob.unset_pain_mod(name)

// Some Traumas

/datum/brain_trauma/special/tenacity/on_gain()
	. = ..()
	owner.set_pain_mod(name, 0)

/datum/brain_trauma/special/tenacity/on_lose()
	owner.unset_pain_mod(name)
	return ..()

// Near death experience
/mob/living/carbon/human/set_health(new_value)
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_KNOCKEDOUT, CRIT_HEALTH_TRAIT))
		src.add_mood_event("near-death", /datum/mood_event/deaths_door)
		set_pain_mod(PAIN_MOD_NEAR_DEATH, 0.1)
	else
		src.clear_mood_event("near-death")
		unset_pain_mod(PAIN_MOD_NEAR_DEATH)

// Stasis gives you a pain modifier and stops pain decay
//
// This is kind of a cop-out, I admit:
// Loigcally, you shouldn't feel any pain on stasis, since all of your body systems are frozen
// However, for balance this kneecaps surgery by making it a no-brainer to use stasis
//
// As a result, I'm opting to add just a "decent" pain modifier instead
/datum/status_effect/grouped/stasis/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.set_pain_mod(id, 0.5)

/datum/status_effect/grouped/stasis/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.unset_pain_mod(id)
	return ..()

// Determination gives a hefty pain modifier
/datum/status_effect/determined/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.set_pain_mod(id, 0.625)
	ADD_TRAIT(owner, TRAIT_NO_PAIN_EFFECTS, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_NO_SHOCK_BUILDUP, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/determined/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.unset_pain_mod(id)
	REMOVE_TRAIT(owner, TRAIT_NO_PAIN_EFFECTS, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_NO_SHOCK_BUILDUP, TRAIT_STATUS_EFFECT(id))
	return ..()

// Fake healthy is supposed to mimic feeling no pain
/datum/status_effect/grouped/screwy_hud/fake_healthy/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NO_PAIN_EFFECTS, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/grouped/screwy_hud/fake_healthy/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NO_PAIN_EFFECTS, TRAIT_STATUS_EFFECT(id))

// Being drunk gives a slight one, note the actual reagent gives one based on its strength
/datum/status_effect/inebriated/drunk/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.set_pain_mod(id, 0.9)

/datum/status_effect/inebriated/drunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.unset_pain_mod(id)
	return ..()

// Being drowsy gives a very slight one
/datum/status_effect/drowsiness/on_apply()
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.set_pain_mod(id, 0.95)

/datum/status_effect/drowsiness/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.unset_pain_mod(id)
	return ..()
