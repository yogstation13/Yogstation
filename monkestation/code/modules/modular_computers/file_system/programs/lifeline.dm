/datum/computer_file/program/lifeline
	filename = "lifeline"
	filedesc = "Lifeline"
	extended_desc = "This program allows for tracking of crew members via their suit sensors."
	transfer_access = list(ACCESS_MEDICAL, ACCESS_BLUESHIELD, ACCESS_BRIG_PHYSICIAN, ACCESS_DETECTIVE)
	category = PROGRAM_CATEGORY_CREW
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR (classic)
	program_icon_state = "radarntos"
	// requires_ntnet = TRUE -- disabled to be constistent with the paramedic's crew monitor
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_LAPTOP | PROGRAM_TABLET
	size = 5
	tgui_id = "NtosLifeline"
	program_icon = "heartbeat"

	// Tracking information
	var/list/sensors = list()
	var/mob/living/selected
	var/last_update_time

	// UI Settings
	var/sort_asc = TRUE
	var/sort_by = "dist"
	var/blueshield = FALSE

	///Used to keep track of the last value program_icon_state was set to, to prevent constant unnecessary update_appearance() calls
	var/last_icon_state = ""


/datum/computer_file/program/lifeline/on_start(mob/living/user)
	. = ..()
	if(.)
		blueshield = istype(computer, /obj/item/modular_computer/pda/blueshield)
		START_PROCESSING(SSfastprocess, src)

/datum/computer_file/program/lifeline/kill_program(mob/user)
	sensors = list()
	selected = null
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/computer_file/program/lifeline/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/computer_file/program/lifeline/ui_data(mob/user)
	return list(
		"selected" = selected,
		"sensors" = update_sensors(),
		"settings" = list(
			"blueshield" = blueshield,
			"sortAsc" = sort_asc,
			"sortBy" = sort_by
		)
	)

/datum/computer_file/program/lifeline/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	switch(action)
		if("select")
			selected = params["ref"]
		if("sortAsc")
			sort_asc = params["val"]
		if("sortBy")
			sort_by = params["val"]
		if("blueshield")
			blueshield = params["val"]
	return TRUE

/datum/computer_file/program/lifeline/proc/update_sensors()
	var/turf/pos = get_turf(computer)
	if (world.time <= last_update_time + 3 SECONDS && sensors)
		return sensors
	var/nt_net = GLOB.crewmonitor.get_ntnet_wireless_status(pos.z)

	sensors = list()
	for(var/tracked_mob in GLOB.suit_sensors_list | GLOB.nanite_sensors_list)
		var/sensor_mode = GLOB.crewmonitor.get_tracking_level(tracked_mob, pos.z, nt_net)
		if (sensor_mode == SENSOR_OFF)
			continue
		var/mob/living/tracked_living_mob = tracked_mob

		var/turf/sensor_pos = get_turf(tracked_living_mob)

		var/list/crewinfo = list(
			ref = REF(tracked_living_mob),
			name = "Unknown",
			ijob = 81, // UNKNOWN_JOB_ID from crew.dm
			dist = -1, // This value tells the UI that location is disabled
		)

		if (sensor_pos.z == pos.z || (sensor_pos.z in SSmapping.get_connected_levels(pos.z)))
			if (sensor_mode == SENSOR_COORDS)
				crewinfo["zdiff"] = sensor_pos.z-pos.z
				crewinfo["dist"] = max(get_dist(pos, sensor_pos), 0)
				crewinfo["degrees"] = round(get_angle(pos, sensor_pos))
				crewinfo["area"] = get_area_name(tracked_living_mob, format_text = TRUE)
		else // tracking through NT Net
			crewinfo["zdiff"] = is_station_level(sensor_pos.z) ? 0 : -1 // 0: on station, -1: mining
			if (sensor_mode == SENSOR_COORDS)
				crewinfo["dist"] = -2 // This value tells the UI that tracking is through NT Net
				crewinfo["area"] = get_area_name(tracked_living_mob, format_text = TRUE)
			else
				crewinfo["dist"] = -3 // This value tells the UI that tracking is through NT Net and location is disabled

		var/obj/item/card/id/id_card = tracked_living_mob.get_idcard(hand_first = FALSE)
		if(id_card)
			crewinfo["name"] = id_card.registered_name
			crewinfo["assignment"] = id_card.assignment
			var/trim_assignment = id_card.get_trim_assignment()
			if (GLOB.crewmonitor.jobs[trim_assignment] != null)
				crewinfo["trim"] = trim_assignment
				crewinfo["ijob"] = GLOB.crewmonitor.jobs[trim_assignment]

		sensors += list(crewinfo)
	last_update_time = world.time
	return sensors

//We use SSfastprocess for the program icon state because it runs faster than process_tick() does.
/datum/computer_file/program/lifeline/process()
	if(computer.active_program != src)
		STOP_PROCESSING(SSfastprocess, src) //We're not the active program, it's time to stop.
		return
	if(!selected)
		return

	var/atom/movable/signal = locate(selected) in GLOB.human_list
	var/turf/here_turf = get_turf(computer)
	if(GLOB.crewmonitor.get_tracking_level(signal, here_turf.z, nt_net=FALSE, validation=FALSE) != SENSOR_COORDS)
		program_icon_state = "[initial(program_icon_state)]lost"
		if(last_icon_state != program_icon_state)
			computer.update_appearance()
			last_icon_state = program_icon_state
		return

	var/turf/target_turf = get_turf(signal)
	var/trackdistance = get_dist_euclidean(here_turf, target_turf)
	switch(trackdistance)
		if(0)
			program_icon_state = "[initial(program_icon_state)]direct"
		if(1 to 12)
			program_icon_state = "[initial(program_icon_state)]close"
		if(13 to 24)
			program_icon_state = "[initial(program_icon_state)]medium"
		if(25 to INFINITY)
			program_icon_state = "[initial(program_icon_state)]far"

	if(last_icon_state != program_icon_state)
		computer.update_appearance()
		last_icon_state = program_icon_state
	computer.setDir(get_dir(here_turf, target_turf))

//We can use process_tick to restart fast processing, since the computer will be running this constantly either way.
/datum/computer_file/program/lifeline/process_tick(seconds_per_tick)
	if(computer.active_program == src)
		START_PROCESSING(SSfastprocess, src)
