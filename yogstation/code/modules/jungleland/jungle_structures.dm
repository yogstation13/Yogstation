/obj/structure/flora/tree/dead/jungle
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "nwtree_1"

/obj/structure/flora/tree/dead/jungle/Initialize()
	. = ..()
	icon_state = "nwtree_[rand(1, 6)]"
