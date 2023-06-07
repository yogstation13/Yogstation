/datum/mutation/human/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = span_notice("You feel power flow through your hands.")
	text_lose_indication = span_notice("The energy in your hands subsides.")
	power_path = /datum/action/cooldown/spell/touch/shock
	instability = 20
	locked = TRUE
	conflicts = list(/datum/mutation/human/shock/far, /datum/mutation/human/insulated)

/datum/action/cooldown/spell/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	hand_path = /obj/item/melee/touch_attack/shock
	button_icon_state = "zap"
	sound = 'sound/weapons/zapbang.ogg'
	cooldown_time = 10 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	button_icon = 'icons/mob/actions/humble/actions_humble.dmi'
	draw_message = span_notice("You channel electricity into your hand.")
	drop_message = span_notice("You let the electricity from your hand dissipate.")


/datum/action/cooldown/spell/touch/shock/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		if(carbon_victim.electrocute_act(15, caster, 1, stun = FALSE))//doesnt stun. never let this stun
			carbon_victim.dropItemToGround(carbon_victim.get_active_held_item())
			carbon_victim.dropItemToGround(carbon_victim.get_inactive_held_item())
			carbon_victim.adjust_timed_status_effect(15 SECONDS, /datum/status_effect/confusion)
			carbon_victim.visible_message(
				span_danger("[caster] electrocutes [victim]!"),
				span_userdanger("[caster] electrocutes you!"),
			)
			return TRUE

	else if(isliving(victim))
		var/mob/living/living_victim = victim
		if(living_victim.electrocute_act(15, caster, 1, stun = FALSE))
			living_victim.visible_message(
				span_danger("[caster] electrocutes [victim]!"),
				span_userdanger("[caster] electrocutes you!"),
			)
			return TRUE

	to_chat(caster, span_warning("The electricity doesn't seem to affect [victim]..."))
	return TRUE

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	icon_state = "zapper"
	item_state = "zapper"
	var/far = FALSE

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!(proximity || far) || !can_see(user, target, 5) || get_dist(target, user) > 5)
		user.visible_message(span_notice("[user]'s hand reaches out but nothing happens."))
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, FALSE, FALSE))//doesnt stun. never let this stun
			user.Beam(C, icon_state="red_lightning", time = 1.5 SECONDS)
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.adjust_confusion(15 SECONDS)
			C.visible_message(span_danger("[user] electrocutes [target]!"),span_userdanger("[user] electrocutes you!"))
		else
			user.visible_message(span_warning("[user] fails to electrocute [target]!"))
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, FALSE)
		user.Beam(L, icon_state="red_lightning", time = 1.5 SECONDS)
		L.visible_message(span_danger("[user] electrocutes [target]!"),span_userdanger("[user] electrocutes you!"))
	else
		to_chat(user,span_warning("The electricity doesn't seem to affect [target]..."))
	remove_hand_with_no_refund(user)
	return ..()
