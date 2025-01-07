/datum/action/cooldown/mob_cooldown/riot/make_minion(mob/living/new_minion, minion_desc, list/command_list = mouse_commands)
	. = ..()
	ADD_TRAIT(new_minion, TRAIT_VIRUSIMMUNE, REF(owner))
