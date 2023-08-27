

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, attack_direction = null)
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, wound_bonus, bare_wound_bonus, sharpness, attack_direction)

/mob/living/carbon/human/revive(full_heal = 0, admin_revive = 0)
	if(..())
		if(dna && dna.species)
			dna.species.spec_revival(src, admin_revive) 
