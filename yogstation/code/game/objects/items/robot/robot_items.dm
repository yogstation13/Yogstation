#define DISPENSE_LOLLIPOP_MODE 1
#define THROW_LOLLIPOP_MODE 2
#define THROW_GUMBALL_MODE 3
#define DISPENSE_ICECREAM_MODE 4
/obj/item/borg/lollipop/attack_self(mob/living/user)
	var/list/choices = list(
		"Throw Lollipop" = image(icon = 'yogstation/icons/obj/interface.dmi', icon_state = "throwloli"),
		"Throw Gumball" = image(icon = 'yogstation/icons/obj/interface.dmi', icon_state = "throwgum"),
		"Dispense Icecream" = image(icon = 'yogstation/icons/obj/interface.dmi', icon_state = "dispice")
	)
	var/choice = show_radial_menu(user,src,choices)
	switch(choice)
		if("Throw Lollipop")
			if(mode == THROW_LOLLIPOP_MODE)
				mode = DISPENSE_LOLLIPOP_MODE
				to_chat(user, "<span class='notice'>Module is now dispensing lollipops.</span>")
			else
				mode = THROW_LOLLIPOP_MODE
				to_chat(user, "<span class='notice'>Module is now throwing lollipops.</span>")
		if("Throw Gumball")
			mode = THROW_GUMBALL_MODE
			to_chat(user, "<span class='notice'>Module is now blasting gumballs.</span>")
		if("Dispense Icecream")
			mode = DISPENSE_ICECREAM_MODE
			to_chat(user, "<span class='notice'>Module is now dispensing ice cream.</span>")

#undef DISPENSE_LOLLIPOP_MODE
#undef THROW_LOLLIPOP_MODE
#undef THROW_GUMBALL_MODE
#undef DISPENSE_ICECREAM_MODE
