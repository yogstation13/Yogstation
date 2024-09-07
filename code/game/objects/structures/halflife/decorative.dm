// TRASH.... //
/obj/structure/halflife/trash
	name = "Base type halflife TRASH"
	desc = "Who the hell littered this here? Call a mapper!"
	icon = 'icons/obj/halflife/miscellaneous.dmi'

/obj/structure/halflife/trash/papers
	name = "scattered pages"
	desc = "Some scattered paper pages. They look mostly ruined."
	icon_state = "scattered_papers"

/obj/structure/halflife/trash/papers/one
	name = "scattered papers"
	desc = "Some scattered papers. All sorts of stuff, from pages to envelopes."
	icon_state = "papers_1"

/obj/structure/halflife/trash/papers/two
	name = "scattered papers"
	desc = "Some scattered papers. All sorts of stuff, from pages to envelopes."
	icon_state = "papers_2"

/obj/structure/halflife/trash/papers/three
	name = "scattered papers"
	desc = "Some scattered papers. All sorts of stuff, from pages to envelopes."
	icon_state = "papers_3"

/obj/structure/halflife/trash/books
	name = "ruined stack of books"
	desc = "A small stack of ruined books. A librarian's worst nightmare."
	icon_state = "bookstack_1"

/obj/structure/halflife/trash/books/Initialize(mapload)
	. = ..()
	icon_state = pick("bookstack_1","bookstack_2","bookstack_3")

/obj/structure/halflife/trash/books/pile
	name = "pile of books"
	desc = "A large, messy pile of ruined books. Would make any intellectual cry."
	icon_state = "bookpile_1"

/obj/structure/halflife/trash/books/pile/Initialize(mapload)
	. = ..()
	icon_state = pick("bookpile_1","bookpile_2","bookpile_3")

/obj/structure/halflife/trash/books/pile_alt
	name = "pile of books"
	desc = "A large, messy pile of ruined books. Would make any intellectual cry."
	icon_state = "bookpile_5"

/obj/structure/halflife/trash/books/pile_alt/Initialize(mapload)
	. = ..()
	icon_state = pick("bookpile_4","bookpile_5","bookpile_6")

/obj/structure/halflife/trash/cardboard
	name = "scattered cardboard"
	desc = "Old cardboard boxes... Thrown all over the place. What a mess."
	icon_state = "cardboard"

/obj/structure/halflife/trash/bricks
	name = "brick rubble"
	desc = "A bunch of old bricks."
	icon_state = "brickrubble"

/obj/structure/halflife/trash/wood
	name = "scrap wood"
	desc = "A bunch of scrap wood. You could probably get a few loose pieces."
	icon_state = "woodscrap"

/obj/structure/halflife/trash/wood/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to sift through the [src] for usable pieces."), \
		span_notice("You begin to dig through the [src] for some wood."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(90)) // It's... scrap wood already.
			user.visible_message(span_notice("[user] gathers up the [src]."), \
				span_notice("You gather up all the [src]."))
			new /obj/item/stack/sheet/mineral/wood(loc, rand(1,2))
			qdel(src)
		else
			user.visible_message(span_notice("[user] somehow messes up gathering the [src]. It melts before their very eyes into nothingness."), \
				span_notice("You somehow manage to mess up gathering the perfectly fine scrap wood. It melts away before your very eyes..."))
			qdel(src)

/obj/structure/halflife/trash/food
	name = "DO NOT USE ME - base type food trash"
	desc = "I am a base type and if you see me in the map someone made a mistake."
	icon_state = "foodstuff_1"

/obj/structure/halflife/trash/food/dinner
	name = "decrepit dinnerware"
	desc = "A small, moldy, and disgusting collection of old silverware, plates, and similar dining utensils. Perhaps the truly desperate could still find some use out of this."
	icon_state = "foodstuff_1"

/obj/structure/halflife/trash/food/dinner/Initialize(mapload)
	. = ..()
	icon_state = pick("foodstuff_1","foodstuff_5")

/obj/structure/halflife/trash/food/dinner/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to search through the [src] for usable materials."), \
		span_notice("You begin to search through [src] for some materials."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(35))
			user.visible_message(span_notice("[user] gathers up materials from the [src]."), \
				span_notice("You gather up some materials from [src]."))
			new /obj/item/stack/sheet/metal(loc, 1)
			qdel(src)
		else
			user.visible_message(span_notice("[user] fails to gather anything useful from the [src]."), \
				span_notice("You don't manage to find anything useful from [src]."))
			if(prob(65)) // SO YOU'RE TELLING ME THERE'S A CHANCE...
				qdel(src)

/obj/structure/halflife/trash/food/glass
	name = "empty bottle and can"
	desc = "An empty glass bottle and an aluminum can picked clean, with some utensils nearby."
	icon_state = "foodstuff_4"

/obj/structure/halflife/trash/food/glass/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to search through [src] for usable materials."), \
		span_notice("You begin to search through [src] for some materials."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(40))
			user.visible_message(span_notice("[user] gathers up materials from the [src]."), \
				span_notice("You gather up some materials from [src]."))
			new /obj/item/stack/sheet/glass(loc, 1)
			qdel(src)
		else
			user.visible_message(span_notice("[user] fails to gather anything useful from the [src]."), \
				span_notice("You don't manage to find anything useful from [src]."))
			if(prob(75)) // SO YOU'RE TELLING ME THERE'S A CHANCE...
				qdel(src)

/obj/structure/halflife/trash/food/misc
	name = "old eating utensils"
	desc = "Moldy silverware, empty cans, and similar utensils. The remnants of a feast no doubt."
	icon_state = "foodstuff_6"

/obj/structure/halflife/trash/food/misc/Initialize(mapload)
	. = ..()
	icon_state = pick("foodstuff_2","foodstuff_3", "foodstuff_6")

/obj/structure/halflife/trash/food/misc/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to search through [src] for usable materials."), \
		span_notice("You begin to search through [src] for some materials."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(35))
			user.visible_message(span_notice("[user] gathers up materials from [src]."), \
				span_notice("You gather up some materials from [src]."))
			new /obj/item/stack/sheet/metal(loc, 1)
			qdel(src)
		else
			user.visible_message(span_notice("[user] fails to gather anything useful from the [src]."), \
				span_notice("You don't manage to find anything useful from [src]."))
			if(prob(65)) // SO YOU'RE TELLING ME THERE'S A CHANCE...
				qdel(src)

/obj/structure/halflife/trash/glass
	name = "DO NOT USE ME - base type glass trash"
	desc = "I am a base type and if you see me in the map someone made a mistake."
	icon_state = "glass_1"

/obj/structure/halflife/trash/glass/cans
	name = "empty bottles and cans"
	desc = "Some empty glass bottles and aluminum cans. You just might be able to make something out of this."
	icon_state = "glass_1"

/obj/structure/halflife/trash/glass/cans/Initialize(mapload)
	. = ..()
	icon_state = pick("glass_1","glass_2")

/obj/structure/halflife/trash/glass/cans/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to search through the [src] for usable materials."), \
		span_notice("You begin to search through [src] for some materials."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(35))
			user.visible_message(span_notice("[user] gathers up materials from the [src]."), \
				span_notice("You gather up some materials from [src]."))
			new /obj/item/stack/sheet/glass(loc, 1)
			qdel(src)
		else
			user.visible_message(span_notice("[user] fails to gather anything useful from [src]."), \
				span_notice("You don't manage to find anything useful from [src]."))
			if(prob(75)) // SO YOU'RE TELLING ME THERE'S A CHANCE...
				qdel(src)

/obj/structure/halflife/trash/glass/plate
	name = "glass bottles and dinnerware"
	desc = "Some empty glass bottles and a broken dinner plate. You just might be able to make something out of this."
	icon_state = "glass_6"

/obj/structure/halflife/trash/glass/plate/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to search through [src] for usable materials."), \
		span_notice("You begin to search through [src] for some materials."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(35))
			user.visible_message(span_notice("[user] gathers up materials from [src]."), \
				span_notice("You gather up some materials from [src]."))
			new /obj/item/stack/sheet/glass(loc, 1)
			qdel(src)
		else
			user.visible_message(span_notice("[user] fails to gather anything useful from [src]."), \
				span_notice("You don't manage to find anything useful from [src]."))
			if(prob(75)) // SO YOU'RE TELLING ME THERE'S A CHANCE...
				qdel(src)

/obj/structure/halflife/trash/glass/basic
	name = "empty glass bottles"
	desc = "A collection of empty glass bottles and broken pieces of some. Someone either had a very good or a very bad time here."
	icon_state = "glass_4"

/obj/structure/halflife/trash/glass/basic/Initialize(mapload)
	. = ..()
	icon_state = pick("glass_3","glass_4", "glass_5")

/obj/structure/halflife/trash/glass/basic/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		return
	user.visible_message(span_notice("[user] begins to search through [src] for usable materials."), \
		span_notice("You begin to search through [src] for some materials."))
	if(do_after(user, 5 SECONDS, src))
		if(prob(35))
			user.visible_message(span_notice("[user] gathers up materials from [src]."), \
				span_notice("You gather up some materials from [src]."))
			new /obj/item/stack/sheet/glass(loc, rand(1,4))
			qdel(src)
		else
			user.visible_message(span_notice("[user] fails to gather anything useful from [src]."), \
				span_notice("You don't manage to find anything useful from [src]."))
			if(prob(80)) // SO YOU'RE TELLING ME THERE'S A CHANCE...
				qdel(src)
