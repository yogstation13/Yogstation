/datum/wires/combine_fabricator
	holder_type = /obj/machinery/combine_fabricator
	proper_name = "Combine Fabricator"

/datum/wires/combine_fabricator/New(atom/holder)
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

/datum/wires/combine_fabricator/interactable(mob/user)
	var/obj/machinery/combine_fabricator/F = holder
	if(!issilicon(user) && F.seconds_electrified && F.shock(user, 100))
		return FALSE
	if(F.panel_open)
		return TRUE

/datum/wires/combine_fabricator/get_status()
	var/obj/machinery/combine_fabricator/F = holder
	var/list/status = list()
	status += "The purple light is [F.hacked ? "off" : "on"]."
	return status

/datum/wires/combine_fabricator/on_pulse(wire)
	var/obj/machinery/combine_fabricator/F = holder
	switch(wire)
		if(WIRE_HACK)
			holder.visible_message(span_notice("[icon2html(F, viewers(holder))] The fabricator's control panel blinks temporarily."))
			F.hacked = TRUE
			addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/machinery/combine_fabricator, reset), wire), 5)
		if(WIRE_ZAP)
			holder.visible_message(span_danger("[icon2html(F, viewers(holder))] The fabricator's hands shake and twist aggressively, grabbing at limbs!"))
			F.wire_break(usr)
		if(WIRE_SHOCK)
			holder.visible_message(span_danger("[icon2html(F, viewers(holder))] The cable sparks faintly."))
			F.seconds_electrified = MACHINE_DEFAULT_ELECTRIFY_TIME

/datum/wires/combine_fabricator/on_cut(wire, mend)
	var/obj/machinery/combine_fabricator/F = holder
	switch(wire)
		if(WIRE_HACK)
			F.hacked = !mend
