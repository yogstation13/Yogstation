/datum/action/cooldown/spell/pointed/guardian
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/guardian/proc/Finished()
	StartCooldown()
	unset_click_ability(owner)

/datum/action/cooldown/spell/pointed/guardian/InterceptClickOn(mob/living/caller_but_not_a_byond_built_in_proc, params, atom/t)
	if (!isliving(t))
		to_chat(caller_but_not_a_byond_built_in_proc, span_warning("You may only use this ability on living things!"))
		return FALSE
	return TRUE
