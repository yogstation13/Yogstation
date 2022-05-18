//Here are the procs used to modify status effects of a mob.
//The effects include: stun, knockdown, unconscious, sleeping, resting, jitteriness, dizziness, ear damage,
// eye damage, eye_blind, eye_blurry, druggy, TRAIT_BLIND trait, and TRAIT_NEARSIGHT trait.

/////////////////////////////////// STUN ////////////////////////////////////

/mob/living/carbon/alien/Stun(amount, updating = 1, ignore_canstun = 0)
	. = ..()

/mob/living/carbon/alien/SetStun(amount, updating = 1, ignore_canstun = 0)
	. = ..()

/mob/living/carbon/alien/AdjustStun(amount, updating = 1, ignore_canstun = 0)
	. = ..()
