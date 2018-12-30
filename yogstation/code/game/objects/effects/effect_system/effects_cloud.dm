/obj/effect/cloud
	name = "cloud"
	icon = 'yogstation/icons/effects/32x32.dmi'
	icon_state = "smoke"
	layer = 16

/obj/effect/cloud/Initialize()
	. = ..()
	playsound(loc, 'yogstation/sound/voice/meeseeksspawn.ogg', 40)
	return INITIALIZE_HINT_QDEL