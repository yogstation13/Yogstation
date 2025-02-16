/datum/antagonist/valentine/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/lover = mob_override || owner.current
	lover.faction |= "[REF(date.current)]"
	lover.faction |= date.current.faction
	date.current.faction |= lover.faction
	date.current.faction |= "[REF(lover)]" // ensure they always have our faction even during body changes

/datum/antagonist/valentine/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/lover = mob_override || owner.current
	// no clean way to ensure that we don't mess up faction assignments unrelated to valentines, so I guess they get to keep their factions obtained through tough love
	lover?.faction -= "[REF(date.current)]"
	date.current?.faction -= "[REF(lover)]"
