/datum/action/cooldown/spell/pointed/collect_soul
	name = "Collect Soul"
	desc = "This ranged spell allows you to take the soul out of someone indebted to you.."

	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

	button_icon = 'icons/mob/actions/actions_devil.dmi'
	button_icon_state = "soulcollect"

	school = SCHOOL_TRANSMUTATION
	invocation = "P'y y'ur de'ts"
	invocation_type = INVOCATION_WHISPER

	active_msg = span_notice("You prepare to collect a soul...")
	cooldown_time = 1 MINUTES
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/collect_soul/is_valid_target(mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	var/datum/antagonist/devil/devil_datum = owner.mind.has_antag_datum(/datum/antagonist/devil)
	if(!devil_datum)
		return FALSE
	if(!target || !istype(target) || !target.mind)
		return FALSE
	if(target.stat != DEAD)
		target.balloon_alert(owner, "target has to be dead!")
		return FALSE
	var/datum/antagonist/infernal_affairs/agent_datum = target.mind.has_antag_datum(/datum/antagonist/infernal_affairs)
	if(!agent_datum)
		target.balloon_alert(owner, "not an agent!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/collect_soul/InterceptClickOn(mob/living/user, params, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!do_after(user, 10 SECONDS, target))
		target.balloon_alert(user, "interrupted!")
		return FALSE

	for(var/obj/item/paper/calling_card/card in target.get_all_contents())
		var/datum/antagonist/infernal_affairs/hunter_datum = card.signed_by_ref?.resolve()
		if(!hunter_datum)
			continue
		//Ensures that the card holder is actually a target.
		var/datum/antagonist/infernal_affairs/agent_datum = target.mind.has_antag_datum(/datum/antagonist/infernal_affairs)
		if(hunter_datum.active_objective.target != agent_datum.owner)
			continue
		target.balloon_alert(user, "soul ripped!")
		agent_datum.soul_harvested(hunter_datum)
		return TRUE
	
	target.balloon_alert(owner, "no card on target...")
	return FALSE
