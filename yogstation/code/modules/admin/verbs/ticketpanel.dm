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
