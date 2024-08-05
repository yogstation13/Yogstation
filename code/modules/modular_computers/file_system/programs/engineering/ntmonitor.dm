/datum/computer_file/program/ntnetmonitor
	filename = "ntmonitor"
	filedesc = "NTNet Diagnostics and Monitoring"
	category = PROGRAM_CATEGORY_ENGINEERING
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
			SSmodular_computers.intrusion_detection_alarm = FALSE
			return TRUE
		if("toggleIDS")
			SSmodular_computers.intrusion_detection_enabled = !SSmodular_computers.intrusion_detection_enabled
			return TRUE
		if("purgelogs")
			SSmodular_computers.purge_logs()
			return TRUE
		if("toggle_function")
			SSmodular_computers.toggle_function(text2num(params["id"]))
			return TRUE

/datum/computer_file/program/ntnetmonitor/ui_data(mob/user)
	if(!SSmodular_computers)
		return
	var/list/data = get_header_data()

	data["ntnetstatus"] = SSmodular_computers.check_function()
	data["idsstatus"] = SSmodular_computers.intrusion_detection_enabled
	data["idsalarm"] = SSmodular_computers.intrusion_detection_alarm

	data["ntnetrelays"] = list()
	for(var/obj/machinery/ntnet_relay/relays as anything in SSmachines.get_machines_by_type(/obj/machinery/ntnet_relay))
		var/list/relay_data = list()
		relay_data["is_operational"] = relays.is_operational()
		relay_data["name"] = relays.name
		relay_data["ref"] = REF(relays)

		data["ntnetrelays"] += list(relay_data)

	data["config_softwaredownload"] = SSmodular_computers.setting_softwaredownload
	data["config_communication"] = SSmodular_computers.setting_communication

	data["ntnetlogs"] = list()
	for(var/i in SSmodular_computers.modpc_logs)
		data["ntnetlogs"] += list(list("entry" = i))

	return data
