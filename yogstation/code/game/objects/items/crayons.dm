/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(is_capped)
		to_chat(user, "<span class='warning'>Take the cap off first!</span>")
		return

	if(check_empty(user))
		return

	if(istype(target, /obj/machinery/light))
		var/obj/machinery/light/light = target
		if(actually_paints)
			light.add_atom_colour(paint_color, WASHABLE_COLOUR_PRIORITY)
			light.bulb_colour = paint_color
			light.update()
		. = use_charges(user, 2)
	..()
