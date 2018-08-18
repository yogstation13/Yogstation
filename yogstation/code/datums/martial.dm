/datum/martial_art/
	var/constant_block = 0 // CONSTANT block chance, rather than requiring to have thrown mode on


/mob/living/carbon/human/check_block()  // i dont wanna make a whole new fucking file just for this
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.constant_block) && mind.martial_art.can_use(src) && !incapacitated(FALSE, TRUE))
			return TRUE
	..()