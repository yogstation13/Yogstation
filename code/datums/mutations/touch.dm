/datum/mutation/human/shock
	name = "Shock Touch"
	desc = "The affected can channel excess electricity through their hands without shocking themselves, allowing them to shock others."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = span_notice("You feel power flow through your hands.")
	text_lose_indication = span_notice("The energy in your hands subsides.")
	power = /obj/effect/proc_holder/spell/targeted/touch/shock
	instability = 20
	locked = TRUE

/obj/effect/proc_holder/spell/targeted/touch/shock
	name = "Shock Touch"
	desc = "Channel electricity to your hand to shock people with."
	drawmessage = "You channel electricity into your hand."
	dropmessage = "You let the electricity from your hand dissipate."
	hand_path = /obj/item/melee/touch_attack/shock
	charge_max = 100
	clothes_req = FALSE
	antimagic_allowed = TRUE
	icon = 'icons/mob/actions/humble/actions_humble.dmi'
	action_icon_state = "zap"

/obj/item/melee/touch_attack/shock
	name = "\improper shock touch"
	desc = "This is kind of like when you rub your feet on a shag rug so you can zap your friends, only a lot less safe."
	catchphrase = null
	on_use_sound = 'sound/weapons/zapbang.ogg'
	icon_state = "zapper"
	item_state = "zapper"
	var/far = FALSE

/obj/item/melee/touch_attack/shock/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!(proximity || far) || !can_see(user, target, 5) || get_dist(target, user) > 5)
		user.visible_message("<span class='notice'>[user]'s hand reaches out but nothing happens.</span>")
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, FALSE, FALSE))//doesnt stun. never let this stun
			user.Beam(C, icon_state="red_lightning", time=15)
			C.dropItemToGround(C.get_active_held_item())
			C.dropItemToGround(C.get_inactive_held_item())
			C.confused += 15
			C.visible_message(span_danger("[user] electrocutes [target]!"),span_userdanger("[user] electrocutes you!"))
			return ..()
		else
			user.visible_message(span_warning("[user] fails to electrocute [target]!"))
			return ..()
	else if(isliving(target))
		var/mob/living/L = target
		L.electrocute_act(15, src, 1, FALSE, FALSE, FALSE, FALSE)
		user.Beam(L, icon_state="red_lightning", time=15)
		L.visible_message(span_danger("[user] electrocutes [target]!"),span_userdanger("[user] electrocutes you!"))
		return ..()
	else
		to_chat(user,span_warning("The electricity doesn't seem to affect [target]..."))
		return ..()
