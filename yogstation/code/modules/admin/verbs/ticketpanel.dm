GLOBAL_VAR_INIT(experimental_adminpanel, TRUE)

/datum/ticket_list_panel
	var/client/holder

/datum/ticket_list_panel/New(user)
	if(user)
		setup(user)

/datum/ticket_list_panel/proc/setup(user)
	if(istype(user,/client))
		holder = user
	else
		var/mob/user_mob = user
		holder = user_mob.client

	ui_interact(holder.mob)

/datum/ticket_list_panel/ui_state(mob/user)
	return GLOB.holder_state

/datum/ticket_list_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TicketListPanel")
		ui.open()

/datum/ticket_list_panel/ui_data(mob/user)
	. = list()
	.["unresolved_tickets"] = list()
	.["resolved_tickets"] = list()

	for(var/datum/admin_help/ahelp as anything in GLOB.ahelp_tickets.tickets_list)
		var/ticket_data = list()
		ticket_data["name"] = ahelp.name
		ticket_data["id"] = ahelp.id
		ticket_data["initiator_key_name"] = ahelp.initiator_key_name
		ticket_data["initiator_ckey"] = ahelp.initiator_ckey
		ticket_data["admin_key"] = ahelp.handling_admin && ahelp.handling_admin.key
		ticket_data["active"] = ahelp.state == AHELP_ACTIVE

		if(ahelp.state == AHELP_ACTIVE)
			.["unresolved_tickets"] += list(ticket_data)
		else
			.["resolved_tickets"] += list(ticket_data)

/datum/ticket_list_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/datum/admin_help/ticket = GLOB.ahelp_tickets.tickets_list[params["id"]]

	switch(action)
		if("view")
			ticket.TicketPanel()
		if("adminmoreinfo")
			if(!ticket.initiator)
				to_chat(holder, "<span class='warning'>Client not found</span>")
				return
			holder.holder.adminmoreinfo(ticket.initiator.mob)
		if("PP")
			if(!ticket.initiator)
				to_chat(holder, "<span class='warning'>Client not found</span>")
				return
			holder.holder.show_player_panel(ticket.initiator.mob)
		if("VV")
			if(!ticket.initiator)
				to_chat(holder, "<span class='warning'>Client not found</span>")
				return
			holder.debug_variables(ticket.initiator.mob)
		if("SM")
			if(!ticket.initiator)
				to_chat(holder, "<span class='warning'>Client not found</span>")
				return
			holder.cmd_admin_subtle_message(ticket.initiator.mob)
		if("FLW")
			if(!ticket.initiator)
				to_chat(holder, "<span class='warning'>Client not found</span>")
				return
			holder.holder.observe_follow(ticket.initiator.mob)
		if("CA")
			holder.check_antagonists()
		if("Resolve")
			ticket.Resolve()
		if("Reject")
			ticket.Reject()
		if("Close")
			ticket.Close()
		if("IC")
			ticket.ICIssue()
