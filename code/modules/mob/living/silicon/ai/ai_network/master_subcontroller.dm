/obj/machinery/ai/master_subcontroller
	name = "master subcontroller"
	desc = "An ancient mainframe dedicated to tasks thought too simple for the onboard experimental AI. This mainframe takes care of duties such as polling APCs for updates, priming door servos and updating air alarms."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	density = TRUE
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 500
	max_integrity = 1000

	circuit = /obj/item/circuitboard/machine/networking_machine
	var/on = TRUE


	var/list/enabled_areas = list(
		"General Areas" = /datum/wires/airlock,
		"Maintenance Tunnels" = /datum/wires/airlock/maint,
		"Command Areas" = /datum/wires/airlock/command,
		"Service Areas" = /datum/wires/airlock/service,
		"Engineering Areas" = /datum/wires/airlock/engineering,
		"Medical Areas" = /datum/wires/airlock/medbay,
		"Science Areas" = /datum/wires/airlock/science,
		"AI Areas" = /datum/wires/airlock/ai
	)

	var/list/disabled_areas = list(
		"Security Areas" = /datum/wires/airlock/security
	)




/obj/machinery/ai/master_subcontroller/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_MULTITOOL)
		var/action = alert("What do you wish to do?",, "Enable Area", "Disable Area", "Cancel")
		if(!action)
			return TRUE
		if(action == "Cancel")
			return TRUE
		if(action == "Enable Area")
			if(!disabled_areas.len)
				to_chat(user, span_warning("There are no areas to enable!"))
				return TRUE
			var/selected_area = input("Please select an area to enable:") as null|anything in disabled_areas
			if(!selected_area)
				return TRUE
			if(!disabled_areas[selected_area])
				return TRUE
			enabled_areas[selected_area] = disabled_areas[selected_area]
			disabled_areas -= selected_area


		if(action == "Disable Area")
			if(!enabled_areas.len)
				to_chat(user, span_warning("There are no areas to disable!"))
				return TRUE
			var/selected_area = input("Please select an area to disable:") as null|anything in enabled_areas
			if(!selected_area)
				return TRUE
			if(!enabled_areas[selected_area])
				return TRUE
			disabled_areas[selected_area] = enabled_areas[selected_area]
			enabled_areas -= selected_area
		return TRUE

	return ..()

/obj/machinery/ai/master_subcontroller/process()
	update_power()
	update_icon()

/obj/machinery/ai/master_subcontroller/update_icon()
	cut_overlays()
	if(on)
		var/mutable_appearance/on_overlay
		if(on_icon)
			on_overlay = mutable_appearance(icon, on_icon)
		else
			on_overlay = mutable_appearance(icon, "[initial(icon_state)]_on")
		add_overlay(on_overlay)
	if(panel_open)
		icon_state = "[initial(icon_state)]_o"
	else
		icon_state = initial(icon_state)

/obj/machinery/ai/master_subcontroller/proc/update_power()
	if(stat & (BROKEN|NOPOWER|EMPED)) // if powered, on. if not powered, off. if too damaged, off
		on = FALSE
	else
		on = TRUE


/obj/machinery/ai/master_subcontroller/connect_to_network()
	. = ..()
	network.cached_subcontroller = src
	
/obj/machinery/ai/master_subcontroller/disconnect_from_network()
	if(network.cached_subcontroller == src)
		network.cached_subcontroller = null
	. = ..()
	network.cached_subcontroller = src
