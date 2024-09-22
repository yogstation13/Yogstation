/obj/item/nullspace_crystal
	name = "null skull"
	desc = "a skull of an ancient psionic user, grants a small amount of nulldust when ground up."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "null_skull"
	///how much nullspace dust does each skull give when used on the psionic awakener
	var/dust = 5
	w_class = WEIGHT_CLASS_TINY
	

/obj/item/nullspace_crystal/afterattack(obj/machinery/I, mob/user, proximity)
	. = ..()
	if(istype(I, /obj/machinery/psionic_awakener))
		var/obj/machinery/psionic_awakener/cart = I
		cart.nullspace_dust += dust
		to_chat(user, span_notice("You force the [name] into the psionic awakener's grinding port, crushing it to microscopic pieces."))
		qdel(src)

/obj/item/nullspace_crystal/brilliant
	name = "fresh null skull"
	desc = "a fresh skull of a weak psionic user, grants a fair amount of nulldust when ground up."
	dust = 10
	icon_state = "fresh_null_skull"
	w_class = WEIGHT_CLASS_TINY

/obj/item/nullspace_crystal/prismatic
	name = "aged null skull"
	desc = "an older skull of an adept psionic user, grants a lot of nulldust when ground up."
	dust = 15
	icon_state = "aged_null_skull"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/nullspace_crystal/true
	name = "living null skull"
	desc = "a pitch black skull of a powerful psionic user, looking into it's eye sockets make your cerebellum burn. Grants a huge boon of nulldust when ground up."
	dust = 50
	icon_state = "psionic_null_skull"
	w_class = WEIGHT_CLASS_NORMAL

/obj/effect/spawner/lootdrop/nullspace_crystal_spawner
	name = "nullskull spawner"
	lootdoubles = FALSE

	loot = list(
		/obj/item/nullspace_crystal = 75,
		/obj/item/nullspace_crystal/brilliant = 20,
		/obj/item/nullspace_crystal/prismatic = 4,
		/obj/item/nullspace_crystal/true = 1)
