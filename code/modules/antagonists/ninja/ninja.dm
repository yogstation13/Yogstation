GLOBAL_LIST_EMPTY(ninja_capture)

/datum/antagonist/ninja
	name = "Ninja"
	antagpanel_category = "Ninja"
	job_rank = ROLE_NINJA
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	var/helping_station = FALSE
	var/give_objectives = TRUE
	var/give_equipment = TRUE

/datum/antagonist/ninja/New()
	if(helping_station)
		can_hijack = HIJACK_PREVENT
	. = ..()

/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	for(var/obj/item/implant/explosive/E in M.implants)
		if(E)
			RegisterSignal(E, COMSIG_IMPLANT_ACTIVATED, .proc/on_)
	update_ninja_icons_added(M)

/datum/antagonist/ninja/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	for(var/obj/item/implant/explosive/E in M.implants)
		if(E)
			UnregisterSignal(M, COMSIG_IMPLANT_ACTIVATED)
	update_ninja_icons_removed(M)

/datum/antagonist/ninja/proc/equip_space_ninja(mob/living/carbon/human/H = owner.current)
	return H.equipOutfit(/datum/outfit/ninja)

/datum/antagonist/ninja/proc/addMemories()
	antag_memory += "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!<br>"
	antag_memory += "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by clicking the initialize UI button, to use abilities like stealth)!<br>"
	antag_memory += "Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.<br>"
	name = "[helping_station?"Nanotrasen Ninja":"Syndicate Ninja"]" // yogs - ninja disposition

/datum/antagonist/ninja/proc/addObjectives(quantity = 6)
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M.current && M.current.stat != DEAD)
			if(ishuman(M.current))
				if(M.special_role)
					possible_targets[M] = 0						//bad-guy
				else if(M.assigned_role in GLOB.command_positions)
					possible_targets[M] = 1						//good-guy

	var/list/possible_objectives = list(1,2,3,4)

	while(objectives.len < quantity)
		switch(pick_n_take(possible_objectives))
			if(1)	//research
				var/datum/objective/download/O = new /datum/objective/download()
				O.owner = owner
				O.gen_amount_goal()
				objectives += O

			if(2)	//steal
				var/datum/objective/steal/special/O = new /datum/objective/steal/special()
				O.owner = owner
				O.find_target()
				objectives += O

			if(3)	//protect/kill
				if(!possible_targets.len)	continue
				var/index = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[index]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(index,index+1)

				if(is_bad_guy ^ helping_station)			//kill (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/assassinate/O = new /datum/objective/assassinate()
					O.owner = owner
					O.target = M
					O.explanation_text = "Slay \the [M.current.real_name], the [M.assigned_role]."
					objectives += O
				else										//protect
					var/datum/objective/protect/O = new /datum/objective/protect()
					O.owner = owner
					O.target = M
					O.explanation_text = "Protect \the [M.current.real_name], the [M.assigned_role], from harm."
					objectives += O
			if(4)	//debrain/capture
				if(!possible_targets.len)	continue
				var/selected = rand(1,possible_targets.len)
				var/datum/mind/M = possible_targets[selected]
				var/is_bad_guy = possible_targets[M]
				possible_targets.Cut(selected,selected+1)

				if(is_bad_guy ^ helping_station)			//debrain (good-ninja + bad-guy or bad-ninja + good-guy)
					var/datum/objective/debrain/O = new /datum/objective/debrain()
					O.owner = owner
					O.target = M
					O.explanation_text = "Steal the brain of [M.current.real_name]."
					objectives += O
				else										//capture
					var/datum/objective/capture/O
					if(helping_station) {
						O = new /datum/objective/capture()
					} else {
						O = new /datum/objective/capture/living()
					}
					O.owner = owner
					O.gen_amount_goal()
					objectives += O
			else
				break
	var/datum/objective/O = new /datum/objective/survive()
	O.owner = owner
	objectives += O

/proc/remove_ninja(mob/living/L)
	if(!L || !L.mind)
		return FALSE
	var/datum/antagonist/datum = L.mind.has_antag_datum(/datum/antagonist/ninja)
	datum.on_removal()
	return TRUE

/proc/is_ninja(mob/living/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/ninja)


/datum/antagonist/ninja/greet()
	SEND_SOUND(owner.current, sound('sound/effects/ninja_greeting.ogg'))
	to_chat(owner.current, "I am an elite mercenary assassin of the mighty Spider Clan. A <font color='red'><B>SPACE NINJA</B></font>!")
	to_chat(owner.current, "Surprise is my weapon. Shadows are my armor. Without them, I am nothing. (//initialize your suit by right clicking on it, to use abilities like stealth)!")
	to_chat(owner.current, "Officially, [helping_station?"Nanotrasen":"The Syndicate"] are my employer.")
	to_chat(owner.current, "<b>If you are new to playing the Space Ninja, please review the <a href='https://wiki.yogstation.net/wiki/Space_Ninja'>Space Ninja</a> wiki entry for explanations and abilities.</b>") //Yogs
	if(helping_station) {
		to_chat(owner.current, "<b>As a Nanotrasen ninja, you are beholden to <a href='https://forums.yogstation.net/help/rules/#rule-3_1_1'>rule 3.1.1</a>: Do not murderbone.</b>")
	}
	owner.announce_objectives()
	return

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()
	if(give_equipment)
		equip_space_ninja(owner.current)
	. = ..()

/datum/antagonist/ninja/proc/on_()
	for(var/mob/L in GLOB.ninja_capture)
		if(get_area(L) == GLOB.areas_by_type[/area/centcom/holding])
			if(!L)
				continue
			var/atom/movable/target = L
			if(isobj(L.loc))
				target = L.loc
			target.forceMove(get_turf(pick(GLOB.generic_event_spawns)))
			if(isliving(L))
				var/mob/living/LI = L
				LI.Knockdown(120)
				LI.blind_eyes(10)
				to_chat(L, span_danger("You lose your footing as the dojo suddenly disappears. You're free!"))
				playsound(L, 'sound/effects/phasein.ogg', 25, 1)
				playsound(L, 'sound/effects/sparks2.ogg', 50, 1)
		GLOB.ninja_capture -= L

/datum/antagonist/ninja/admin_add(datum/mind/new_owner,mob/admin)
	var/adj
	switch(input("What kind of ninja?", "Ninja") as null|anything in list("Random","Syndicate","Nanotrasen","No objectives"))
		if("Random")
			helping_station = pick(TRUE,FALSE)
			adj = ""
		if("Syndicate")
			helping_station = FALSE
			adj = "syndie"
		if("Nanotrasen")
			helping_station = TRUE
			adj = "friendly"
		if("No objectives")
			give_objectives = FALSE
			adj = "objectiveless"
		else
			return
	if(helping_station)
		can_hijack = HIJACK_PREVENT
	new_owner.assigned_role = ROLE_NINJA
	new_owner.special_role = ROLE_NINJA
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has [adj] ninja'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has [adj] ninja'ed [key_name(new_owner)].")

/datum/antagonist/ninja/proc/update_ninja_icons_added(var/mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.join_hud(ninja)
	set_antag_hud(ninja, "ninja")

/datum/antagonist/ninja/proc/update_ninja_icons_removed(var/mob/living/carbon/human/ninja)
	var/datum/atom_hud/antag/ninjahud = GLOB.huds[ANTAG_HUD_NINJA]
	ninjahud.leave_hud(ninja)
	set_antag_hud(ninja, null)
