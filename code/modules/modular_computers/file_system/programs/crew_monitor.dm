/datum/computer_file/program/crew_monitor
	filename = "crewmon"
	filedesc = "Crew Suit Sensor Monitor"
	extended_desc = "This program allows for viewing of crew members vitals via their suit sensors."
	category = PROGRAM_CATEGORY_CREW
	ui_header = "borg_mon.gif" //DEBUG -- new icon before PR
	program_icon_state = "crew"
	requires_ntnet = TRUE
	transfer_access = ACCESS_MEDICAL
	available_on_ntnet = TRUE
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET | PROGRAM_PHONE //| PROGRAM_TELESCREEN // For my other PR
	network_destination = "tracking program"
	size = 5
	tgui_id = "NtosCrewMonitor"
	program_icon = "heartbeat"

/datum/computer_file/program/crew_monitor/ui_data(mob/user)
	var/list/data = get_header_data()
	data |= GLOB.crewmonitor.ui_data(user)
	return data
