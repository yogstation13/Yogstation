/datum/antagonist/veil
	name = "Darkspawn Veil"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "veil"
	roundend_category = "veils"
	antagpanel_category = "Darkspawn"
	antag_moodlet = /datum/mood_event/thrall
	var/list/abilities = list(/datum/action/cooldown/spell/toggle/nightvision, /datum/action/cooldown/spell/pointed/seize/lesser)
	var/current_willpower_progress = 0
	var/datum/team/darkspawn/team

/datum/antagonist/veil/get_team()
	return team

/datum/antagonist/veil/on_gain()
	owner.special_role = "veil"
	message_admins("[key_name_admin(owner.current)] was veiled by a darkspawn!")
	log_game("[key_name(owner.current)] was veiled by a darkspawn!")
	if(iscarbon(owner.current))
		var/mob/living/carbon/dude = owner.current
		dude.faction |= ROLE_DARKSPAWN
		var/obj/item/organ/shadowtumor/ST = dude.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
		if(!ST || !istype(ST))
			ST = new
			ST.Insert(dude, FALSE, FALSE)

	for (var/T in GLOB.antagonist_teams)
		if (istype(T, /datum/team/darkspawn))
			team = T
	if(!team)
		CRASH("veil made without darkspawns")
	return ..()

/datum/antagonist/veil/on_removal()
	message_admins("[key_name_admin(owner.current)] was deveiled!")
	log_game("[key_name(owner.current)] was deveiled!")
	owner.special_role = null
	var/mob/living/M = owner.current
	M.faction -= ROLE_DARKSPAWN
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip, followed by a low-pitched beep."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude..."))
	else
		M.visible_message(span_big("[M] looks like their mind is their own again!"))
		to_chat(M,span_userdanger("A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the darkspawn or your time under their command..."))
		to_chat(owner, span_notice("As your mind is released from their grasp, you feel your strength returning."))
	var/obj/item/organ/tumor = M.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(tumor && istype(tumor, /obj/item/organ/shadowtumor))
		qdel(tumor)
	M.update_sight()
	return ..()

/datum/antagonist/veil/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	if(team)
		team.add_veil(current_mob.mind)

	add_team_hud(current_mob, /datum/antagonist/darkspawn)
	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(veil_life))
	RegisterSignal(current_mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	current_mob.update_appearance(UPDATE_OVERLAYS)
	current_mob.grant_language(/datum/language/darkspawn)

	current_mob.AddComponent(/datum/component/internal_cam, list(ROLE_DARKSPAWN))
	var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
	if(cam)
		cam.change_cameranet(GLOB.thrallnet)

	for(var/spell in abilities)
		if(ispreternis(current_mob) && ispath(spell, /datum/action/cooldown/spell/toggle/nightvision))
			continue //preterni are already designed for it
		var/datum/action/cooldown/spell/new_spell = new spell(owner)
		new_spell.Grant(current_mob)

/datum/antagonist/veil/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	if(team)
		team.remove_veil(current_mob.mind)

	UnregisterSignal(current_mob, COMSIG_LIVING_LIFE)
	UnregisterSignal(current_mob, COMSIG_ATOM_UPDATE_OVERLAYS)
	current_mob.update_appearance(UPDATE_OVERLAYS)
	current_mob.remove_language(/datum/language/darkspawn)

	qdel(current_mob.GetComponent(/datum/component/internal_cam))
	for(var/datum/action/cooldown/spell/spells in current_mob.actions)
		if(spells.type in abilities)//no keeping your abilities
			spells.Remove(current_mob)
			qdel(spells)

/datum/antagonist/veil/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!ishuman(source))
		return

	var/mob/living/carbon/human/dude = source

	//draw both the overlay itself and the emissive overlay
	var/mutable_appearance/overlay = mutable_appearance('yogstation/icons/mob/darkspawn.dmi', "veil_sigils", -UNDER_SUIT_LAYER)
	overlay.color = COLOR_DARKSPAWN_PSI
	overlays += overlay

	if(!(dude.wear_suit || dude.w_uniform))//glow the sigils if they're not wearing something covering them
		overlays += mutable_appearance('yogstation/icons/mob/darkspawn.dmi', "veil_sigils", source)

/datum/antagonist/veil/proc/veil_life(mob/living/source, seconds_per_tick, times_fired)
	if(!source || source.stat == DEAD)
		return
	var/obj/item/organ/tumor = source.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(!tumor || !istype(tumor, /obj/item/organ/shadowtumor)) //if they somehow lose their tumor in an unusual way
		source.remove_veil()
		return

	for(var/mob/living/thing in range(5, source))
		if(!thing.client) //gotta be an actual player (hope no one goes afk)
			continue
		if(is_darkspawn_or_veil(thing))
			continue
		current_willpower_progress += 2

	if(current_willpower_progress >= 100)
		current_willpower_progress = 0
		team.grant_willpower(1)

/datum/antagonist/veil/greet()
	to_chat(owner, span_progenitor("Krx'lna tyhx graha xthl'kap" ))
	if(ispreternis(owner.current))
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
	flash_color(owner, flash_color = "#21007F", flash_time = 10 SECONDS)

/datum/antagonist/veil/roundend_report()
	return "[printplayer(owner)]"
