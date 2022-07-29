///////////////////////////////////////////////////
/// 				Antag recipes				///
// see granters.dm - at the top for easy viewing //
///////////////////////////////////////////////////

// Weapons
/datum/crafting_recipe/baseball_bat
	name = "Baseball Bat"
	result = /obj/item/melee/baseball_bat
	reqs = list(/obj/item/stack/sheet/mineral/wood = 30
				)
	tools = list(TOOL_HATCHET) //to carve the wood into shape
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/lance
	name = "Explosive Lance (Grenade)"
	result = /obj/item/twohanded/spear
	reqs = list(/obj/item/twohanded/spear = 1,
				/obj/item/grenade = 1)
	blacklist = list(/obj/item/twohanded/spear/explosive,
					/obj/item/grenade/flashbang)
	parts = list(/obj/item/twohanded/spear = 1,
				/obj/item/grenade = 1)
	time = 1.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/knifeboxing
	name = "Knife-boxing Gloves"
	result = /obj/item/clothing/gloves/knifeboxing
	reqs = list(/obj/item/clothing/gloves/boxing = 1,
				/obj/item/kitchen/knife = 2)
	time = 10 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/pipebomb
	name = "Pipe Bomb"
	result = /obj/item/grenade/pipebomb
	reqs = list(/datum/reagent/fuel = 50,
				/obj/item/stack/cable_coil = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/pipe = 1,
				/obj/item/assembly/mousetrap = 1)
	tools = list(TOOL_WELDER, TOOL_WRENCH, TOOL_WIRECUTTER)
	time = 1.5 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE 	//This was such a bad idea

/datum/crafting_recipe/flamethrower
	name = "Flamethrower"
	result = /obj/item/flamethrower
	reqs = list(/obj/item/weldingtool = 1,
				/obj/item/assembly/igniter = 1,
				/obj/item/stack/rods = 1)
	parts = list(/obj/item/assembly/igniter = 1,
				/obj/item/weldingtool = 1)
	tools = list(TOOL_SCREWDRIVER)
	time = 1 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/makeshiftpistol
	name = "Makeshift Pistol"
	result = /obj/item/gun/ballistic/automatic/pistol/makeshift
	reqs = list(/obj/item/weaponcrafting/receiver = 1,
				/obj/item/stack/sheet/metal = 4,
				/obj/item/stack/rods = 2,
           		/obj/item/stack/tape = 3)
	tools = list(TOOL_SCREWDRIVER)
	time = 12 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

/datum/crafting_recipe/makeshiftsuppressor
	name = "Makeshift Suppressor"
	result = /obj/item/suppressor/makeshift
	reqs = list(/obj/item/reagent_containers/food/drinks/soda_cans = 1,
				/obj/item/stack/rods = 1,
				/obj/item/stack/sheet/cloth = 2,
           		/obj/item/stack/tape = 1)
	time = 12 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON
	always_availible = FALSE

// Ammo

/datum/crafting_recipe/makeshiftmagazine
	name = "Makeshift Pistol Magazine (10mm)"
	result = /obj/item/ammo_box/magazine/m10mm/makeshift
	reqs = list(/obj/item/stack/sheet/metal = 2,
        		/obj/item/stack/tape = 2)
	time = 12 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/datum/crafting_recipe/bola_arrow
	name = "Bola arrow"
	result = /obj/item/ammo_casing/caseless/arrow/bola
	time = 3 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow = 1,
				/obj/item/stack/sheet/silk = 1,
				/obj/item/restraints/legcuffs/bola = 1)
	parts = list(/obj/item/ammo_casing/caseless/arrow = 1, /obj/item/restraints/legcuffs/bola = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE

/*
/datum/crafting_recipe/explosive_arrow
	name = "Explosive arrow"
	result = /obj/item/ammo_casing/caseless/arrow/explosive
	time = 3 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow = 1,
				/obj/item/stack/sheet/silk = 1,
				/obj/item/grenade = 1)
	parts = list(/obj/item/ammo_casing/caseless/arrow = 1, /obj/item/grenade = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE
*/

/datum/crafting_recipe/flaming_arrow
	name = "Flaming arrow"
	result = /obj/item/ammo_casing/caseless/arrow/flaming
	time = 3 SECONDS
	reqs = list(/obj/item/ammo_casing/caseless/arrow = 1,
				/obj/item/stack/sheet/cloth = 1,
				/datum/reagent/fuel = 10)
	parts = list(/obj/item/ammo_casing/caseless/arrow = 1)
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
	always_availible = FALSE
