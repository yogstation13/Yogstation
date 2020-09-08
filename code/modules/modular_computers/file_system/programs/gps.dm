/datum/computer_file/program/gps
	filename = "gps"
	filedesc = "GPS"
	ui_header = ""
	program_icon_state = ""
	extended_desc = "Connects to the GPS system to give the user information on the current locations of other GPS systems and signals."
	network_destination = "GPS"
	size = 2
	tgui_id = "NtosGPS"
	ui_x = 600
	ui_y = 350
	var/gpstag = "MPC0"
	var/emped = FALSE
	var/tracking = TRUE
	var/updating = TRUE //Automatic updating of GPS list. Can be set to manual by user.
	var/global_mode = TRUE //If disabled, only GPS signals of the same Z level are shown

/datum/computer_file/program/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("rename")
			var/a = stripped_input(usr, "Please enter desired tag.", name, gpstag, 20)
			gpstag = a
			. = TRUE
			name = "global positioning system ([gpstag])"

		if("power")
			toggletracking(usr)
			. = TRUE
		if("updating")
			updating = !updating
			. = TRUE
		if("globalmode")
			global_mode = !global_mode
			. = TRUE

/datum/computer_file/program/ui_data(mob/user)
	var/list/data = list()
	data["power"] = tracking
	data["tag"] = gpstag
	data["updating"] = updating
	data["globalmode"] = global_mode
	if(!tracking || emped) //Do not bother scanning if the GPS is off or EMPed
		return data

	var/turf/curr = get_turf_global(src) // yogs - get_turf_global instead of get_turf
	data["currentArea"] = "[get_area_name(curr, TRUE)]"
	data["currentCoords"] = "[curr.x], [curr.y], [curr.z]"

	var/list/signals = list()
	data["signals"] = list()

	for(var/gps in GLOB.GPS_list)
		var/obj/item/gps/G = gps
		if(G.emped || !G.tracking || G == src)
			continue
		var/turf/pos = get_turf_global(G) // yogs - get_turf_global instead of get_turf
		if(!global_mode && pos.z != curr.z)
			continue
		var/list/signal = list()
		signal["entrytag"] = G.gpstag //Name or 'tag' of the GPS
		signal["coords"] = "[pos.x], [pos.y], [pos.z]"
		if(pos.z == curr.z) //Distance/Direction calculations for same z-level only
			signal["dist"] = max(get_dist(curr, pos), 0) //Distance between the src and remote GPS turfs
			signal["degrees"] = round(Get_Angle(curr, pos)) //0-360 degree directional bearing, for more precision.

		signals += list(signal) //Add this signal to the list of signals
	data["signals"] = signals
	return data