/obj/machinery/power/port_gen/pacman/super/metro
	name = "\improper old uranium generator"
	icon_state = "portgen1_0"
	base_icon = "portgen1"
	circuit = /obj/item/circuitboard/machine/pacman/super
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	power_gen = 15000
	time_per_sheet = 400
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF


/obj/machinery/power/port_gen/pacman/super/metro/attackby(obj/item/O, mob/user, params)
	if(!active)
		if(O.tool_behaviour == TOOL_WRENCH)
			return
	..()