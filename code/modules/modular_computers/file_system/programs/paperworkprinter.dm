//TODO: add more sane printing handling
/datum/computer_file/program/paperwork_printer
	filename = "ppwrkprnt"
	filedesc = "Paperwork Printing"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "id"
	extended_desc = "Program for dispensing paperwork"
	requires_ntnet = FALSE
	size = 4
	tgui_id = "NtosPaperworkPrinter"
	program_icon = "clipboard-list"

/datum/computer_file/program/paperwork_printer/ui_static_data(mob/user)
	var/list/data = get_header_data()
	var/list/papers = list()
	//filter out paperwork we're not allowed to have
	for(var/R in subtypesof(/obj/item/paper/paperwork))
		var/obj/item/paper/paperwork/P = R
		if(initial(P.printable))
			papers += list(list("name" = initial(P.name), "id" = initial(P.id)))
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	data["printable_papers"] = papers
	return data

/datum/computer_file/program/paperwork_printer/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	//this variable stores the object of which we're actually going to print
	if(action == "PRG_print")
		var/paperworkToPick = params["paperworkID"]
		for(var/R in subtypesof(/obj/item/paper/paperwork))
			var/obj/item/paper/paperwork/P = R
			if(initial(P.id)==paperworkToPick)
				src.print(P)
				break
			

/datum/computer_file/program/paperwork_printer/proc/print(var/obj/item/paper/paperwork/T)
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]
	if(computer && printer) //This option should never be called if there is no printer
		if(!printer.print_type(T))
			to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
			return
		else
			//it printed, how many pages are left?
			var/pages_left = printer.stored_paper
			computer.visible_message(span_notice("\The [computer] prints out a paper. There are [pages_left] pages left."))
