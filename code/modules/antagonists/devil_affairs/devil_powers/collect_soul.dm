/datum/action/cooldown/spell/pointed/collect_soul
	name = "Collect Soul"
	desc = "This ranged spell allows you to take the soul out of someone indebted to you.."
//	base_icon_state = "ignite"

	background_icon_state = "bg_demon"
	overlay_icon_state = "ab_goldborder"

	school = SCHOOL_TRANSMUTATION
	invocation = "P'y y'ur de'ts"
	invocation_type = INVOCATION_WHISPER

	active_msg = span_notice("You prepare to collect a soul...")
	sound = 'sound/magic/fireball.ogg'
	cooldown_time = 1 MINUTES
	spell_requirements = NONE

/datum/action/cooldown/spell/pointed/collect_soul/is_valid_target(mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!target || !istype(target) || !target.mind)
		return FALSE
	if(target.stat != DEAD)
		target.balloon_alert(owner, "target has to be dead!")
		return FALSE
	var/datum/antagonist/devil/devil_datum = owner.mind.has_antag_datum(/datum/antagonist/infernal_affairs)
	if(!devil_datum)
		return FALSE
	var/datum/antagonist/infernal_affairs/agent_datum = target.mind.has_antag_datum(/datum/antagonist/infernal_affairs)
	if(!agent_datum)
		target.balloon_alert(user, "not an agent!")
		return FALSE
	var/obj/item/paper/calling_card/card = locate() in target.get_all_contents()
	if(!card)
		target.balloon_alert(owner, "no card found!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/collect_soul/InterceptClickOn(mob/living/user, params, mob/living/target)
	. = ..()
	if(!.)
		return FALSE
	if(!do_after(user, 10 SECONDS, target))
		target.balloon_alert(user, "interrupted!")
		return FALSE

	var/obj/item/paper/calling_card/card = locate() in target.get_all_contents()
	//safety
	if(!card)
		target.balloon_alert(owner, "no card found!")
		return FALSE

	target.balloon_alert(user, "soul ripped!")
	var/datum/antagonist/infernal_affairs/agent_datum = target.mind.has_antag_datum(/datum/antagonist/infernal_affairs)
	var/datum/antagonist/infernal_affairs/hunter_datum = card.signed_by_ref?.resolve()
	agent_datum.soul_harvested(hunter_datum)
	return TRUE
