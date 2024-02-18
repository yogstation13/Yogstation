#define MONITOR_MAINMENU 0
#define MONITOR_SERVERLOGS 1

/obj/machinery/computer/telecomms/server
	name = "telecommunications server monitoring console"
	icon_screen = "comm_logs"
	desc = "A computer dedicated to monitoring telecommunication server logs."

	var/screen_state = MONITOR_MAINMENU	 // the screen state
	var/list/cached_server_list = list() // The servers located by the computer
	var/obj/machinery/telecomms/server/SelectedServer

	var/network = "NULL"		// the network to probe

	var/universal_translate = FALSE // set to TRUE if it can translate nonhuman speech

	req_access = list(ACCESS_TCOMSAT)
	circuit = /obj/item/circuitboard/computer/comm_server
	tgui_id = "LogBrowser"

/obj/machinery/computer/telecomms/server/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user,src,ui)
	if(!ui)
		ui = new(user,src,"LogBrowser")
		ui.open()

/obj/machinery/computer/telecomms/server/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("Back")
			screen_state = MONITOR_MAINMENU
			SelectedServer = null
			return TRUE
		if("ViewServer")
			var/id = params["server_id"]
			if(!id)
				return
			for(var/machine in cached_server_list)
				var/obj/machinery/telecomms/server/m = machine
				if(m.id == id)
					SelectedServer = m
					break
			if(SelectedServer)
				screen_state = MONITOR_SERVERLOGS
				return TRUE
			return
		if("DeleteLog")
			if(!SelectedServer)
				return
			var/name = params["name"]
			if(!name || !istext(name) || length(name) > 1024)
				return
			for(var/l in SelectedServer.log_entries)
				var/datum/comm_log_entry/log = l
				if(log.name == name)
					SelectedServer.log_entries.Remove(log)
					return TRUE
			return
		if("SetNetwork")
			var/net = params["network"]
			if(!net || !istext(net) || isnotpretty(net) || length(net) > 15)
				return
			network = params["network"]
			return TRUE
		if("Scan")
			if(cached_server_list.len > 0)
				cached_server_list = list()
			for(var/obj/machinery/telecomms/server/T in range(TELECOMMS_SCAN_RANGE, src))
				if(T.network == network)
					cached_server_list.Add(T)
			return TRUE
		if("Refresh")
			return TRUE // Welp, you asked for it

/obj/machinery/computer/telecomms/server/proc/generate_message(datum/comm_log_entry/log, mob/user)
	if(!log.parameters["message"])
		return "***"
	var/lang = log.parameters["language"] 
	if(universal_translate || !lang)
		return log.parameters["message"]
	if(user.has_language(lang))
		return log.parameters["message"]
	else
		var/datum/language/D = GLOB.language_datum_instances[lang]
		return D.scramble(log.parameters["message"])
	
/obj/machinery/computer/telecomms/server/ui_data(mob/user)
	var/list/data = list()
	data["screen_state"] = screen_state
	data["network"] = network
	if(screen_state == MONITOR_MAINMENU)
		var/list/servers = list()
		for(var/machine in cached_server_list)
			var/obj/machinery/telecomms/server/m = machine
			servers.Add(m.id)
		data["servers"] = servers
	if(screen_state == MONITOR_SERVERLOGS)
		data["selected_name"] = SelectedServer.id
		data["totaltraffic"] = SelectedServer.log_entries.len
		data["define_max_storage"] = SERVER_LOG_STORAGE_MAX
		data["logs"] = list()
		for(var/l in SelectedServer.log_entries)
			var/datum/comm_log_entry/log = l
			var/list/datalog = list()
			datalog["is_corrupt"] = (log.input_type == "Corrupt File")
			datalog["is_error"] = (log.input_type == "Execution Error")
			datalog["name"] = log.parameters["name"] || "Unknown"
			datalog["job"] = log.parameters["job"] || FALSE
			datalog["message"] = generate_message(log,user)
			datalog["packet_id"] = log.name // since this is some MD5 thing we can actually use this to ID this packet later in ui_act()
			data["logs"] += list(datalog)

	return data

#undef MONITOR_MAINMENU
#undef MONITOR_SERVERLOGS
