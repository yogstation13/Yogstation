/obj/machinery/rnd/production/circuit_imprinter/department
<<<<<<< HEAD
	name = "department circuit imprinter"
	desc = "A special circuit imprinter with a built in interface meant for departmental usage, with built in ExoSync recievers allowing it to print designs researched that match its ROM-encoded department type."
=======
	name = "Department Circuit Imprinter"
	desc = "A special circuit imprinter with a built in interface meant for departmental usage, with built in ExoSync recievers allowing it to print designs researched that match its ROM-encoded department type. Features a bluespace materials reciever for recieving materials without the hassle of running to mining!"
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	icon_state = "circuit_imprinter"
	container_type = OPENCONTAINER
	circuit = /obj/item/circuitboard/machine/circuit_imprinter/department
	requires_console = FALSE
	consoleless_interface = TRUE

/obj/machinery/rnd/production/circuit_imprinter/department/science
<<<<<<< HEAD
	name = "department circuit imprinter (Science)"
=======
	name = "department protolathe (Science)"
>>>>>>> d30da792ce... Merge remote-tracking branch 'upstream/master' into pets
	allowed_department_flags = DEPARTMENTAL_FLAG_ALL|DEPARTMENTAL_FLAG_SCIENCE
	department_tag = "Science"