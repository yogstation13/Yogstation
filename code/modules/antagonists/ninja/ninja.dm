GLOBAL_LIST_EMPTY(ninja_capture)

/datum/antagonist/ninja
	name = "Ninja"
	antagpanel_category = "Ninja"
	job_rank = ROLE_NINJA
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	antag_moodlet = /datum/mood_event/focused
	var/give_objectives = TRUE
	var/give_equipment = TRUE

/datum/antagonist/ninja/apply_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	for(var/obj/item/implant/explosive/E in M.implants)
		if(E)
			RegisterSignal(E, COMSIG_IMPLANT_ACTIVATED, .proc/on_death)
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
	antag_memory += "I am not allied to the Syndicate nor NanoTrasen. I am not complete my objectives without drawing too much attention."
	name = "Spider Clan Ninja"

/datum/antagonist/ninja/proc/addObjectives(quantity = 4)

	var/list/possible_objectives = list(1,2,2,2,3,3,4)

	while(objectives.len < quantity)
		switch(pick_n_take(possible_objectives))
			if(1)	//research
				var/datum/objective/download/O = new
				O.owner = owner
				O.gen_amount_goal()
				objectives += O

			if(2)	//steal
				var/datum/objective/steal/special/O = new
				O.owner = owner
				O.find_target()
				objectives += O

			if(3)	//kill
				var/datum/objective/assassinate/A = pick(/datum/objective/assassinate, /datum/objective/assassinate/cloned, /datum/objective/assassinate/once)
				A = new A
				A.owner = owner
				A.find_target()
				objectives += A
				if(A.target && prob(20))
					var/datum/objective/minor/deadpics/D = new
					D.owner = owner
					D.target = A.target
					objectives += D
			if(4)	//debrain/capture
				var/datum/objective/protect/P = new
				P.owner = owner
				P.find_target()
				objectives += P
				if(P.target && prob(20))
					var/datum/objective/maroon/M = new
					M.owner = owner
					M.target = P.target
					objectives += M
			else //Failsafe.
				break

	var/datum/objective/survive/O = new
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
	to_chat(owner.current, "I am not allied to the Syndicate nor NanoTrasen. I am not complete my objectives without drawing too much attention.")
	to_chat(owner.current, "<b>If you are new to playing the Space Ninja, please review the <a href='https://wiki.yogstation.net/wiki/Space_Ninja'>Space Ninja</a> wiki entry for explanations and abilities.</b>") //Yogs
	to_chat(owner.current, "<b>As a Ninja, you are beholden to <a href='https://forums.yogstation.net/help/rules/#rule-3_1_1'>rule 3.1.1</a>: Do not murderbone.</b>")
	owner.announce_objectives()
	return

/datum/antagonist/ninja/on_gain()
	if(give_objectives)
		addObjectives()
	addMemories()
	if(give_equipment)
		equip_space_ninja(owner.current)
	. = ..()

/datum/antagonist/ninja/proc/on_death()
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
	switch(input("What kind of ninja?", "Ninja") as null|anything in list("Normal", "No objectives"))
		if("Normal")
			give_objectives = TRUE
			adj = "normal"
		if("No objectives")
			give_objectives = FALSE
			adj = "objectiveless"
		else
			return
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
