#define VIEW_COMPILE 1
#define VIEW_NETWORK 2
#define VIEW_LOGS 3

/obj/machinery/computer/telecomms/traffic
	name = "telecommunications traffic control console"

	/// The servers located by the computer
	var/list/obj/machinery/telecomms/server/servers = list()
	/// The network to probe
	var/network = "NULL"
	/// The current code being used
	var/storedcode = ""
	/// The ID currently inserted
	var/obj/item/card/id/inserted_id
	/// The name and job on the ID used to log in
	var/user_name = ""
	/// Logs for users logging in/out or compiling code
	var/list/access_log = list()
	/// Output from compiling to the servers
	var/list/compiler_output = list()
	/// Which tab to be viewing
	var/view_mode = VIEW_COMPILE

	circuit = /obj/item/circuitboard/computer/telecomms/comm_traffic

	req_access = list(ACCESS_TCOM_ADMIN)
	var/unlimited_range = FALSE

/obj/machinery/computer/telecomms/traffic/Initialize(mapload)
	. = ..()
	GLOB.traffic_comps += src
	if(mapload)
		unlimited_range = TRUE
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/telecomms/traffic/LateInitialize()
	. = ..()
	refresh_servers()
	for(var/obj/machinery/telecomms/server/new_server in servers)
		new_server.autoruncode = TRUE

/obj/machinery/computer/telecomms/traffic/Destroy()
	GLOB.traffic_comps -= src
	return ..()

/*
/obj/machinery/computer/telecomms/traffic/process()

	if(stat & (NOPOWER|BROKEN))
		stop_editing()
		return

	if(editingcode && editingcode.machine != src)
		stop_editing()
		return

	if(!editingcode)
		if(length(viewingcode) > 0)
			editingcode = pick(viewingcode)
			viewingcode.Remove(editingcode)
		return

	process = !process
	if(!process)
		return

	// loop if there's someone manning the keyboard
	if(!editingcode.client)
		stop_editing()
		return

	// For the typer, the input is enabled. Buffer the typed text
	storedcode = "[winget(editingcode, "tcscode", "text")]"
	winset(editingcode, "tcscode", "is-disabled=false")

	// If the player's not manning the keyboard anymore, adjust everything
	if(!in_range(editingcode, src) && !issilicon(editingcode) || editingcode.machine != src)
		winshow(editingcode, "Telecomms IDE", 0) // hide the window!
		editingcode = null
		return

	// For other people viewing the typer type code, the input is disabled and they can only view the code
	// (this is put in place so that there's not any magical shenanigans with 50 people inputting different code all at once)

	if(length(viewingcode))
		// This piece of code is very important - it escapes quotation marks so string aren't cut off by the input element
		var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
		showcode = replacetext(storedcode, "\"", "\\\"")

		for(var/mob/M in viewingcode)

			if( (M.machine == src && in_range(M, src) ) || issilicon(M))
				winset(M, "tcscode", "is-disabled=true")
				winset(M, "tcscode", "text=\"[showcode]\"")
			else
				viewingcode.Remove(M)
				winshow(M, "Telecomms IDE", 0) // hide the windows
*/

/obj/machinery/computer/telecomms/traffic/proc/create_log(entry)
	if(!user_name)
		CRASH("[type] tried to create a log with no user_name!")
	access_log += "\[[get_timestamp()]\] [user_name] [entry]"

/obj/machinery/computer/telecomms/traffic/ui_interact(mob/user, datum/tgui/ui)
	if(is_banned_from(user.ckey, "Network Admin"))
		return "You are banned from using NTSL."
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NtslEditor", name)
		ui.open()

/obj/machinery/computer/telecomms/traffic/ui_data(mob/user)
	var/list/data = list()
	var/list/server_data = list()
	for(var/obj/machinery/telecomms/server/server in servers)
		server_data.Add(list(list(
			"server" = REF(server),
			"server_id" = server.id,
			"server_name" = server.name,
			"run_code" = server.autoruncode,
		)))
	data["server_data"] = server_data
	data["stored_code"] = storedcode
	data["network"] = network
	data["user_name"] = user_name
	data["has_access"] = inserted_id
	data["access_log"] = access_log.Copy()
	data["compiler_output"] = compiler_output.Copy()
	data["emagged"] = ((obj_flags & EMAGGED) > 0)
	return data

/obj/machinery/computer/telecomms/traffic/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	
	switch(action)
		if("refresh_servers")
			refresh_servers()
			return TRUE
		if("toggle_code_execution")
			var/obj/machinery/telecomms/server/selected_server = locate(params["selected_server"])
			selected_server.autoruncode = !selected_server.autoruncode
			return TRUE
		if("save_code")
			storedcode = params["saved_code"]
			return TRUE
		if("compile_code")
			if(!user_name)
				message_admins("[key_name_admin(usr)] attempted compiling NTSL without being logged in.") // tell admins that someone tried a javascript injection
				return
			for(var/obj/machinery/telecomms/server/server as anything in servers)
				server.setcode(storedcode)
			qdel(compiler_output)
			compiler_output = compile_all(usr)
			return TRUE
		if("set_network")
			if(!user_name)
				return
			network = params["new_network"]
			return TRUE
		if("log_in")
			var/mob/usr_mob = usr
			if(usr_mob.has_unlimited_silicon_privilege)
				user_name = "System Administrator"
			else if(check_access(inserted_id))
				user_name = "[inserted_id?.registered_name] ([inserted_id?.assignment])"
			else
				var/obj/item/card/id/user_id = usr_mob.get_idcard(TRUE)
				if(!check_access(user_id))
					return
				user_name = "[user_id?.registered_name] ([user_id?.assignment])"
			create_log("has logged in.")
			return TRUE
		if("log_out")
			if(obj_flags & EMAGGED)
				return TRUE
			create_log("has logged out.")
			user_name = null
			return TRUE
		if("set_tab")
			if(!user_name)
				return
			view_mode = params["new_tab"]
			return TRUE
		if("clear_logs")
			if(!user_name)
				message_admins("[key_name_admin(usr)] attempted clearing NTSL logs without being logged in.")
				return
			qdel(access_log)
			access_log = list()
			create_log("cleared access logs.")
			return TRUE

/obj/machinery/computer/telecomms/traffic/ui_close(mob/user)
	return ..()

/obj/machinery/computer/telecomms/traffic/proc/refresh_servers()
	qdel(servers)
	servers = list()
	for(var/obj/machinery/telecomms/server/new_server as anything in GLOB.tcomms_servers)
		if(new_server.network != network)
			continue
		if(!unlimited_range && get_dist(src, new_server))
			continue
		servers.Add(new_server)

/obj/machinery/computer/telecomms/traffic/proc/compile_all(mob/user)
	if(is_banned_from(user.ckey, "Network Admin"))
		return list("You are banned from using NTSL.")
	if(!servers.len)
		return list("No servers detected.")
	for(var/obj/machinery/telecomms/server/server as anything in servers)
		var/list/compile_errors = server.compile(user)
		if(!compile_errors)
			return list("A fatal error has occured. Please contact your local network adminstrator.")
		if(istext(compile_errors))
			return splittext(compile_errors, "\n")
		var/list/text_list = list()
		for(var/datum/scriptError/error in compile_errors)
			text_list.Add(error.message)
		if(text_list.len)
			return text_list
	create_log("compiled to all linked servers on [network].")
	return list("Compiling finished.")

/*
	user.set_machine(src)
	var/dat = "<HTML><HEAD><meta charset='UTF-8'><TITLE>Telecommunication Traffic Control</TITLE></HEAD><BODY><center><b>Telecommunications Traffic Control</b></center>"
	dat += "<br><b><font color='[(auth ? "green" : "red")]'>[(auth ? "AUTHED" : "NOT AUTHED")]:</font></b> <A href='?src=\ref[src];auth=1'>[(!auth ? "Insert ID" : auth)]</A><BR>"
	dat += "<A href='?src=\ref[src];print=1'>View System Log</A><HR>"

	if(issilicon(user) || auth)

		switch(screen)


		  // --- Main Menu ---

			if(0)
				dat += "<br>[temp]<br>"
				dat += "<br>Current Network: <a href='?src=\ref[src];network=1'>[network]</a><br>"
				if(servers.len)
					dat += "<br>Detected Telecommunication Servers:<ul>"
					for(var/obj/machinery/telecomms/T in servers)
						dat += "<li><a href='?src=\ref[src];viewserver=[T.id]'>\ref[T] [T.name]</a> ([T.id])</li>"
					dat += "</ul>"
					dat += "<br><a href='?src=\ref[src];operation=release'>\[Flush Buffer\]</a>"

				else
					dat += "<br>No servers detected. Scan for servers: <a href='?src=\ref[src];operation=scan'>\[Scan\]</a>"


		  // --- Viewing Server ---

			if(1)
				if(SelectedServer)
					dat += "<br>[temp]<br>"
					dat += "<center><a href='?src=\ref[src];operation=mainmenu'>\[Main Menu\]</a>     <a href='?src=\ref[src];operation=refresh'>\[Refresh\]</a></center>"
					dat += "<br>Current Network: [network]"
					dat += "<br>Selected Server: [SelectedServer.id]"
					dat += "<br><br>"
					dat += "<br><a href='?src=\ref[src];operation=editcode'>\[Edit Code\]</a>"
					dat += "<br>Signal Execution: "
					if(SelectedServer.autoruncode)
						dat += "<a href='?src=\ref[src];operation=togglerun'>ALWAYS</a>"
					else
						dat += "<a href='?src=\ref[src];operation=togglerun'>NEVER</a>"
				else
					screen = 0
					return

	dat += "</BODY></HTML>"
	user << browse(dat, "window=traffic_control;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return

/obj/machinery/computer/telecomms/traffic/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["auth"])
		if(iscarbon(usr))
			var/mob/living/carbon/C = usr
			if(!auth)
				var/obj/item/card/id/I = C.get_active_held_item()
				if(istype(I))
					if(check_access(I))
						if(!C.transferItemToLoc(I, src))
							return
						auth = I
						create_log("has logged in.", usr)
			else
				create_log("has logged out.", usr)
				auth.loc = src.loc
				C.put_in_hands(auth)
				auth = null
			updateUsrDialog()
			return

	if(href_list["print"])
		usr << browse(print_logs(), "window=traffic_logs")
		return

	if(!auth && !issilicon(usr) && !emagged)
		to_chat(usr, span_danger("ACCESS DENIED."))
		return

	if(href_list["viewserver"])
		screen = 1
		for(var/obj/machinery/telecomms/T in servers)
			if(T.id == href_list["viewserver"])
				SelectedServer = T
				create_log("selected server [T.name]", usr)
				break
	if(href_list["operation"])
		create_log("has performed action: [href_list["operation"]].", usr)
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
					if(unlimited_range)
						for(var/obj/machinery/telecomms/server/T as anything in GLOB.tcomms_servers)
							if(T.network == network)
								servers.Add(T)
					else
						for(var/obj/machinery/telecomms/server/T in range(25, src))
							if(T.network == network)
								servers.Add(T)

					if(!servers.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE SERVERS IN \[[network]\] -</font color>"
					else
						temp = "<font color = #336699>- [servers.len] SERVERS PROBED & BUFFERED -</font color>"

					screen = 0

			if("editcode")
				if(is_banned_from(usr.ckey, "Network Admin"))
					to_chat(usr, span_warning("You are banned from using NTSL."))
					return
				if(editingcode == usr)
					return
				if(usr in viewingcode)
					return
				if(!editingcode)
					lasteditor = usr
					editingcode = usr
					winshow(editingcode, "Telecomms IDE", 1) // show the IDE
					winset(editingcode, "tcscode", "is-disabled=false")
					winset(editingcode, "tcscode", "text=\"\"")
					var/showcode = replacetext(storedcode, "\\\"", "\\\\\"")
					showcode = replacetext(storedcode, "\"", "\\\"")
					winset(editingcode, "tcscode", "text=\"[showcode]\"")

				else
					viewingcode.Add(usr)
					winshow(usr, "Telecomms IDE", 1) // show the IDE
					winset(usr, "tcscode", "is-disabled=true")
					winset(editingcode, "tcscode", "text=\"\"")
					var/showcode = replacetext(storedcode, "\"", "\\\"")
					winset(usr, "tcscode", "text=\"[showcode]\"")

			if("togglerun")
				SelectedServer.autoruncode = !(SelectedServer.autoruncode)

	if(href_list["network"])

		var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)

		if(newnet && canAccess(usr))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LONG -</font color>"

			else

				network = newnet
				screen = 0
				servers = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"
				create_log("has set the network to [network].", usr)

	updateUsrDialog()
	return

*/

/obj/machinery/computer/telecomms/traffic/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/card/id) && check_access(item) && user.transferItemToLoc(item, src))
		inserted_id = item
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		return
	return ..()

/obj/machinery/computer/telecomms/traffic/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	user_name = "System Administrator"
	create_log("has logged in.")
	playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
	to_chat(user, span_notice("You bypass the console's security protocols."))

/obj/machinery/computer/telecomms/traffic/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		if(inserted_id)
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
			inserted_id.forceMove(drop_location())
			carbon_user.put_in_hands(inserted_id)
			inserted_id = null
