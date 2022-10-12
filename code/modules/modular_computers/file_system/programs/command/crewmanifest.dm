/datum/computer_file/program/crew_manifest
	filename = "crewmani"
	filedesc = "Crew Manifest"
	category = PROGRAM_CATEGORY_CMD
	program_icon_state = "id"
	extended_desc = "Program for viewing and printing the current crew manifest"
	requires_ntnet = FALSE
	size = 4
	tgui_id = "NtosCrewManifest"
	program_icon = "clipboard-list"

/datum/computer_file/program/crew_manifest/ui_static_data(mob/user)
	var/list/data = list()
	data["manifest"] = GLOB.data_core.get_manifest()
	return data

/datum/computer_file/program/crew_manifest/ui_data(mob/user)
	var/list/data = get_header_data()

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/crew_manifest/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	switch(action)
		if("PRG_print")
			if(computer && printer) //This option should never be called if there is no printer
				var/contents = "<h2>Crew Manifest\n</h2>"
				var/manifest = GLOB.data_core.get_manifest() // Keys are string names of departments, values are lists of lists. Each list therein has two elements: "name" and "rank"
				computer.play_interact_sound()

				for(var/dep in manifest) // For each department
					contents += "<br><h3>[dep]</h34><br>"
					for(var/person in manifest[dep]) // For each individual
						var/n = person["name"]
						var/r = person["rank"]
						contents += "<b>[n]</b> - <i>[r]</i><br>"

				if(!printer.print_text(contents,text("crew manifest ([])", station_time_timestamp()),FALSE))
					to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
					return
				else
					computer.visible_message(span_notice("\The [computer] prints out a paper."))
