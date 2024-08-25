// Weapons

/datum/crafting_recipe/pin_removal
	name = "Pin Removal"
	result = /obj/item/gun
	reqs = list(/obj/item/gun = 1)
	parts = list(/obj/item/gun = 1)
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	time = 5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/IED
	name = "IED"
	result = /obj/item/grenade/iedcasing
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	parts = list(/obj/item/reagent_containers/food/drinks/soda_cans = 1)
	time = 1.5 SECONDS
	category = CAT_WEAPON_RANGED

/datum/crafting_recipe/strobeshield
	name = "Strobe Shield"
	result = /obj/item/shield/riot/flash
	reqs = list(/obj/item/wallframe/flasher = 1,
				/obj/item/assembly/flash/handheld = 1,
				/obj/item/shield/riot = 1)
	blacklist = list(/obj/item/shield/riot/buckler, /obj/item/shield/riot/tele)
	time = 4 SECONDS
	category = CAT_WEAPON_MELEE

/datum/crafting_recipe/plasma_glass_arrow
	name = "Plasmaglass Arrow"
	result = /obj/item/ammo_casing/reusable/arrow/glass/plasma
	time = 1.5 SECONDS
	reqs = list(/obj/item/shard/plasma = 1,
				/obj/item/stack/rods = 1,
				/obj/item/stack/cable_coil = 3)
	category = CAT_WEAPON_AMMO
