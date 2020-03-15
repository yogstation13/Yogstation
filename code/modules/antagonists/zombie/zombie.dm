/datum/antagonist/zombie
	name = "Zombie"
	roundend_category = "zombies"
	antagpanel_category = "Zombie"

	var/datum/action/innate/zombie/zomb/zombify = new
	var/datum/action/innate/zombie/talk/talko = new
	job_rank = ROLE_BLOB
	var/datum/team/zombie/team
	var/hud_type = "rev"


/datum/antagonist/zombie/get_team()
	return team

/datum/antagonist/zombie/create_team(datum/team/zombie/new_team)
	if(!new_team)
		//todo remove this and allow admin buttons to create more than one cult
		for(var/datum/antagonist/zombie/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.team)
				team = H.team
				return
		team = new /datum/team/zombie
		team.setup_objectives()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/antagonist/zombie/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/zombie/Destroy()
	QDEL_NULL(zombify)
	QDEL_NULL(talko)
	return ..()


/datum/antagonist/zombie/greet()
	to_chat(owner.current, "<B><font size=3 color=red>You have been infected with a zombie virus! In 10-15 minutes you will be able to turn into a zombie...</font><B>")
	to_chat(owner.current, "<b>Use the button at the top of the screen (When it appears) to activate the infection. It will kill you, but you will rise as a zombie shortly after!</a><b>") //Yogs
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/bloodcult.ogg', 100, FALSE, pressure_affected = FALSE)//subject to change
	owner.announce_objectives()

/datum/antagonist/zombie/on_gain()
	. = ..()
	var/mob/living/current = owner.current
	add_objectives()
	SSticker.mode.zombies += owner // Only add after they've been given objectives

	current.log_message("has been made a zombie!", LOG_ATTACK, color="#960000")

	var/datum/atom_hud/antag/revhud = GLOB.huds[ANTAG_HUD_REV]
	revhud.join_hud(current)
	set_antag_hud(current, hud_type)


/datum/antagonist/zombie/apply_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	current.faction |= "zombies"
	talko.Grant(current)

/datum/antagonist/zombie/remove_innate_effects()
	. = ..()
	var/mob/living/current = owner.current
	talko.Remove(current)
	current.faction -= "zombies"


/datum/antagonist/zombie/on_removal()
	SSticker.mode.zombies -= owner

	var/datum/atom_hud/antag/revhud = GLOB.huds[ANTAG_HUD_REV]
	revhud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
	. = ..()


/datum/antagonist/zombie/admin_add(datum/mind/new_owner,mob/admin)
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has zombied'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has zombied'ed [key_name(new_owner)].")


/datum/antagonist/zombie/get_admin_commands()
	. = ..()
	.["Give Button"] = CALLBACK(src,.proc/admin_give_button)
	.["Remove Button"] = CALLBACK(src,.proc/remove_button)

/datum/antagonist/zombie/proc/admin_give_button(mob/admin)
	zombify.Grant(owner.current)

/datum/antagonist/zombie/proc/remove_button(mob/admin)
	zombify.Remove(owner.current)


/datum/team/zombie
	name = "Zombies"



/datum/team/zombie/proc/setup_objectives()
	//SUMMON OBJECTIVE

	var/datum/objective/custom/obj = new()
	obj.name = "Kill EVERYONE!"
	obj.completed = TRUE
	objectives += obj



/datum/team/zombie/roundend_report()
	var/list/parts = list()
	parts += "<span class='greentext big'>BRAINS</span>"

	if(members.len)
		parts += "<span class='header'>The zombies were:</span>"
		parts += printplayerlist(members)

	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/action/innate/zombie
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS

/datum/action/innate/zombie/IsAvailable()
	if(!isinfected(owner))
		return FALSE
	return ..()

/datum/action/innate/zombie/zomb
	name = "Zombify!"
	desc = "Initiate the infection, and kill this host.. THIS ACTION IS INSTANT."
	button_icon_state = "cult_comms"

/datum/action/innate/zombie/zomb/Activate()
	var/mob/living/carbon/human/H = usr
	if(alert(H, "Are you sure you want to kill yourself, and revive as a zombie some time after?", "Confirmation", "Yes", "No") == "No")
		return FALSE

	if(!H.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/nodamage/ZI = new()
		ZI.Insert(H)

	H.death()

/datum/action/innate/zombie/talk
	name = "Chat"
	desc = "TALK TO ALL OF THEM!"
	button_icon_state = "cult_comms"

/datum/action/innate/zombie/talk/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other zombies.", "Voice of Blood", "")
	if(!input || !IsAvailable())
		return

	talk(usr, input)

/datum/action/innate/zombie/talk/proc/talk(mob/living/user, message)
	var/my_message
	if(!message)
		return
	var/title = "Zombie"
	var/span = "cult"
	my_message = "<span class='[span]'><b>[title] [findtextEx(user.name, user.real_name) ? user.name : "[user.real_name] (as [user.name])"]:</b> [message]</span>"
	for(var/i in GLOB.player_list)
		var/mob/M = i
		if(iszombo(M))
			to_chat(M, my_message)
		else if(M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, user)
			to_chat(M, "[link] [my_message]")

	user.log_talk(message, LOG_SAY, tag="cult")