#define MUNDANE 0
#define DIVULGED 1
#define PROGENITOR 2

//aka Shadowlings/umbrages/whatever
/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawn"
	antagpanel_category = "Darkspawn"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "darkspawn"
	var/darkspawn_state = MUNDANE //0 for normal crew, 1 for divulged, and 2 for progenitor
	antag_moodlet = /datum/mood_event/sling

	//Psi variables
	var/psi = 100 //Psi is the resource used for darkspawn powers
	var/psi_cap = 100 //Max Psi by default
	var/psi_regen = 20 //How much Psi will regenerate after using an ability
	var/psi_regen_delay = 5 //How many ticks need to pass before Psi regenerates
	var/psi_regen_ticks = 0 //When this hits 0, regenerate Psi and return to psi_regen_delay
	var/psi_used_since_regen = 0 //How much Psi has been used since we last regenerated
	var/psi_regenerating = FALSE //Used to prevent duplicate regen proc calls

	//Lucidity variables
	var/lucidity = 3 //Lucidity is used to buy abilities and is gained by using Devour Will
	var/lucidity_drained = 0 //How much lucidity has been drained from unique players
	var/lucidity_needed = 20 //how much lucidity is needed to win

	//upgrade variables
	var/list/upgrades = list() //An associative list ("id" = null or TRUE) containing the passive upgrades the darkspawn has
	var/datum/antag_menu/shadow_store/shadow_store //Antag menu used for opening the UI
	var/datum/action/innate/darkspawn/shadow_store/shadow_store_action //Used to link the menu with our antag datum

	var/specialization = NONE

// Antagonist datum things like assignment //

/datum/antagonist/darkspawn/on_gain()
	SSticker.mode.darkspawn += owner
	owner.special_role = "darkspawn"
	owner.current.hud_used.psi_counter.invisibility = 0
	update_psi_hud()
	var/datum/action/innate/darkspawn/divulge/action = new()
	action.Grant(owner.current)
	action.darkspawn = src
	upgrades += action
	addtimer(CALLBACK(src, PROC_REF(begin_force_divulge)), 23 MINUTES) //this won't trigger if they've divulged when the proc runs
	START_PROCESSING(SSprocessing, src)
	var/datum/objective/darkspawn/O = new
	objectives += O
	O.update_explanation_text()
	owner.announce_objectives()
	return ..()

/datum/antagonist/darkspawn/on_removal()
	SSticker.mode.darkspawn -= owner
	owner.special_role = null
	owner.current.hud_used.psi_counter.invisibility = initial(owner.current.hud_used.psi_counter.invisibility)
	owner.current.hud_used.psi_counter.maptext = ""
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/apply_innate_effects(mob/living/mob_override)
	var/mob/living/current_mob = mob_override || owner.current
	handle_clown_mutation(current_mob, mob_override ? null : "Our powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
	current_mob.grant_language(/datum/language/darkspawn)
	add_team_hud(current_mob)

/datum/antagonist/darkspawn/remove_innate_effects()
	owner.current.remove_language(/datum/language/darkspawn)

//Round end stuff
/datum/antagonist/darkspawn/proc/check_darkspawn_death()
	for(var/DM in get_antag_minds(/datum/antagonist/darkspawn))
		var/datum/mind/dark_mind = DM
		if(istype(dark_mind))
			if((dark_mind?.current?.stat != DEAD) && ishuman(dark_mind.current))
				return FALSE
	return TRUE

/datum/antagonist/darkspawn/roundend_report()
	return "[owner ? printplayer(owner) : "Unnamed Darkspawn"]"

/datum/antagonist/darkspawn/roundend_report_header()
	if(SSticker.mode.sacrament_done)
		return "<span class='greentext big'>The darkspawn have completed the Sacrament!</span><br>"
	else if(!SSticker.mode.sacrament_done && check_darkspawn_death())
		return "<span class='redtext big'>The darkspawn have been killed by the crew!</span><br>"
	else if(!SSticker.mode.sacrament_done && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return "<span class='redtext big'>The crew escaped the station before the darkspawn could complete the Sacrament!</span><br>"
	else
		return "<span class='redtext big'>The darkspawn have failed!</span><br>"

//Admin panel stuff

/datum/antagonist/darkspawn/antag_panel_data()
	. = "<b>Upgrades:</b><br>"
	for(var/V in upgrades)
		. += "[V]<br>"

//i have deleted all admin procs because i don't want to have to worry about those while reworking it, they can be added in a later PR
//i'm making this rework for the players (and for me) not the admins

/datum/antagonist/darkspawn/greet()
	to_chat(owner.current, "<span class='velvet bold big'>You are a darkspawn!</span>")
	to_chat(owner.current, "<i>Append :[MODE_KEY_DARKSPAWN] or .[MODE_KEY_DARKSPAWN] before your message to silently speak with any other darkspawn.</i>")
	to_chat(owner.current, "<i>When you're ready, retreat to a hidden location and Divulge to shed your human skin.</i>")
	to_chat(owner.current, span_boldwarning("If you do not do this within twenty five minutes, this will happen involuntarily. Prepare quickly."))
	to_chat(owner.current, "<i>Remember that this will make you die in the light and heal in the dark - keep to the shadows.</i>")
	owner.current.playsound_local(get_turf(owner.current), 'yogstation/sound/ambience/antag/darkspawn.ogg', 50, FALSE)

/datum/objective/darkspawn
	explanation_text = "Become lucid and perform the Sacrament."

/datum/objective/darkspawn/update_explanation_text()
	explanation_text = "Become lucid and perform the Sacrament. You will need to devour [SSticker.mode.required_succs] different people's wills and purchase all passive upgrades to do so."

/datum/objective/darkspawn/check_completion()
	if(..())
		return TRUE
	return (SSticker.mode.sacrament_done)

// Darkspawn-related things like Psi //

/datum/antagonist/darkspawn/process() //This is here since it controls most of the Psi stuff
	psi = min(psi, psi_cap)
	if(psi != psi_cap)
		psi_regen_ticks--
		if(!psi_regen_ticks)
			regenerate_psi()
	update_psi_hud()

/datum/antagonist/darkspawn/proc/has_psi(amt)
	return psi >= amt

/datum/antagonist/darkspawn/proc/use_psi(amt)
	if(!has_psi(amt))
		return
	psi_regen_ticks = psi_regen_delay
	psi_used_since_regen += amt
	psi -= amt
	psi = round(psi, 0.2)
	update_psi_hud()
	return TRUE

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	if(psi_regenerating)
		return
	psi_regenerating = TRUE
	var/total_regen = min(psi_regen, psi_used_since_regen)
	for(var/i in 1 to psi_cap) //tick it up very quickly instead of just increasing it by the regen; also include a failsafe to avoid infinite loops
		if(!total_regen || psi >= psi_cap)
			break
		psi = min(psi + 1, psi_cap)
		total_regen--
		update_psi_hud()
		sleep(0.05 SECONDS)
	psi_used_since_regen = 0
	psi_regen_ticks = psi_regen_delay
	psi_regenerating = FALSE
	return TRUE

/datum/antagonist/darkspawn/proc/update_psi_hud()
	if(!owner.current || !owner.current.hud_used)
		return
	var/atom/movable/screen/counter = owner.current.hud_used.psi_counter
	counter.maptext = ANTAG_MAPTEXT(psi, COLOR_DARKSPAWN_PSI)

/datum/antagonist/darkspawn/proc/begin_force_divulge()
	if(darkspawn_state != MUNDANE)
		return
	to_chat(owner.current, span_userdanger("You feel the skin you're wearing crackling like paper - you will forcefully divulge soon! Get somewhere hidden and dark!"))
	owner.current.playsound_local(owner.current, 'yogstation/sound/magic/divulge_01.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(force_divulge), 2 MINUTES))

/datum/antagonist/darkspawn/proc/force_divulge()
	if(darkspawn_state != MUNDANE)
		return
	var/mob/living/carbon/C = owner.current
	if(C && !ishuman(C))
		C.humanize()
	var/mob/living/carbon/human/H = owner.current
	if(!H)
		owner.current.gib(TRUE)
	H.visible_message(span_boldwarning("[H]'s skin begins to slough off in sheets!"), \
	span_userdanger("You can't maintain your disguise any more! It begins sloughing off!"))
	playsound(H, 'yogstation/sound/creatures/darkspawn_force_divulge.ogg', 50, FALSE)
	H.do_jitter_animation(1000)
	var/processed_message = span_velvet("<b>\[Mindlink\] [H.real_name] has not divulged in time and is now forcefully divulging.</b>")
	for(var/mob/M in GLOB.player_list)
		if(M.stat != DEAD && isdarkspawn(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, null, H)
	addtimer(CALLBACK(src, PROC_REF(divulge), TRUE), 2.5 SECONDS)

/datum/antagonist/darkspawn/proc/divulge(forced = FALSE)
	if(darkspawn_state >= DIVULGED)
		return FALSE
	if(forced)
		owner.current.visible_message(
			span_boldwarning("[owner.current]'s skin sloughs off, revealing black flesh covered in symbols!"), 
			span_userdanger("You have forcefully divulged!"))
	var/mob/living/carbon/human/user = owner.current
	to_chat(user, "<span class='velvet bold'>Your mind has expanded. The Psi Web is now available. Avoid the light. Keep to the shadows. Your time will come.</span>")
	user.fully_heal()
	user.set_species(/datum/species/darkspawn)
	ADD_TRAIT(user, TRAIT_SPECIESLOCK, "darkspawn divulge") //prevent them from swapping species which can fuck stuff up
	show_to_ghosts = TRUE
	shadow_store = new(src)
	shadow_store_action = new(shadow_store)
	shadow_store_action.Grant(owner.current)
	shadow_store_action.darkspawn = src
	darkspawn_state = DIVULGED
	return TRUE

/datum/antagonist/darkspawn/proc/sacrament()
	var/mob/living/carbon/human/user = owner.current
	if(!SSticker.mode.sacrament_done)
		set_security_level(SEC_LEVEL_GAMMA)
		addtimer(CALLBACK(src, PROC_REF(sacrament_shuttle_call)), 50)
	for(var/datum/action/innate/darkspawn/leftover_ability in user.actions)
		leftover_ability.Remove(user)
		QDEL_NULL(leftover_ability)
	// Spawn the cosmic progenitor
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = new(get_turf(user))
	user.status_flags |= GODMODE
	user.mind.transfer_to(progenitor)
	var/datum/action/cooldown/spell/list_target/progenitor_curse/curse = new(progenitor)
	curse.Grant(progenitor)
	sound_to_playing_players('yogstation/sound/magic/sacrament_complete.ogg', 50, FALSE, pressure_affected = FALSE)
	psi = 9999
	psi_cap = 9999
	psi_regen = 9999
	psi_regen_delay = 1
	SSticker.mode.sacrament_done = TRUE
	darkspawn_state = PROGENITOR
	QDEL_IN(user, 5)

/datum/antagonist/darkspawn/proc/sacrament_shuttle_call()
	SSshuttle.emergency.request(null, 0, null, FALSE, 0.1)

/datum/antagonist/darkspawn/get_preview_icon()
	var/icon/darkspawn_icon = icon('yogstation/icons/mob/darkspawn_progenitor.dmi', "darkspawn_progenitor")

	darkspawn_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)

	return darkspawn_icon

#undef MUNDANE
#undef DIVULGED
#undef PROGENITOR
