/datum/action/cooldown/spell/toggle/flow
	name = "Flow"
	desc = "Use the arts to Flow, giving shove and stun immunity, as well as brute, burn, dismember and pierce resistance. You cannot run while this is active."
	background_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	background_icon_state = "vamp_power_off"
	button_icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	button_icon_state = "power_fortitude"
	buttontooltipstyle = "cult"
	
	check_flags = null
	cooldown_time = 8 SECONDS
	var/was_running
	var/resist_multiplier = 0.4
	var/list/granted_traits = list(TRAIT_PIERCEIMMUNE, TRAIT_NODISMEMBER, TRAIT_PUSHIMMUNE, TRAIT_NOVEHICLE, TRAIT_STUNIMMUNE)

/datum/action/cooldown/spell/toggle/flow/process()
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/carbon/user = owner
	if(istype(user) && user.m_intent != MOVE_INTENT_WALK)
		user.toggle_move_intent()
		user.balloon_alert(user, "you attempt to run, crushing yourself.")
		user.adjustBruteLoss(rand(5,15))
		
/datum/action/cooldown/spell/toggle/flow/Enable()
	. = ..()
	to_chat(owner, span_notice("Your flesh, skin, and muscles become as steel."))
	
	var/mob/living/carbon/human/dude = owner
	dude.physiology.brute_mod *= resist_multiplier
	dude.physiology.burn_mod *= resist_multiplier
	owner.add_traits(granted_traits, type)

	was_running = (owner.m_intent == MOVE_INTENT_RUN)
	if(was_running)
		dude.toggle_move_intent()

/datum/action/cooldown/spell/toggle/flow/Disable()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/dude = owner
	dude.physiology.brute_mod /= resist_multiplier
	dude.physiology.burn_mod /= resist_multiplier
	dude.remove_traits(granted_traits, type)

	if(was_running && dude.m_intent == MOVE_INTENT_WALK)
		dude.toggle_move_intent()
	return ..()
