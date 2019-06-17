/obj/machinery/door/airlock
	var/obj/structure/deployed_brace/brace

/obj/machinery/door/airlock/proc/apply_brace(obj/item/brace/B, mob/user)
	if(brace)
		to_chat(user, "<span class='warning'>[src] is already braced!</span>")
		return
	if(!density)
		to_chat(user, "<span class='warning'>Close [src] first!</span>")
		return
	to_chat(user, "<span class='notice'>You start installing [B] on [src]...</span>")
	playsound(src, 'sound/items/jaws_pry.ogg', 100)
	if(!do_after(user, 5 SECONDS, target = src))
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
	to_chat(user, "<span class='notice'>You install [B] on [src].</span>")
	playsound(src, 'sound/items/jaws_pry.ogg', 100)

/obj/machinery/door/airlock/proc/dir_to_cardinal(dir)
	if((dir & NORTH) && (!is_blocked_turf(get_step(src, NORTH), TRUE)))
		return NORTH
	if((dir & SOUTH) && (!is_blocked_turf(get_step(src, SOUTH), TRUE)))
		return SOUTH
	if(dir & EAST)
		return EAST
	if(dir & WEST)
		return WEST

/obj/machinery/door/airlock/Moved()
	if(brace)
		brace.remove()
	return ..()