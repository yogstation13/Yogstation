/datum/wires/disposals
	holder_type = /obj/structure/disposalpipe/sorting
	proper_name = "Disposals Sorting Pipe"

/datum/wires/disposals/interactable(mob/user)
	var/obj/structure/disposalpipe/sorting/A = holder
	if(A.panel_open)
		return TRUE

/datum/wires/disposals/get_status()
	var/obj/structure/disposalpipe/sorting/A = holder
	var/list/status = list()
	status += "The sorting light is [A.last_sort ? "green" : "red"]."
	status += "The scan light is [A.sort_scan ? "lit" : "off"]."
	return status

/datum/wires/disposals/New(atom/holder)
	wires = list(
		WIRE_SORT_FORWARD,
		WIRE_SORT_SIDE,
		WIRE_SORT_SCAN
	)
	add_duds(3)
	..()

/datum/wires/disposals/on_pulse(wire)
	var/obj/structure/disposalpipe/sorting/A = holder
	switch(wire)
		if(WIRE_SORT_SCAN) // freeze sorting for 10 seconds
			if(A.sort_scan)
				A.sort_scan = FALSE
			addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/structure/disposalpipe/sorting, reset_scan)), 100)
		if(WIRE_SORT_FORWARD) // make things go forward if frozen
			A.last_sort = FALSE
		if(WIRE_SORT_SIDE) // make things go sideways if frozen
			A.last_sort = TRUE

/datum/wires/disposals/on_cut(wire, mend)
	var/obj/structure/disposalpipe/sorting/A = holder
	switch(wire)
		if(WIRE_SORT_SCAN) // freeze/unfreeze sorting forever
			A.sort_scan = mend
