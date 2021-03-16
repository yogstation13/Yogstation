/datum/wires/igniter
	holder_type = /obj/machinery/igniter
	proper_name = "Igniter"

/datum/wires/igniter/New(atom/holder)
	wires = list(
		WIRE_POWER,
		WIRE_SAFETY,
	)
	..()

/datum/wires/igniter/interactable(mob/user)
	var/obj/machinery/igniter/A = holder
	if(A.panel_open)
		return TRUE

/datum/wires/igniter/get_status()
	var/obj/machinery/igniter/A = holder
	var/list/status = list()
	status += "The saftey light is [A.safety ? "lit" : "off"]."
	status += "The power light is [A.on ? "lit" : "off"]."
	return status

/datum/wires/igniter/on_pulse(wire)
	var/obj/machinery/igniter/A = holder
	switch(wire)
		if(WIRE_SAFETY) // Stop it from being turned on
			A.safety = !A.safety
			if(A.safety)
				A.on = FALSE
			A.update_icon()
		if(WIRE_POWER) // Toggle power
			A.on = !A.on
			A.update_icon()

/datum/wires/igniter/on_cut(wire, mend)
	var/obj/machinery/igniter/A = holder
	switch(wire)
		if(WIRE_POWER) // Toggle power
			A.on = FALSE
			A.update_icon()
		if(WIRE_SAFETY) // Stop it from being turned on
			A.on = FALSE
			A.safety = FALSE
			A.update_icon()
