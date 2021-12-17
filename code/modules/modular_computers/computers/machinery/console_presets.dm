/obj/machinery/modular_computer/console/preset
	// Can be changed to give devices specific hardware
	var/_has_second_id_slot = FALSE
	var/_has_printer = FALSE
	var/_has_battery = FALSE
	var/_has_ai = FALSE

/obj/machinery/modular_computer/console/preset/Initialize()
	. = ..()
	if(!cpu)
		return
	cpu.install_component(new /obj/item/computer_hardware/processor_unit)

	cpu.install_component(new /obj/item/computer_hardware/card_slot)
	if(_has_second_id_slot)
		cpu.install_component(new /obj/item/computer_hardware/card_slot/secondary)
	if(_has_printer)
		cpu.install_component(new /obj/item/computer_hardware/printer)
	if(_has_battery)
		cpu.install_component(new /obj/item/computer_hardware/battery(cpu, /obj/item/stock_parts/cell/computer/super))
	if(_has_ai)
		cpu.install_component(new /obj/item/computer_hardware/ai_slot)
	install_programs()

// Override in child types to install preset-specific programs.
/obj/machinery/modular_computer/console/preset/proc/install_programs()
	return



// ===== SECURITY CONSOLE =====
/obj/machinery/modular_computer/console/preset/security
	console_department = "Security"
	name = "security console"
	desc = "A stationary computer. This one comes preloaded with security programs."

/obj/machinery/modular_computer/console/preset/security/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/secureye())

// ===== ENGINEERING CONSOLE =====
/obj/machinery/modular_computer/console/preset/engineering
	console_department = "Engineering"
	name = "engineering console"
	desc = "A stationary computer. This one comes preloaded with engineering programs."

/obj/machinery/modular_computer/console/preset/engineering/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/power_monitor())
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/supermatter_monitor())

// ===== TELECOMS CONSOLE =====
/obj/machinery/modular_computer/console/preset/tcomms
	console_department = "Engineering"
	name = "telecomunications console"
	desc = "A stationary computer. This one comes preloaded with engineering programs targeted at monitoring telecomunications traffic."

/obj/machinery/modular_computer/console/preset/tcomms/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())

// ===== RESEARCH CONSOLE =====
/obj/machinery/modular_computer/console/preset/research
	console_department = "Research"
	name = "research console"
	desc = "A stationary computer. This one comes preloaded with research programs."
	_has_ai = TRUE

/obj/machinery/modular_computer/console/preset/research/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/robocontrol())

// ===== CARGO CONSOLE =====
/obj/machinery/modular_computer/console/preset/cargo
	console_department = "Supply"
	name = "cargo console"
	desc = "A stationary computer. This one comes preloaded with programs to keep the station stocked."

/obj/machinery/modular_computer/console/preset/cargo/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/bounty_board())

// ===== QUARTERMASTER CONSOLE =====
/obj/machinery/modular_computer/console/preset/cargo/qm
	console_department = "Supply"
	name = "quartermaster's console"
	desc = "A stationary computer. This one comes preloaded with programs to keep the station stocked and monitor the lavaland mining opperation."

/obj/machinery/modular_computer/console/preset/cargo/qm/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/secureye/mining())

// ===== MINING CONSOLE =====
/obj/machinery/modular_computer/console/preset/mining
	console_department = "Supply"
	name = "mining console"
	desc = "A stationary computer. This one comes preloaded with programs to monitor the lavaland mining opperation."

/obj/machinery/modular_computer/console/preset/mining/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/secureye/mining())


// ===== COMMAND CONSOLE =====
/obj/machinery/modular_computer/console/preset/command
	console_department = "Command"
	name = "command console"
	desc = "A stationary computer. This one comes preloaded with command programs."
	_has_second_id_slot = TRUE
	_has_printer = TRUE

/obj/machinery/modular_computer/console/preset/command/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/card_mod())

// ===== HoP =====
/obj/machinery/modular_computer/console/preset/command/hop
	name = "head of personnel's console"
	desc = "A stationary computer. This one comes preloaded with bureaucratic programs."

/obj/machinery/modular_computer/console/preset/command/hop/install_programs()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/job_management())
	hard_drive.store_file(new/datum/computer_file/program/crew_manifest())
	hard_drive.store_file(new/datum/computer_file/program/bounty_board())
	hard_drive.store_file(new/datum/computer_file/program/secureye/mining())

// ===== HoS =====
/obj/machinery/modular_computer/console/preset/command/hos
	name = "head of security's console"
	desc = "A stationary computer. This one comes preloaded with security programs."

/obj/machinery/modular_computer/console/preset/command/hos/install_programs()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/secureye())

// ===== CE =====
/obj/machinery/modular_computer/console/preset/command/ce
	name = "chief engineer's console"
	desc = "A stationary computer. This one comes preloaded with engineering programs."

/obj/machinery/modular_computer/console/preset/command/ce/install_programs()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/power_monitor())
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/supermatter_monitor())
	hard_drive.store_file(new/datum/computer_file/program/energy_harvester_control())

// ===== RD =====
/obj/machinery/modular_computer/console/preset/command/rd
	name = "research director's console"
	desc = "A stationary computer. This one comes preloaded with research programs."
	_has_ai = TRUE

/obj/machinery/modular_computer/console/preset/command/rd/install_programs()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new/datum/computer_file/program/aidiag())
	hard_drive.store_file(new/datum/computer_file/program/robocontrol())

// ===== CMO =====
/obj/machinery/modular_computer/console/preset/command/cmo
	name = "chief medical officer's console"
	desc = "A stationary computer. This one comes preloaded with medical programs." //One day

/*
/obj/machinery/modular_computer/console/preset/command/cmo/install_programs()
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
*/


// ===== CIVILIAN CONSOLE =====
/obj/machinery/modular_computer/console/preset/civilian
	console_department = "Civilian"
	name = "civilian console"
	desc = "A stationary computer. This one comes preloaded with generic programs."

/obj/machinery/modular_computer/console/preset/civilian/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/arcade())

// curator
/obj/machinery/modular_computer/console/preset/curator
	console_department = "Civilian"
	name = "art console"
	desc = "A stationary computer. This one comes preloaded with art programs."
	_has_printer = TRUE

/obj/machinery/modular_computer/console/preset/curator/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/portrait_printer())

