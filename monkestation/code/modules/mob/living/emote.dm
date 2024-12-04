/datum/emote/living/laugh/run_emote(mob/user, params, type_override, intentional = FALSE)
	. = ..()
	if (HAS_TRAIT(user, TRAIT_FEEBLE))
		feeble_quirk_wound_chest(user)
