/datum/wires/ai_data_core
	holder_type = /obj/machinery/ai/data_core
	proper_name = "AI Data Core"

/datum/wires/ai_data_core/New(atom/holder)
	wires = list(
		WIRE_AI, WIRE_ZAP
		//WIRE_HACK
	)
	add_duds(6)
	..()

/datum/wires/ai_data_core/interactable(mob/user)
	var/obj/machinery/ai/data_core/C = holder
	if(C.panel_open)
		return TRUE

/datum/wires/ai_data_core/get_status()
	var/obj/machinery/ai/data_core/C = holder
	var/list/status = list()
	status += "The blue light is [C.ai_connection ? "blinking" : "off"]."
	return status

/datum/wires/ai_data_core/on_pulse(wire)
	var/obj/machinery/ai/data_core/C = holder
	switch(wire)
		if(WIRE_AI)
			C.ai_connection = FALSE
			addtimer(CALLBACK(A, /obj/machinery/ai/data_core.proc/reset_wire, wire), 60)

/datum/wires/ai_data_core/on_cut(wire, mend)
	var/obj/machinery/ai/data_core/C = holder
	switch(wire)
		if(WIRE_ZAP)
			C.shock(usr, 50)
		if(WIRE_AI)
			C.ai_connection = !mend
