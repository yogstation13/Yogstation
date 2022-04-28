/obj/structure/katana_grave
	name = "katana mound"
	desc = "A desolate and shallow grave for those who have fallen. This one seems to be punctuated by a katana."
	icon = 'icons/obj/lavaland/misc.dmi'
	icon_state = "grave_katana"
	anchored = TRUE
	var/obj/item/dropping_item = /obj/item/katana/cursed

/obj/structure/katana_grave/attack_hand(mob/user)
	. = ..()
	qdel(src)

/obj/structure/katana_grave/Destroy()
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	new /obj/structure/fluff/grave/empty(get_turf(src))
	new dropping_item(get_turf(src))
	. = ..()
	