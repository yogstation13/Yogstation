/datum/action/cooldown/spell/pointed/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "cluwne"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cluwne_target.dmi'

	school = SCHOOL_TRANSMUTATION
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = INVOCATION_SHOUT

	base_icon_state = "cluwne"
	cast_range = 3
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 12.5 SECONDS

/datum/action/cooldown/spell/pointed/cluwnecurse/is_valid_target(atom/cast_on)
	if(!ishuman(cast_on))
		to_chat(owner, span_notice("You are unable to curse [cast_on]!"))
		return FALSE
	var/mob/living/target = cast_on
	if(target.anti_magic_check())
		to_chat(owner, span_notice("They didn't laugh!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/cluwnecurse/InterceptClickOn(mob/living/caller, params, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	target.cluwneify()
	return TRUE

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /datum/action/cooldown/spell/pointed/cluwnecurse
