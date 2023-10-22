/datum/mutation/human/radproof
	name = "Radproof"
	desc = "Adapts the host's body to be better suited at preventing cancer caused by radioactivity at the expense of it's ability to handle toxic matter."
	quality = POSITIVE
	text_gain_indication = span_warning("You can't feel it in your bones!")
	instability = 35
	difficulty = 8

/datum/mutation/human/radproof/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_RADIMMUNE, type)
	owner.physiology.tox_mod *= 1.5

/datum/mutation/human/radproof/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_RADIMMUNE, type)
	owner.physiology.tox_mod /= 1.5
