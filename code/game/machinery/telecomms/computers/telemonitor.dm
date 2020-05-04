
/*
	Telecomms monitor tracks the overall trafficing of a telecommunications network
	and displays a heirarchy of linked machines.
*/


/obj/machinery/computer/telecomms/monitor
	name = "telecommunications monitoring console"
	icon_screen = "comm_monitor"
	desc = "Monitors the details of the telecommunications network it's synced with."

	var/screen = 0				// the screen number:
	var/list/machinelist = list()	// the machines located by the computer
	var/obj/machinery/telecomms/SelectedMachine

	var/network = "NULL"		// the network to probe

	var/temp = ""				// temporary feedback messages
	circuit = /obj/item/circuitboard/computer/comm_monitor

/obj/machinery/computer/telecomms/monitor/ui_interact(mob/user)
	. = ..()
	var/dat = "<HTML><HEAD><meta charset='UTF-8'><TITLE>Telecommunications Monitor</TITLE></HEAD><BODY><center><b>Telecommunications Monitor</b></center>"

	switch(screen)


	  // --- Main Menu ---

		if(0)
			dat += "<br>[temp]<br><br>"
			dat += "<br>Current Network: <a href='?src=[REF(src)];network=1'>[network]</a><br>"
			if(machinelist.len)
				dat += "<br>Detected Network Entities:<ul>"
				for(var/obj/machinery/telecomms/T in machinelist)
					dat += "<li><a href='?src=[REF(src)];viewmachine=[T.id]'>[REF(T)] [T.name]</a> ([T.id])</li>"
				dat += "</ul>"
				dat += "<br><a href='?src=[REF(src)];operation=release'>\[Flush Buffer\]</a>"
			else
				dat += "<a href='?src=[REF(src)];operation=probe'>\[Probe Network\]</a>"


	  // --- Viewing Machine ---

		if(1)
			dat += "<br>[temp]<br>"
			dat += "<center><a href='?src=[REF(src)];operation=mainmenu'>\[Main Menu\]</a></center>"
			dat += "<br>Current Network: [network]<br>"
			dat += "Selected Network Entity: [SelectedMachine.name] ([SelectedMachine.id])<br>"
			dat += "Linked Entities: <ol>"
			for(var/obj/machinery/telecomms/T in SelectedMachine.links)
				if(!T.hide)
					dat += "<li><a href='?src=[REF(src)];viewmachine=[T.id]'>[REF(T.id)] [T.name]</a> ([T.id])</li>"
			dat += "</ol>"

	dat += "</BODY></HTML>"

	user << browse(dat, "window=comm_monitor;size=575x400")
	onclose(user, "server_control")

	temp = ""
	return


/obj/machinery/computer/telecomms/monitor/Topic(href, href_list)
	if(..())
		return


	add_fingerprint(usr)
	usr.set_machine(src)

	if(href_list["viewmachine"])
		screen = 1
		for(var/obj/machinery/telecomms/T in machinelist)
			if(T.id == href_list["viewmachine"])
				SelectedMachine = T
				break

	if(href_list["operation"])
		switch(href_list["operation"])

			if("release")
				machinelist = list()
				screen = 0

			if("mainmenu")
				screen = 0

			if("probe")
				if(machinelist.len > 0)
					temp = "<font color = #D70B00>- FAILED: CANNOT PROBE WHEN BUFFER FULL -</font color>"

				else
					for(var/sel_z in get_multiz_accessible_levels(z))
						for(var/obj/machinery/telecomms/server/T in urange(25, locate(x, y, sel_z)))
							if(T.network == network)
								machinelist.Add(T)

					if(!machinelist.len)
						temp = "<font color = #D70B00>- FAILED: UNABLE TO LOCATE NETWORK ENTITIES IN \[[network]\] -</font color>"
					else
						temp = "<font color = #336699>- [machinelist.len] ENTITIES LOCATED & BUFFERED -</font color>"

					screen = 0


	if(href_list["network"])

		var/newnet = stripped_input(usr, "Which network do you want to view?", "Comm Monitor", network)
		if(newnet && ((usr in range(1, src)) || issilicon(usr)))
			if(length(newnet) > 15)
				temp = "<font color = #D70B00>- FAILED: NETWORK TAG STRING TOO LENGHTLY -</font color>"

			else
				network = newnet
				screen = 0
				machinelist = list()
				temp = "<font color = #336699>- NEW NETWORK TAG SET IN ADDRESS \[[network]\] -</font color>"

	updateUsrDialog()
	return

/obj/machinery/computer/telecomms/monitor/attackby()
	. = ..()
	updateUsrDialog()
