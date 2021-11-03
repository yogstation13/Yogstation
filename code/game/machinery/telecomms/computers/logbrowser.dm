#define MONITOR_MAINMENU 0
#define MONITOR_SERVERLOGS 1

/obj/machinery/computer/telecomms/server
	name = "telecommunications server monitoring console"
	icon_screen = "comm_logs"
	desc = "A computer dedicated to monitoring telecommuncation server logs."

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
			datalog["message"] = log.parameters["message"] || "***"
			datalog["packet_id"] = log.name // since this is some MD5 thing we can actually use this to ID this packet later in ui_act()
			data["logs"] += list(datalog)

	return data

#undef MONITOR_MAINMENU
#undef MONITOR_SERVERLOGS


/*
/obj/machinery/computer/telecomms/server/ui_interact(mob/user)
	. = ..()
	var/dat = "<HTML><HEAD><meta charset='UTF-8'><TITLE>Telecommunication Server Monitor</TITLE></HEAD><BODY><center><b>Telecommunications Server Monitor</b></center>"

	switch(screen)


	  // --- Main Menu ---

		if(0)
			dat += "<br>[temp]<br>"
			dat += "<br>Current Network: <a href='?src=[REF(src)];network=1'>[network]</a><br>"
			if(servers.len)
				dat += "<br>Detected Telecommunication Servers:<ul>"
				for(var/obj/machinery/telecomms/T in servers)
					dat += "<li><a href='?src=[REF(src)];viewserver=[T.id]'>[REF(T)] [T.name]</a> ([T.id])</li>"
				dat += "</ul>"
				dat += "<br><a href='?src=[REF(src)];operation=release'>\[Flush Buffer\]</a>"

			else
				dat += "<br>No servers detected. Scan for servers: <a href='?src=[REF(src)];operation=scan'>\[Scan\]</a>"


	  // --- Viewing Server ---

		if(1)
			dat += "<br>[temp]<br>"
			dat += "<center><a href='?src=[REF(src)];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=[REF(src)];operation=refresh'>\[Refresh\]</a></center>"
			dat += "<br>Current Network: [network]"
			dat += "<br>Selected Server: [SelectedServer.id]"

			if(SelectedServer.totaltraffic >= 1024)
				dat += "<br>Total recorded traffic: [round(SelectedServer.totaltraffic / 1024)] Terrabytes<br><br>"
			else
				dat += "<br>Total recorded traffic: [SelectedServer.totaltraffic] Gigabytes<br><br>"

			dat += "Stored Logs: <ol>"

			var/i = 0
			for(var/datum/comm_log_entry/C in SelectedServer.log_entries)
				i++


				// If the log is a speech file
				if(C.input_type == "Speech File")
					dat += "<li><font color = #008F00>[C.name]</font>  <font color = #FF0000><a href='?src=[REF(src)];delete=[i]'>\[X\]</a></font><br>"

					// -- Determine race of orator --

					var/mobtype = C.parameters["mobtype"]
					var/race			   // The actual race of the mob

					if(ispath(mobtype, /mob/living/carbon/human) || ispath(mobtype, /mob/living/brain))
						race = "Humanoid"

					// NT knows a lot about slimes, but not aliens. Can identify slimes
					else if(ispath(mobtype, /mob/living/simple_animal/slime))
						race = "Slime"

					else if(ispath(mobtype, /mob/living/carbon/monkey))
						race = "Monkey"

					// sometimes M gets deleted prematurely for AIs... just check the job
					else if(ispath(mobtype, /mob/living/silicon) || C.parameters["job"] == "AI")
						race = "Artificial Life"

					else if(isobj(mobtype))
						race = "Machinery"

					else if(ispath(mobtype, /mob/living/simple_animal))
						race = "Domestic Animal"

					else
						race = "<i>Unidentifiable</i>"

					dat += "<u><font color = #18743E>Data type</font></u>: [C.input_type]<br>"
					dat += "<u><font color = #18743E>Source</font></u>: [C.parameters["name"]] (Job: [C.parameters["job"]])<br>"
					dat += "<u><font color = #18743E>Class</font></u>: [race]<br>"
					var/message = C.parameters["message"]
					var/language = C.parameters["language"]

					// based on [/atom/movable/proc/lang_treat]
					if (universal_translate || user.has_language(language))
						message = "\"[message]\""
					else if (!user.has_language(language))
						var/datum/language/D = GLOB.language_datum_instances[language]
						message = "\"[D.scramble(message)]\""
					else if (language)
						message = "<i>(unintelligible)</i>"

					dat += "<u><font color = #18743E>Contents</font></u>: [message]<br>"
					dat += "</li><br>"

				else if(C.input_type == "Execution Error")
					dat += "<li><font color = #990000>[C.name]</font>  <a href='?src=[REF(src)];delete=[i]'>\[X\]</a><br>"
					dat += "<u><font color = #787700>Error</font></u>: \"[C.parameters["message"]]\"<br>"
					dat += "</li><br>"

				else
					dat += "<li><font color = #000099>[C.name]</font>  <a href='?src=[REF(src)];delete=[i]'>\[X\]</a><br>"
					dat += "<u><font color = #18743E>Data type</font></u>: [C.input_type]<br>"
					dat += "<u><font color = #18743E>Contents</font></u>: <i>(unintelligible)</i><br>"
					dat += "</li><br>"


			dat += "</ol>"
			
	dat += "</BODY></HTML>"

	user << browse(dat, "window=comm_monitor;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return


/obj/machinery/computer/telecomms/server/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				break

	if(href_list["operation"])
		switch(href_list["operation"])

			if("release")
				servers = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("scan")
				if(servers.len > 0)
					temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

				else
					for(var/obj/machinery/telecomms/server/T in urange(25, src))
						if(T.network == network)
							servers.Add(T)

					if(!servers.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font color>"
					else
						temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font color>"

					screen = 0

	if(href_list["delete"])

		if(!src.allowed(usr) && !(obj_flags & EMAGGED))
			to_chat(usr, span_danger("ACCESS DENIED."))
			return

		if(SelectedServer)

			var/datum/comm_log_entry/D = SelectedServer.log_entries[text2num(href_list["delete"])]

			temp = "<font color = #336699>- DELETED ENTRY: [D.name] -</font color>"

			SelectedServer.log_entries.Remove(D)
			qdel(D)

		else
			temp = "<font color = #D70B00>- FAILED: NO SELECTED MACHINE -</font color>"

	if(href_list["network"])

		var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)

		if(newnet && ((usr in range(1, src)) || issilicon(usr)))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

			else

				network = newnet
				screen = 0
				servers = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

	updateUsrDialog()
	return

/obj/machinery/computer/telecomms/server/attackby()
	. = ..()
	updateUsrDialog()
*/