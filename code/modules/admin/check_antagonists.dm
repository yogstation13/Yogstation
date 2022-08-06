//I wish we had interfaces sigh, and i'm not sure giving team and antag common root is a better solution here

//Whatever interesting things happened to the antag admins should know about
//Include additional information about antag in this part
/datum/antagonist/proc/antag_listing_status()
	if(!owner)
		return "(Unassigned)"
	if(!owner.current)
		return "(Body destroyed)"
	else
		if(owner.current.stat == DEAD)
			return "(DEAD)"
		else if(!owner.current.client && !owner.current.oobe_client) //yogs - oobe_client
			return "(No client)"

// Antag constructor
/datum/antagonist/proc/antag_listing_entry()
	var/list/antag_construct
	if(owner.current) // [0:"Traitor", 1:"Joe Schmoe", 2:"(DEAD)", 3:"[0x2100b3a5]", 4:MOB?, 5:CLIENT?, 6:Antag/Datum]
		antag_construct = list(list(name, antag_listing_name(), antag_listing_status(), REF(src), TRUE, owner.current.client, src))
	else
		antag_construct = list(list(name, antag_listing_name(), antag_listing_status(), REF(src), FALSE, FALSE, src))
	return antag_construct

/datum/antagonist/proc/antag_listing_name()
	if(!owner)
		return "Unassigned"
	if(owner.current)
		return owner.current.real_name
	else
		return owner.name

/datum/team/proc/get_team_antags(antag_type,specific = FALSE)
	. = list()
	for(var/datum/antagonist/A in GLOB.antagonists)
		if(A.get_team() == src && (!antag_type || !specific && istype(A,antag_type) || specific && A.type == antag_type))
			. += A

//Builds section for the team
/datum/team/proc/antag_listing_entry()
	//NukeOps:
	// Jim (Status) FLW PM TP
	// Joe (Status) FLW PM TP
	//Disk:
	// Deep Space FLW
	
	// Team constructor
	// [0: "TeamName", 1:[AntagConstructor, AntagConstructor], 2:[Name of Tracked, [[Name, TRACK_REF], [Name, TRACK_REF]]]]
	var/list/team_construct = list(antag_listing_name(), list(), list(FALSE,list()))
	for(var/datum/antagonist/A in get_team_antags())
		team_construct[2] += A.antag_listing_entry()
	return list(team_construct)

/datum/team/proc/antag_listing_name()
	return name

/datum/team/proc/antag_listing_footer()
	return

//Moves them to the top of the list if TRUE
/datum/antagonist/proc/is_gamemode_hero()
	return FALSE

/datum/team/proc/is_gamemode_hero()
	return FALSE

/datum/admins/proc/check_antagonists()
	if(!SSticker.HasRoundStarted())
		alert("The game hasn't started yet!")
		return
	if(!check_rights(0))
		return
	
	var/datum/tgui_check_antags/tgui = new(usr)//create the datum
	tgui.ui_interact(usr)

/datum/tgui_check_antags
	var/client/holder //client of whoever is using this datum

/datum/tgui_check_antags/ui_state(mob/user)
	return GLOB.admin_state

/datum/tgui_check_antags/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// Open UI
		ui = new(user, src, "CheckAntags")
		ui.open()

/datum/tgui_check_antags/ui_close()
	qdel(src)

/datum/tgui_check_antags/New(user) //user can either be a client or a mob
	if (user) //Prevents runtimes on datums being made without clients
		setup(user)

/datum/tgui_check_antags/proc/setup(user) //H can either be a client or a mob
	if (istype(user,/client))
		var/client/user_client = user
		holder = user_client //if its a client, assign it to holder
	else
		var/mob/user_mob = user
		holder = user_mob.client //if its a mob, assign the mob's client to holder

/datum/tgui_check_antags/ui_data(mob/user)
	var/list/data = list()
	var/connected_players = GLOB.clients.len
	var/lobby_players = 0
	var/observers = 0
	var/observers_connected = 0
	var/living_players = 0
	var/living_players_connected = 0
	var/living_players_antagonist = 0
	var/brains = 0
	var/other_players = 0
	var/living_skipped = 0
	var/drones = 0
	for(var/mob/M in GLOB.mob_list)
		if(M.ckey)
			if(isnewplayer(M))
				lobby_players++
				continue
			else if(M.stat != DEAD && M.mind && !isbrain(M))
				if(isdrone(M))
					drones++
					continue
				if(is_centcom_level(M.z))
					living_skipped++
					continue
				living_players++
				if(M.mind.special_role)
					living_players_antagonist++
				if(M.client)
					living_players_connected++
			else if(M.stat == DEAD || isobserver(M))
				observers++
				if(M.client)
					observers_connected++
			else if(isbrain(M))
				brains++
			else
				other_players++
	
	var/list/all_antagonists = list()
	var/list/antagonist_types = list()

	var/list/all_teams = list()
	var/list/priority_sections = list()
	var/list/sections = list()

	for(var/datum/antagonist/A in GLOB.antagonists)
		if(!A.owner)
			continue
		if(A.get_team())
			all_teams |= A.get_team()
	
	for(var/datum/team/T in all_teams)
		for(var/datum/antagonist/X in GLOB.antagonists)
			if(!X.owner)
				continue
			if(X.get_team() != T)
				all_antagonists += X.antag_listing_entry()
		if(T.is_gamemode_hero())
			priority_sections += T.antag_listing_entry()
		else
			sections += T.antag_listing_entry()
	
	for(var/X in all_antagonists)
		if(!antagonist_types.Find(X[1]))
			antagonist_types += X[1]

	data["mode"] = SSticker.mode.name
	data["replacementmode"] = SSticker.mode.replacementmode ? SSticker.mode.replacementmode.name : FALSE
	data["time"] = DisplayTimeText(world.time - SSticker.round_start_time)
	data["shuttlecalled"] = EMERGENCY_IDLE_OR_RECALLED
	data["shuttletransit"] = SSshuttle.emergency.mode == SHUTTLE_CALL
	var/timeleft = SSshuttle.emergency.timeLeft()
	data["shuttletime"] = "[(timeleft / 60) % 60]:[add_leading(num2text(timeleft % 60), 2, "0")]"
	data["continue1"] = CONFIG_GET(keyed_list/continuous)[SSticker.mode.config_tag]
	data["continue2"] = CONFIG_GET(keyed_list/midround_antag)[SSticker.mode.config_tag]
	data["midround_time_limit"] = CONFIG_GET(number/midround_antag_time_check)
	data["midround_living_limit"] = CONFIG_GET(number/midround_antag_life_check)
	data["end_on_death_limits"] = SSticker.mode.round_ends_with_antag_death
	data["connected_players"] = connected_players
	data["lobby_players"] = lobby_players
	data["observers"] = observers
	data["observers_connected"] = observers_connected
	data["living_players"] = living_players
	data["living_players_connected"] = living_players_connected
	data["living_players_antagonist"] = living_players_antagonist
	data["brains"] = brains
	data["other_players"] = other_players
	data["living_skipped"] = living_skipped
	data["drones"] = drones
	data["antags"] = all_antagonists
	data["antag_types"] = antagonist_types
	data["priority_sections"] = priority_sections
	data["sections"] = sections
	return data

/datum/tgui_check_antags/proc/check_rights(rights_required, show_msg=1)
	var/client/rights = holder
	var/mob/mob_user = rights.mob
	if(rights && mob_user)
		if (check_rights_for(rights, rights_required))
			return 1
		else
			if(show_msg)
				to_chat(mob_user, "<font color='red'>Error: You do not have sufficient rights to do that. You require one of the following flags:[rights2text(rights_required," ")].</font>", confidential=TRUE)
	return 0

/datum/tgui_check_antags/ui_act(action, params)
	if(..())
		return
	var/client/rights = holder
	var/datum/admins/admindatum = rights.holder
	var/mob/mob_user = rights.mob

	if(mob_user != usr)
		return

	switch(action)
		if("callshuttle")
			if(!check_rights(R_ADMIN))
				return
			if(EMERGENCY_AT_LEAST_DOCKED)
				return
			SSshuttle.emergency.request()
			log_admin("[key_name(mob_user)] called the Emergency Shuttle.")
			message_admins(span_adminnotice("[key_name_admin(mob_user)] called the Emergency Shuttle to the station."))

		if("recallshuttle")
			if(!check_rights(R_ADMIN))
				return
			if(EMERGENCY_AT_LEAST_DOCKED)
				return
			switch(SSshuttle.emergency.mode)
				if(SHUTTLE_CALL)
					SSshuttle.emergency.cancel()
					log_admin("[key_name(mob_user)] sent the Emergency Shuttle back.")
					message_admins(span_adminnotice("[key_name_admin(mob_user)] sent the Emergency Shuttle back."))
		
		if("edit_shuttle_time")
			if(!check_rights(R_SERVER))
				return
			if(params["time"] && text2num(params["time"]))
				var/timer = text2num(params["time"])
				SSshuttle.emergency.setTimer(timer*10)
				log_admin("[key_name(mob_user)] edited the Emergency Shuttle's timeleft to [timer] seconds.")
				minor_announce("The emergency shuttle will reach its destination in [round(SSshuttle.emergency.timeLeft(600))] minutes.")
				message_admins(span_adminnotice("[key_name_admin(mob_user)] edited the Emergency Shuttle's timeleft to [timer] seconds."))
		
		if("end_antag_death")
			if(!check_rights(R_ADMIN))
				return
			var/list/continuous = CONFIG_GET(keyed_list/continuous)
			continuous[SSticker.mode.config_tag] = FALSE
			message_admins(span_adminnotice("[key_name_admin(mob_user)] toggled the round to end with the antagonists."))
			

		if("cont_antag_death")
			if(!check_rights(R_ADMIN))
				return
			var/list/continuous = CONFIG_GET(keyed_list/continuous)
			continuous[SSticker.mode.config_tag] = TRUE
			message_admins(span_adminnotice("[key_name_admin(mob_user)] toggled the round to continue if all antagonists die."))

		if("dont_create_new")
			if(!check_rights(R_ADMIN))
				return
			var/list/midround_antag = CONFIG_GET(keyed_list/midround_antag)
			midround_antag[SSticker.mode.config_tag] = FALSE
			message_admins(span_adminnotice("[key_name_admin(mob_user)] toggled the round to skip the midround antag system."))

		if("create_new")
			if(!check_rights(R_ADMIN))
				return
			var/list/midround_antag = CONFIG_GET(keyed_list/midround_antag)
			midround_antag[SSticker.mode.config_tag] = TRUE
			message_admins(span_adminnotice("[key_name_admin(mob_user)] toggled the round to use the midround antag system."))

		if("midround_time_limit")
			if(!check_rights(R_ADMIN))
				return
			if(params["timelimit"] && text2num(params["timelimit"]))
				var/timer = text2num(params["timelimit"])
				CONFIG_SET(number/midround_antag_time_check, timer)
				message_admins(span_adminnotice("[key_name_admin(mob_user)] edited the maximum midround antagonist time to [timer] minutes."))

		if("living_crew_limit")
			if(!check_rights(R_ADMIN))
				return
			if(params["crewlimit"] && text2num(params["crewlimit"]))
				var/ratio = text2num(params["crewlimit"])
				CONFIG_SET(number/midround_antag_life_check, ratio / 100)
				message_admins(span_adminnotice("[key_name_admin(mob_user)] edited the midround antagonist living crew ratio to [ratio]% alive."))

		if("cont_death_limits")
			if(!check_rights(R_ADMIN) || SSticker.mode.round_ends_with_antag_death == 0)
				return
			SSticker.mode.round_ends_with_antag_death = 0
			message_admins(span_adminnotice("[key_name_admin(mob_user)] edited the midround antagonist system to continue as extended upon failure."))

		if("end_death_limits")
			if(!check_rights(R_ADMIN) || SSticker.mode.round_ends_with_antag_death == 1)
				return
			SSticker.mode.round_ends_with_antag_death = 1
			message_admins(span_adminnotice("[key_name_admin(mob_user)] edited the midround antagonist system to end the round upon failure."))

		if("end_round")
			if(!check_rights(R_ADMIN))
				return
			message_admins(span_adminnotice("[key_name_admin(mob_user)] is considering ending the round."))
			if(alert(mob_user, "This will end the round, are you SURE you want to do this?", "Confirmation", "Yes", "No") == "Yes")
				if(alert(mob_user, "Final Confirmation: End the round NOW?", "Confirmation", "Yes", "No") == "Yes")
					message_admins(span_adminnotice("[key_name_admin(mob_user)] has ended the round."))
					SSticker.force_ending = 1 //Yeah there we go APC destroyed mission accomplished
					return
				else
					message_admins(span_adminnotice("[key_name_admin(mob_user)] decided against ending the round."))
			else
				message_admins(span_adminnotice("[key_name_admin(mob_user)] decided against ending the round."))
		
		if("delay_round")
			if(!check_rights(R_ADMIN))
				return
			if(!SSticker.delay_end)
				SSticker.admin_delay_notice = input(usr, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text
				if(isnull(SSticker.admin_delay_notice))
					return
			else
				SSticker.admin_delay_notice = null
			SSticker.delay_end = !SSticker.delay_end
			var/reason = SSticker.delay_end ? "for reason: [SSticker.admin_delay_notice]" : "."//laziness
			var/msg = "[SSticker.delay_end ? "delayed" : "undelayed"] the round end [reason]"
			log_admin("[key_name(mob_user)] [msg]")
			message_admins("[key_name_admin(mob_user)] [msg]")
			if(SSticker.ready_for_reboot && !SSticker.delay_end) //we undelayed after standard reboot would occur
				SSticker.standard_reboot()

		if("toggle_ctf")
			if(!check_rights(R_ADMIN))
				return
			toggle_all_ctf(mob_user)

		if("trigger_reboot")
			if(!check_rights(R_ADMIN))
				return
			var/confirm = alert(mob_user, "Are you sure you want to reboot the server?", "Confirm Reboot", "Yes", "No")
			if(confirm == "No")
				return
			if(confirm == "Yes")
				admindatum.restart()
		
		if("check_teams")
			if(!check_rights(R_ADMIN))
				return
			admindatum.check_teams()

		if("plypp")
			if(!check_rights(R_ADMIN))
				return
			if(!params["player_objs"])
				return
			
			var/datum/antagonist/TR = locate(params["player_objs"]) in GLOB.antagonists

			if(!istype(TR))
				to_chat(mob_user, span_danger("Antag datum is invalid!"), confidential=TRUE)
				return
			
			if(!TR.owner)
				to_chat(mob_user, span_danger("Antag datum has no mind!"), confidential=TRUE)
				return
			
			if(!TR.owner.current)
				to_chat(mob_user, span_danger("Antag datum has no mob!"), confidential=TRUE)
				return
			
			admindatum.show_player_panel(TR.owner.current)
		
		if("plyvv")
			if(!check_rights(R_ADMIN))
				return
			if(!params["player_objs"])
				return
			
			var/datum/antagonist/TR = locate(params["player_objs"]) in GLOB.antagonists

			if(!istype(TR))
				to_chat(mob_user, span_danger("Antag datum is invalid!"), confidential=TRUE)
				return
			
			if(!TR.owner)
				to_chat(mob_user, span_danger("Antag datum has no mind!"), confidential=TRUE)
				return
			
			if(!TR.owner.current)
				to_chat(mob_user, span_danger("Antag datum has no mob!"), confidential=TRUE)
				return
			
			rights.debug_variables(TR.owner.current)

		if("plypm")
			if(!params["player_objs"])
				return
			
			var/datum/antagonist/TR = locate(params["player_objs"]) in GLOB.antagonists

			if(!istype(TR))
				to_chat(mob_user, span_danger("Antag datum is invalid!"), confidential=TRUE)
				return
			
			if(!TR.owner)
				to_chat(mob_user, span_danger("Antag datum has no mind!"), confidential=TRUE)
				return
			
			if(!TR.owner.current?.client)
				to_chat(mob_user, span_danger("Antag datum has no client to PM!"), confidential=TRUE)
				return

			rights.cmd_admin_pm(TR.owner.current.client, null)
		
		if("plyflw")
			if(!check_rights(R_ADMIN))
				return
			if(!params["player_objs"])
				return
			
			var/datum/antagonist/TR = locate(params["player_objs"]) in GLOB.antagonists

			if(!istype(TR))
				to_chat(mob_user, span_danger("Antag datum is invalid!"), confidential=TRUE)
				return
			
			if(!TR.owner)
				to_chat(mob_user, span_danger("Antag datum has no mind!"), confidential=TRUE)
				return
			
			if(!TR.owner.current)
				to_chat(mob_user, span_danger("Antag datum has no mob!"), confidential=TRUE)
				return
			
			admindatum.observe_follow(TR.owner.current)

		if("plyobj")
			if(!check_rights(R_ADMIN))
				return

			if(!SSticker.HasRoundStarted())
				alert("The game hasn't started yet!")
				return
			
			if(!params["player_objs"])
				return
			
			var/datum/antagonist/TR = locate(params["player_objs"]) in GLOB.antagonists

			if(!istype(TR))
				to_chat(mob_user, span_danger("Antag datum is invalid!"), confidential=TRUE)
				return
			
			if(!TR.owner)
				to_chat(mob_user, span_danger("Antag datum has no mind!"), confidential=TRUE)
				return
			
			var/datum/mind/M = TR.owner

			M.traitor_panel()
		
		if("objflw")
			if(!check_rights(R_ADMIN))
				return
			if(!params["objref"])
				return
			
			var/atom/OB = locate(params["objref"])

			if(!istype(OB))
				to_chat(mob_user, span_danger("Atom is invalid!"), confidential=TRUE)
				return

			admindatum.observe_follow(OB)
