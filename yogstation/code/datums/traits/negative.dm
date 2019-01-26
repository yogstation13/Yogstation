/datum/quirk/family_heirloom
	value = 0 // Yogs Made It Free and no longer mood locked
	mood_quirk = FALSE // Just Incase

////

/datum/quirk/unrobust
	name = "Unrobust"
	desc = "You lack having little physical strength or energy.! Instantly lose -20 maximum health"
	value = -2
	mob_trait = TRAIT_UNROBUST
	gain_text = "<span class='notice'>You feel so unrobust than usual.</span>"
	lose_text = "<span class='danger'>You feel more strong.</span>"

/datum/quirk/unrobust/on_spawn()
	var/mob/living/carbon/human/mob_tar = quirk_holder
	mob_tar.maxHealth -= 20
	mob_tar.health -= 20


