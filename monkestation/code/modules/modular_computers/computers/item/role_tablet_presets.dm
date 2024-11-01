/obj/item/modular_computer/pda/security/brig_physician
	name = "brig physician PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#A52F29#0000CC#918F8C"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/radar/lifeline, // For finding security officers
	)

/obj/item/modular_computer/pda/engineering
	starting_programs = list(
		/datum/computer_file/program/supermatter_monitor,
		/datum/computer_file/program/alarm_monitor,
	)

/obj/item/modular_computer/pda/roboticist
	starting_programs = list(
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/borg_monitor,
	)

/obj/item/modular_computer/pda/psychologist
	name = "Psychologist PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#242424#333333"
	starting_programs = list(
		/datum/computer_file/program/records/medical,
		/datum/computer_file/program/robocontrol,
	)

/obj/item/modular_computer/pda/psychologist/Initialize(mapload)
	. = ..()
	for(var/datum/computer_file/program/messenger/messenger_app in stored_files)
		messenger_app.spam_mode = TRUE

/obj/item/modular_computer/pda/blueshield //for now functionally the same as sec but with lifeline. But having it here means if we want to give a fancy pda or a CC command PDA we most certainly.
	name = "blueshield PDA"
	greyscale_colors = "#EA3232#0000cc"
	starting_programs = list(
		/datum/computer_file/program/records/security,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/radar/lifeline,
	)

/obj/item/modular_computer/pda/signal
	name = "signal PDA"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#0EC220#727272"
	starting_programs = list()

/obj/item/modular_computer/pda/barber
	name = "barber PDA"
	greyscale_colors = "#933ea8#235AB2"
	starting_programs = list()
