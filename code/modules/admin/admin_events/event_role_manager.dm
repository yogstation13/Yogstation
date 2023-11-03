GLOBAL_DATUM_INIT(event_role_manager, /datum/event_role_manager, new)

/client/proc/event_role_manager()
	set name = "Event Role Manager"
	set category = "Event"
	GLOB.event_role_manager.ui_interact(mob)

/datum/event_role_manager
	var/role_assignments = list()

/datum/event_role_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "EventRoleManager")
		ui.open()
		
/datum/event_role_manager/ui_state(mob/user)
	return GLOB.fun_state

/datum/event_role_manager/ui_data(mob/user)
	. = ..()

	var/list/assignments = list()
	for(var/ckey in role_assignments)
		var/ckey_data = list()
		var/datum/event_role_assignment/assignment = role_assignments[ckey]
		ckey_data["ckey"] = ckey
		ckey_data["title"] = assignment.title
		ckey_data["role_alt_title"] = assignment.role_alt_title
		assignments.Add(list(ckey_data))
	.["assignments"] = assignments

	var/jobs = list()
	for(var/job in SSjob.name_occupations_all)
		jobs += job
	.["jobs"] = jobs

/datum/event_role_manager/ui_act(action, params)
	if(..())
		return
	var/ckey = ckey(params["ckey"])
	switch(action)
		if("addCkey")
			LAZYSET(role_assignments, ckey, new /datum/event_role_assignment)
			return TRUE
		if("setTitle")
			var/datum/event_role_assignment/assignment = LAZYACCESS(role_assignments, ckey)
			if(assignment)
				assignment.title = params["title"]
			return TRUE
		if("setAltTitle")
			var/datum/event_role_assignment/assignment = LAZYACCESS(role_assignments, ckey)
			if(assignment)
				assignment.role_alt_title = params["alt_title"]
			return TRUE
		if("removeCkey")
			LAZYREMOVE(role_assignments, ckey)
			return TRUE

/datum/event_role_manager/proc/admin_status_panel(var/list/items)
	if(!LAZYLEN(role_assignments))
		return
	
	items += "Assigned player status:"

	for(var/ckey in role_assignments)
		var/client/client = GLOB.directory[ckey]
		if(!client)
			items += "<font color='red'>[ckey] is not connected</font>"
			continue
		var/mob/player = client.mob
		if(!istype(player, /mob/dead/new_player))
			items += "<font color='red'>[ckey] is type [player.type]</font>"
		else
			var/mob/dead/new_player/new_player = player
			if(new_player.ready == PLAYER_READY_TO_PLAY)
				items += "<font color='green'>[ckey] - Ready</font>"
			else
				items += "<font color='red'>[ckey] - Not Ready</font>"

/datum/event_role_manager/proc/setup_event_positions()
	for(var/ckey in role_assignments)
		var/client/client = GLOB.directory[ckey]
		if(!client)
			message_admins("[ckey] is not connected")
			continue
		var/mob/player = client.mob
		var/datum/event_role_assignment/assignment = role_assignments[ckey]
		if(!istype(player, /mob/dead/new_player))
			message_admins("[ckey] is not in the lobby!")
			continue
		if(assignment.title)
			player.mind.assigned_role = assignment.title
		if(assignment.role_alt_title)
			player.mind.role_alt_title = assignment.role_alt_title
		SSjob.unassigned -= player

		var/mob/dead/new_player/new_player = player
		if(new_player.ready != PLAYER_READY_TO_PLAY)
			message_admins("[ckey] is not ready, forcing ready")
			new_player.ready = PLAYER_READY_TO_PLAY

/datum/event_role_assignment
	var/title
	var/role_alt_title
