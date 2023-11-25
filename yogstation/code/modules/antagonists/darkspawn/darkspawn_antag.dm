/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawn"
	antagpanel_category = "Darkspawn"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "darkspawn"
	ui_name = "AntagInfoDarkspawn"
	var/darkspawn_state = MUNDANE //0 for normal crew, 1 for divulged, and 2 for progenitor
	antag_moodlet = /datum/mood_event/sling

	var/disguise_name //name of the player character

	//Psi variables
	var/psi = 100 //Psi is the resource used for darkspawn powers
	var/psi_cap = 100 //Max Psi by default
	var/psi_regen_delay = 10 SECONDS //How long before psi starts regenerating
	var/psi_per_second = 10 //how much psi is regenerated per second once it does start regenerating
	COOLDOWN_DECLARE(psi_cooldown)//When this finishes it's cooldown, regenerate Psi and restart
	var/psi_regenerating = FALSE //Used to prevent duplicate regen proc calls

	var/willpower = 3 //Lucidity is used to buy abilities and is gained by using Devour Will

	//Default light damage variables (modified by some abilities)
	var/dark_healing = 5
	var/light_burning = 7

	//upgrade variables
	var/list/upgrades = list() //A list of all the upgrades we currently have (actual objects, not just typepaths)
	
	var/specialization = NONE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------UI and Psi web stuff--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/ui_data(mob/user)
	var/list/data = list()

	data["willpower"] = willpower
	
	return data

/datum/antagonist/darkspawn/ui_static_data(mob/user)
	var/list/data = list()
	
	data["antag_name"] = name
	data["objectives"] = get_objectives()
	data["lucidity_drained"] = SSticker.mode.lucidity
	data["required_succs"] = SSticker.mode.required_succs
	data["specialization"] = specialization //whether or not they've picked their specializationW

	return data

/datum/antagonist/darkspawn/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("purchase")
			var/upgrade_path = text2path(params["upgrade_path"])
			if(!ispath(upgrade_path, /datum/psi_web))
				return FALSE
			//var/datum/psi_web/selected = new upgrade_path
			SEND_SIGNAL(owner, COMSIG_DARKSPAWN_PURCHASE_POWER, upgrade_path)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Gain and loss stuff---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/on_gain()
	SSticker.mode.darkspawn += owner
	owner.special_role = "darkspawn"
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
	if(!current_mob)
		return
	handle_clown_mutation(current_mob, mob_override ? null : "Our powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
	add_team_hud(current_mob)
	current_mob.grant_language(/datum/language/darkspawn)

	//psi stuff
	if(current_mob?.hud_used?.psi_counter)
		current_mob.hud_used.psi_counter.invisibility = 0
		update_psi_hud()
	START_PROCESSING(SSprocessing, src)

	current_mob.faction |= ROLE_DARKSPAWN

	//for panopticon
	if(current_mob)
		current_mob.AddComponent(/datum/component/internal_cam, list(ROLE_DARKSPAWN))
		var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
		if(cam)
			cam.change_cameranet(GLOB.thrallnet)

	//divulge
	if(darkspawn_state == MUNDANE)
		var/datum/action/cooldown/spell/divulge/action = new(owner)
		action.Grant(current_mob)
		upgrades += action
		addtimer(CALLBACK(src, PROC_REF(begin_force_divulge)), 23 MINUTES) //this won't trigger if they've divulged when the proc runs

/datum/antagonist/darkspawn/remove_innate_effects()
	owner.current.remove_language(/datum/language/darkspawn)
	owner.current.faction -= ROLE_DARKSPAWN
	if(owner.current)
		var/datum/component/internal_cam/cam = owner.current.GetComponent(/datum/component/internal_cam)
		if(cam)
			cam.RemoveComponent()

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Greet and Objective---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/greet()
	var/mob/user = owner.current
	if(!user) //sanity check
		return
		
	user.playsound_local(get_turf(user), 'yogstation/sound/ambience/antag/darkspawn.ogg', 50, FALSE)

	var/list/report = list()
	report += span_progenitor("You are a darkspawn!")
	report += span_notice("Add :[MODE_KEY_DARKSPAWN] or .[MODE_KEY_DARKSPAWN] before your message to silently speak with any other darkspawn.")
	report += "When you are ready, retreat to a hidden location and Divulge to shed your human skin."
	report += "Remember that this will make you die in the light and heal in the dark - keep to the shadows."
	report += span_boldwarning("If you do not do this within twenty five minutes, this will happen involuntarily. Prepare quickly.")
	to_chat(user, report.Join("<br>"))

/datum/objective/darkspawn
	explanation_text = "Become lucid and perform the Sacrament."

/datum/objective/darkspawn/update_explanation_text()
	explanation_text = "Devour enough wills to gain [SSticker.mode.required_succs] lucidity and perform the sacrament."

/datum/objective/darkspawn/check_completion()
	if(..())
		return TRUE
	return (SSticker.mode.sacrament_done)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Round End stuff-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/roundend_report()
	return "[owner ? printplayer(owner) : "Unnamed Darkspawn"]"

/datum/antagonist/darkspawn/roundend_report_header() //put lore flavour in here
	var/list/report = list()

	if(SSticker.mode.sacrament_done)
		report += "<span class='greentext big'>The darkspawn have completed the Sacrament!</span><br>"
	else if(!SSticker.mode.sacrament_done && check_darkspawn_death())
		report += "<span class='redtext big'>The darkspawn have been killed by the crew!</span><br>"
	else if(!SSticker.mode.sacrament_done && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		report += "<span class='redtext big'>The crew escaped the station before the darkspawn could complete the Sacrament!</span><br>"
	else //fallback in case the round ends weirdly
		report += "<span class='redtext big'>The darkspawn have failed!</span><br>"

	return report

/datum/antagonist/darkspawn/proc/check_darkspawn_death() //check if a darkspawn is still alive
	for(var/DM in get_antag_minds(/datum/antagonist/darkspawn))
		var/datum/mind/dark_mind = DM
		if(istype(dark_mind) && (dark_mind?.current?.stat != DEAD))
			return FALSE
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Admin panel stuff---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/get_admin_commands()
	. = ..()
	if(darkspawn_state == MUNDANE)
		.["Force Divulge"] = CALLBACK(src, PROC_REF(divulge), TRUE)
	.["Set Lucidity"] = CALLBACK(src, PROC_REF(set_lucidity))
	.["Set Willpower"] = CALLBACK(src, PROC_REF(set_shop))
	.["Set Psi Values"] = CALLBACK(src, PROC_REF(set_psi))
	.["Set Max Veils"] = CALLBACK(src, PROC_REF(set_max_veils))

/datum/antagonist/darkspawn/proc/set_lucidity(mob/admin)
	var/lucid = input(admin, "How much lucidity should all darkspawns have?") as null|num
	if(lucid)
		SSticker.mode.lucidity = lucid

/datum/antagonist/darkspawn/proc/set_shop(mob/admin)
	var/will = input(admin, "How much willpower should [owner] have?") as null|num
	if(will)
		willpower = will

/datum/antagonist/darkspawn/proc/set_max_veils(mob/admin)
	var/thrall = input(admin, "How many veils should the darkspawn team be able to get?") as null|num
	if(thrall)
		SSticker.mode.max_veils = thrall

/datum/antagonist/darkspawn/proc/set_psi(mob/admin)
	var/max = input(admin, "What should the psi cap be?") as null|num
	if(max)
		psi_cap = max
	var/regen = input(admin, "How much psi should be regenerated per second?") as null|num
	if(regen)
		psi_per_second = regen
	var/delay = input(admin, "What should the delay to psi regeneration be?") as null|num
	if(delay)
		psi_regen_delay = delay

/datum/antagonist/darkspawn/antag_panel_data()
	. += "<b>Lucidity:</b> [SSticker.mode.lucidity ? SSticker.mode.lucidity : "0"] / [SSticker.mode.required_succs ? SSticker.mode.required_succs : "0"]<br>"
	. += "<b>Willpower:</b> [willpower ? willpower : "0"]<br>"
	. += "<b>Psi Cap:</b> [psi_cap]. <b>Psi per second:</b> [psi_per_second]. <b>Psi regen delay:</b> [psi_regen_delay ? "[psi_regen_delay/10] seconds" : "no delay"]<br>"
	. += "<b>Max Veils:</b> [SSticker.mode.max_veils ? SSticker.mode.max_veils : "0"]<br>"

	. += "<b>Upgrades:</b><br>"
	for(var/V in upgrades)
		. += "[V]<br>"

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Psi regen and usage-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/process(delta_time)
	psi = min(psi, psi_cap)
	if(psi < psi_cap && COOLDOWN_FINISHED(src, psi_cooldown) && !psi_regenerating)
		if(HAS_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK))
			return //prevent regeneration
		regenerate_psi()
	update_psi_hud()

/datum/antagonist/darkspawn/proc/has_psi(amt)
	return psi >= amt

/datum/antagonist/darkspawn/proc/use_psi(amt)
	if(!has_psi(amt))
		return
	if(psi_regen_delay)
		COOLDOWN_START(src, psi_cooldown, psi_regen_delay)
	psi -= amt
	psi = round(psi, 0.1)
	update_psi_hud()
	return TRUE

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	psi_regenerating = TRUE 
	var/regen_amount = max(1, (psi_per_second/20))//max speed is 20 ticks per second, regenerate extra per tick if regen speed is over 20 (only encountered when admemes mess with numbers)
	psi = min(psi + regen_amount, psi_cap)
	psi = round(psi, 0.1) //keep it at reasonable numbers rather than ridiculous decimals
	update_psi_hud()
	if(psi >= psi_cap || !COOLDOWN_FINISHED(src, psi_cooldown))
		psi_regenerating = FALSE
		return
	var/delay = (1/psi_per_second) SECONDS
	addtimer(CALLBACK(src, PROC_REF(regenerate_psi)), delay, TIMER_UNIQUE) //tick it up very quickly

///temporarily block psi regeneration
/datum/antagonist/darkspawn/proc/block_psi(duration = 5 SECONDS, identifier)
	if(!identifier)
		return
	ADD_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK, identifier)
	addtimer(CALLBACK(src, PROC_REF(unblock_psi), identifier), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/antagonist/darkspawn/proc/unblock_psi(identifier)
	REMOVE_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK, identifier)

/datum/antagonist/darkspawn/proc/update_psi_hud()
	if(!owner.current || !owner.current.hud_used)
		return
	var/atom/movable/screen/counter = owner.current.hud_used.psi_counter
	counter.maptext = ANTAG_MAPTEXT(psi, COLOR_DARKSPAWN_PSI)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Divulge--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/proc/divulge(forced = FALSE)
	if(darkspawn_state >= DIVULGED)
		return FALSE
		
	var/mob/living/carbon/human/user = owner.current

	if(!user || !istype(user))//sanity check
		return

	if(forced)
		owner.current.visible_message(
			span_boldwarning("[owner.current]'s skin sloughs off, revealing black flesh covered in symbols!"), 
			span_userdanger("You have forcefully divulged!"))

	for(var/datum/action/cooldown/spell/spells in user.actions) //remove the ability that triggers this
		if(istype(spells, /datum/action/cooldown/spell/divulge))
			spells.Remove(user)
			qdel(spells)


	disguise_name = user.real_name //keep track of the old name
	user.fully_heal()
	user.set_species(/datum/species/shadow/darkspawn)
	ADD_TRAIT(user, TRAIT_SPECIESLOCK, "darkspawn divulge") //prevent them from swapping species which can fuck stuff up

	show_to_ghosts = TRUE
	var/processed_message = span_velvet("<b>\[Mindlink\] [disguise_name] has removed their human disguise and is now [user.real_name].</b>")
	for(var/T in GLOB.alive_mob_list)
		var/mob/M = T
		if(is_darkspawn_or_veil(M))
			to_chat(M, processed_message)
	for(var/T in GLOB.dead_mob_list)
		var/mob/M = T
		to_chat(M, "<a href='?src=[REF(M)];follow=[REF(user)]'>(F)</a> [processed_message]")


	//will be handled by darkspawn classes when chubby finishes them
	var/datum/action/cooldown/spell/touch/devour_will/devour = new(owner)
	upgrades |= devour
	devour.Grant(owner.current)
	var/datum/action/cooldown/spell/toggle/light_eater/eater = new(owner)
	upgrades |= eater
	eater.Grant(owner.current)
	var/datum/action/cooldown/spell/sacrament/sacrament = new(owner)
	upgrades |= sacrament
	sacrament.Grant(owner.current)

	darkspawn_state = DIVULGED
	to_chat(user, span_velvet("<b>Your mind has expanded. The Psi Web is now available. Avoid the light. Keep to the shadows. Your time will come.</b>"))
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Forced Divulge------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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
	var/processed_message = span_progenitor("\[Mindlink\] [H.real_name] has not divulged in time and is now forcefully divulging.")
	for(var/mob/M in GLOB.player_list)
		if(M.stat != DEAD && isdarkspawn(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, null, H)
	addtimer(CALLBACK(src, PROC_REF(divulge), TRUE), 2.5 SECONDS)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Sacrament------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/proc/sacrament()
	var/mob/living/carbon/human/user = owner.current

	if(!user || !istype(user))//sanity check
		return

	user.status_flags |= GODMODE

	if(!SSticker.mode.sacrament_done)
		SSticker.mode.sacrament_done = TRUE
		set_security_level(SEC_LEVEL_DELTA)
		shatter_lights()
		addtimer(CALLBACK(src, PROC_REF(sacrament_shuttle_call)), 5 SECONDS)

	SSachievements.unlock_achievement(/datum/achievement/greentext/darkspawn, user.client)

	for(var/datum/action/cooldown/spell/spells in user.actions) //they'll have progenitor specific abilities
		spells.Remove(user)
		qdel(spells)
	// Spawn the progenitor
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = new(get_turf(user), user.real_name)
	user.mind.transfer_to(progenitor)

	psi = 9999
	psi_cap = 9999
	psi_per_second = 9999
	psi_regen_delay = 0
	update_psi_hud()

	darkspawn_state = PROGENITOR
	QDEL_IN(user, 1)

///get rid of all lights by calling the light eater proc
/datum/antagonist/darkspawn/proc/shatter_lights()
	for(var/obj/machinery/light/L in GLOB.machines)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, on_light_eater)), rand(1, 30)) //stagger the "shatter" to reduce lag

///call a shuttle
/datum/antagonist/darkspawn/proc/sacrament_shuttle_call()
	SSshuttle.emergency.request(null, 0, null, 0.1)

///To get the icon in preferences
/datum/antagonist/darkspawn/get_preview_icon()
	var/icon/darkspawn_icon = icon('yogstation/icons/mob/darkspawn_progenitor.dmi', "darkspawn_progenitor")
	darkspawn_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return darkspawn_icon
