/obj/structure/window/bananium
	name = "bananium window"
	desc = "A window that is made out of bananium."
	icon_state = "bananium_window"
	glass_type = /obj/item/stack/sheet/mineral/bananium
	var/spam_flag = 0

/obj/structure/window/bananium/Bumped(atom/movable/AM)
	honk()
	..()

/obj/structure/window/bananium/attackby(obj/item/W, mob/user, params)
	honk()
	return ..()

/obj/structure/window/bananium/attack_hand(mob/user)
	honk()
	. = ..()

/obj/structure/window/bananium/attack_paw(mob/user)
	honk()
	..()

/obj/structure/window/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/obj/structure/window/bananium/spawner/east
	dir = EAST

/obj/structure/window/bananium/spawner/west
	dir = WEST

/obj/structure/window/bananium/spawner/north
	dir = NORTH

/obj/structure/window/bananium/unanchored
	anchored = FALSE

/obj/structure/window/bananium/fulltile
	icon = 'yogstation/icons/obj/smooth_structures/bananium_window.dmi'
	icon_state = "bananium_window"
	dir = FULLTILE_WINDOW_DIR
	max_integrity = 50
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/obj/structure/window/fulltile, /obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile, /obj/structure/window/plasma/reinforced/fulltile, /obj/structure/window/bananium/fulltile)
	glass_amount = 2

/obj/structure/window/bananium/fulltile/unanchored
	anchored = FALSE