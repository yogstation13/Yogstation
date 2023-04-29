/datum/action/cooldown/spell/pointed/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	base_icon_state = "cluwne"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cluwne_target.dmi'

	school = SCHOOL_TRANSMUTATION
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = INVOCATION_SHOUT

	cast_range = 3
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 12.5 SECONDS
	var/list/compatible_mobs = list(/mob/living/carbon/human)

/datum/action/cooldown/spell/pointed/cluwnecurse/InterceptClickOn(mob/living/caller, params, atom/click_target)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/target = click_target
	if(!(target.type in compatible_mobs))
		to_chat(owner, span_notice("You are unable to curse [target]!"))
		return FALSE
	if(target.anti_magic_check())
		to_chat(owner, span_notice("They didn't laugh!"))
		return FALSE
	var/mob/living/carbon/human/H = target
	H.cluwneify()
	return TRUE

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /datum/action/cooldown/spell/pointed/cluwnecurse
