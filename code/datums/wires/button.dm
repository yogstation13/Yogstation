/datum/wires/button
	holder_type = /obj/machinery/button
	proper_name = "Button"
	randomize = TRUE

/datum/wires/button/New(atom/holder)
	wires = list(
		WIRE_ACTIVATE,
		WIRE_IDSCAN,
		WIRE_MAINTENANCE,
		WIRE_POWER1
	)
	..()

/datum/wires/button/interactable(mob/user)
	var/obj/machinery/button/M = holder
	if(M.panel_open && !M.hatch)
		return TRUE

/datum/wires/button/on_pulse(wire, mob/user)
	var/obj/machinery/button/button_holder = holder
	switch(wire)
		if(WIRE_ACTIVATE)
			holder.visible_message(span_notice("[icon2html(button_holder, viewers(holder))] The button clanks."))
			button_holder.attack_hand(hacked = TRUE)
		if(WIRE_IDSCAN)
			holder.visible_message(span_notice("[icon2html(button_holder, viewers(holder))] The access light flickers."))
		if(WIRE_MAINTENANCE)
			holder.visible_message(span_notice("[icon2html(button_holder, viewers(holder))] The maintenance hatch wobbles."))
		else
			holder.visible_message(span_notice("[icon2html(button_holder, viewers(holder))] The lights shut off briefly."))
