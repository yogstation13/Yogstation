/obj/item/nullspace_crystal
	name = "dull nullspace crystal"
	desc = "a pitch black crystal, found in the space between red and blue. This one looks particularly dull."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "nullspace_crystal"
	///how much nullspace dust does each crystal give when used on the psionic awakener
	var/dust = 5

/obj/item/nullspace_crystal/afterattack(obj/machinery/I, mob/user, proximity)
	. = ..()
	if(istype(I, /obj/machinery/psionic_awakener))
		var/obj/machinery/psionic_awakener/cart = I
		cart.nullspace_dust += dust
		to_chat(user, span_notice("You force the nullspace crystal into the psionic awakener's crystal port, you can hear a soft grinding sound."))
		qdel(src)

/obj/item/nullspace_crystal/brilliant
	name = "brilliant nullspace crystal"
	desc = "a slightly less pitch black crystal, found in the space between red and blue. This one looks particularly brilliant."
	dust = 10

/obj/item/nullspace_crystal/prismatic
	name = "prismatic nullspace crystal"
	desc = "an oddly black crystal, found in the space between red and blue. This one looks particularly prismatic. You know what that means right?"
	dust = 25

/obj/item/nullspace_crystal/true
	name = "true nullspace crystal"
	desc = "a crystal made of pure condensed nullspace, looking through it is like a kaleidoscope, with different versions of you looking back."
	dust = 100

/obj/effect/spawner/lootdrop/nullspace_crystal_spawner
	name = "nullspace crystal spawner"
	lootdoubles = FALSE

	loot = list(
		/obj/item/nullspace_crystal = 75,
		/obj/item/nullspace_crystal/brilliant = 20,
		/obj/item/nullspace_crystal/prismatic = 4,
		/obj/item/nullspace_crystal/true = 1)
