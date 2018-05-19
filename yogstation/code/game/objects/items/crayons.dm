/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(is_capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return

	if(check_empty(user))
		return

	if(istype(target, /obj/machinery/light))
		if(actually_paints)
			target.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
			target.light_color = paint_color
			target.update_light()
		. = use_charges(user, 2)
	..()