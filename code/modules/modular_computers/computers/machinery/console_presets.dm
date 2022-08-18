/obj/machinery/modular_computer/console/preset
	starting_components = list(	/obj/item/computer_hardware/network_card/wired,
								/obj/item/computer_hardware/recharger/APC,
								/obj/item/computer_hardware/hard_drive/super,
								/obj/item/computer_hardware/processor_unit,
								/obj/item/computer_hardware/card_slot)



// ===== SECURITY CONSOLE =====
/obj/machinery/modular_computer/console/preset/security
	console_department = "Security"
	name = "security console"
	desc = "A stationary computer. This one comes preloaded with security programs."
	starting_files = list(	new /datum/computer_file/program/secureye)
	initial_program = /datum/computer_file/program/secureye

// ===== ENGINEERING CONSOLE =====
/obj/machinery/modular_computer/console/preset/engineering
	console_department = "Engineering"
	name = "engineering console"
	desc = "A stationary computer. This one comes preloaded with engineering programs."
	starting_files = list(	new /datum/computer_file/program/power_monitor,
							new /datum/computer_file/program/alarm_monitor,
							new /datum/computer_file/program/supermatter_monitor)
	initial_program = /datum/computer_file/program/power_monitor

// ===== TELECOMS CONSOLE =====
/obj/machinery/modular_computer/console/preset/tcomms
	console_department = "Engineering"
	name = "telecommunications console"
	desc = "A stationary computer. This one comes preloaded with engineering programs targeted at monitoring telecomunications traffic."
	starting_files = list(	new /datum/computer_file/program/ntnetmonitor,
							new /datum/computer_file/program/chatclient)
	initial_program = /datum/computer_file/program/ntnetmonitor

// ===== RESEARCH CONSOLE =====
/obj/machinery/modular_computer/console/preset/research
	console_department = "Research"
	name = "research console"
	desc = "A stationary computer. This one comes preloaded with research programs."
	starting_files = list(	new /datum/computer_file/program/robocontrol)
	initial_program = /datum/computer_file/program/robocontrol

// ===== MEDICAL CONSOLE =====
/obj/machinery/modular_computer/console/preset/medical
	console_department = "Medical"
	name = "medical console"
	desc = "A stationary computer. This one comes preloaded with medical programs."
	starting_files = list(	new /datum/computer_file/program/crew_monitor)
	initial_program = /datum/computer_file/program/crew_monitor

// ===== CARGO CONSOLE =====
/obj/machinery/modular_computer/console/preset/cargo
	console_department = "Supply"
	name = "cargo console"
	desc = "A stationary computer. This one comes preloaded with programs to keep the station stocked."
	starting_files = list(	new /datum/computer_file/program/bounty_board)
	initial_program = /datum/computer_file/program/bounty_board

// ===== QUARTERMASTER CONSOLE =====
/obj/machinery/modular_computer/console/preset/cargo/qm
	console_department = "Supply"
	name = "quartermaster's console"
	desc = "A stationary computer. This one comes preloaded with programs to keep the station stocked and monitor the lavaland mining opperation."
	starting_files = list(	new /datum/computer_file/program/bounty_board,
							new /datum/computer_file/program/secureye/mining)

// ===== MINING CONSOLE =====
/obj/machinery/modular_computer/console/preset/mining
	console_department = "Supply"
	name = "mining console"
	desc = "A stationary computer. This one comes preloaded with programs to monitor the lavaland mining opperation."
	starting_files = list(	new /datum/computer_file/program/secureye/mining)
	initial_program = /datum/computer_file/program/secureye/mining

// ===== COMMAND CONSOLE =====
/obj/machinery/modular_computer/console/preset/command
	console_department = "Command"
	name = "command console"
	desc = "A stationary computer. This one comes preloaded with command programs."
	starting_components = list(	/obj/item/computer_hardware/network_card/wired,
								/obj/item/computer_hardware/recharger/APC,
								/obj/item/computer_hardware/hard_drive/super,
								/obj/item/computer_hardware/processor_unit,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/printer,
								/obj/item/computer_hardware/card_slot/secondary)

	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/card_mod)

// ===== HoP =====
/obj/machinery/modular_computer/console/preset/command/hop
	name = "head of personnel's console"
	desc = "A stationary computer. This one comes preloaded with bureaucratic programs."
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/job_management,
							new /datum/computer_file/program/crew_manifest,
							new /datum/computer_file/program/bounty_board,
							new /datum/computer_file/program/secureye/mining)

// ===== HoS =====
/obj/machinery/modular_computer/console/preset/command/hos
	name = "head of security's console"
	desc = "A stationary computer. This one comes preloaded with security programs."
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/secureye)

// ===== CE =====
/obj/machinery/modular_computer/console/preset/command/ce
	name = "chief engineer's console"
	desc = "A stationary computer. This one comes preloaded with engineering programs."
	starting_files = list(new 	/datum/computer_file/program/chatclient,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/power_monitor,
							new /datum/computer_file/program/alarm_monitor,
							new /datum/computer_file/program/supermatter_monitor,
							new /datum/computer_file/program/energy_harvester_control)

// ===== RD =====
/obj/machinery/modular_computer/console/preset/command/rd
	name = "research director's console"
	desc = "A stationary computer. This one comes preloaded with research programs."
	starting_components = list(	/obj/item/computer_hardware/network_card/wired,
								/obj/item/computer_hardware/recharger/APC,
								/obj/item/computer_hardware/hard_drive/super,
								/obj/item/computer_hardware/processor_unit,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/printer,
								/obj/item/computer_hardware/card_slot/secondary,
								/obj/item/computer_hardware/ai_slot)

	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/ntnetmonitor,
							new /datum/computer_file/program/aidiag,
							new /datum/computer_file/program/robocontrol)

// ===== CMO =====
/obj/machinery/modular_computer/console/preset/command/cmo
	name = "chief medical officer's console"
	desc = "A stationary computer. This one comes preloaded with medical programs."
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/card_mod,
							new /datum/computer_file/program/crew_monitor)


// ===== CIVILIAN CONSOLE =====
/obj/machinery/modular_computer/console/preset/civilian
	console_department = "Civilian"
	name = "civilian console"
	desc = "A stationary computer. This one comes preloaded with generic programs."
	starting_files = list(	new /datum/computer_file/program/chatclient,
							new /datum/computer_file/program/arcade)

// ===== CURATOR =====
/obj/machinery/modular_computer/console/preset/curator
	console_department = "Civilian"
	name = "art console"
	desc = "A stationary computer. This one comes preloaded with art programs."
	starting_components = list(	/obj/item/computer_hardware/network_card/wired,
								/obj/item/computer_hardware/recharger/APC,
								/obj/item/computer_hardware/hard_drive/super,
								/obj/item/computer_hardware/processor_unit,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/printer)

	starting_files = list(	new /datum/computer_file/program/portrait_printer)
	initial_program = /datum/computer_file/program/portrait_printer

//Curator gets to be special
/obj/machinery/modular_computer/console/preset/curator/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/canvas))
		if(alert(user, "Are you sure you want to upload this painting? This will irreversibly delete the current painting and require you to print it out again in future rounds.", "Confirm", "No", "Yes") != "Yes")
			return
		var/obj/item/canvas/P = I
		var/obj/structure/sign/painting/frame = new(src)
		frame.persistence_id = "public_paintings"
		frame.C = P
		frame.C.finalize(user)
		frame.save_persistent()
		qdel(P)
		qdel(frame)
		return FALSE
	return ..()


// ===== NETWORK ADMIN CONSOLE =====
/obj/machinery/modular_computer/console/preset/netmin
	console_department = "Engineering"
	name = "ai network console"
	desc = "A stationary computer. This one comes preloaded with ai network administration software"
	starting_files = list(	new /datum/computer_file/program/ai_network_interface)
	initial_program = /datum/computer_file/program/ai_network_interface
