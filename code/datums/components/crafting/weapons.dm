// Weapons

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/grenade/iedcasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/lighter/greyscale = 1,
				/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	time = 1.5 SECONDS
	category = CAT_WEAPON_RANGED


/datum/crafting_recipe/crossbow
	name = "Rebar Crossbow"
	result = /obj/item/gun/ballistic/bow/crossbow/rebar
	reqs = list(/obj/item/stack/sheet/metal = 10,
				/obj/item/restraints/handcuffs/cable = 1,
				/obj/item/lighter/greyscale = 1,
				/obj/item/stack/tape = 1)
	time = 10 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/rebar
	name = "Rebar Bolt"
	result = /obj/item/ammo_casing/reusable/arrow/rebar
	reqs = list(/obj/item/stack/rods = 3)
	time = 20 SECONDS
	category = CAT_WEAPON_RANGED
