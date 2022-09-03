/datum/computer_file/program/chemscan
	filename = "chemscan"
	filedesc = "Chemical Scanner"
	category = PROGRAM_CATEGORY_MED
	program_icon_state = "air"
	extended_desc = "A small built-in sensor reads out the chemicals in an item."
	network_destination = "chem scan"
	size = 4
	tgui_id = "NtosChem"
	program_icon = "flask"
	var/list/lastscan = list()

/datum/computer_file/program/chemscan/run_program(mob/living/user)
	. = ..()
	if (!.)
		return FALSE
	if(!computer?.get_modular_computer_part(MC_SENSORS)) //Giving a clue to users why the program is spitting out zeros.
		to_chat(user, "<span class='warning'>\The [computer] flashes an error: \"hardware\\sensorpackage\\startup.bin -- file not found\".</span>")
		return FALSE
	return TRUE

/datum/computer_file/program/chemscan/clickon(atom/A, mob/living/user, params)
	var/obj/item/computer_hardware/sensorpackage/sensors = computer?.get_modular_computer_part(MC_SENSORS)
	if(!sensors?.check_functionality())
		return FALSE
	if(!isnull(A.reagents))
		lastscan["reagents"] = list()
		if(A.reagents.reagent_list.len > 0)
			var/reagents_length = A.reagents.reagent_list.len
			lastscan["reagents"]["len"] = reagents_length
			to_chat(user, span_notice("[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found."))
			lastscan["reagents"]["reagentlist"] = list()
			for (var/datum/reagent/re in A.reagents.reagent_list)
				lastscan["reagents"]["reagentlist"] += "\t [re]"
			to_chat(user, span_notice("Results recorded to [computer]"))
			return TRUE
		else
			to_chat(user, span_notice("No active chemical agents found in [A]."))
			return TRUE
	else
		lastscan = list()
		to_chat(user, span_notice("No significant chemical agents found in [A]."))
		return TRUE

/datum/computer_file/program/chemscan/ui_data(mob/user)
	var/list/data = get_header_data()
	if(lastscan.len)
		data["out"] = "Reagents found"
		data["len"] = lastscan["reagents"]["len"]
		data["chems"] = lastscan["reagents"]["reagentlist"]
	else
		data["out"] = "No chemicals found"
		data["len"] = 0
	return data

/datum/computer_file/program/chemscan/ui_act(action, list/params)
	if(..())
		return TRUE
