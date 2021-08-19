/obj/screen/vampire
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "power_display"
	name = "usable blood"
	invisibility = INVISIBILITY_ABSTRACT
/obj/screen/vampire/Initialize()
	. = ..()
	screen_loc = ui_lingchemdisplay
