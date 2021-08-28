

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE)
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, wound_bonus, bare_wound_bonus, sharpness)
