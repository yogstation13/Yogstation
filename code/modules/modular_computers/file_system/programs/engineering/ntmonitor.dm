/datum/computer_file/program/ntnetmonitor
	filename = "ntmonitor"
	filedesc = "NTNet Diagnostics and Monitoring"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes."
	size = 12
	requires_ntnet = TRUE
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET | PROGRAM_PHONE | PROGRAM_TELESCREEN | PROGRAM_PDA
	required_access = ACCESS_NETWORK	//NETWORK CONTROL IS A MORE SECURE PROGRAM.
	available_on_ntnet = TRUE
	tgui_id = "NtosNetMonitor"
	program_icon = "network-wired"

/datum/computer_file/program/ntnetmonitor/ui_act(action, params)
	if(..())
		return
	computer.play_interact_sound()
	switch(action)
		if("resetIDS")
			if(SSmodular_computers)
				SSmodular_computers.resetIDS()
			return TRUE
		if("toggleIDS")
			if(SSmodular_computers)
				SSmodular_computers.toggleIDS()
			return TRUE
		if("toggleWireless")
			if(!SSmodular_computers)
				return

			// NTNet is disabled. Enabling can be done without user prompt
			if(SSmodular_computers.setting_disabled)
				SSmodular_computers.setting_disabled = FALSE
				return TRUE

			SSmodular_computers.setting_disabled = TRUE
			return TRUE
		if("purgelogs")
			if(SSmodular_computers)
				SSmodular_computers.purge_logs()
			return TRUE
		if("updatemaxlogs")
			var/logcount = params["new_number"]
			if(SSmodular_computers)
				SSmodular_computers.update_max_log_count(logcount)
			return TRUE
		if("toggle_function")
			if(!SSmodular_computers)
				return
			SSmodular_computers.toggle_function(text2num(params["id"]))
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	if(!SSmodular_computers)
		return
	var/list/data = get_header_data()

	data["ntnetstatus"] = SSmodular_computers.check_function()
	data["ntnetrelays"] = SSmodular_computers.relays.len
	data["idsstatus"] = SSmodular_computers.intrusion_detection_enabled
	data["idsalarm"] = SSmodular_computers.intrusion_detection_alarm

	data["config_softwaredownload"] = SSmodular_computers.setting_softwaredownload
	data["config_peertopeer"] = SSmodular_computers.setting_peertopeer
	data["config_communication"] = SSmodular_computers.setting_communication
	data["config_systemcontrol"] = SSmodular_computers.setting_systemcontrol

	data["ntnetlogs"] = list()
	data["minlogs"] = MIN_NTNET_LOGS
	data["maxlogs"] = MAX_NTNET_LOGS

	for(var/i in SSmodular_computers.logs)
		data["ntnetlogs"] += list(list("entry" = i))
	data["ntnetmaxlogs"] = SSmodular_computers.setting_maxlogcount

	return data
