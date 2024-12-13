#define AIR_CONTENTS	((25*ONE_ATMOSPHERE)*(air_contents.return_volume())/(R_IDEAL_GAS_EQUATION*air_contents.return_temperature()))

/obj/machinery/atmospherics/components/unary/tank
	name = "pressure tank"
	desc = "A large vessel containing pressurized gas. Unanchor with a wrench by left-clicking, rotate with a wrench by right-clicking, relabel or recolor with Alt-click."

	icon = 'icons/obj/atmospherics/pressure_tank.dmi'
	icon_state = "base"

	max_integrity = 800
	density = TRUE
	layer = ABOVE_WINDOW_LAYER
	pipe_flags = PIPING_ONE_PER_TURF
	move_resist = MOVE_RESIST_DEFAULT

	greyscale_config = /datum/greyscale_config/pressure_tank
	greyscale_colors = "#ffffff"

	var/static/list/label2types = list(
		"air pressure tank" = /obj/machinery/atmospherics/components/unary/tank/air,
		"plasma pressure tank" = /obj/machinery/atmospherics/components/unary/tank/plasma,
		"oxygen pressure tank" = /obj/machinery/atmospherics/components/unary/tank/oxygen,
		"nitrogen pressure tank" = /obj/machinery/atmospherics/components/unary/tank/nitrogen,
		"carbon dioxide pressure tank" = /obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	)

	var/volume = 10000 //in liters
	var/gas_type = 0

/obj/machinery/atmospherics/components/unary/tank/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_volume(volume)
	air_contents.set_temperature(T20C)
	if(gas_type)
		air_contents.set_moles(gas_type, AIR_CONTENTS)
		name = "[name] ([GLOB.gas_data.names[gas_type]])" // Automatically names them after gas type
	set_piping_layer(piping_layer)

/obj/machinery/atmospherics/components/unary/tank/attackby(obj/item/I, mob/user, params)
	var/datum/gas_mixture/air_contents = airs[1]
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)
	if(panel_open || air_contents.total_moles() < 1000)
		if(default_unfasten_wrench(user, I, 10))
			change_pipe_connection(!anchored)
			return
	else
		to_chat(user, span_warning("[panel_open? "Open the panel first!" : "Too much gas inside, make sure it's below 1000 moles!"]"))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/tank/attackby_secondary(obj/item/I, mob/user, params)
	if(!anchored)
		if(default_change_direction_wrench(user, I))
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	else
		return SECONDARY_ATTACK_CALL_NORMAL

/obj/machinery/atmospherics/components/unary/tank/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	set_init_directions()
	update_icon(UPDATE_ICON)
	return TRUE

/obj/machinery/atmospherics/components/unary/tank/AltClick(mob/living/L)
	. = ..()
	var/list/options = list("Relabel", "Recolor")
	var/option = tgui_input_list(usr, "Choose to recolor or relabel", "Pressure Tank", options)
	if(option == "Relabel")
		var/label = tgui_input_list(usr, "New pressure tank label", "Canister", label2types)
		if(isnull(label))
			return
		if(!..())
			var/newtype =  label2types[label]
			if(newtype)
				var/obj/machinery/portable_atmospherics/canister/replacement = newtype
				investigate_log("was relabelled to [initial(replacement.name)] by [key_name(usr)].", INVESTIGATE_ATMOS)
				name = initial(replacement.name)
				desc = initial(replacement.desc)
				icon_state = initial(replacement.icon_state)
				set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))

	else
		var/initial_config = greyscale_config
		var/list/allowed_configs = list("[/datum/greyscale_config/pressure_tank]")
		if(isnull(initial_config))
			return

		var/datum/greyscale_modify_menu/menu = new(
			src, usr, allowed_configs, CALLBACK(src, PROC_REF(recolor)),
			starting_icon_state = initial(icon_state),
			starting_config = greyscale_config,
			starting_colors = greyscale_colors
		)
		menu.ui_interact(usr)

/obj/machinery/atmospherics/components/unary/tank/proc/recolor(datum/greyscale_modify_menu/menu)
	set_greyscale(menu.split_colors, menu.config.type)

/obj/machinery/atmospherics/components/unary/tank/air
	name = "pressure tank (Air)"
	greyscale_config = null
	greyscale_colors = null

/obj/machinery/atmospherics/components/unary/tank/air/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS * 0.2)
	air_contents.set_moles(GAS_N2, AIR_CONTENTS * 0.8)

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide
	name = "pressure tank (CO2)"
	gas_type = GAS_CO2
	greyscale_colors = "#2f2f38"

/obj/machinery/atmospherics/components/unary/tank/carbon_dioxide/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_CO2, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/plasma
	name = "pressure tank (Plasma)"
	gas_type = GAS_PLASMA
	greyscale_colors = "#f05f16"

/obj/machinery/atmospherics/components/unary/tank/plasma/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_PLASMA, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/oxygen
	name = "pressure tank (O2)"
	gas_type = GAS_O2
	greyscale_colors = "#148df4"

/obj/machinery/atmospherics/components/unary/tank/oxygen/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_O2, AIR_CONTENTS)

/obj/machinery/atmospherics/components/unary/tank/nitrogen
	name = "pressure tank (N2)"
	gas_type = GAS_N2
	greyscale_colors = "#2d8f44"

/obj/machinery/atmospherics/components/unary/tank/nitrogen/Initialize(mapload)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(GAS_N2, AIR_CONTENTS)
