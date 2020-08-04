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
	extended_desc = "This program connects to onboard gravitic sensor systems."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CONSTRUCTION
	network_destination = "singularity monitoring system"
	size = 2
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

/// Returns a stage threshold linked to the singularity defines.
/datum/computer_file/program/singularity_monitor/proc/get_threshold(threshold)
	threshold = clamp(threshold, 1, 6)
	switch(threshold)
		if(1)
			return STAGE_ONE_THRESHOLD
		if(2)
			return STAGE_TWO_THRESHOLD
		if(3)
			return STAGE_THREE_THRESHOLD
		if(4)
			return STAGE_FOUR_THRESHOLD
		if(5)
			return STAGE_FIVE_THRESHOLD
		if(6)
			return STAGE_SIX_THRESHOLD

/// Refreshes list of singularities
/datum/computer_file/program/singularity_monitor/proc/refresh()
	singularities = list()
	var/turf/T = get_turf(ui_host())
	if(!T)
		return
	for(var/obj/singularity/S in GLOB.singularities)
		if ((is_station_level(S.z) || is_mining_level(S.z)) && istype(S, /obj/singularity)) 
		//for(x in y) includes subtypes. We don't want subtypes here.
			singularities.Add(S)

	if(!(active in singularities))
		active = null

/datum/computer_file/program/singularity_monitor/proc/get_status()
	. = "ALL CLEAR"
	for(var/obj/singularity/S in singularities)
		if(S.check_setup())
			. = "OH GOD OH FUCK"

/datum/computer_file/program/singularity_monitor/ui_data()
	var/list/data = get_header_data()
	var/turf/pos = get_turf(ui_host())

	if(!isnull(active))
		var/turf/T = get_turf(active)
		var/area/A = get_area(active)
		if(!T)
			active = null
			refresh()
			return
		data["active"] = TRUE
		data["area"] = A.name
		data["x"] = T.x
		data["y"] = T.y
		data["dist"] = max(get_dist_euclidian(pos, T), 0) //Distance between the src and the sing
		data["degrees"] = round(Get_Angle(pos, T)) //0-360 degree directional bearing, for more precision.
		data["energy"] = active.energy
		data["size"] = (active.current_size+1)/2
		data["consume_range"] = active.consume_range
		data["pull_range"] = active.grav_pull
		data["down_threshold"] = get_threshold((active.current_size+1)/2)
		data["up_threshold"] = get_threshold((active.current_size+3)/2)

	else
		var/list/sings = list()
		var/counter = 1
		for(var/obj/singularity/S in singularities)
			var/area_name = "Space"
			var/turf/T = get_turf(S)
			var/area/A = get_area(S)
			if(A)
				area_name = A.name
			sings.Add(list(list(
				"area" = area_name,
				"x" = T.x,
				"y" = T.y,  
				"dist" = max(get_dist_euclidian(pos, T), 0), //Distance between the src and the sing
				"degrees" = round(Get_Angle(pos, T)), //0-360 degree directional bearing, for more precision.
				"energy" = S.energy,
				"size" = (S.current_size+1)/2,
				"consume_range" = S.consume_range,
				"pull_range" = S.grav_pull,
				"uid" = counter
				)))
			counter += 1
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
			active = singularities[text2num(params["target"])]
			return TRUE
