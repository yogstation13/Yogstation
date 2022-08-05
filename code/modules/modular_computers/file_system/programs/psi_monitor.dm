/*
/datum/computer_file/program/psimonitor
	filename = "psimonitor"
	filedesc = "Psi Monitor"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "comm_monitor"
	extended_desc = "This program monitors and configures implanted psi monitors."
	size = 6
	requires_ntnet = TRUE
	usage_flags = PROGRAM_CONSOLE | PROGRAM_LAPTOP | PROGRAM_TABLET | PROGRAM_PHONE | PROGRAM_TELESCREEN
	transfer_access = ACCESS_MEDICAL
	available_on_ntnet = TRUE
	tgui_id = "NtosPsiMonitor"
	var/obj/item/implant/psi_control/selected_implant
	var/show_violations = FALSE
	var/authorized

/obj/machinery/psi_monitor/New()
	SSpsi.psi_monitors += src
	..()
/*
/obj/machinery/psi_monitor/emag_act(var/remaining_charges, var/mob/user)
	if(!emagged)
		emagged = TRUE
		remaining_charges--
		req_one_access.Cut()
		to_chat(user, "<span class='notice'>You short out the access protocols.</span>")
		return TRUE
	return FALSE
*/

/datum/computer_file/program/psimonitor/ui_act(action, params)
	if(..())
		return
	computer.play_interact_sound()
	switch(action)
		if("login")
			var/obj/item/card/id/ID = usr.GetID()
			if(!ID || (transfer_access in ID.GetAccess()))
				to_chat(usr, span_warning("Access denied."))
			else
				authorized = "[ID.registered_name] ([ID.assignment])"
			return TRUE
		if("logout")
			authorized = FALSE
			return TRUE
		if("change_mode")
			selected_implant.psi_mode = input("Select a new implant mode.", "Psi Dampener") as null|anything in list(PSI_IMPLANT_AUTOMATIC, PSI_IMPLANT_SHOCK, PSI_IMPLANT_WARN, PSI_IMPLANT_LOG, PSI_IMPLANT_DISABLED)
			return TRUE
		/*
		if("remove_violation")
			var/remove_ind = text2num(href_list["remove_violation"])
			if(remove_ind > 0 && remove_ind <= psi_violations.len)
				psi_violations.Cut(remove_ind, remove_ind++)
			return TRUE
		*/
		if("change_mode")
			selected_implant.psi_mode = input("Select a new implant mode.", "Psi Dampener") as null|anything in list(PSI_IMPLANT_AUTOMATIC, PSI_IMPLANT_SHOCK, PSI_IMPLANT_WARN, PSI_IMPLANT_LOG, PSI_IMPLANT_DISABLED)
			return TRUE

/datum/computer_file/program/psimonitor/ui_data(mob/user)
	if(!SSnetworks.station_network)
		return
	var/list/data = get_header_data()

	data["authorized"] = authorized
	data["ntnetrelays"] = SSnetworks.station_network.relays.len
	data["idsstatus"] = SSnetworks.station_network.intrusion_detection_enabled
	data["idsalarm"] = SSnetworks.station_network.intrusion_detection_alarm

	data["config_softwaredownload"] = SSnetworks.station_network.setting_softwaredownload
	data["config_peertopeer"] = SSnetworks.station_network.setting_peertopeer
	data["config_communication"] = SSnetworks.station_network.setting_communication
	data["config_systemcontrol"] = SSnetworks.station_network.setting_systemcontrol

	data["logs"] = list()
	if(selected_implant.logs)
		data["logs"] = selected_implant.logs

	for(var/i in SSnetworks.station_network.logs)
		data["ntnetlogs"] += list(list("entry" = i))
	data["ntnetmaxlogs"] = SSnetworks.station_network.setting_maxlogcount
/*
/obj/machinery/psi_monitor/interact(var/mob/user)

	var/list/dat = list()
	dat += "<h1>Psi Dampener Monitor</h1>"
	if(authorized)
		dat += "<b>[authorized]</b> <a href='?src=\ref[src];logout=1'>Logout</a>"
	else
		dat += "<a href='?src=\ref[src];login=1'>Login</a>"

	dat += "<h2>Active Psionic Dampeners</h2><hr>"
	dat += "<center><table>"
	dat += "<tr><td><b>Operant</b></td><td><b>System load</b></td><td><b>Mode</b></td></tr>"
	for(var/thing in SSpsi.psi_dampeners)
		var/obj/item/weapon/implant/psi_control/implant = thing
		if(!implant.imp_in)
			continue
		dat += "<tr><td>[implant.imp_in.name]</td>"
		if(implant.malfunction)
			dat += "<td>ERROR</td><td>ERROR</td>"
		else
			dat += "<td>[implant.overload]%</td><td>[authorized ? "<a href='?src=\ref[src];change_mode=\ref[implant]'>[implant.psi_mode]</a>" : "[implant.psi_mode]"]</td>"
		dat += "</tr>"
	dat += "</table><hr></center>"

	if(show_violations)
		dat += "<h2>Psionic Control Violations <a href='?src=\ref[src];show_violations=0'>-</a></h2><hr><center><table>"
		if(psi_violations.len)
			for(var/i =  1 to psi_violations.len)
				var/entry = psi_violations[i]
				dat += "<tr><td><br>[entry]</td><td>[authorized ? "<a href='?src=\ref[src];remove_violation=[i]'>Remove</a>" : ""]</td></tr>"
		else
			dat += "<tr><td colspan = 2>None reported.</td></tr>"
		dat += "</table></center><hr>"
	else
		dat += "<h2>Psionic Control Violations <a href='?src=\ref[src];show_violations=1'>+</a></h2><hr>"

	var/datum/browser/popup = new(user, "psi_monitor_\ref[src]", "Psi-Monitor")
	popup.set_content(jointext(dat,null))
	popup.open()
*/
*/
