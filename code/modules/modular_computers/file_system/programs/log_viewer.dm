/datum/computer_file/program/logviewer
	filename = "logviewer"
	filedesc = "Thinktronic Log Viewer"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors stationwide NTNet network, provides access to logging systems, and allows for configuration changes"
	size = 5
	available_on_ntnet = TRUE
	tgui_id = "NtosLogViewer"
	program_icon = "file-alt"

	var/datum/computer_file/log/activelog

/datum/computer_file/program/logviewer/ui_act(action, params)
	if(..())
		return

	var/obj/item/computer_hardware/hard_drive/HDD = computer.all_components[MC_HDD]
	var/obj/item/computer_hardware/printer/printer = computer.all_components[MC_PRINT]
	switch(action)
		if("PRG_Print")
			if(!HDD)
				to_chat(usr, span_danger("\The [src] displays a \"How the fuck did this happen? PLEASE make a bug report if you see this.\" error."))
				return
			if(!printer)
				to_chat(usr, span_danger("\The [src] displays a \"No printer found. Unable to print file.\" error."))
				return
			var/datum/computer_file/F = HDD.find_file_by_name(params["name"])
			if(!F || !istype(F))
				to_chat(usr, span_danger("\The [src] displays a \"No file found. Unable to print file.\" error."))
				return
			if(printer.print_file(F) && computer)
				computer.play_ping()
		if("PRG_Open")
			if(!HDD)
				to_chat(usr, span_danger("\The [src] displays a \"How the fuck did this happen? PLEASE make a bug report if you see this.\" error."))
				return
			var/datum/computer_file/F = HDD.find_file_by_name(params["name"])
			if(!F || !istype(F))
				to_chat(usr, span_danger("\The [src] displays a \"No file found. Unable to view file.\" error."))
				return
			if(!istype(F, /datum/computer_file/log))
				to_chat(usr, span_danger("\The [src] displays a \"Incorrect file type. Unable to view file.\" error."))
				return
			activelog = F
			return TRUE

/datum/computer_file/program/logviewer/ui_data(mob/user)
	if(!SSnetworks.station_network)
		return
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/hard_drive/HDD = computer.all_components[MC_HDD]
	var/list/files = list()
	for(var/datum/computer_file/F in HDD.stored_files)
		var/viewable = FALSE
		var/datum/computer_file/log/logfile = F
		if(istype(logfile))
			viewable = TRUE
		files += list(list(
			"name" = F.filename,
			"type" = F.filetype,
			"size" = F.size,
			"printable" = F.can_print,
			"openable" = viewable,
		))
		data["files"] = files
	data["Log"] = list()
	data["hasactivefile"] = FALSE
	if(activelog)
		data["Log"] = activelog.formatfile(FALSE)
		data["hasactivefile"] = TRUE
	return data
