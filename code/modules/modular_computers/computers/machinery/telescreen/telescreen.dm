/obj/machinery/modular_computer/telescreen
	name = "telescreen"
	desc = "A wall-mounted touchscreen computer."
	icon = 'icons/obj/modular_telescreen.dmi'
	icon_state = "telescreen"
	icon_state_unpowered = "telescreen"
	icon_state_powered = "telescreen"
	hardware_flag = PROGRAM_TELESCREEN
	anchored = TRUE
	density = FALSE
	base_idle_power_usage = 75
	base_active_power_usage = 300
	max_hardware_size = WEIGHT_CLASS_NORMAL
	steel_sheet_cost = 10
	interact_sounds = list('sound/machines/computers/pda_click.ogg')

/obj/machinery/modular_computer/telescreen/attackby(var/obj/item/W as obj, var/mob/user as mob)
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(cpu.all_components.len)
			to_chat(user, span_warning("Remove all components from \the [src] before unsecuring it."))
			return
		new /obj/item/wallframe/telescreen(get_turf(src.loc))
		visible_message("\The [src] has been unsecured by [user].")
		cpu.relay_qdel()
		qdel(src)
		return
	..()

/obj/item/wallframe/telescreen
	name = "\improper telescreen frame"
	icon = 'icons/obj/modular_telescreen.dmi'
	icon_state = "telescreen"
	w_class = WEIGHT_CLASS_BULKY
	result_path = /obj/machinery/modular_computer/telescreen
	pixel_shift = -32
