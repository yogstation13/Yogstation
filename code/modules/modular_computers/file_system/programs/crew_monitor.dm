/datum/computer_file/program/crew_monitor
	filename = "crewmon"
	filedesc = "Crew Suit Sensor Monitor"
	extended_desc = "This program allows for viewing of crew members vitals via their suit sensors."
	category = PROGRAM_CATEGORY_CREW
	ui_header = "health_green.gif"
	program_icon_state = "crew"
	requires_ntnet = TRUE
	transfer_access = ACCESS_MEDICAL
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET | PROGRAM_PHONE | PROGRAM_TELESCREEN | PROGRAM_INTEGRATED
	network_destination = "tracking program"
	size = 5
	tgui_id = "NtosCrewMonitor"
	program_icon = "heartbeat"
	var/program_icon_state_alarm = "crew-red"
	var/alarm = FALSE

/datum/computer_file/program/crew_monitor/New()
	..()
	set_signals()

/datum/computer_file/program/crew_monitor/Destroy()
	..()
	clear_signals()

/datum/computer_file/program/crew_monitor/proc/set_signals()
	RegisterSignal(GLOB.crewmonitor, COMSIG_MACHINERY_CREWMON_UPDATE, .proc/update_overlay, override = TRUE)

/datum/computer_file/program/crew_monitor/proc/clear_signals()
	UnregisterSignal(GLOB.crewmonitor, COMSIG_MACHINERY_CREWMON_UPDATE)

/datum/computer_file/program/crew_monitor/proc/update_overlay()
	if(!computer)
		return
	var/z = computer.z
	if(!z)
		var/turf/T = get_turf(computer)
		z = T.z
	var/list/death_list = GLOB.crewmonitor.death_list?["[z]"]
	if(death_list && death_list.len > 0)
		alarm = TRUE
	else
		alarm = FALSE
	if(alarm)
		program_icon_state = program_icon_state_alarm
		ui_header = "health_red.gif"
	else
		program_icon_state = initial(program_icon_state)
		ui_header = "health_green.gif"
	if(istype(computer))
		computer.update_icon()

/datum/computer_file/program/crew_monitor/ui_data(mob/user)
	var/list/data = get_header_data()
	data |= GLOB.crewmonitor.ui_data(user)
	update_overlay()
	return data
