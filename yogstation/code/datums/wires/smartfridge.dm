/datum/wires/smartfridge
	holder_type = /obj/machinery/smartfridge
	proper_name = "Smartfridge"

/datum/wires/smartfridge/New(atom/holder)
	wires = list(
		WIRE_POWER, WIRE_SHOCK, WIRE_SPEAKER, WIRE_DISABLE
	)
	add_duds(2)
	..()

/datum/wires/smartfridge/interactable(mob/user)
	var/obj/machinery/smartfridge/V = holder
	if(!issilicon(user) && V.seconds_electrified && V.shock(user, 100))
		return FALSE
	if(V.panel_open)
		return TRUE

/datum/wires/smartfridge/get_status()
	var/obj/machinery/smartfridge/V = holder
	var/list/status = list()
	status += "The power light is [!(V.stat & (BROKEN|NOPOWER)) ? "on" : "off"]."
	status += "The orange light is [(V.seconds_electrified && !(V.stat & (BROKEN|NOPOWER))) ? "on" : "off"]."
	status += "The check wiring light is [V.dispenser_arm ? "off" : "on"]."
	status += "The speaker light is [V.pitches ? "on" : "off"]."
	return status

/datum/wires/smartfridge/on_pulse(wire)
	var/obj/machinery/smartfridge/V = holder
	switch(wire)
		if(WIRE_POWER)
			//V.stat |= NOPOWER
			//We could disable power here temporarily similar to APC short wires, but for now, it does nothing on pulse.
		if(WIRE_DISABLE)
			V.dispenser_arm = !V.dispenser_arm
		if(WIRE_SHOCK)
			V.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME
		if(WIRE_SPEAKER)
			V.pitches = !V.pitches

/datum/wires/smartfridge/on_cut(wire, mend)
	var/obj/machinery/smartfridge/V = holder
	switch(wire)
		if(WIRE_POWER)
			V.power_wire_cut = !mend
			//Set stat for power status.
			if(mend && V.powered() && V.anchored)
				V.stat &= ~NOPOWER
			else
				V.stat |= NOPOWER
			//Register status change.
			V.power_change()
		if(WIRE_DISABLE)
			if(!mend)
				V.dispenser_arm = FALSE
		if(WIRE_SHOCK)
			if(mend)
				V.seconds_electrified = MACHINE_NOT_ELECTRIFIED
			else
				V.seconds_electrified = MACHINE_ELECTRIFIED_PERMANENT
		if(WIRE_SPEAKER)
			V.pitches = mend