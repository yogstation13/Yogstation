/datum/action/cooldown/bloodsucker/fortitude
	name = "Fortitude"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings."
	button_icon_state = "power_fortitude"
	power_explanation = "Fortitude:\n\
		Activating Fortitude will provide pierce, stun and dismember immunity.\n\
		You will additionally gain resistance to Brute and Stamina damge, scaling with level.\n\
		While using Fortitude, attempting to run will crush you.\n\
		At level 4, you gain complete stun immunity.\n\
		Higher levels will increase Brute and Stamina resistance."
	power_flags = BP_AM_TOGGLE | BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY
	purchase_flags = BLOODSUCKER_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 30
	cooldown_time = 8 SECONDS
	constant_bloodcost = 0.2
	sol_multiplier = 3
	var/was_running
	var/fortitude_resist // So we can raise and lower your brute resist based on what your level_current WAS.
	/// Base traits granted by fortitude.
	var/static/list/base_traits = list(
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_PUSHIMMUNE,
		TRAIT_NO_SPRINT,
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
	)
	/// Upgraded traits granted by fortitude.
	var/static/list/upgraded_traits = list(TRAIT_STUNIMMUNE, TRAIT_CANT_STAMCRIT)

/datum/action/cooldown/bloodsucker/fortitude/ActivatePower(trigger_flags)
	. = ..()
	owner.balloon_alert(owner, "fortitude turned on.")
	to_chat(owner, span_notice("Your flesh, skin, and muscles become as steel."))
	// Traits & Effects
	owner.add_traits(base_traits, FORTITUDE_TRAIT)
	if(level_current >= 4)
		owner.add_traits(upgraded_traits, FORTITUDE_TRAIT) // They'll get stun resistance + this, who cares.
	var/mob/living/carbon/human/bloodsucker_user = owner
	if(IS_BLOODSUCKER(owner) || IS_VASSAL(owner))
		fortitude_resist = max(0.3, 0.7 - level_current * 0.1)
		bloodsucker_user.physiology.brute_mod *= fortitude_resist
		bloodsucker_user.physiology.stamina_mod *= fortitude_resist

	was_running = ((owner.m_intent == MOVE_INTENT_RUN) || (owner.m_intent == MOVE_INTENT_SPRINT))
	if(was_running)
		bloodsucker_user.set_move_intent(MOVE_INTENT_WALK)

/datum/action/cooldown/bloodsucker/fortitude/process(seconds_per_tick)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	var/mob/living/carbon/user = owner
	/// Prevents running while on Fortitude
	if(user.m_intent != MOVE_INTENT_WALK)
		user.set_move_intent(MOVE_INTENT_WALK)
		user.balloon_alert(user, "you attempt to run, crushing yourself.")
		user.take_overall_damage(brute = rand(5, 15))
	/// We don't want people using fortitude being able to use vehicles
	if(istype(user.buckled, /obj/vehicle))
		user.buckled.unbuckle_mob(src, force=TRUE)

/datum/action/cooldown/bloodsucker/fortitude/DeactivatePower()
	if(ishuman(owner) && (IS_BLOODSUCKER(owner) || IS_VASSAL(owner)))
		var/mob/living/carbon/human/bloodsucker_user = owner
		bloodsucker_user.physiology.brute_mod /= fortitude_resist
		bloodsucker_user.physiology.stamina_mod /= fortitude_resist
	// Remove Traits & Effects
	owner.remove_traits(base_traits + upgraded_traits, FORTITUDE_TRAIT)

	if(was_running && owner.m_intent == MOVE_INTENT_WALK)
		owner.set_move_intent(MOVE_INTENT_RUN)
	owner.balloon_alert(owner, "fortitude turned off.")

	return ..()
