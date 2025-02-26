/obj/item/circuitboard/computer/comm_traffic
	name = "Telecommunications Traffic Control"
	build_path = /obj/machinery/computer/telecomms/traffic

/datum/design/board/traffic
	name = "Traffic Console"
	desc = "Allows for the construction of Traffic Control Console."
	id = "s_traffic"
	build_path = /obj/item/circuitboard/computer/comm_traffic
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_TELECOMMS
	)
	departmental_flags = DEPARTMENT_BITFLAG_ENGINEERING | DEPARTMENT_BITFLAG_SCIENCE

/obj/machinery/computer/telecomms/traffic
	name = "traffic control computer"
	desc = "A computer used to interface with the programming of communication servers."

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

	var/unlimited_range = FALSE

	circuit = /obj/item/circuitboard/computer/comm_traffic

	req_access = list(ACCESS_TCOMMS_ADMIN)

/obj/machinery/computer/telecomms/traffic/Initialize(mapload)
	..()
	GLOB.traffic_comps += src
	if(length(GLOB.pretty_filter_items) == 0)
		setup_pretty_filter()
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
	servers = null
	if(!isnull(inserted_id))
		inserted_id.forceMove(drop_location())
		inserted_id = null
	return ..()

/obj/machinery/computer/telecomms/traffic/proc/create_log(entry)
	if(!user_name)
		CRASH("[type] tried to create a log with no user_name!")
	access_log += "\[[get_timestamp()]\] [user_name] [entry]"

/obj/machinery/computer/telecomms/traffic/ui_interact(mob/user, datum/tgui/ui)
	if(is_banned_from(user.ckey, JOB_SIGNAL_TECHNICIAN))
		to_chat(user, span_warning("You are banned from using the NTSL console"))
		return "You are banned from using NTSL."

	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "NTSLCoding")
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

	data["admin_view"] = FALSE
	if(user.client.holder) // enables an admin-only button in case of severe grief
		data["admin_view"] = TRUE

	return data

/obj/machinery/computer/telecomms/traffic/ui_act(action, list/params)
	. = ..()
	if(action == "admin_reset") // something to note, this will runtime when clicked on by an admin ghost. But still works.
		if(!usr.client.holder)
			message_admins("[key_name_admin(usr)] has attempted to call \"admin_reset\" on a traffic console, this should not be possible as a non-admin and could have been an attempted javascript injection.")
			return
		network = "tcommsat"
		refresh_servers()
		for(var/obj/machinery/telecomms/server/server as anything in servers)
			server.rawcode = "def process_signal(sig){ return sig;" // bare minimum
		qdel(compiler_output)
		compiler_output = compile_all(usr)
		var/message = "[key_name_admin(usr)] has completelly cleared the NTSL console of code and re-compiled as an admin, this should only be done in severe rule infractions."
		message_admins(message)
		logger.Log(LOG_NTSL, "[key_name(src)] [message] [loc_name(src)]")
		access_log += "\[[get_timestamp()]\] ERR !NTSL REMOTELLY CLEARED BY NANOTRASEN STAFF!"
		return TRUE
	if(.)
		return

	playsound(src, "terminal_type", 15, FALSE)
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
				if(storedcode && istext(storedcode))
					server.rawcode = storedcode
			qdel(compiler_output)
			compiler_output = compile_all(usr)
			return TRUE
		if("set_network")
			if(!user_name)
				return
			network = params["new_network"]
			return TRUE
		if("log_in")
			var/mob/living/usr_mob = usr
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
			access_log.Cut()
			create_log("cleared access logs.")
			return TRUE

/obj/machinery/computer/telecomms/traffic/proc/refresh_servers()
	servers.Cut()
	for(var/obj/machinery/telecomms/server/new_server as anything in GLOB.tcomms_servers)
		if(new_server.network != network)
			continue
		if(!unlimited_range && get_dist(src, new_server) > 15)
			continue
		servers.Add(new_server)

/obj/machinery/computer/telecomms/traffic/proc/compile_all(mob/user)
	if(is_banned_from(user.ckey, JOB_SIGNAL_TECHNICIAN))
		return list("You are banned from using NTSL.")
	if(!length(servers))
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
		if(length(text_list))
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
	if(!user.can_perform_action(src, NEED_DEXTERITY) || !iscarbon(user))
		return

	var/mob/living/carbon/carbon_user = user
	if(inserted_id)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		inserted_id.forceMove(drop_location())
		carbon_user.put_in_hands(inserted_id)
		inserted_id = null
