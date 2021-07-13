GLOBAL_LIST_EMPTY(connection_logs)

/datum/connection_log
	var/datum/connection_entry/last_data_point
	var/first_login
	var/list/datum/connection_entry/data_points = list()

/datum/connection_log/New()
	first_login = world.time

/datum/connection_log/proc/logout(mob/C)
	var/datum/connection_entry/CE = new()
	CE.disconnected = world.time
	CE.disconnect_type = C.type
	CE.living = isliving(C)
	CE.job = C.mind?.assigned_role || "Ghost"
	last_data_point = CE
	data_points |= CE

/datum/connection_log/proc/login()
	if(last_data_point)
		last_data_point.connected = world.time

/datum/connection_entry
	var/disconnected
	var/connected
	var/disconnect_type
	var/living = FALSE
	var/job

/client/proc/disconnect_panel()
	set name = "Disconnection Panel"
	set desc = "Panel showing information about the currently disconneted players"
	set category = "Admin"
	if(!check_rights(R_ADMIN))
		return
	new /datum/disconnect_panel(usr)

/datum/disconnect_panel
	var/client/holder

/datum/disconnect_panel/New(user)
	if(user)
		setup(user)

/datum/disconnect_panel/proc/setup(user)
	if(istype(user,/client))
		holder = user
	else
		var/mob/user_mob = user
		holder = user_mob.client

	ui_interact(holder.mob)

/datum/disconnect_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/disconnect_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DisconnectPanel")
		ui.open()

/datum/disconnect_panel/ui_data(mob/user)
	. = list()
	.["world_time"] = world.time
	.["users"] = list()
	for(var/ckey in GLOB.connection_logs)
		var/datum/connection_log/CL = GLOB.connection_logs[ckey]
		if(!CL.last_data_point)
			continue

		var/ckey_data = list()
		ckey_data["ckey"] = ckey
		ckey_data["connected"] = !!CL.last_data_point.connected
		ckey_data["last"] = entry2ui(CL.last_data_point)

		for(var/datum/connection_entry/entry in CL.data_points)
			ckey_data["history"] += list(entry2ui(entry))

		.["users"] += list(ckey_data)

/datum/disconnect_panel/proc/entry2ui(datum/connection_entry/entry)
	. = list()
	.["disconnect"] = entry.disconnected
	.["connect"] = entry.connected
	.["type"] = entry.disconnect_type
	.["living"] = entry.living
	.["job"] = entry.job
