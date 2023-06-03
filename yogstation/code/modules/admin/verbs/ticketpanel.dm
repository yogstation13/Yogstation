GLOBAL_VAR_INIT(experimental_adminpanel, TRUE)

/datum/admin_help_tickets/ui_state(mob/user)
	return GLOB.holder_state

/datum/admin_help_tickets/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketListPanel")
		ui.open()

/datum/admin_help_tickets/ui_data(mob/user)
	. = list()
	.["unresolved_tickets"] = list()
	.["resolved_tickets"] = list()
	.["user_key"] = user.key

	for(var/i in 1 to tickets_list.len)
		var/datum/admin_help/ahelp = tickets_list[i]
		if(!istype(ahelp)) return

		var/ticket_data = list()
		ticket_data["name"] = ahelp.name
		ticket_data["id"] = ahelp.id
		ticket_data["index"] = i
		ticket_data["initiator_key_name"] = ahelp.initiator_key_name
		ticket_data["initiator_ckey"] = ahelp.initiator_ckey
		ticket_data["admin_key"] = ahelp.handling_admin_ckey
		ticket_data["active"] = ahelp.state == AHELP_ACTIVE

		ticket_data["has_client"] = !!ahelp.initiator
		ticket_data["has_mob"] = ticket_data["has_client"] && !!ahelp.initiator.mob

		if(ahelp.state == AHELP_ACTIVE)
			.["unresolved_tickets"] += list(ticket_data)
		else
			.["resolved_tickets"] += list(ticket_data)

/datum/admin_help_tickets/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/datum/admin_help/ticket = tickets_list[params["index"]]
	if(!ticket)
		return FALSE

	. = TRUE
	if(ticket_ui_act(action, ticket))
		return
	switch(action)
		if("view")
			ticket.TicketPanel()
			return
		if("reply")
			usr.client.cmd_admin_pm(ticket.initiator)
			return
	return FALSE

/datum/admin_help/ui_state(mob/user)
	return GLOB.always_state

/datum/admin_help/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketPanel")
		ui.open()

/datum/admin_help/ui_data(mob/user)
	. = list()
	.["is_admin"] = !!user.client.holder
	.["name"] = name
	.["id"] = id
	.["admin"] = handling_admin_ckey
	.["is_resolved"] = state != AHELP_ACTIVE
	.["initiator_key_name"] = initiator_key_name
	.["popups"] = popups_enabled

	var/mob/initiator_mob = initiator && initiator.mob
	var/datum/mind/initiator_mind = initiator_mob && initiator_mob.mind
	.["has_client"] = !!initiator
	.["has_mob"] = !!initiator_mob
	.["role"] = initiator_mind && initiator_mind.assigned_role
	.["antag"] = initiator_mind && initiator_mind.special_role

	var/location = ""
	if(initiator_mob)
		var/turf/T = get_turf(initiator.mob)
		location = "([initiator.mob.loc == T ? "" : "in [initiator.mob.loc] at "][T.x], [T.y], [T.z]"
		if(isturf(T))
			if(isarea(T.loc))
				location += " in area [T.loc]"
		location += ")"
	.["location"] = location

	.["log"] = list()

	for(var/datum/ticket_log/TL as anything in _interactions)
		var/log_data = list()
		log_data["time"] = TL.gametime
		log_data["user"] = TL.user
		log_data["text"] = TL.text
		log_data["for_admins"] = TL.for_admins
		.["log"] += list(log_data)


/datum/admin_help/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	. = TRUE
	if(ticket_ui_act(action, src))
		return

	switch(action)
		if("send_message")
			var/message = params["message"]
			if(usr.client.holder)
				usr.client.cmd_admin_pm(initiator, message)
				return
			if(usr.client.current_ticket != src)
				to_chat(usr, "<span class=warning>You are not able to reply to this ticket. To open a ticket, please use the adminhelp verb")
			if(handling_admin_ckey)
				var/prefix = discord_admin ? "$" : ""
				usr.client.cmd_admin_pm("[prefix][handling_admin_ckey]", message)
			else
				MessageNoRecipient(message)
			return
	return FALSE

/proc/ticket_ui_act(action, T)
	var/datum/admin_help/ticket = T
	if(!ticket)
		return
	. = TRUE
	switch(action)
		if("adminmoreinfo")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.holder.adminmoreinfo(ticket.initiator.mob)
			return
		if("PP")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.holder.show_player_panel(ticket.initiator.mob)
			return
		if("VV")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.debug_variables(ticket.initiator.mob)
			return
		if("SM")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.cmd_admin_subtle_message(ticket.initiator.mob)
			return
		if("FLW")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.holder.observe_follow(ticket.initiator.mob)
			return
		if("CA")
			usr.client.check_antagonists()
			return
		if("Resolve")
			ticket.Resolve()
			return
		if("Reject")
			ticket.Reject()
			return
		if("Close")
			ticket.Close()
			return
		if("IC")
			ticket.ICIssue()
			return
		if("MHelp")
			ticket.MhelpQuestion()
			return
		if("togglePopups")
			ticket.PopUps()
			return
		if("Administer")
			ticket.Administer(TRUE)
			return
		if("Wiki")
			ticket.WikiIssue()
			return
		if("Bug")
			ticket.GithubIssue()
			return
		if("TP")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.holder.show_traitor_panel(ticket.initiator.mob)
			return
		if("Logs")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			show_individual_logging_panel(ticket.initiator.mob)
			return
		if("Smite")
			if(!ticket.initiator)
				to_chat(usr, span_warning("Client not found"))
				return
			usr.client.smite(ticket.initiator.mob)
			return
	return FALSE
