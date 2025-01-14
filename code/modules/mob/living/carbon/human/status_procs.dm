
/mob/living/carbon/human/Stun(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount) * physiology.knockdown_mod
	return ..()

/mob/living/carbon/human/Paralyze(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Immobilize(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= (rand(125, 130) * 0.01)
	if(HAS_TRAIT(src, TRAIT_LIGHT_SLEEPER))
		amount *= 0.75
	return ..()

/mob/living/carbon/human/Sleeping(amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= (rand(125, 130) * 0.01)
	if(HAS_TRAIT(src, TRAIT_LIGHT_SLEEPER))
		amount *= 0.75
	return ..()

/mob/living/carbon/human/cure_husk(list/sources)
	. = ..()
	if(.)
		update_body_parts()

/mob/living/carbon/human/become_husk(source)
	if(HAS_TRAIT(src, TRAIT_NO_HUSK)) //skeletons shouldn't be husks.
		cure_husk()
		return
	. = ..()
	if(.)
		update_body_parts()
