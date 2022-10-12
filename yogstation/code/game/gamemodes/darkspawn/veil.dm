/datum/antagonist/veil
	name = "Darkspawn Veil"
	job_rank = ROLE_DARKSPAWN
	roundend_category = "veils"
	antagpanel_category = "Darkspawn"
	antag_moodlet = /datum/mood_event/thrall

/datum/antagonist/veil/on_gain()
	. = ..()
	SSticker.mode.update_darkspawn_icons_added(owner)
	SSticker.mode.veils += owner
	owner.special_role = "veil"
	message_admins("[key_name_admin(owner.current)] was veiled by a darkspawn!")
	log_game("[key_name(owner.current)] was veiled by a darkspawn!")

/datum/antagonist/veil/on_removal()
	SSticker.mode.update_darkspawn_icons_removed(owner)
	SSticker.mode.veils -= owner
	message_admins("[key_name_admin(owner.current)] was deveiled!")
	log_game("[key_name(owner.current)] was deveiled!")
	owner.special_role = null
	var/mob/living/M = owner.current
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip, followed by a low-pitched beep."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude..."))
	else
		M.visible_message(span_big("[M] looks like their mind is their own again!"))
		to_chat(M,span_userdanger("A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the darkspawn or your time under their command..."))
	M.update_sight()
	return ..()

/datum/antagonist/veil/greet()
	to_chat(owner, "<span class='velvet big'><b>ukq wna ieja jks</b></span>" )
	if(ispreternis(owner))
		to_chat(owner, "<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \n\
		A consciousness brushes against your own. You dream.\n\
		Of a vast, glittering empire stretching from star to star. \n\
		Then, a Void blankets the canopy, suffocating the light. \n\
		Hungry eyes bear into you from the blackness. Ancient. Familiar. \n\
		You feel the warm consciousness welcome your own. Realization spews forth as the veil recedes. \n\
		Serve the darkspawn above all else. Your former allegiances are now forfeit. Their goal is yours, and yours is theirs.</b>")
	else
		to_chat(owner, "<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \n\
		A consciousness brushes against your own. You dream. \n\
		Of a vast, empty Void in the deep of space. \n\
		Something lies in the Void. Ancient. Unknowable. It watches you with hungry eyes. \n\
		Eyes filled with stars. \n\
		You feel the vast consciousness slowly consume your own and the veil falls away. \n\
		Serve the darkspawn above all else. Your former allegiances are now forfeit. Their goal is yours, and yours is theirs.</b>")
	to_chat(owner, "<i>Use <b>:[MODE_KEY_DARKSPAWN] or .[MODE_KEY_DARKSPAWN]</b> before your messages to speak over the Mindlink. This only works across your current z-level.</i>")
	to_chat(owner, "<i>Ask for help from your masters or fellows if you're new to this role.</i>")
	SEND_SOUND(owner.current, sound ('yogstation/sound/ambience/antag/become_veil.ogg', volume = 50))
	flash_color(owner, flash_color = "#21007F", flash_time = 100)

/datum/antagonist/veil/roundend_report()
	return "[printplayer(owner)]"
