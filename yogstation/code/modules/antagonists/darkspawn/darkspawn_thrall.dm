/datum/antagonist/thrall
	name = "Darkspawn Thrall"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "thrall"
	roundend_category = "thralls"
	antagpanel_category = "Darkspawn"
	antag_moodlet = /datum/mood_event/thrall
	///The abilities granted to the thrall
	var/list/abilities = list(/datum/action/cooldown/spell/toggle/nightvision, /datum/action/cooldown/spell/pointed/darkspawn_build/thrall_eye/thrall)
	///How many ticks towards willpower generation has happened so far
	var/current_willpower_progress = 0
	///Amount of progress required to generate willpower, increases every time
	var/current_willpower_max = 80
	///The darkspawn team that the thrall is on
	var/datum/team/darkspawn/team

/datum/antagonist/thrall/get_team()
	return team

/datum/antagonist/thrall/on_gain()
	owner.special_role = "thrall"
	message_admins("[key_name_admin(owner.current)] was thralled by a darkspawn!")
	log_game("[key_name(owner.current)] was thralled by a darkspawn!")
	for (var/datum/team/darkspawn/T in GLOB.antagonist_teams)
		team = T
	if(!team)
		team = new
		stack_trace("thrall made without darkspawns")
	return ..()

/datum/antagonist/thrall/on_removal()
	message_admins("[key_name_admin(owner.current)] was dethralled!")
	log_game("[key_name(owner.current)] was dethralled!")
	owner.special_role = null
	var/mob/living/M = owner.current
	M.faction -= ROLE_DARKSPAWN
	if(issilicon(M))
		M.audible_message(span_notice("[M] lets out a short blip, followed by a low-pitched beep."))
		to_chat(M,span_userdanger("You have been turned into a[ iscyborg(M) ? " cyborg" : "n AI" ]! You are no longer a thrall! Though you try, you cannot remember anything about your servitude..."))
	else
		M.visible_message(span_big("[M] looks like their mind is their own again!"))
		to_chat(M,span_userdanger("A piercing white light floods your eyes. Your mind is your own again! Though you try, you cannot remember anything about the darkspawn or your time under their command..."))
	return ..()

/datum/antagonist/thrall/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	if(team)
		team.add_thrall(current_mob.mind)

	add_team_hud(current_mob, /datum/antagonist/darkspawn)

	RegisterSignal(current_mob, COMSIG_LIVING_LIFE, PROC_REF(thrall_life))
	RegisterSignal(current_mob, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	current_mob.update_appearance(UPDATE_OVERLAYS)
	current_mob.grant_language(/datum/language/darkspawn)
	current_mob.faction |= ROLE_DARKSPAWN

	current_mob.AddComponent(/datum/component/internal_cam, list(ROLE_DARKSPAWN))
	var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
	if(cam)
		cam.change_cameranet(GLOB.thrallnet)

	for(var/spell in abilities)
		if(ispreternis(current_mob) && ispath(spell, /datum/action/cooldown/spell/toggle/nightvision))
			continue //preterni are already designed for it
		var/datum/action/cooldown/spell/new_spell = new spell(owner)
		new_spell.Grant(current_mob)

	if(isliving(current_mob))
		var/obj/item/organ/shadowtumor/ST = current_mob.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
		if(!ST || !istype(ST))
			ST = new
			ST.Insert(current_mob, FALSE, FALSE)

/datum/antagonist/thrall/remove_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	if(!current_mob)
		return //sanity check

	if(team)
		team.remove_thrall(current_mob.mind)

	UnregisterSignal(current_mob, COMSIG_LIVING_LIFE)
	UnregisterSignal(current_mob, COMSIG_ATOM_UPDATE_OVERLAYS)
	current_mob.update_appearance(UPDATE_OVERLAYS)
	current_mob.remove_language(/datum/language/darkspawn)
	current_mob.faction -= ROLE_DARKSPAWN

	qdel(current_mob.GetComponent(/datum/component/internal_cam))
	for(var/datum/action/cooldown/spell/spells in current_mob.actions)
		if(spells.type in abilities)//no keeping your abilities
			spells.Remove(current_mob)
			qdel(spells)
	var/obj/item/organ/tumor = current_mob.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(tumor && istype(tumor, /obj/item/organ/shadowtumor))
		qdel(tumor)
	current_mob.update_sight()

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Antag hud---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall/add_team_hud(mob/target, antag_to_check)
	QDEL_NULL(team_hud_ref)

	team_hud_ref = WEAKREF(target.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/has_antagonist,
		"antag_team_hud_[REF(src)]",
		hud_image_on(target),
		antag_to_check || type,
	))

	// Add HUDs that they couldn't see before
	for (var/datum/atom_hud/alternate_appearance/basic/has_antagonist/antag_hud as anything in GLOB.has_antagonist_huds)
		if (is_team_darkspawn(owner.current)) //needs to change this line so both the darkspawn and thrall sees it
			antag_hud.show_to(owner.current)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Body Sigil--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!ishuman(source))
		return

	//draw both the overlay itself and the emissive overlay
	var/mutable_appearance/overlay = mutable_appearance('yogstation/icons/mob/darkspawn.dmi', "veil_sigils", -UNDER_SUIT_LAYER)
	overlay.color = COLOR_DARKSPAWN_PSI
	overlays += overlay

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Passive willpower gen---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall/proc/thrall_life(mob/living/source, seconds_per_tick, times_fired)
	if(!source || source.stat == DEAD)
		return
	var/obj/item/organ/tumor = source.getorganslot(ORGAN_SLOT_BRAIN_TUMOR)
	if(!tumor || !istype(tumor, /obj/item/organ/shadowtumor)) //if they somehow lose their tumor in an unusual way
		source.remove_thrall()
		return

	var/found_other = FALSE
	for(var/mob/living/thing in range(10, source))
		if(!thing.client) //gotta be an actual player (hope no one goes afk)
			continue
		if(is_team_darkspawn(thing))
			continue
		if(!can_see(source, thing, 10))
			continue
		found_other = TRUE

	if(found_other)
		current_willpower_progress += seconds_per_tick

	if(current_willpower_progress >= current_willpower_max)
		current_willpower_max *= 2
		current_willpower_progress = 0
		team.grant_willpower(1, TRUE)

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Antag greet--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/thrall/greet()
	to_chat(owner, span_progenitor("Krx'lna tyhx graha xthl'kap" ))

	var/list/flavour = list()
	if(ispreternis(owner.current))
		flavour += "You feel the warm consciousness welcome your own. Realization spews forth as the veil recedes."
	else
		flavour += "You feel the vast consciousness slowly consume your own and the veil falls away."
	flavour += "Serve the darkspawn above all else. Your former allegiances are now forfeit."
	flavour += "Their goal is yours, and yours is theirs."
	to_chat(owner, span_velvet(flavour.Join("<br>")))

	to_chat(owner, span_notice("<i>Use <b>.[MODE_KEY_DARKSPAWN]</b> before your messages to speak over the Mindlink.</i>"))
	to_chat(owner, span_notice("<i>Blending in with regular crewmembers will generate willpower for your masters.</i>"))
	to_chat(owner, span_notice("<i>Ask for help from your masters or fellows if you're new to this role.</i>"))
	SEND_SOUND(owner.current, sound ('yogstation/sound/ambience/antag/become_veil.ogg', volume = 50))
	flash_color(owner, flash_color = COLOR_VELVET, flash_time = 10 SECONDS)

/datum/antagonist/thrall/roundend_report()
	return "[printplayer(owner)]"
