/obj/item/modular_computer/tablet/pda/preset
	starting_components = list(
		/obj/item/computer_hardware/processor_unit/pda,
		/obj/item/stock_parts/cell/computer/micro,
		/obj/item/computer_hardware/hard_drive/small/pda,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/card_slot,
    /obj/item/computer_hardware/printer/mini,
	)

	starting_files = list(	new /datum/computer_file/program/budgetorders,
							new /datum/computer_file/program/bounty_board)
	var/reskin_name = null // Name that shows up in PDA painter, or null if forbidden

// This is literally the worst possible cheap tablet
/obj/item/modular_computer/tablet/pda/preset/basic
	reskin_name = "Default"
	desc = "A standard issue PDA often given to station personnel."

/obj/item/modular_computer/tablet/pda/preset/scientist
	reskin_name = "Scientist"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#B347BC"

/obj/item/modular_computer/tablet/pda/preset/geneticist
	reskin_name = "Geneticist"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#000099#0097CA"

/obj/item/modular_computer/tablet/pda/preset/medical
	reskin_name = "Medical"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#000099#3F96CC"

/obj/item/modular_computer/tablet/pda/preset/medical/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/crew_monitor,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/medical/chem
	reskin_name = "Chemist"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#FAFAFA#355FAC#EA6400"
	starting_components = list(
		/obj/item/computer_hardware/processor_unit/pda,
		/obj/item/stock_parts/cell/computer/micro,
		/obj/item/computer_hardware/hard_drive/small/pda,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/card_slot,
		/obj/item/computer_hardware/sensorpackage,
	)

/obj/item/modular_computer/tablet/pda/preset/medical/chem/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/chemscan,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/medical/paramed/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/radar/lifeline,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/medical/viro
	reskin_name = "Virologist"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#FAFAFA#355FAC#57C451"

/obj/item/modular_computer/tablet/pda/preset/robo
	reskin_name = "Roboticist"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#484848#0099CC#D94927"

/obj/item/modular_computer/tablet/pda/preset/robo/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/robocontrol,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/cargo
	reskin_name = "Cargo"
	greyscale_colors = "#D6B328#6506CA"

/obj/item/modular_computer/tablet/pda/preset/cargo/Initialize(mapload)
	starting_files |= list(
//		new /datum/computer_file/program/bounty_board, Both of these come with the preset PDA hardware (/obj/item/computer_hardware/hard_drive/small/pda).
//		new /datum/computer_file/program/budgetorders, Uncomment if any change is made to that in question.
		new /datum/computer_file/program/cargobounty,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/cargo/quartermaster
	reskin_name = "Quartermaster"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D6B328#6506CA#927444"

/obj/item/modular_computer/tablet/pda/preset/cargo/quartermaster/Initialize(mapload)
	starting_files |= list(
			new /datum/computer_file/program/robocontrol,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/shaft_miner
	reskin_name = "Shaft Miner"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#927444#D6B328#6C3BA1"

/obj/item/modular_computer/tablet/pda/preset/engineering
	reskin_name = "Station Engineer"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#D99A2E#69DBF3#E3DF3D"

/obj/item/modular_computer/tablet/pda/preset/engineering/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/alarm_monitor,
		new /datum/computer_file/program/supermatter_monitor,
		new /datum/computer_file/program/nuclear_monitor,
		new /datum/computer_file/program/power_monitor
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/atmos
	reskin_name = "Atmospheric Technician"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#EEDC43#727272#00E5DA"
	starting_components = list(
		/obj/item/computer_hardware/processor_unit/pda,
		/obj/item/stock_parts/cell/computer/micro,
		/obj/item/computer_hardware/hard_drive/small/pda,
		/obj/item/computer_hardware/network_card,
		/obj/item/computer_hardware/card_slot,
		/obj/item/computer_hardware/sensorpackage,
	)

/obj/item/modular_computer/tablet/pda/preset/atmos/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/atmosscan,
		new /datum/computer_file/program/alarm_monitor,
		new /datum/computer_file/program/supermatter_monitor,
		new /datum/computer_file/program/nuclear_monitor
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/network_admin
	reskin_name = "Network Admin"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#EEDC43#69DBF3#00CC00"

/obj/item/modular_computer/tablet/pda/preset/janitor
	reskin_name = "Janitor"
	greyscale_colors = "#933ea8#235AB2"

/obj/item/modular_computer/tablet/pda/preset/chaplain
	reskin_name = "Chaplain"
	greyscale_config = /datum/greyscale_config/tablet/chaplain
	greyscale_colors = "#333333#D11818"

/obj/item/modular_computer/tablet/pda/preset/botanist
	reskin_name = "Botanist"
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#50E193#E26F41#71A7CA"

/obj/item/modular_computer/tablet/pda/preset/cook
	reskin_name = "Cook"
	greyscale_colors = "#FAFAFA#A92323"

/obj/item/modular_computer/tablet/pda/preset/artist
	reskin_name = "Artist"
	greyscale_colors = "#3E1111#112334"

/obj/item/modular_computer/tablet/pda/preset/fountainpen //Lawyer, Curator, Bartender
	pen_type = /obj/item/pen/fountain

/obj/item/modular_computer/tablet/pda/preset/fountainpen/lawyer
	reskin_name = "Lawyer"
	greyscale_colors = "#4C76C8#FFE243"

/obj/item/modular_computer/tablet/pda/preset/fountainpen/bartender
	reskin_name = "Bartender"
	greyscale_colors = "#333333#C7C7C7"

/obj/item/modular_computer/tablet/pda/preset/fountainpen/curator
	reskin_name = "Curator"
	desc = "A small experimental microcomputer."
	icon_state = "pda-library"
	icon_state_unpowered = "pda-library"
	icon_state_powered = "pda-library"
	greyscale_config = null
	greyscale_colors = null

// Honk

/obj/item/modular_computer/tablet/pda/preset/mime
	reskin_name = "Mime"
	greyscale_config = /datum/greyscale_config/tablet/mime
	greyscale_colors = "#FAFAFA#EA3232"
	pen_type = /obj/item/toy/crayon/mime

/obj/item/modular_computer/tablet/pda/preset/clown
	reskin_name = "Clown"
	desc = "A hilarious PDA often given to station pranksters."
	icon_state = "pda-clown"
	icon_state_unpowered = "pda-clown"
	icon_state_powered = "pda-clown"
	greyscale_config = /datum/greyscale_config/tablet/clown //config doesn't actually do anything but -
	greyscale_colors = null //- hey if you want to set up some cool shit go ahead
	pen_type = /obj/item/toy/crayon/rainbow

/obj/item/modular_computer/tablet/pda/preset/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 120, NO_SLIP_WHEN_WALKING)

// Honk end

/obj/item/modular_computer/tablet/pda/preset/security
	reskin_name = "Security"
	greyscale_colors = "#EA3232#0000CC"

/obj/item/modular_computer/tablet/pda/preset/security/detective
	reskin_name = "Detective"
	greyscale_colors = "#805A2F#990202"

/obj/item/modular_computer/tablet/pda/preset/security/warden
	reskin_name = "Warden"
	greyscale_config = /datum/greyscale_config/tablet/stripe_split
	greyscale_colors = "#EA3232#0000CC#363636"

/obj/item/modular_computer/tablet/pda/preset/security/warden/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/secureye,
	)
	return ..()

//for inside one of the nukie lockers and the ones infiltrators spawn with
/obj/item/modular_computer/tablet/pda/preset/syndicate
	desc = "Based off Nanotrasen's PDAs, this one has been reverse-engineered and loaded with illegal software provided by the Syndicate."
	greyscale_config = /datum/greyscale_config/tablet/stripe_thick
	greyscale_colors = "#A80001#5C070F#000000"
	starting_components = list( /obj/item/computer_hardware/processor_unit/small,
								/obj/item/stock_parts/cell/computer,
								/obj/item/computer_hardware/hard_drive/small/syndicate,
								/obj/item/computer_hardware/network_card/advanced,
								/obj/item/computer_hardware/card_slot,
								/obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/preset/syndicate/Initialize(mapload)
	obj_flags |= EMAGGED //starts emagged
	starting_files |= list(
		new /datum/computer_file/program/bomberman,
	)
	return ..()

// The worst thing mankind can fathom - used in clown ops and nukie clown costume
/obj/item/modular_computer/tablet/pda/preset/clown/syndicate
	desc = "A hilariously terrifying PDA reverse-engineered by the Syndicate, given to their most unhinged operatives."

/obj/item/modular_computer/tablet/pda/preset/clown/syndicate/Initialize(mapload)
	obj_flags |= EMAGGED //starts emagged //rather have this than re-do clown stuff over
	starting_files |= list(
		new /datum/computer_file/program/bomberman,
	)
	return ..()

/obj/item/modular_computer/tablet/pda/preset/bureaucrat
	desc = "A standard issue PDA issued to certain Nanotrasen personnel to help with inspections."
	greyscale_config = /datum/greyscale_config/tablet/captain
	greyscale_colors = "#2EBE3B#FF0000#FFFFFF#FFD55B" // Rockin the company colors
	pen_type = /obj/item/pen/fountain/captain

/obj/item/modular_computer/tablet/pda/preset/bureaucrat/Initialize(mapload)
	starting_files |= list(
		new /datum/computer_file/program/crew_manifest,
		new /datum/computer_file/program/paperwork_printer
	)
	return ..()
