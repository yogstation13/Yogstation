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
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/paperwork_printer/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	//this variable stores the object of which we're actually going to print
	var/obj/item/paper/paperwork/which
	//this flag determines if anything is actually printed
	var/print = FALSE
	if(action == "PRG_print")
		var/paperworkToPick = params["whichpaperwork"]
		switch(paperworkToPick)
			if("GeneralRequest")
				which = /obj/item/paper/paperwork/general_request_form
				print = TRUE
			if("ComplaintForm")
				which = /obj/item/paper/paperwork/complaint_form
				print = TRUE
			if("IncidentForm")
				which = /obj/item/paper/paperwork/incident_report
				print = TRUE
			if("ItemRequest")
				which = /obj/item/paper/paperwork/item_form
				print = TRUE
			if("CyberizationConsent")
				which = /obj/item/paper/paperwork/cyborg_request_form
				print = TRUE
			if("HOPAccessRequest")
				which = /obj/item/paper/paperwork/hopaccessrequestform
				print = TRUE
			if("JobReassignment")
				which = /obj/item/paper/paperwork/hop_job_change_form
				print = TRUE
			if("RDRequestForm")
				which = /obj/item/paper/paperwork/rd_form
				print = TRUE
			if("MechRequest")
				which = /obj/item/paper/paperwork/mech_form
				print = TRUE
			if("JobChangeCertificate")
				which = /obj/item/paper/paperwork/jobchangecert
				print = TRUE
			if("SecIncidentForm")
				which = /obj/item/paper/paperwork/sec_incident_report
				print = TRUE
	if(print)
		var/obj/item/computer_hardware/printer/printer
		print = !print
		if(computer)
			printer = computer.all_components[MC_PRINT]
		if(computer && printer) //This option should never be called if there is no printer
			if(!printer.print_type(which))
				to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
				return
			else
				//it printed, how many pages are left?
				var/pages_left = printer.stored_paper
				computer.visible_message(span_notice("\The [computer] prints out a paper. There are [pages_left] pages left."))
