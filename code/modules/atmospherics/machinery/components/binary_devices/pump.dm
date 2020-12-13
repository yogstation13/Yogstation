// Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.
//
// node1, air1, network1 correspond to input
// node2, air2, network2 correspond to output
//
// Thus, the two variables affect pump operation are set in New():
//   air1.volume
//     This is the volume of gas available to the pump that may be transfered to the output
//   air2.volume
//     Higher quantities of this cause more air to be perfected later
//     but overall network volume is also increased as this increases...

/obj/machinery/atmospherics/components/binary/pump
	icon_state = "pump_map-3"
	name = "gas pump"
	desc = "A pump that moves gas by pressure."

	can_unwrench = TRUE
	shift_underlay_only = FALSE

	var/target_pressure = ONE_ATMOSPHERE

	var/frequency = 0
	var/id = null
	var/datum/radio_frequency/radio_connection

	construction_type = /obj/item/pipe/directional
	pipe_state = "pump"

/obj/machinery/atmospherics/components/binary/pump/CtrlClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || issilicon(user))
		on = !on
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/pump/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK) || issilicon(user))
		target_pressure = MAX_OUTPUT_PRESSURE
		update_icon()
	return ..()

/obj/machinery/atmospherics/components/binary/pump/Destroy()
	SSradio.remove_object(src,frequency)
	if(radio_connection)
		radio_connection = null
	return ..()

/obj/machinery/atmospherics/components/binary/pump/update_icon_nopipes()
	icon_state = (on && is_operational()) ? "pump_on-[set_overlay_offset(piping_layer)]" : "pump_off-[set_overlay_offset(piping_layer)]"

/obj/machinery/atmospherics/components/binary/pump/process_atmos()
//	..()
	if(!on || !is_operational())
		return

	var/datum/gas_mixture/air1 = airs[1]
	var/datum/gas_mixture/air2 = airs[2]

	var/output_starting_pressure = air2.return_pressure()

	if((target_pressure - output_starting_pressure) < 0.01)
		//No need to pump gas if target is already reached!
		return

	//Calculate necessary moles to transfer using PV=nRT
	if((air1.total_moles() > 0) && (air1.return_temperature()>0))
		var/pressure_delta = target_pressure - output_starting_pressure
		var/transfer_moles = pressure_delta*air2.return_volume()/(air1.return_temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		update_parents()

//Radio remote control
/obj/machinery/atmospherics/components/binary/pump/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	if(frequency)
		radio_connection = SSradio.add_object(src, frequency, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/pump/proc/broadcast_status()
	if(!radio_connection)
		return

	var/datum/signal/signal = new(list(
		"tag" = id,
		"device" = "AGP",
		"power" = on,
		"target_output" = target_pressure,
		"sigtype" = "status"
	))
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

/obj/machinery/atmospherics/components/binary/pump/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/components/binary/pump/ui_data()
	var/data = list()
	data["on"] = on
	data["pressure"] = round(target_pressure)
	data["max_pressure"] = round(MAX_OUTPUT_PRESSURE)
	return data

/obj/machinery/atmospherics/components/binary/pump/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("power")
			on = !on
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_SUPERMATTER) // yogs - makes supermatter invest useful
			. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "max")
				pressure = MAX_OUTPUT_PRESSURE
				. = TRUE
			else if(pressure == "input")
				pressure = input("New output pressure (0-[MAX_OUTPUT_PRESSURE] kPa):", name, target_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				target_pressure = clamp(pressure, 0, MAX_OUTPUT_PRESSURE)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_ATMOS)
				investigate_log("was set to [target_pressure] kPa by [key_name(usr)]", INVESTIGATE_SUPERMATTER) // yogs - makes supermatter invest useful
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/atmosinit()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id) || (signal.data["sigtype"]!="command"))
		return

	var/old_on = on //for logging

	if("power" in signal.data)
		on = text2num(signal.data["power"])

	if("power_toggle" in signal.data)
		on = !on

	if("set_output_pressure" in signal.data)
		target_pressure = clamp(text2num(signal.data["set_output_pressure"]),0,ONE_ATMOSPHERE*50)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_SUPERMATTER) // yogs - make supermatter invest useful

	if("status" in signal.data)
		broadcast_status()
		return

	broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/binary/pump/can_unwrench(mob/user)
	. = ..()
	if(. && on && is_operational())
		to_chat(user, "<span class='warning'>You cannot unwrench [src], turn it off first!</span>")
		return FALSE


/obj/machinery/atmospherics/components/binary/pump/layer2
	piping_layer = 2
	icon_state= "pump_map-2"

/obj/machinery/atmospherics/components/binary/pump/layer4
	piping_layer = 4
	icon_state= "pump_map-4"

/obj/machinery/atmospherics/components/binary/pump/on
	on = TRUE
	icon_state = "pump_on_map-3"

/obj/machinery/atmospherics/components/binary/pump/on/layer2
	piping_layer = 2
	icon_state= "pump_on_map-2"

/obj/machinery/atmospherics/components/binary/pump/on/layer4
	piping_layer = 4
	icon_state= "pump_on_map-4"
