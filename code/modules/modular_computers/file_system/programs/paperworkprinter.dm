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

/datum/computer_file/program/paperwork_printer/ui_data(mob/user)
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
			src.doprint(1)
		if("PRG_print_ComplaintForm")
			src.doprint(2)
		if("PRG_print_IncidentRepForm")
			src.doprint(3)
		if("PRG_print_ItemReqForm")
			src.doprint(4)
		if("PRG_print_CyberConsentForm")
			src.doprint(5)
		if("PRG_print_HOPAccessForm")
			src.doprint(6)
		if("PRG_print_JobReassignForm")
			src.doprint(7)
		if("PRG_print_RDReqForm")
			src.doprint(8)
		if("PRG_print_MechReqForm")
			src.doprint(9)
		if("PRG_print_JobChangeCert")
			src.doprint(10)
		if("PRG_print_SecRepForm")
			src.doprint(11)

/datum/computer_file/program/paperwork_printer/proc/doprint(ftype)
	if(..())
		return
	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]
	var/obj/item/paper/paperwork/which = /obj/item/paper/paperwork
	switch(ftype)
		if(1)
			which = /obj/item/paper/paperwork/general_request_form
		if(2)
			which = /obj/item/paper/paperwork/complaint_form
		if(3)
			which = /obj/item/paper/paperwork/incident_report
		if(4)
			which = /obj/item/paper/paperwork/item_form
		if(5)
			which = /obj/item/paper/paperwork/cyborg_request_form
		if(6)
			which = /obj/item/paper/paperwork/hopaccessrequestform
		if(7)
			which = /obj/item/paper/paperwork/hop_job_change_form
		if(8)
			which = /obj/item/paper/paperwork/rd_form
		if(9)
			which = /obj/item/paper/paperwork/mech_form
		if(10)
			which = /obj/item/paper/paperwork/jobchangecert
		if(11)
			which = /obj/item/paper/paperwork/sec_incident_report
	if(computer && printer) //This option should never be called if there is no printer
		if(!printer.print_type(which))
			to_chat(usr, span_notice("Hardware error: Printer was unable to print the file. It may be out of paper."))
			return
		else
			computer.visible_message(span_notice("\The [computer] prints out a paper."))
