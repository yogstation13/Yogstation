#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_ORIENTED "Random Oriented"
#define RANDOM_RUNE "Random Rune"
#define RANDOM_ANY "Random Anything"

/obj/item/toy/crayon/spraycan/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(is_capped)
		to_chat(user, span_warning("Take the cap off first!"))
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
