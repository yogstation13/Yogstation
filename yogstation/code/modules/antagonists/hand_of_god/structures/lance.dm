/obj/structure/hog_structure/lance
	name = "Prismatic lance"
	desc = "A defensive structure, used to... well... kill everyone.."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "lance"
	icon_originalname = "lance"
	max_integrity = 65

/obj/structure/hog_structure/lance/Initialize()
	. = ..()
	if(!weapon)
		weapon = new /obj/item/hog_item/prismatic_lance/guardian(src)
