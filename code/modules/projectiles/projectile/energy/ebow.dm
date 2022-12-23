/obj/item/projectile/energy/bolt //ebow bolts
	name = "bolt"
	icon_state = "cbbolt"
	irradiate = 200
	pass_flags = PASSGLASS

/obj/item/projectile/energy/bolt/on_hit(atom/target, blocked = FALSE)
	..()
	if(ishuman(target))
		target.reagents.add_reagent(/datum/reagent/toxin/polonium/ebow, 10)
		target.reagents.add_reagent(/datum/reagent/toxin/mutagen, 8)
		target.reagents.add_reagent(/datum/reagent/peaceborg/tire, 8)
		target.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 8)
		target.reagents.add_reagent(/datum/reagent/toxin/anacea, 6)

/obj/item/projectile/energy/bolt/halloween
	name = "candy corn"
	icon_state = "candy_corn"
