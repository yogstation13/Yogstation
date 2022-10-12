/datum/wires/mecha_part_fabricator
	holder_type = /obj/machinery/mecha_part_fabricator
	proper_name = "Exosuit fabricator"

/datum/wires/mecha_part_fabricator/New(atom/holder)
	wires = list(
		///Allows anyone to use the fabricator, still makes it unable to make combat mechs
		WIRE_HACK,
		///Instead of shocking, makes fabricator hands lash out and break a random limb
		WIRE_ZAP
	)
	add_duds(6)
	..()

/datum/wires/mecha_part_fabricator/interactable(mob/user)
	var/obj/machinery/mecha_part_fabricator/F = holder
	if(F.panel_open)
		return TRUE

/datum/wires/mecha_part_fabricator/get_status()
	var/obj/machinery/mecha_part_fabricator/F = holder
	var/list/status = list()
	status += "The purple light is [F.hacked ? "on" : "off"]."
	return status

/datum/wires/mecha_part_fabricator/on_pulse(wire)
	var/obj/machinery/mecha_part_fabricator/F = holder
		switch(wire)
			if(WIRE_HACK)
				holder.visible_message(span_notice("[icon2html(F, viewers(holder))] The fabricator's control panel blinks temporarily."))
			if(WIRE_ZAP)
				holder.visible_message(span_notice("[icon2html(F, viewers(holder))] The fabricator's hands grapple aggresively into the air!"))
				F.wire_zap(usr)

/datum/wires/mecha_part_fabricator/on_cut(wire, mend)
	var/obj/machinery/mecha_part_fabricator/F = holder
	switch(wire)
		if(WIRE_HACK)
			F.hacked = !mend