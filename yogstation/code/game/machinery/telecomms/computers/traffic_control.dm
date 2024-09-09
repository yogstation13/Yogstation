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

	circuit = /obj/item/circuitboard/computer/telecomms/comm_traffic

	req_access = list(ACCESS_TCOMMS_ADMIN)
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
