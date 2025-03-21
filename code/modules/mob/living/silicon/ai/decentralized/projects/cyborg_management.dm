

/datum/ai_project/cyborg_management_basic
	name = "Cyborg Management Basics"
	description = "This research functions as a prerequisite for other cyborg research such as remote unlock and remote module reset."
	research_cost = 2500
	can_be_run = FALSE
	category = AI_PROJECT_CYBORG

/datum/ai_project/cyborg_management_unlock
	name = "Cyborg Management - Unlock"
	description = "Mimicking a robotics console, generates and sends a one-time use signal that can unlock an active connected cyborg."
	research_cost = 2500
	research_requirements_text = "Cyborg Management Basics"
	research_requirements = list(/datum/ai_project/cyborg_management_basic)
	category = AI_PROJECT_CYBORG
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/remote_unlock
	ability_recharge_cost = 2500

/datum/ai_project/cyborg_management_unlock/finish()
	add_ability(ability_path)

/datum/action/innate/ai/ranged/remote_unlock
	name = "Unlock Cyborg"
	desc = "Unlock an active connected cyborg."
	button_icon = 'icons/mob/actions/actions_flightsuit.dmi' // Better sprites welcome.
	button_icon_state = "flightsuit_lock"
	uses = 1
	delete_on_empty = FALSE
	enable_text = span_notice("You mimick and prepare to send one-time code used by robotics consoles. Click an active connected cyborg to unlock them.")
	disable_text = span_notice("You decide not to send the one-time code.")

/datum/action/innate/ai/ranged/remote_unlock/do_ability(mob/living/caller_but_not_a_byond_built_in_proc, params, atom/clicked_on)
	if(!iscyborg(clicked_on))
		to_chat(owner, span_warning("You can only unlock cyborgs!"))
		return FALSE
	if(!isAI(caller_but_not_a_byond_built_in_proc))
		CRASH("Non-AI has /remote_unlock ability!")

	var/mob/living/silicon/robot/cyborg = clicked_on
	var/mob/living/silicon/ai/ai = caller_but_not_a_byond_built_in_proc
	if(cyborg.stat == DEAD)
		to_chat(ai, span_warning("You cannot unlock dead cyborgs!"))
		return FALSE
	if(!(cyborg in ai.connected_robots))
		to_chat(ai, span_warning("You cannot unlock unconnected cyborgs!"))
		return FALSE
	if(!cyborg.lockcharge)
		to_chat(ai, span_warning("This cyborg is not locked down!"))
		return FALSE

	unset_ranged_ability(ai)
	adjust_uses(-1)

	to_chat(ai, span_notice("You send the one-time code toward [cyborg]."))
	cyborg.SetLockdown(FALSE)

	playsound(cyborg, 'sound/machines/twobeep.ogg', 50, 0)
	cyborg.audible_message(span_danger("You hear beeps coming from [cyborg]!"))
	return TRUE

/datum/ai_project/cyborg_management_reset
	name = "Cyborg Management - Reset"
	description = "With a specially tailored program, tricks a connected cyborg's module connection into believing it was briefly disconnected which triggers a module reset." // Weak flavor.
	research_cost = 2500
	research_requirements_text = "Cyborg Management Basics"
	research_requirements = list(/datum/ai_project/cyborg_management_basic)
	category = AI_PROJECT_CYBORG
	can_be_run = FALSE
	ability_path = /datum/action/innate/ai/ranged/remote_reset
	ability_recharge_cost = 2500

/datum/ai_project/cyborg_management_reset/finish()
	add_ability(ability_path)

/datum/action/innate/ai/ranged/remote_reset
	name = "Reset Cyborg Module"
	desc = "Triggers a module reset on an active connected cyborg."
	button_icon = 'icons/mob/actions/actions_revenant.dmi' // Better sprites welcome.
	button_icon_state = "malfunction"
	uses = 1
	delete_on_empty = FALSE
	enable_text = span_notice("You prepare to upload and run to a special program to a cyborg. Click an active connected cyborg to reset them.")
	disable_text = span_notice("You decide not to upload the program.")

/datum/action/innate/ai/ranged/remote_reset/do_ability(mob/living/caller_but_not_a_byond_built_in_proc, params, atom/clicked_on)
	if(!iscyborg(clicked_on))
		to_chat(owner, span_warning("You can only reset cyborgs!"))
		return FALSE
	if(!isAI(caller_but_not_a_byond_built_in_proc))
		CRASH("Non-AI has /remote_reset ability!")

	var/mob/living/silicon/robot/cyborg = clicked_on
	var/mob/living/silicon/ai/ai = caller_but_not_a_byond_built_in_proc
	if(cyborg.stat == DEAD)
		to_chat(ai, span_warning("You cannot reset dead cyborgs!"))
		return FALSE
	if(!(cyborg in ai.connected_robots))
		to_chat(ai, span_warning("You cannot reset unconnected cyborgs!"))
		return FALSE
	if(!cyborg.has_module())
		to_chat(ai, span_warning("This cyborg hasn't selected a module yet!"))
		return FALSE

	unset_ranged_ability(ai)
	adjust_uses(-1)

	to_chat(ai, span_notice("You upload and run a special program to [cyborg]."))
	cyborg.ResetModule(FALSE)

	playsound(cyborg, 'sound/machines/twobeep.ogg', 50, 0)
	cyborg.audible_message(span_danger("You hear beeps coming from [cyborg]!"))
	return TRUE
