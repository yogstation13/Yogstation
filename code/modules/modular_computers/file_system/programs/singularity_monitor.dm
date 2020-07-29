/** This is the ntOS modular application that allows you to track singularities
  * find out their current energy level, their location, distance from you, direction
  * and everything you need to know to survive Lord Singuloth's fury.
  * Currently only works for proper singularities and not its subtypes since I'm prioritizing
  * getting this to work for MDonalds event.
  */

/datum/computer_file/program/singularity_monitor
	filename = "singulomonitor"
	filedesc = "Singularity Monitoring"
	// ui_header = "smmon_0.gif" get a good image later
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated supermatter sensors to provide information on the status of supermatter-based engines."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CONSTRUCTION
	network_destination = "singularity monitoring system"
	size = 5
	tgui_id = "NtosSingularityMonitor"
	ui_x = 600
	ui_y = 350
	var/last_status = SUPERMATTER_INACTIVE
	var/list/singularities
	var/obj/singularity/active		// Currently selected supermatter crystal.


/datum/computer_file/program/singularity_monitor/process_tick()
	..()/*
	var/new_status = get_status()
	if(last_status != new_status)
		last_status = new_status
		ui_header = "smmon_[last_status].gif"
		program_icon_state = "smmon_[last_status]"
		if(istype(computer))
			computer.update_icon()
	do later when you get good icons	
	*/

/datum/computer_file/program/singularity_monitor/run_program(mob/living/user)
	. = ..(user)
	refresh()

/// Flushes memory and kills program
/datum/computer_file/program/singularity_monitor/kill_program(forced = FALSE)
	active = null
	singularities = null
	..()

/// Refreshes list of singularities
/datum/computer_file/program/singularity_monitor/proc/refresh()
	singularities = list()
	var/turf/T = get_turf(ui_host())
	if(!T)
		return
	for(var/obj/singularity/S in GLOB.singularities)
		if ((is_station_level(S.z) || is_mining_level(S.z) || S.z == T.z) && istype(S, obj/singularity)) 
		//for(x in y) includes subtypes. We don't want subtypes here.
			singularities.Add(S)

	if(!(active in singularities))
		active = null

/datum/computer_file/program/singularity_monitor/proc/get_status()
	. = "ALL CLEAR"
	for(var/obj/singularity/S in singularities)
		if(S.get_status())
			. = "OH GOD OH FUCK"

/datum/computer_file/program/singularity_monitor/ui_data()
	var/list/data = get_header_data()

	if(istype(active))
		var/turf/T = get_turf_global(active)
		if(!T)
			active = null
			refresh()
			return
		data["active"] = TRUE
		data["area"] = "[get_area_name(T, TRUE)]"
		data["coordinates"] = "[T.x], [T.y], [T.z]"
		data["energy"] = active.energy
		data["size"] = active.current_size
	else
		var/list/sings = list()
		for(var/obj/singularity/S in singularities)
			var/area/A = get_area(S)
			var/turf/T = get_turf_global(S)
			if(A)
				sings.Add(list(list(
				"area" = A.name,
				"coordinates" = "[T.x], [T.y], [T.z]",  
				"energy" = S.energy,
				"size" = S.current_size,
				"uid" = S.uid
				)))

		data["active"] = FALSE
		data["singularities"] = sings

	return data

/datum/computer_file/program/singularity_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("PRG_clear")
			active = null
			return TRUE
		if("PRG_refresh")
			refresh()
			return TRUE
		if("PRG_set")
			var/newuid = text2num(params["target"])
			for(var/obj/singularity/S in singularities)
				if(S.uid == newuid)
					active = S
			return TRUE
