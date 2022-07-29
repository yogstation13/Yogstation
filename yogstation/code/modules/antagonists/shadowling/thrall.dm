GLOBAL_LIST_INIT(thrall_spell_types, typecacheof(list(/obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind, /obj/effect/proc_holder/spell/targeted/lesser_glare, /obj/effect/proc_holder/spell/self/lesser_shadow_walk, /obj/effect/proc_holder/spell/self/thrall_night_vision)))

/datum/antagonist/thrall/shadowling
	name = "Shadowling Thrall"
	job_rank = ROLE_SHADOWLING
	roundend_category = "thralls"
	antagpanel_category = "Shadowlings"
	antag_moodlet = /datum/mood_event/thrall
	
/datum/antagonist/thrall/shadowling/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		var/list/no_team_antag = list(
			/datum/antagonist/rev,
			/datum/antagonist/clockcult,
			/datum/antagonist/darkspawn,
			/datum/antagonist/cult,
			/datum/antagonist/zombie
			)
		for(var/datum/antagonist/NTA in new_owner.antag_datums)
			if(NTA.type in no_team_antag)
				return FALSE

/datum/antagonist/thrall/shadowling/on_gain()
	. = ..()
	SSticker.mode.update_shadow_icons_added(owner)
	SSticker.mode.thralls += owner
	owner.special_role = "thrall"
	message_admins("[key_name_admin(owner.current)] was enthralled by a shadowling!")
	log_game("[key_name(owner.current)] was enthralled by a shadowling!")
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/lesser_shadowling_hivemind(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/targeted/lesser_glare(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/lesser_shadow_walk(null))
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/thrall_night_vision(null))

/datum/antagonist/thrall/shadowling/on_removal()
	SSticker.mode.update_shadow_icons_removed(owner)
	SSticker.mode.thralls -= owner
	message_admins("[key_name_admin(owner.current)] was dethralled!")
	log_game("[key_name(owner.current)] was dethralled!")
	owner.special_role = null
	for(var/X in owner.spell_list)
		var/obj/effect/proc_holder/spell/S = X
		if(is_type_in_typecache(S, GLOB.thrall_spell_types)) //only remove thrall spells!
			owner.RemoveSpell(S)
	var/mob/living/M = owner.current
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip, followed by a low-pitched beep."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude..."))
	else
		M.visible_message(span_big("[M] looks like their mind is their own again!"))
		to_chat(M,span_userdanger("A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the shadowlings or your time under their command..."))
	M.update_sight()
	return ..()

/datum/antagonist/thrall/shadowling/greet()
	to_chat(owner, span_shadowling("<b>You see the truth. Reality has been torn away and you realize what a fool you've been.</b>"))
	if(ispreternis(owner))
		to_chat(owner, span_shadowling("<b>The shadowlings- your creators, have returned to become gods.</b> Serve them above all else and ensure they complete their goals.</b>"))
	else
		to_chat(owner, span_shadowling("<b>The shadowlings are your masters.</b> Serve them above all else and ensure they complete their goals.</b>"))
	to_chat(owner, span_shadowling("You may not harm other thralls or the shadowlings. However, you do not need to obey other thralls."))
	to_chat(owner, span_shadowling("Your body has been irreversibly altered. The attentive can see this - you may conceal it by wearing a mask."))
	to_chat(owner, span_shadowling("Though not nearly as powerful as your masters, you possess some weak powers. These can be found in the Thrall Abilities tab."))
	to_chat(owner, span_shadowling("You may communicate with your allies by using the Lesser Commune ability."))
	SEND_SOUND(owner.current, sound('yogstation/sound/ambience/antag/thrall.ogg'))

/datum/antagonist/thrall/shadowling/roundend_report()
	return "[printplayer(owner)]"
