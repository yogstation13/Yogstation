/obj/structure/table/bananium
	name = "bananium table"
	desc = "A table made out of bananium very squeaky."
	icon = 'yogstation/icons/obj/smooth_structures/bananium_table.dmi'
	icon_state = "bananium_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	frame = /obj/structure/table_frame/bananium
	framestack = /obj/item/stack/sheet/mineral/bananium
	buildstack = /obj/item/stack/sheet/mineral/bananium
	framestackamount = 1
	buildstackamount = 1
	canSmoothWith = list(/obj/structure/table/bananium)
	var/spam_flag = 0

/obj/structure/table/bananium/attackby(obj/item/W, mob/user, params)
	honk()
	return ..()

/obj/structure/table/bananium/attack_hand(mob/user)
	honk()
	. = ..()

/obj/structure/table/bananium/attack_paw(mob/user)
	honk()
	..()

/obj/structure/table/bananium/proc/honk()
	if(!spam_flag)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		spawn(20)
			spam_flag = 0

/obj/structure/table/bananium/honk_act()
	return FALSE

/obj/structure/rack/skeletal
	name = "minibar"
	desc = "Different from the Middle Ages version."
	icon = 'yogstation/icons/obj/stationobjs.dmi'
	icon_state = "minibar"

/obj/structure/rack/skeletal/left
	icon_state = "minibar_left"

/obj/structure/rack/skeletal/right
	icon_state = "minibar_right"