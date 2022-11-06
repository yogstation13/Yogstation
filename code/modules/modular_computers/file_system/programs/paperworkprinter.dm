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
	var/obj/item/paper/paperwork/which
	var/print = 1

/datum/computer_file/program/paperwork_printer/ui_static_data(mob/user)
	var/list/data = get_header_data()
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	if(computer)
		data["have_printer"] = !!printer
	else
		data["have_printer"] = FALSE
	return data

/datum/computer_file/program/paperwork_printer/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	switch(action)
		if("PRG_print_GenReqForm")
			which = /obj/item/paper/paperwork/general_request_form
			print = 1
		if("PRG_print_ComplaintForm")
			which = /obj/item/paper/paperwork/complaint_form
			print = 1
		if("PRG_print_IncidentRepForm")
			which = /obj/item/paper/paperwork/incident_report
			print = 1
		if("PRG_print_ItemReqForm")
			which = /obj/item/paper/paperwork/item_form
			print = 1
		if("PRG_print_CyberConsentForm")
			which = /obj/item/paper/paperwork/cyborg_request_form
			print = 1
		if("PRG_print_HOPAccessForm")
			which = /obj/item/paper/paperwork/hopaccessrequestform
			print = 1
		if("PRG_print_JobReassignForm")
			which = /obj/item/paper/paperwork/hop_job_change_form
			print = 1
		if("PRG_print_RDReqForm")
			which = /obj/item/paper/paperwork/rd_form
			print = 1
		if("PRG_print_MechReqForm")
			which = /obj/item/paper/paperwork/mech_form
			print = 1
		if("PRG_print_JobChangeCert")
			which = /obj/item/paper/paperwork/jobchangecert
			print = 1
		if("PRG_print_SecRepForm")
			which = /obj/item/paper/paperwork/sec_incident_report
			print = 1
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
				computer.visible_message(span_notice("\The [computer] prints out a paper."))
