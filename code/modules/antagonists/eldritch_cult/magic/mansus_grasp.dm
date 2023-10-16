/datum/action/cooldown/spell/touch/mansus_grasp
	name = "Mansus Grasp"
	desc = "A powerful combat initiation spell that deals massive stamina damage. It may have other effects if you continue your research..."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_EVOCATION
	cooldown_time = 10 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/touch_attack/mansus_fist

/datum/action/cooldown/spell/touch/mansus_grasp/is_valid_target(atom/cast_on)
	return TRUE // This baby can hit anything

/datum/action/cooldown/spell/touch/mansus_grasp/can_cast_spell(feedback = TRUE)
	return ..() && !!IS_HERETIC(owner)

/datum/action/cooldown/spell/touch/mansus_grasp/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of [victim]!"),
		span_danger("The spell bounces off of you!"),
	)

/datum/action/cooldown/spell/touch/mansus_grasp/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
//	if(!isliving(victim)) for now, makes heretic hand hit everything but it's for the best
//		return FALSE

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return FALSE

	if(isliving(victim))
		var/mob/living/living_hit = victim
		living_hit.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
		if(iscarbon(victim))
			var/mob/living/carbon/carbon_hit = victim
			carbon_hit.adjust_timed_status_effect(4 SECONDS, /datum/status_effect/speech/slurring/heretic)
			carbon_hit.AdjustKnockdown(5 SECONDS)
			carbon_hit.adjustStaminaLoss(80)

	return TRUE

/obj/item/melee/touch_attack/mansus_fist
	name = "Mansus Grasp"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes knockdown, minor bruises, and major stamina damage. \
		It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus"
	item_state = "mansus"

/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] effortlessly snaps [user.p_their()] fingers near [A], igniting it with eldritch energies. Fucking badass!")
	remove_hand_with_no_refund(user)
