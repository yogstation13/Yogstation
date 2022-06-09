//////////
// GUNS //
//////////

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

/datum/crafting_recipe/makeshiftmagazine
	name = "Makeshift Pistol Magazine (10mm)"
	result = /obj/item/ammo_box/magazine/m10mm/makeshift
	reqs = list(/obj/item/stack/sheet/metal = 2,
        		/obj/item/stack/tape = 2)
	time = 12 SECONDS
	category = CAT_WEAPONRY
	subcategory = CAT_AMMO
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

/datum/crafting_recipe/gauss
	name = "Makeshift gauss rifle"
	reqs = list(/obj/item/stock_parts/cell = 1,
				/obj/item/weaponcrafting/stock = 1,
				/obj/item/weaponcrafting/receiver = 1,
				/obj/item/stack/tape = 1,
				/obj/item/stack/rods = 4,
				/obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER,TOOL_WELDER,TOOL_WRENCH)
	result = /obj/item/gun/ballistic/gauss
	time = 12
	category = CAT_WEAPONRY
	subcategory = CAT_WEAPON


///////////
// TOOLS //
///////////

/datum/crafting_recipe/makeshiftcrowbar
	name = "Makeshift Crowbar"
	reqs = list(/obj/item/stack/rods = 3) //just bang them together
	result = /obj/item/crowbar/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftwrench
	name = "Makeshift Wrench"
	reqs = list(/obj/item/stack/sheet/metal = 2)
	result = /obj/item/wrench/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftwirecutters
	name = "Makeshift Wirecutters"
	reqs = list(/obj/item/stack/sheet/metal = 2,
				/obj/item/stack/rods = 2)
	result = /obj/item/wirecutters/makeshift
	time = 15 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftweldingtool
	name = "Makeshift Welding Tool"
	reqs = list(/obj/item/tank/internals/emergency_oxygen = 1,
				/obj/item/assembly/igniter = 1)
	tools = list(TOOL_SCREWDRIVER)
	result = /obj/item/weldingtool/makeshift
	time = 16 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftmultitool
	name = "Makeshift Multitool"
	reqs = list(/obj/item/assembly/igniter = 1,
				/obj/item/assembly/signaler = 1,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/stack/cable_coil = 10)
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	result = /obj/item/multitool/makeshift
	time = 16 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftscrewdriver
	name = "Makeshift Screwdriver"
	reqs = list(/obj/item/stack/rods = 3)
	result = /obj/item/screwdriver/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftknife
	name = "Makeshift Knife"
	reqs = list(/obj/item/stack/rods = 3,
				/obj/item/stack/sheet/metal = 1,
        		/obj/item/stack/tape = 2)
	result = /obj/item/kitchen/knife/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftpickaxe
	name = "Makeshift Pickaxe"
	reqs = list(
           /obj/item/crowbar = 1,
           /obj/item/kitchen/knife = 1,
           /obj/item/stack/tape = 1)
	result = /obj/item/pickaxe/makeshift
	category = CAT_TOOLS
	always_availible = FALSE

/datum/crafting_recipe/makeshiftradio
	name = "Makeshift Radio"	
	reqs = list(/obj/item/assembly/signaler = 1,
        		/obj/item/radio/headset = 1,
				/obj/item/stack/cable_coil = 5)
	tools = list(TOOL_SCREWDRIVER)
	result = /obj/item/radio/off/makeshift
	time = 12 SECONDS
	category = CAT_TOOLS
	always_availible = FALSE
