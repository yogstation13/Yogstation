/obj/structure/headpike
	name = "spooky head on a spear"
	desc = "When you really want to send a message."
	icon = 'icons/obj/structures.dmi'
	density = FALSE
	anchored = TRUE
	var/obj/item/melee/spear/spear
	var/obj/item/bodypart/head/victim

/obj/structure/headpike/glass //for regular spears
	icon_state = "headpike"

/obj/structure/headpike/bone //for bone spears
	icon_state = "headpike-bone"

/obj/structure/headpike/bamboo //for bamboo spears
	icon_state = "headpike-bamboo"

/obj/structure/headpike/CheckParts(list/parts_list)
	victim = locate(/obj/item/bodypart/head) in parts_list
	name = "[victim.name] on a spear"
	..()
	update_appearance(UPDATE_ICON)

/obj/structure/headpike/glass/CheckParts(list/parts_list)
	spear = locate(/obj/item/melee/spear) in parts_list
	..()

/obj/structure/headpike/bone/CheckParts(list/parts_list)
	spear = locate(/obj/item/melee/spear/bonespear) in parts_list
	..()

/obj/structure/headpike/bamboo/CheckParts(list/parts_list)
	spear = locate(/obj/item/melee/spear/bamboospear) in parts_list
	..()

/obj/structure/headpike/Initialize(mapload)
	. = ..()
	pixel_x = rand(-8, 8)

/obj/structure/headpike/update_overlays()
	. = ..()
	var/obj/item/bodypart/head/H = locate() in contents
	if(!H)
		return
	var/mutable_appearance/MA = new()
	MA.copy_overlays(H)
	MA.pixel_y = 12
	. += MA

/obj/structure/headpike/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	to_chat(user, span_notice("You take down [src]."))
	victim.forceMove(drop_location())
	victim = null
	spear.forceMove(drop_location())
	spear = null
	qdel(src)
