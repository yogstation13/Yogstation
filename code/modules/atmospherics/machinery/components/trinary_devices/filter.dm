/obj/machinery/atmospherics/components/trinary/filter
	icon_state = "filter_off-0"
	density = FALSE

	name = "gas filter"
	desc = "Very useful for filtering gasses."

	can_unwrench = TRUE
	var/transfer_rate = MAX_TRANSFER_RATE
	///What gases are we filtering, by typepath
	var/list/filter_type = list()
	var/frequency = 0
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/trinary/flippable
	pipe_state = "filter"

/obj/machinery/atmospherics/components/trinary/filter/CtrlClick(mob/user)
	if(can_interact(user))
		on = !on
		var/msg = "was turned [on ? "on" : "off"] by [key_name(usr)]"
		investigate_log(msg, INVESTIGATE_ATMOS)
		investigate_log(msg, INVESTIGATE_SUPERMATTER) // yogs - make supermatter invest useful
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/AltClick(mob/user)
	if(can_interact(user))
		transfer_rate = MAX_TRANSFER_RATE
		var/msg = "was set to [transfer_rate] L/s by [key_name(usr)]"
		investigate_log(msg, INVESTIGATE_ATMOS)
		investigate_log(msg, INVESTIGATE_SUPERMATTER) // yogs - make supermatter invest useful
		balloon_alert(user, "volume output set to [transfer_rate] L/s")
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/trinary/filter/Destroy()
	SSradio.remove_object(src,frequency)
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/update_icon()
	cut_overlays()
	for(var/direction in GLOB.cardinals)
		if(!(direction & initialize_directions))
			continue
		var/obj/machinery/atmospherics/node = findConnecting(direction)

		var/image/cap
		if(node)
			cap = getpipeimage(icon, "cap", direction, node.pipe_color, piping_layer = piping_layer, trinary = TRUE)
		else
			cap = getpipeimage(icon, "cap", direction, piping_layer = piping_layer, trinary = TRUE)

		add_overlay(cap)

	return ..()

/obj/machinery/atmospherics/components/trinary/filter/update_icon_nopipes()
	var/on_state = on && nodes[1] && nodes[2] && nodes[3] && is_operational()
	icon_state = "filter_[on_state ? "on" : "off"]-[set_overlay_offset(piping_layer)][flipped ? "_f" : ""]"

/obj/machinery/atmospherics/components/trinary/filter/process_atmos()
	..()
	if(!on || !(nodes[1] && nodes[2] && nodes[3]) || !is_operational())
		return

	//Early return
	var/datum/gas_mixture/air1 = airs[1]
	if(!air1 || air1.return_temperature() <= 0)
		return

	var/datum/gas_mixture/air2 = airs[2]
	var/datum/gas_mixture/air3 = airs[3]

	var/transfer_ratio = transfer_rate / air1.return_volume()

	if(transfer_ratio <= 0)
		return

	// Attempt to transfer the gas.

	// If the main output is full, we try to send filtered output to the side port (air2).
	// If the side output is full, we try to send the non-filtered gases to the main output port (air3).
	// Any gas that can't be moved due to its destination being too full is sent back to the input (air1).

	var/side_output_full = air2.return_pressure() >= MAX_OUTPUT_PRESSURE
	var/main_output_full = air3.return_pressure() >= MAX_OUTPUT_PRESSURE

	// If both output ports are full, there's nothing we can do. Don't bother removing anything from the input.
	if (side_output_full && main_output_full)
		return

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	if(!removed || !removed.total_moles())
		return

	var/filtering = TRUE
	if(!filter_type.len)
		filtering = FALSE

	// Process if we have a filter set.
	// If no filter is set, we just try to forward everything to air3 to avoid gas being outright lost.
	if(filtering)
		var/datum/gas_mixture/filtered_out = new

		for(var/gas in removed.get_gases() & filter_type)
			var/datum/gas_mixture/removing = removed.remove_specific_ratio(gas, 1)
			if(removing)
				filtered_out.merge(removing)
		// Send things to the side output if we can, return them to the input if we can't.
		// This means that other gases continue to flow to the main output if the side output is blocked.
		if (side_output_full)
			air1.merge(filtered_out)
		else
			air2.merge(filtered_out)

	// Send things to the main output if we can, return them to the input if we can't.
	// This lets filtered gases continue to flow to the side output in a manner consistent with the main output behavior.
	if (main_output_full)
		air1.merge(removed)
	else
		air3.merge(removed)

	update_parents()

/obj/machinery/atmospherics/components/trinary/filter/atmosinit()
	set_frequency(frequency)
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosFilter", name)
		ui.open()

/obj/machinery/atmospherics/components/trinary/filter/ui_data()
	var/data = list()
	data["on"] = on
	data["rate"] = round(transfer_rate)
	data["max_rate"] = round(MAX_TRANSFER_RATE)

	data["filter_types"] = list()
	for(var/path in GLOB.meta_gas_info)
		var/list/gas = GLOB.meta_gas_info[path]
		data["filter_types"] += list(list("name" = gas[META_GAS_NAME], "gas_id" = gas[META_GAS_ID], "enabled" = (path in filter_type)))

	return data

/obj/machinery/atmospherics/components/trinary/filter/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			var/msg = "was turned [on ? "on" : "off"] by [key_name(usr)]"
			investigate_log(msg, INVESTIGATE_ATMOS)
			investigate_log(msg, INVESTIGATE_SUPERMATTER) // yogs - make supermatter invest useful
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "max")
				rate = MAX_TRANSFER_RATE
				. = TRUE
			else if(rate == "input")
				rate = input("New transfer rate (0-[MAX_TRANSFER_RATE] L/s):", name, transfer_rate) as num|null
				if(!isnull(rate) && !..())
					. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				transfer_rate = clamp(rate, 0, MAX_TRANSFER_RATE)
				var/msg = "was set to [transfer_rate] L/s by [key_name(usr)]"
				investigate_log(msg, INVESTIGATE_ATMOS)
				investigate_log(msg, INVESTIGATE_SUPERMATTER) // yogs - make supermatter invest useful
		if("toggle_filter")
			if(!gas_id2path(params["val"]))
				return TRUE
			filter_type ^= gas_id2path(params["val"])
			var/change
			if(gas_id2path(params["val"]) in filter_type)
				change = "added"
			else
				change = "removed"
			var/gas_name = GLOB.meta_gas_info[gas_id2path(params["val"])][META_GAS_NAME]
			var/msg = "[key_name(usr)] [change] [gas_name] from the filter type."
			investigate_log(msg, INVESTIGATE_ATMOS)
			investigate_log(msg, INVESTIGATE_SUPERMATTER) // yogs - make supermatter invest useful
			. = TRUE
	update_icon()

/obj/machinery/atmospherics/components/trinary/filter/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first!"))
		return FALSE

// mapping

/obj/machinery/atmospherics/components/trinary/filter/layer2
	piping_layer = 2
	icon_state = "filter_off_map-2"
/obj/machinery/atmospherics/components/trinary/filter/layer4
	piping_layer = 4
	icon_state = "filter_off_map-4"

/obj/machinery/atmospherics/components/trinary/filter/on
	on = TRUE
	icon_state = "filter_on-0"

/obj/machinery/atmospherics/components/trinary/filter/on/layer2
	piping_layer = 2
	icon_state = "filter_on_map-2"
/obj/machinery/atmospherics/components/trinary/filter/on/layer4
	piping_layer = 4
	icon_state = "filter_on_map-4"

/obj/machinery/atmospherics/components/trinary/filter/flipped
	icon_state = "filter_off-0_f"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/filter/flipped/layer2
	piping_layer = 2
	icon_state = "filter_off_f_map-2"
/obj/machinery/atmospherics/components/trinary/filter/flipped/layer4
	piping_layer = 4
	icon_state = "filter_off_f_map-4"

/obj/machinery/atmospherics/components/trinary/filter/flipped/on
	on = TRUE
	icon_state = "filter_on-0_f"

/obj/machinery/atmospherics/components/trinary/filter/flipped/on/layer2
	piping_layer = 2
	icon_state = "filter_on_f_map-2"
/obj/machinery/atmospherics/components/trinary/filter/flipped/on/layer4
	piping_layer = 4
	icon_state = "filter_on_f_map-4"

/obj/machinery/atmospherics/components/trinary/filter/atmos //Used for atmos waste loops
	on = TRUE
	icon_state = "filter_on-0"
/obj/machinery/atmospherics/components/trinary/filter/atmos/n2
	name = "Nitrogen filter (N2)"
	filter_type = list(/datum/gas/nitrogen)
/obj/machinery/atmospherics/components/trinary/filter/atmos/o2
	name = "Oxygen filter (O2)"
	filter_type = list(/datum/gas/oxygen)
/obj/machinery/atmospherics/components/trinary/filter/atmos/co2
	name = "Carbon dioxide filter (CO2)"
	filter_type = list(/datum/gas/carbon_dioxide)
/obj/machinery/atmospherics/components/trinary/filter/atmos/n2o
	name = "Nitrous oxide filter (N2O)"
	filter_type = list(/datum/gas/nitrous_oxide)
/obj/machinery/atmospherics/components/trinary/filter/atmos/plasma
	name = "Plasma filter"
	filter_type = list(/datum/gas/plasma)

/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped //This feels wrong, I know
	icon_state = "filter_on-0_f"
	flipped = TRUE
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/n2
	name = "Nitrogen filter (N2)"
	filter_type = list(/datum/gas/nitrogen)
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/o2
	name = "Oxygen filter (O2)"
	filter_type = list(/datum/gas/oxygen)
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/co2
	name = "Carbon dioxide filter (CO2)"
	filter_type = list(/datum/gas/carbon_dioxide)
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/n2o
	name = "Nitrous oxide filter (N2O)"
	filter_type = list(/datum/gas/nitrous_oxide)
/obj/machinery/atmospherics/components/trinary/filter/atmos/flipped/plasma
	name = "Plasma filter"
	filter_type = list(/datum/gas/plasma)

// These two filter types have critical_machine flagged to on and thus causes the area they are in to be exempt from the Grid Check event.

/obj/machinery/atmospherics/components/trinary/filter/critical
	critical_machine = TRUE

/obj/machinery/atmospherics/components/trinary/filter/flipped/critical
	critical_machine = TRUE
