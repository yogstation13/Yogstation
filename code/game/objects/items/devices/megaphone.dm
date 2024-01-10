/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/last_used = 0
	var/list/voicespan = list(SPAN_COMMAND)
	
/obj/item/megaphone/examine(mob/user)
	. = ..()
	if(last_used > world.time)
		. += span_warning("\The [src] is recharging!")

/obj/item/megaphone/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is uttering [user.p_their()] last words into \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	last_used = 0//so they dont have to worry about recharging
	user.say("AAAAAAAAAAAARGHHHHH", forced="megaphone suicide")//he must have died while coding this
	return OXYLOSS

/obj/item/megaphone/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/megaphone/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_HANDS)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/megaphone/proc/spamcheck()
	var/recharge_time = 5 SECONDS
	if(last_used > world.time)
		return FALSE
	last_used = world.time + recharge_time
	update_appearance(UPDATE_ICON)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_icon)), recharge_time)
	return TRUE

/obj/item/megaphone/update_overlays()
	. = ..()
	var/mutable_appearance/base_overlay
	if(last_used > world.time)
		base_overlay = mutable_appearance(icon, "megaphone_recharging")
	else
		base_overlay = mutable_appearance(icon, "megaphone_charged")
	. += base_overlay

/obj/item/megaphone/proc/handle_speech(mob/living/carbon/user, list/speech_args)
	if (user.get_active_held_item() == src)
		if(!spamcheck())
			to_chat(user, span_warning("\The [src] needs to recharge!"))
		else
			playsound(loc, 'sound/items/megaphone.ogg', 100, 0, 1)
			speech_args[SPEECH_SPANS] |= voicespan

/obj/item/megaphone/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	voicespan = list(SPAN_REALLYBIG, "userdanger")
	to_chat(user, span_warning("You overload \the [src]'s voice synthesizer."))
	return TRUE
	
/obj/item/megaphone/sec
	name = "security megaphone"
	icon_state = "megaphone-sec"

/obj/item/megaphone/command
	name = "command megaphone"
	icon_state = "megaphone-command"

/obj/item/megaphone/cargo
	name = "supply megaphone"
	icon_state = "megaphone-cargo"

/obj/item/megaphone/clown
	name = "clown's megaphone"
	desc = "Something that should not exist."
	icon_state = "megaphone-clown"
	voicespan = list(SPAN_CLOWN)
