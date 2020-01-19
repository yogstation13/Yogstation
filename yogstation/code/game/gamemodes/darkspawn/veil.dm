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
		M.audible_message("<span class='notice'>[M] lets out a short blip, followed by a low-pitched beep.</span>")
		to_chat(M,"<span class='userdanger'>You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude...</span>")
	else
		M.visible_message("<span class='big'>[M] looks like their mind is their own again!</span>")
		to_chat(M,"<span class='userdanger'>A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the darkspawn or your time under their command...</span>")
	M.update_sight()
	return ..()

/datum/antagonist/veil/greet()
	to_chat(owner, "<span class='velvet big'><b>ukq wna ieja jks</b></span>" )
	to_chat(owner, "<b>Your mind goes numb. Your thoughts go blank. You feel utterly empty. \n\
	A mind brushes against your own. You dream.\n\
	Of a vast, empty Void in the deep of space.\n\
	Something lies in the Void. Ancient. Unknowable. It watches you with hungry eyes. \n\
	Eyes filled with stars.\n\
	You feel a vast consciousness slowly consume your own and the veil falls away.\n\
	Serve the darkspawn above all else. Your former allegiances are now forfeit. Their goal is yours, and yours is theirs.</b>")
	to_chat(owner, "<i>Use <b>.k</b> before your messages to speak over the Mindlink. This only works across your current z-level.</i>")
	to_chat(owner, "<i>Ask for help from your masters or fellows if you're new to this role.</i>")
	SEND_SOUND(owner.current, sound ('yogstation/sound/ambience/antag/become_veil.ogg', volume = 50))
	flash_color(owner, flash_color = "#21007F", flash_time = 100)

/datum/antagonist/veil/roundend_report()
	return "[printplayer(owner)]"
