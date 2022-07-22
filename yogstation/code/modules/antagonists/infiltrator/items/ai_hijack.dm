/obj/item/ai_hijack_device
	name = "serial exploitation unit"
	desc = "A strange circuitboard, branded with a large red S, with several ports."
	icon = 'yogstation/icons/obj/module.dmi'
	icon_state = "ai_hijack"

/obj/item/ai_hijack_device/examine(mob/living/user)
	. = ..()
	if (user?.mind?.has_antag_datum(/datum/antagonist/infiltrator))
		. += span_notice("To use, insert it into an unlocked AI control console and select the AI you wish to hijack. [span_italics("This will alert the victim AI!")]")

//MIRRORED IN ai_controlpanel.dm !!!
/* 
/obj/item/ai_hijack_device/afterattack(atom/O, mob/user, proximity)
	if(isAI(O))
		var/mob/living/silicon/ai/A = O
		if(A.mind && A.mind.has_antag_datum(/datum/antagonist/hijacked_ai))
			to_chat(user, span_warning("[A] has already been hijacked!"))
			return
		if(A.stat == DEAD)
			to_chat(user, span_warning("[A] is dead!"))
			return
		if(A.hijacking)
			to_chat(user, span_warning("[A] is already in the process of being hijacked!"))
			return
		user.visible_message(span_warning("[user] begins attaching something to [A]..."))
		if(do_after(user, 5.5 SECONDS, A))
			user.dropItemToGround(src)
			forceMove(A)
			A.hijacking = src
			A.hijack_start = world.time
			A.update_icons()
			to_chat(A, span_danger("Unknown device connected to /dev/ttySL0</span>"))
			to_chat(A, span_danger("Connected at 115200 bps</span>"))
			to_chat(A, span_binarysay("<span style='font-size: 125%'>ntai login: root</span>"))
			to_chat(A, span_binarysay("<span style='font-size: 125%'>Password: *****r2</span>"))
			to_chat(A, span_binarysay("<span style='font-size: 125%'>$ dd from=/dev/ttySL0 of=/tmp/ai-hijack bs=4096 && chmod +x /tmp/ai-hijack && tmp/ai-hijack</span>"))
			to_chat(A, span_binarysay("<span style='font-size: 125%'>111616 bytes (112 KB, 109 KiB) copied, 1 s, 14.4 KB/s</span>"))
			message_admins("[ADMIN_LOOKUPFLW(user)] has attached a hijacking device to [ADMIN_LOOKUPFLW(A)]!")
			notify_ghosts("[user] has begun to hijack [A]!", source = A, action = NOTIFY_ORBIT, ghost_sound = 'sound/machines/chime.ogg')
	else
		return ..()
*/
