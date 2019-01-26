//predominantly positive traits
//Yogs traits

/datum/quirk/robust
	name = "Robust"
	desc = "You are a strong and healthy! Instantly gain +15 maximum Health"
	value = 3
	mob_trait = TRAIT_ROBUST
	gain_text = "<span class='notice'>You feel more robust than usual.</span>"
	lose_text = "<span class='danger'>You feel less robust than usual.</span>"

/datum/quirk/robust/on_spawn()
	var/mob/living/carbon/human/mob_tar = quirk_holder
	mob_tar.maxHealth += 15
	mob_tar.health += 15