
/obj/structure/disposalpipe/sorting
	var/last_sort = FALSE
	var/sort_scan = TRUE
	var/panel_open = FALSE

/obj/structure/disposalpipe/sorting/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/disposals(src)

/obj/structure/disposalpipe/sorting/nextdir(obj/structure/disposalholder/H)
	var/sortdir = dpdir & ~(dir | turn(dir, 180))
	if(sort_scan)
		if(check_sorting(H))
			if(!wires.is_cut(WIRE_SORT_SIDE))
				last_sort = TRUE
		else
			if(!wires.is_cut(WIRE_SORT_FORWARD))
				last_sort = FALSE
	if(H.dir != sortdir && last_sort)
		return sortdir

	// go with the flow to positive direction
	return dir

/obj/structure/disposalpipe/sorting/proc/reset_scan()
	if(!wires.is_cut(WIRE_SORT_SCAN))
		sort_scan = TRUE

/obj/structure/disposalpipe/sorting/update_overlays()
	. = ..()
	if(panel_open)
		. += image('yogstation/icons/obj/atmospherics/pipes/disposal.dmi', "[icon_state]-open")

/obj/structure/disposalpipe/sorting/screwdriver_act(mob/living/user, obj/item/I)
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, span_notice("You [panel_open ? "open" : "close"] the wire panel."))
	update_appearance(UPDATE_ICON)
	return TRUE

/obj/structure/disposalpipe/sorting/attackby(obj/item/I, mob/user)
	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return TRUE
	return ..()
