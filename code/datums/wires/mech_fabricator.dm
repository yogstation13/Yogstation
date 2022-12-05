/datum/wires/mecha_part_fabricator
	holder_type = /obj/machinery/mecha_part_fabricator
	proper_name = "Exosuit fabricator"

/datum/wires/mecha_part_fabricator/New(atom/holder)
	wires = list(
		///Allows anyone to use the fabricator, still makes it unable to make combat mechs
		WIRE_HACK,
		///Instead of shocking, makes fabricator hands lash out and break a random limb
		WIRE_ZAP,
		///This one shocks the machine, but only temporarily.
		WIRE_SHOCK
	)
	add_duds(2)
	..()

/datum/wires/mecha_part_fabricator/interactable(mob/user)
	var/obj/machinery/mecha_part_fabricator/F = holder
	if(!issilicon(user) && F.seconds_electrified && F.shock(user, 100))
		return FALSE
	if(F.panel_open)
		return TRUE

/datum/wires/mecha_part_fabricator/get_status()
	var/obj/machinery/mecha_part_fabricator/F = holder
	var/list/status = list()
	status += "The purple light is [F.hacked ? "off" : "on"]."
	return status

/datum/wires/mecha_part_fabricator/on_pulse(wire)
	var/obj/machinery/mecha_part_fabricator/F = holder
	switch(wire)
		if(WIRE_HACK)
			holder.visible_message(span_notice("[icon2html(F, viewers(holder))] The fabricator's control panel blinks temporarily."))
			F.hacked = TRUE
			addtimer(CALLBACK(F, /obj/machinery/mecha_part_fabricator.proc/reset, wire), 5)
		if(WIRE_ZAP)
			holder.visible_message(span_danger("[icon2html(F, viewers(holder))] The fabricator's hands shake and twist aggressively, grabbing at limbs!"))
			F.wire_break(usr)
		if(WIRE_SHOCK)
			holder.visible_message(span_danger("[icon2html(F, viewers(holder))] The cable sparks faintly."))
			F.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME

/datum/wires/mecha_part_fabricator/on_cut(wire, mend)
	var/obj/machinery/mecha_part_fabricator/F = holder
	switch(wire)
		if(WIRE_HACK)
			F.hacked = !mend
