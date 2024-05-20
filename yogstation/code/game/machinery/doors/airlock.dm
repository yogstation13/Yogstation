/obj/machinery/door/airlock
	var/obj/structure/deployed_brace/brace

/obj/machinery/door/airlock/proc/apply_brace(obj/item/brace/B, mob/user)
	if(brace)
		to_chat(user, span_warning("[src] is already braced!"))
		return
	if(!density)
		to_chat(user, span_warning("Close [src] first!"))
		return
	to_chat(user, span_notice("You start installing [B] on [src]..."))
	playsound(src, 'sound/items/jaws_pry.ogg', 100)
	if(!do_after(user, 5 SECONDS, src))
		return
	var/brace_dir = dir_to_cardinal(get_dir(src, user))
	var/turf/T = get_step(src, brace_dir)
	brace = new(T)
	B.forceMove(brace)
	brace.brace_item = B
	brace.placed_on = src
	switch(brace_dir)
		if(NORTH)
			brace.pixel_y = -32
		if(SOUTH)
			brace.pixel_y = 32
		if(EAST)
			brace.pixel_x = -32
		if(WEST)
			brace.pixel_x = 32
	to_chat(user, span_notice("You install [B] on [src]."))
	playsound(src, 'sound/items/jaws_pry.ogg', 100)

/obj/machinery/door/airlock/proc/dir_to_cardinal(dir)
	var/turf/north_turf = get_step(src, NORTH)
	if((dir & NORTH) && (!north_turf.is_blocked_turf(TRUE)))
		return NORTH
	var/turf/south_turf = get_step(src, SOUTH)
	if((dir & SOUTH) && (!south_turf.is_blocked_turf(TRUE)))
		return SOUTH
	if(dir & EAST)
		return EAST
	if(dir & WEST)
		return WEST

/obj/machinery/door/airlock/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	if(brace)
		brace.remove()
	return ..()
