/mob/living/simple_animal/drone
	ignores_capitalism = TRUE // Yogs -- Lets drones buy a damned smoke for christ's sake

/mob/living/simple_animal/drone/Initialize()
	.=..()
	add_trait(TRAIT_PACIFISM, JOB_TRAIT)
	add_trait(TRAIT_NOGUNS, JOB_TRAIT) //fuck drones t. nich