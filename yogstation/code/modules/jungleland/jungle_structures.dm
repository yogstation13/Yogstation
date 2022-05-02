/obj/structure/flora/tree/dead/jungle
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "nwtree_1"

/obj/structure/flora/tree/dead/jungle/Initialize()
	. = ..()
	icon_state = "nwtree_[rand(1, 6)]"

/obj/effect/temp_visual/skin_twister_in
	layer = BELOW_MOB_LAYER
	duration = 8
	icon = 'yogstation/icons/effects/64x64.dmi'
	icon_state = "skin_twister_in"
	pixel_y = -16
	pixel_x = -16

/obj/effect/temp_visual/skin_twister_out
	layer = BELOW_MOB_LAYER
	duration = 8
	icon = 'yogstation/icons/effects/64x64.dmi'
	icon_state = "skin_twister_out"
	pixel_y = -16
	pixel_x = -16
