/client/verb/hotkeys_help()
	set name = "hotkeys-help"
	set category = "OOC"
	

	to_chat(src, "All hotkeys can be viewed and modified under Preferences -> Keybindings. Click on Default to switch to hotkeys mode")

/client/verb/show_tickets()
	set name = "Tickets"
	set desc = "Show list of tickets"
	set hidden = 1

	if(holder)
		view_tickets()
	else
		for(var/I in GLOB.ahelp_tickets.tickets_list)
			var/datum/admin_help/T = I
			if(compare_ckey(T.initiator_ckey, usr) && T.state == AHELP_ACTIVE)
				T.TicketPanel()
				return

		to_chat(src, "<span class='danger'>You have no open tickets!</span>")
	return
