/mob/living/silicon/ai
	var/obj/item/ai_hijack_device/hijacking
	var/mutable_appearance/hijack_overlay
	var/hijack_start = 0

/mob/living/silicon/ai/proc/set_core_display_icon_yogs(input)
	var/datum/ai_skin/S = input

	for (var/each in GLOB.ai_core_displays) //change status of displays
		var/obj/machinery/status_display/ai_core/M = each
		M.set_ai(S.icon_state, S.icon)
		M.update()


/mob/living/silicon/ai/attack_hand(mob/user)
	if(hijacking)
		user.visible_message(span_danger("[user] attempts to disconnect the circuit board from [src]"), span_notice("There appears to be something connected to [src]'s ports! You attempt to disconnect it..."))
		if (do_after(user, 10 SECONDS, src))
			hijacking.forceMove(loc)
			hijacking = null
			hijack_start = 0
			update_icons()
			to_chat(src, span_bolddanger("Unknown device disconnected. Systems confirmed secure."))
		else
			to_chat(user, span_notice("You fail to remove the device."))
		return
	return ..()

/mob/living/silicon/ai/update_icons()
	..()
	cut_overlays()
	if(hijacking)
		if(!hijack_overlay)
			hijack_overlay = mutable_appearance('yogstation/icons/obj/module.dmi', "ai_hijack_overlay")
			hijack_overlay.layer = layer+0.1
			hijack_overlay.pixel_x = 8
		add_overlay(hijack_overlay)
		icon_state = "ai-static"
	else if(!hijacking && hijack_overlay)
		QDEL_NULL(hijack_overlay)


/mob/living/silicon/ai/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	. = ..()
	if(istype(card) && interaction == AI_TRANS_TO_CARD && hijacking)
		hijacking.forceMove(get_turf(card))
		hijacking.visible_message(span_warning("[hijacking] falls off of [AI] as it's transferred to [card]!"))
		hijacking = null
		hijack_start = 0
		to_chat(src, span_bolddanger("Unknown device disconnected. Systems confirmed secure."))
