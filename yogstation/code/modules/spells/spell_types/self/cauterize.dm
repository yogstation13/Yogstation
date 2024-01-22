/datum/action/cooldown/spell/cauterize
	name = "Cauterize"
	desc = "Replace all brute/burn damage with burn damage, taken over time. Higher levels increases time taken to return back to original damage level."
	button_icon = 'yogstation/icons/mob/actions.dmi'
	button_icon_state = "cauterize"

	school = SCHOOL_TRANSMUTATION //not restoration!
	invocation = "AMOS INO!"
	invocation_type = INVOCATION_SHOUT

	cooldown_time = 80 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS
	var/cauterize_duration = 2 SECONDS
	spell_requirements = SPELL_REQUIRES_WIZARD_GARB

/datum/action/cooldown/spell/cauterize/cast(mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/total_dam = target.getBruteLoss() + target.getFireLoss()
	var/real_duration = cauterize_duration+((spell_level-1)*10) //60 at highest, same as cooldown
	target.adjustBruteLoss(-500)
	target.adjustFireLoss(-500)
	var/damage_per_tick = total_dam/real_duration
	if(total_dam>=100)
		to_chat(target, span_warning("You really feel like you should heal your burns!"))
	for(var/i in 1 to real_duration)
		addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon, adjustFireLoss), damage_per_tick), 1 SECONDS)

	return TRUE

/datum/spellbook_entry/cauterize
	name = "Cauterize"
	spell_type = /datum/action/cooldown/spell/cauterize
	category = "Defensive"
