#define SCREEN_MAINMENU 0
#define SCREEN_SERVER 1
#define SCREEN_LOGS 2
#define SCREEN_CODING 3

#define TELECOMMS_SEARCH_RANGE 25 // The radius from which a traffic computer can perceive servers.

/obj/machinery/computer/telecomms/traffic
	name = "traffic control computer"
	desc = "A computer used to interface with the programming of communication servers."

	var/emagged = FALSE
	var/list/cached_server_list = list() // The servers located by the computer
	var/mob/editUser
	var/mob/lastUser
	var/obj/machinery/telecomms/server/serverSelected

	var/network = null // The network we're currently looking at
	var/codestr = "" // Cached code, completely undigested string (!!!)

	var/screen_state = SCREEN_MAINMENU

	var/obj/item/card/id/auth = null
	var/list/access_log = list()
	circuit = /obj/item/circuitboard/computer/telecomms/comm_traffic

	req_access = list(ACCESS_TCOM_ADMIN)

	tgui_id = "TrafficControl"

/obj/machinery/computer/telecomms/traffic/Initialize(mapload)
	. = ..()
	GLOB.traffic_comps += src

/obj/machinery/computer/telecomms/traffic/Destroy()
	GLOB.traffic_comps -= src
	return ..()

/obj/machinery/computer/telecomms/traffic/proc/isAuthorized(mob/user) // Confirm that the current user can use the restricted functions of this computer.
	return issilicon(user) || ( (emagged || auth) &&  in_range(user, src))

/obj/machinery/computer/telecomms/traffic/proc/create_log(entry, mob/user)
	var/id = null
	if(issilicon(user) || isAI(user))
		id = "System Administrator"
	else if(ispAI(user))
		id = "[user.name] (pAI)"
	else if(isdrone(user))
		id = "[user.name]"
	else
		if(auth)
			id = "[auth.registered_name] ([auth.assignment])"
		else
			return
	access_log += "\[[get_timestamp()]\] [id] [entry]"

/obj/machinery/computer/telecomms/traffic/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/card/id) && check_access(O) && user.transferItemToLoc(O, src))
		auth = O
		create_log("has logged in.", usr)
	else
		..()

/obj/machinery/computer/telecomms/traffic/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(!auth)
			var/obj/item/card/id/I = C.get_active_held_item()
			if(istype(I))
				if(check_access(I))
					if(!C.transferItemToLoc(I, src))
						return
					auth = I
					create_log("has logged in.", user)
		else
			create_log("has logged out.", user)
			auth.forceMove(drop_location())
			C.put_in_hands(auth)
			auth = null
		return

/obj/machinery/computer/telecomms/traffic/emag_act(mob/user)
	if(!emagged)
		playsound(src.loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = TRUE
		to_chat(user, span_notice("You you disable the security protocols."))

/obj/machinery/computer/telecomms/traffic/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TrafficControl")
		ui.open()

/obj/machinery/computer/telecomms/traffic/ui_act(action, list/params)
	if(..())
		return
	switch(action)
		if("refreshme")
			return TRUE
		if("back")
			if(!isAuthorized(usr))
				return
			switch(screen_state)
				if(SCREEN_SERVER)
					screen_state = SCREEN_MAINMENU
					return TRUE
				if(SCREEN_CODING)
					screen_state = SCREEN_SERVER
					return TRUE
				else
					screen_state = SCREEN_MAINMENU // Just to be sure
					return TRUE
		if("goto")
			if(!isAuthorized(usr))
				return
			switch(params["screen_state"])
				if(SCREEN_SERVER)
					screen_state = SCREEN_SERVER
					return TRUE
				if(SCREEN_CODING)
					screen_state = SCREEN_CODING
					return TRUE
				if(SCREEN_MAINMENU)
					screen_state = SCREEN_MAINMENU
					return TRUE
				if(SCREEN_LOGS)
					screen_state = SCREEN_LOGS
					return TRUE
			return
		if("savecode")
			if(!isAuthorized(usr))
				return
			codestr = params["code"]
			return TRUE
		if("auth")
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
				return TRUE
			return
		if("scan")
			if(!isAuthorized(usr))
				return
			if(cached_server_list.len > 0)
				cached_server_list = list()
			for(var/obj/machinery/telecomms/server/T in range(TELECOMMS_SEARCH_RANGE, src))
				if(T.network == network)
					cached_server_list.Add(T)
			screen_state = SCREEN_MAINMENU
			return TRUE
		if("select")
			for(var/s in cached_server_list)
				var/obj/machinery/telecomms/server/server = s
				if(server.id == params["server_id"])
					serverSelected = server
					return TRUE
		if("toggle_code")
			serverSelected.autoruncode = !(serverSelected.autoruncode)
			return TRUE

/obj/machinery/computer/telecomms/traffic/ui_data(mob/user)
	var/data = list()

	//Basic state variables
	data["screen_state"] = screen_state
	data["auth"] = auth ? auth.registered_name : FALSE
	data["is_authorized"] = issilicon(user) || emagged || (auth ? TRUE : FALSE)
	if(serverSelected)
		data["serverSelected_id"] = serverSelected.id
		data["serverSelected_enabledcode"] = serverSelected.autoruncode
	else
		data["serverSelected_id"] = -1

	//Server data
	if(screen_state == SCREEN_MAINMENU)
	{
		var/list/servers = list()
		for(var/obj/machinery/telecomms/server/s in cached_server_list)
			servers.Add(s.id)
		data["servers"] = servers
		
	}
	else if(screen_state == SCREEN_LOGS)
	{
		data["logs"] = access_log // Inshallah this will work
	}
	return data

#undef SCREEN_MAINMENU
#undef SCREEN_SERVER
#undef SCREEN_LOGS
#undef SCREEN_CODING
#undef TELECOMMS_SEARCH_RANGE