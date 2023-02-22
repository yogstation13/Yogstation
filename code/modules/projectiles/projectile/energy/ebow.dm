/obj/item/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	irradiate = 200
	pass_flags = PASSGLASS

/obj/item/projectile/energy/bolt/on_hit(atom/target, blocked = FALSE)
	..()
	if(ishuman(target))
		target.reagents.add_reagent(/datum/reagent/toxin/relaxant, 6)
		target.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6)
		target.reagents.add_reagent(/datum/reagent/toxin/anacea, 4)

/obj/item/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"
