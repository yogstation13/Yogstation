//////lavaland surface papers

/obj/item/paper/fluff/stations/lavaland/surface/henderson_report
	name = "Important Notice - Mrs. Henderson"
	info = "Nothing of interest to report."

//ratvar

/obj/structure/dead_ratvar
	name = "hulking wreck"
	desc = "The remains of a monstrous war machine."
	icon = 'icons/obj/lavaland/dead_ratvar.dmi'
	icon_state = "dead_ratvar"
	flags_1 = ON_BORDER_1
	appearance_flags = 0
	layer = FLY_LAYER
	anchored = TRUE
	density = TRUE
	bound_width = WORLD_ICON_SIZE*13
	bound_height = WORLD_ICON_SIZE*2
	pixel_y = -10*PIXEL_MULTIPLIER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
