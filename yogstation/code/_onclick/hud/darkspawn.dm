/obj/screen/darkspawn_psi
	name = "psi"
	icon = 'yogstation/icons/mob/screen_gen.dmi'
	icon_state = "psi_counter"
	invisibility = INVISIBILITY_ABSTRACT
/obj/screen/darkspawn_psi/Initialize()
	. = ..()
	screen_loc = ui_lingchemdisplay
