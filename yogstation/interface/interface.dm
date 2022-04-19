/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"

	to_chat(src, "All hotkeys can be viewed and modified under Preferences -> Keybindings. Click on Default to switch to hotkeys mode")

/client/verb/show_tickets()
	set name = "Tickets"
	set desc = "Show list of tickets"
	set hidden = TRUE

	if(holder)
		view_tickets()
	else
		if(current_ticket && current_ticket.state == AHELP_ACTIVE)
			current_ticket.TicketPanel()
			return
		to_chat(src, span_danger("You have no open tickets!"))
	return
