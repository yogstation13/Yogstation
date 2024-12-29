/obj/item/book/granter/martial/the_tunnel_arts
	martial = /datum/martial_art/the_tunnel_arts
	name = "odd scroll"
	martial_name = "tunnel arts"
	desc = "A scroll made up of torn books, scrawled with gray crayon."
	greet = span_sciradio("You can visualize how you and your kind will one day rule the spinward sector with a gray fist. You've learned The Tunnel Arts. You can review what you've learned at any time within The Tunnel Arts tab.")
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "scroll-ancient"
	remarks = list("I must prove myself worthy to the masters of the maintainence...",
		"What do you mean you can clone yourself...?",
		"I feel someone with the fireaxe running away from the captain...",
		"I don't think this would combine with other martial arts...",
		"Graytide sectorwide..."
	)

/obj/item/book/granter/martial/the_tunnel_arts/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/the_tunnel_arts/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "odd scroll"
		desc = "Whatever was written here, you can't recognize it anymore."
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)

/obj/item/book/granter/martial/the_tunnel_arts/can_learn(mob/user)
	//someone ought to find logic to make it assistant only, but I don't wanna
	return TRUE

