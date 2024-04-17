/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawn"
	antagpanel_category = "Darkspawn"
	job_rank = ROLE_DARKSPAWN
	antag_hud_name = "darkspawn"
	ui_name = "AntagInfoDarkspawn"
	antag_moodlet = /datum/mood_event/sling

	//team used for all the darkspawns, thralls, and the objective
	var/datum/team/darkspawn/team
	///name of the player character before the divulge
	var/disguise_name 
	///name of the player character after the divulge
	var/darkspawn_name 
	///keeps track of where the darkspawn player is in progression
	var/darkspawn_state = DARKSPAWN_MUNDANE //0 for normal crew, 1 for divulged, and 2 for progenitor
	///Component that keeps track of all the spells a darkspawn can learn
	var/datum/component/darkspawn_class/picked_class

	//Psi variables
	//Psi is the resource used for darkspawn powers
	///Currently available psi
	var/psi = 100 
	///Maximum amount of psi
	var/psi_cap = 100 
	///How long before psi starts regenerating
	var/psi_regen_delay = 9 SECONDS 
	///how much psi is regenerated per second once it does start regenerating
	var/psi_per_second = 20 
	///When this finishes it's cooldown, regenerate Psi and restart
	COOLDOWN_DECLARE(psi_cooldown)
	///Used to prevent duplicate regen proc calls
	var/psi_regenerating = FALSE 
 
 	///Willpower is used to buy abilities and is gained by using Devour Will
	var/willpower = 6

	///Default amount healed in darkness
	var/dark_healing = 8
	///Default amount of damage taken in light
	var/light_burning = 7
	///These three variables 
	///multiplies brute damage taken
	var/brute_mod = 1
	///multiplies burn damage taken
	var/burn_mod = 1
	///multiplies stamina damage taken
	var/stam_mod = 1

	///Boolean, if the player has been notified that they are being revived by undying sigils
	var/revive_notice = FALSE

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Gain and loss stuff---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/on_gain()
	START_PROCESSING(SSprocessing, src)
	owner.special_role = "darkspawn"
	for (var/T in GLOB.antagonist_teams)
		if (istype(T, /datum/team/darkspawn))
			team = T
	if(!team)
		team = new
	team.add_member(owner)
	return ..()

/datum/antagonist/darkspawn/on_removal()
	STOP_PROCESSING(SSprocessing, src)
	owner.special_role = null
	if(team)
		team.remove_member(owner)
	owner.current.hud_used.psi_counter.invisibility = initial(owner.current.hud_used.psi_counter.invisibility)
	owner.current.hud_used.psi_counter.maptext = ""
	QDEL_NULL(picked_class)
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

	current_mob.faction |= ROLE_DARKSPAWN

	//for panopticon
	if(current_mob)
		current_mob.AddComponent(/datum/component/internal_cam, list(ROLE_DARKSPAWN))
		var/datum/component/internal_cam/cam = current_mob.GetComponent(/datum/component/internal_cam)
		if(cam)
			cam.change_cameranet(GLOB.thrallnet)

	//divulge
	if(darkspawn_state == DARKSPAWN_MUNDANE)
		var/datum/action/cooldown/spell/divulge/action = locate() in current_mob.actions
		if(!action)
			action = new(owner)
			action.Grant(current_mob)
		addtimer(CALLBACK(src, PROC_REF(begin_force_divulge)), 20 MINUTES) //this won't trigger if they've divulged when the proc runs

/datum/antagonist/darkspawn/remove_innate_effects()
	owner.current.remove_language(/datum/language/darkspawn)
	owner.current.faction -= ROLE_DARKSPAWN
	if(owner.current)
		qdel(owner.current.GetComponent(/datum/component/internal_cam))

	for(var/datum/action/cooldown/spell/spells in owner.current.actions) //remove divulge if they haven't yet
		if(istype(spells, /datum/action/cooldown/spell/divulge))
			spells.Remove(owner.current)
			qdel(spells)

////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Antag hud---------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/add_team_hud(mob/target, antag_to_check)
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
//------------------------------------Greet---------------------------------------//
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

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Antag Team stuff----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/get_team()
	return team

/datum/antagonist/darkspawn/create_team(datum/team/darkspawn/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

////////////////////////////////////////////////////////////////////////////////////
//----------------------------UI and Psi web stuff--------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/ui_data(mob/user)
	var/list/data = list()

	data["willpower"] = willpower
	data["objectives"] = get_objectives()
	data["divulged"] = (darkspawn_state > DARKSPAWN_MUNDANE)
	data["ascended"] = (darkspawn_state == DARKSPAWN_PROGENITOR)
	data["has_class"] = picked_class
	if(team)
		data["lucidity_drained"] = team.lucidity
		data["max_thralls"] = team.max_thralls
		data["current_thralls"] = LAZYLEN(team.thralls)
		if(LAZYLEN(team.thralls))
			var/list/thrall_names = list()
			for(var/datum/mind/dude in team.thralls)
				thrall_names += dude.name
			data["thrall_names"] += list(thrall_names)

	var/list/categories = list(STORE_OFFENSE, STORE_UTILITY, STORE_PASSIVE)
	for(var/category in categories)
		var/list/category_data = list()
		category_data["name"] = category

		var/list/paths = list()

		if(picked_class)
			for(var/datum/psi_web/knowledge as anything in picked_class.get_purchasable_abilities())
				if(category != initial(knowledge.menu_tab))
					continue

				var/list/knowledge_data = list()
				knowledge_data["path"] = knowledge
				knowledge_data["name"] = initial(knowledge.name)
				knowledge_data["desc"] = initial(knowledge.desc)
				knowledge_data["lore_description"]  = initial(knowledge.lore_description)
				knowledge_data["cost"] = initial(knowledge.willpower_cost)
				knowledge_data["disabled"] = (initial(knowledge.willpower_cost) > willpower)
				knowledge_data["infinite"] = (initial(knowledge.infinite))
				if(initial(knowledge.icon_state)) //only include an icon if one actually exists
					knowledge_data["icon"] = icon2base64(icon(initial(knowledge.icon), initial(knowledge.icon_state)))

				paths += list(knowledge_data)
		
		category_data["knowledgeData"] = paths
		data["categories"] += list(category_data)

	return data

/datum/antagonist/darkspawn/ui_static_data(mob/user)
	var/list/data = list()
	
	data["antag_name"] = name

	for(var/datum/component/darkspawn_class/class as anything in subtypesof(/datum/component/darkspawn_class))
		if(!initial(class.choosable))
			continue
		var/list/class_data = list()
		class_data["path"] = class
		class_data["name"] = initial(class.name)
		class_data["color"] = initial(class.class_color)
		class_data["description"] = initial(class.description)
		class_data["long_description"] = initial(class.long_description)

		data["classData"] += list(class_data)

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
			SEND_SIGNAL(owner, COMSIG_DARKSPAWN_PURCHASE_POWER, upgrade_path)
		if("select")
			if(picked_class)
				return FALSE
			var/class_path = text2path(params["class_path"])
			if(!ispath(class_path, /datum/component/darkspawn_class))
				return FALSE
			picked_class = owner.AddComponent(class_path)
			var/processed_message = span_velvet("<b>\[Mindlink\] [owner.current] has selected [picked_class.name] as their class.</b>")
			for(var/T in GLOB.alive_mob_list)
				var/mob/M = T
				if(is_darkspawn_or_thrall(M))
					to_chat(M, processed_message)

/datum/antagonist/darkspawn/ui_status(mob/user, datum/ui_state/state)
	if(user.stat == DEAD)
		return UI_CLOSE
	return ..()
	
////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Process proc-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/process(delta_time)
	psi = min(psi, psi_cap)
	if(psi < psi_cap && COOLDOWN_FINISHED(src, psi_cooldown) && !psi_regenerating)
		if(HAS_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK))
			return //prevent regeneration
		regenerate_psi()
	update_psi_hud()

	//low probability because i want it to be super rare and a "wait what the FUCK they can do that!?" type moment
	//if it becomes too common, then people stop putting darkspawn brains in mmi (which is metagaming, but whatever)
	if((rand(0, 10000) == 0) && owner.current && (isbrain(owner.current) || issilicon(owner.current)))//who in their RIGHT mind would put the brain of the PSIONIC antag into an mmi after you kill them
		addtimer(CALLBACK(src, PROC_REF(grant_reform)), rand(1, (20 MINUTES)), TIMER_UNIQUE) //give it a random delay before granting the ability, so it's luck squared to get it immediately

	if((owner?.current?.stat == DEAD) && HAS_TRAIT(src, TRAIT_DARKSPAWN_UNDYING) && ishuman(owner.current) && !QDELETED(owner.current))
		var/mob/living/carbon/human/deadguy = owner.current
		var/turf/location = get_turf(owner.current)
		var/light_amount = location.get_lumcount()
		if(light_amount < SHADOW_SPECIES_DIM_LIGHT)
			if(!revive_notice)
				deadguy.visible_message(span_notice("[deadguy]'s body twitches."), span_progenitor("Your body lurches as it refuses to be stopped by death."))
				revive_notice = TRUE
			deadguy.heal_ordered_damage(10, list(STAMINA, BURN, BRUTE, TOX, OXY, CLONE, BRAIN), BODYPART_ANY)
			if(deadguy.health >= deadguy.maxHealth)
				deadguy.grab_ghost()
				deadguy.revive(TRUE)
				revive_notice = FALSE
				deadguy.visible_message(span_progenitor("[deadguy]'s sigils flare brightly as they are once again in the realm of the living!"), span_progenitor("You rise once more!"))
				playsound(deadguy, 'yogstation/sound/magic/demented_outburst_scream.ogg', 40, FALSE)
		else if(revive_notice)
			revive_notice = FALSE
			deadguy.visible_message(span_notice("[deadguy]'s body stills."), span_velvet("Your body stills once more."))

	if(owner.current && ishuman(owner.current) && !isshadowperson(owner.current))
		var/datum/action/cooldown/spell/divulge/action = locate() in owner.current.actions
		if(!action)
			action = new(owner)
			action.Grant(owner.current)

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Psi regen and usage-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
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
	if(owner.current)
		owner.current.throw_alert("psiblock", /atom/movable/screen/alert/psiblock)
	addtimer(CALLBACK(src, PROC_REF(unblock_psi), identifier), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/antagonist/darkspawn/proc/unblock_psi(identifier)
	REMOVE_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK, identifier)
	if(!HAS_TRAIT(src, TRAIT_DARKSPAWN_PSIBLOCK) && owner.current)
		owner.current.clear_alert("psiblock")

/datum/antagonist/darkspawn/proc/update_psi_hud()
	if(!owner.current || !owner.current.hud_used)
		return
	var/atom/movable/screen/counter = owner.current.hud_used.psi_counter
	counter.maptext = ANTAG_MAPTEXT(psi, COLOR_DARKSPAWN_PSI)

////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Divulge--------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/proc/divulge(forced = FALSE)
	if(darkspawn_state >= DARKSPAWN_DIVULGED)
		return FALSE
		
	var/mob/living/carbon/human/user = owner.current

	if(!user || !istype(user))//sanity check
		return

	if(!picked_class) //you didn't pick, now it gets forced on you
		var/list/classes = list()
		for(var/datum/component/darkspawn_class/class as anything in subtypesof(/datum/component/darkspawn_class))
			if(initial(class.choosable))
				classes |= class

		var/chosen = pick(classes)

		picked_class = owner.AddComponent(chosen)
	
	owner.assigned_role = picked_class.name //they stop being whatever job they were the moment they divulge

	if(forced)
		owner.current.visible_message(
			span_boldwarning("[owner.current]'s skin sloughs off, revealing warping black flesh covered in symbols!"), 
			span_userdanger("You have forcefully divulged!"))

	for(var/datum/action/cooldown/spell/spells in user.actions) //remove the ability that triggers this
		if(istype(spells, /datum/action/cooldown/spell/divulge))
			spells.Remove(user)
			qdel(spells)

	user.fully_heal()
	disguise_name = user.real_name //keep track of the old name
	user.set_species(/datum/species/shadow/darkspawn)
	darkspawn_name = user.real_name //keep track of the new name
	user.update_appearance(UPDATE_OVERLAYS)

	show_to_ghosts = TRUE
	var/processed_message = span_velvet("<b>\[Mindlink\] [disguise_name] has removed their human disguise and is now [darkspawn_name].</b>")
	for(var/mob/M as anything in GLOB.alive_mob_list)
		if(M == user)
			continue
		if(is_team_darkspawn(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, null, user)

	darkspawn_state = DARKSPAWN_DIVULGED
	to_chat(user, span_velvet("Your mind has expanded. Avoid the light. Keep to the shadows. Your time will come."))
	to_chat(user, span_progenitor("Access to the Psi Web store has been unlocked in the antag menu."))
	to_chat(user, span_progenitor("Spend your [willpower] willpower to purchase abilities and upgrades."))
	return TRUE

////////////////////////////////////////////////////////////////////////////////////
//------------------------------Forced Divulge------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/proc/begin_force_divulge()
	if(darkspawn_state != DARKSPAWN_MUNDANE)
		return
	if(owner.current.stat == DEAD)
		return
	to_chat(owner.current, span_userdanger("You feel the skin you're wearing crackling like paper - you will forcefully divulge soon! Get somewhere hidden and dark!"))
	owner.current.playsound_local(owner.current, 'yogstation/sound/magic/divulge_01.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(force_divulge), 5 MINUTES))

/datum/antagonist/darkspawn/proc/force_divulge()
	if(darkspawn_state != DARKSPAWN_MUNDANE)
		return
	if(owner.current.stat == DEAD)
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
		if(M.stat != DEAD && is_team_darkspawn(M))
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

	if(!GLOB.sacrament_done)
		GLOB.sacrament_done = TRUE
		team.upon_sacrament()
		SSsecurity_level.set_level(SEC_LEVEL_DELTA)
		shatter_lights()
		addtimer(CALLBACK(src, PROC_REF(sacrament_shuttle_call)), 5 SECONDS)
		set_starlight(COLOR_VELVET) //i wanna change power and range, but that causes immense lag
		to_chat(world, span_velvet("Reality begins to quake and crack at the seams."))
		addtimer(CALLBACK(src, PROC_REF(start_overlay)), 15 SECONDS)
		SEND_GLOBAL_SIGNAL(COMSIG_DARKSPAWN_ASCENSION)

	SSachievements.unlock_achievement(/datum/achievement/greentext/darkspawn, user.client)

	for(var/datum/action/cooldown/spell/spells in user.actions) //they'll have progenitor specific abilities
		spells.Remove(user)
		qdel(spells)

	var/class_color = COLOR_DARKSPAWN_PSI
	var/datum/component/darkspawn_class/class = user.GetComponent(/datum/component/darkspawn_class)
	if(class && istype(class) && class.class_color)
		class_color = class.class_color //this line actually kinda hurts me
		
	// Spawn the progenitor
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = new(get_turf(user), user.real_name, class_color)
	user.mind.transfer_to(progenitor)

	psi = 9999
	psi_cap = 9999
	psi_per_second = 9999
	psi_regen_delay = 0
	update_psi_hud()

	darkspawn_state = DARKSPAWN_PROGENITOR
	QDEL_IN(user, 1)

///get rid of all lights by calling the light eater proc
/datum/antagonist/darkspawn/proc/shatter_lights()
	for(var/obj/machinery/light/L in GLOB.machines)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, on_light_eater)), rand(1, 50)) //stagger the "shatter" to reduce lag

///call a shuttle
/datum/antagonist/darkspawn/proc/sacrament_shuttle_call()
	SSshuttle.emergency.request(null, 0, null, 0.1)

/datum/antagonist/darkspawn/proc/start_overlay()
	to_chat(world, span_progenitor("SOMETHING IS WRONG."))
	for(var/mob/living/person in GLOB.player_list)
		person.AddComponent(/datum/component/shadowlands)

////////////////////////////////////////////////////////////////////////////////////
//----------------------------Reform body from brain------------------------------//
////////////////////////////////////////////////////////////////////////////////////
///proc used to delay the granting of the reform body ability
/datum/antagonist/darkspawn/proc/grant_reform()
	if(!owner.current || !(isbrain(owner.current) || issilicon(owner.current)))
		return
	var/datum/action/cooldown/spell/reform_body/recreance = locate() in owner.current.actions
	if(recreance)
		return
	recreance = new(owner)
	recreance.Grant(owner.current)

///creates a new human body for the darkspawn player and transfers their mind to it
/datum/antagonist/darkspawn/proc/reform_body()
	if(!owner.current)
		return

	for(var/datum/action/cooldown/spell/spells in owner.current.actions) //remove the ability that triggers this
		if(istype(spells, /datum/action/cooldown/spell/reform_body))
			spells.Remove(owner.current)
			qdel(spells)

	if(owner.current && !(isbrain(owner.current) || issilicon(owner.current)))
		return

	var/mob/living/old_body = owner.current
	var/mob/living/carbon/human/returner = new(get_turf(old_body))

	if(darkspawn_state >= DARKSPAWN_DIVULGED)//set them back to being a darkspawn
		returner.set_species(/datum/species/shadow/darkspawn)

	var/new_name = darkspawn_name || darkspawn_name()
	returner.fully_replace_character_name(null, new_name)
	owner.transfer_to(returner)
	returner.update_appearance(UPDATE_OVERLAYS)

	if(picked_class) //should bring back all powers, might be something i'm overlooking
		picked_class.refresh_powers()

	playsound(returner, 'yogstation/sound/magic/divulge_end.ogg', 50, 0)
	playsound(returner, 'yogstation/sound/creatures/darkspawn_death.ogg', 50, 0)
	
	var/processed_message = span_progenitor("<b>\[Mindlink\] [returner] has reformed their body.</b>")
	for(var/T in GLOB.alive_mob_list)
		var/mob/M = T
		if(is_team_darkspawn(M))
			to_chat(M, processed_message)
	deadchat_broadcast(processed_message, null, returner)

	if(isbrain(old_body))
		var/mob/living/brain/thinker = old_body
		if(thinker.container)
			qdel(thinker.container)
			return

	for(var/thing in old_body)
		qdel(thing)
	old_body.gib(TRUE, TRUE, TRUE)

////////////////////////////////////////////////////////////////////////////////////
//-------------------------------Preview icon-------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/get_preview_icon()
	var/icon/darkspawn_icon = icon('yogstation/icons/mob/human_parts.dmi', "darkspawn_head")
	darkspawn_icon.Blend(icon('yogstation/icons/mob/human_parts.dmi', "darkspawn_chest"), ICON_OVERLAY)
	darkspawn_icon.Blend(icon('yogstation/icons/mob/human_parts.dmi', "darkspawn_r_arm"), ICON_OVERLAY)
	darkspawn_icon.Blend(icon('yogstation/icons/mob/human_parts.dmi', "darkspawn_l_arm"), ICON_OVERLAY)
	darkspawn_icon.Blend(icon('yogstation/icons/mob/human_parts.dmi', "darkspawn_r_leg"), ICON_OVERLAY)
	darkspawn_icon.Blend(icon('yogstation/icons/mob/human_parts.dmi', "darkspawn_l_leg"), ICON_OVERLAY)

	var/class_color
	var/class_icon
	switch(rand(1,3))
		if(1)
			class_color = COLOR_YELLOW
			class_icon = "scout_sigils"
		if(2)
			class_color = COLOR_RED
			class_icon = "fighter_sigils"
		if(3)
			class_color = COLOR_STRONG_VIOLET
			class_icon = "warlock_sigils"
		
	var/icon/eyes = icon('yogstation/icons/mob/darkspawn.dmi', "eyes")
	eyes.Blend(class_color, ICON_MULTIPLY)
	darkspawn_icon.Blend(eyes, ICON_OVERLAY)

	var/icon/sigil = icon('yogstation/icons/mob/darkspawn.dmi', class_icon)
	sigil.Blend(class_color, ICON_MULTIPLY)
	darkspawn_icon.Blend(sigil, ICON_OVERLAY)

	return finish_preview_icon(darkspawn_icon)
	
////////////////////////////////////////////////////////////////////////////////////
//------------------------------Admin panel stuff---------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/datum/antagonist/darkspawn/get_admin_commands()
	. = ..()
	if(darkspawn_state == DARKSPAWN_MUNDANE)
		.["Force Divulge"] = CALLBACK(src, PROC_REF(divulge), TRUE)
	.["Set Lucidity"] = CALLBACK(src, PROC_REF(set_lucidity))
	.["Set Willpower"] = CALLBACK(src, PROC_REF(set_shop))
	.["Set Psi Values"] = CALLBACK(src, PROC_REF(set_psi))
	.["Set Max Thralls"] = CALLBACK(src, PROC_REF(set_max_thralls))
	if(picked_class)
		.["Refund Ability"] = CALLBACK(src, PROC_REF(refund_ability))
	.["Set Class"] = CALLBACK(src, PROC_REF(set_class))

/datum/antagonist/darkspawn/proc/set_lucidity(mob/admin)
	var/lucid = input(admin, "How much lucidity should all darkspawns have?") as null|num
	if(lucid && team)
		team.lucidity = lucid

/datum/antagonist/darkspawn/proc/set_shop(mob/admin)
	var/will = input(admin, "How much willpower should [owner] have?") as null|num
	if(will)
		willpower = will

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

/datum/antagonist/darkspawn/proc/set_max_thralls(mob/admin)
	var/thrall = input(admin, "How many thralls should the darkspawn team be able to get?") as null|num
	if(thrall && team)
		team.max_thralls = thrall

/datum/antagonist/darkspawn/proc/refund_ability(mob/admin)
	if(!picked_class)
		return

	var/list/abilities = list()
	for(var/datum/psi_web/ability as anything in picked_class.learned_abilities)
		if(initial(ability.willpower_cost)) //if there's even a cost to refund
			abilities |= ability
		
	if(!LAZYLEN(abilities))
		to_chat(admin, span_warning("There are no abilities to refund"))
		return

	var/datum/psi_web/picked_ability = tgui_input_list(admin, "Select which ability to refund.", "Select Ability", abilities)
	if(!picked_ability || !istype(picked_ability, /datum/psi_web))
		return
	
	if(QDELETED(src) || QDELETED(owner.current) || QDELETED(picked_class))
		return

	picked_class.lose_power(picked_ability, TRUE)

/datum/antagonist/darkspawn/proc/set_class(mob/admin)
	var/list/classes = list()
	for(var/datum/component/darkspawn_class/class as anything in subtypesof(/datum/component/darkspawn_class))
		if(initial(class.choosable))
			classes |= class
	classes |= "vvv Not regularly selectible vvv"
	classes |= subtypesof(/datum/component/darkspawn_class)
		
	var/chosen = tgui_input_list(admin, "Select which class to force on the target.", "Select Class", classes)
	if(!chosen || !ispath(chosen, /datum/component/darkspawn_class))
		return
	
	if(QDELETED(src) || QDELETED(owner.current))
		return

	picked_class = owner.AddComponent(chosen)
	if(darkspawn_state >= DARKSPAWN_DIVULGED)
		owner.assigned_role = picked_class.name //they stop being whatever job they were the moment they divulge

/datum/antagonist/darkspawn/antag_panel_data()
	if(team)
		. += "<b>Lucidity:</b> [team.lucidity ? team.lucidity : "0"] / [team.required_succs ? team.required_succs : "0"]<br>"
	. += "<b>Willpower:</b> [willpower ? willpower : "0"]<br>"
	. += "<b>Psi Cap:</b> [psi_cap]. <b>Psi per second:</b> [psi_per_second]. <b>Psi regen delay:</b> [psi_regen_delay ? "[psi_regen_delay/10] seconds" : "no delay"]<br>"
	if(team)
		. += "<b>Max Thralls:</b> [team.max_thralls ? team.max_thralls : "0"]<br>"

	var/datum/component/darkspawn_class/class = owner.GetComponent(/datum/component/darkspawn_class)
	if(class && istype(class) && class.learned_abilities)
		. += "<b>Upgrades:</b><br>"
		for(var/datum/psi_web/ability as anything in class.learned_abilities)
			. += "[ability.name]<br>"
