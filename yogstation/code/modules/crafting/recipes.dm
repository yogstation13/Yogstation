/datum/crafting_recipe/improvised_bandage
	name = "Improvised Bandage"
	result = /obj/item/medical/bandage/improvised
	reqs = list(/obj/item/clothing/torncloth = 2)
	time = 4.5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/soaked_improvised_bandage
	name = "Improvised Bandage (Soaked)"
	result = /obj/item/medical/bandage/improvised_soaked
	reqs = list(/obj/item/clothing/torncloth = 2, /datum/reagent/water = 20)
	time = 4.5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/drone_shell
	name = "Drone Shell"
	result = /obj/item/drone_shell
	reqs = list(/obj/item/stock_parts/cell = 1, /obj/item/assembly/flash/handheld = 1, /obj/item/crowbar = 1, /obj/item/wrench = 1, /obj/item/restraints/handcuffs/cable = 1, /obj/item/screwdriver = 1, /obj/item/multitool = 1, /obj/item/weldingtool = 1, /obj/item/wirecutters = 1, /obj/item/storage/backpack = 1, /obj/item/stack/sheet/plasteel = 5)
	time = 12 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermech
	name = "Locker Mech"
	result = /obj/mecha/makeshift
	reqs = list(/obj/item/stack/cable_coil = 20,
				/obj/item/stack/sheet/metal = 10,
				/obj/item/storage/toolbox = 2, // For feet
				/obj/item/tank/internals/oxygen = 1, // For air
				/obj/item/electronics/airlock = 1, //You are stealing the motors from airlocks
				/obj/item/extinguisher = 1, //For bastard pnumatics
				/obj/item/paper = 5, //Cause paper is the best for making a mech airtight obviously
				/obj/item/flashlight = 1, //For the mech light
				/obj/item/stack/rods = 4, //to mount the equipment
				/obj/item/chair = 2) //For legs
	tools = list(/obj/item/weldingtool, /obj/item/screwdriver, /obj/item/wirecutters)
	time = 20 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechdrill
	name = "Makeshift exosuit drill"
	result = /obj/item/mecha_parts/mecha_equipment/drill/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/surgicaldrill = 1)
	tools = list(/obj/item/screwdriver)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/lockermechclamp
	name = "Makeshift exosuit clamp"
	result = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/makeshift
	reqs = list(/obj/item/stack/cable_coil = 5,
				/obj/item/stack/sheet/metal = 2,
				/obj/item/wirecutters = 1) //Don't ask, its just for the grabby grabby thing
	tools = list(/obj/item/screwdriver)
	time = 5 SECONDS
	category = CAT_ROBOT

/datum/crafting_recipe/chitintreads // Whats funny about these is that they require something only ashwalkers have to make but ashwalkers cant even wear em heh
	name = "Chitin Boots"
	result = /obj/item/clothing/shoes/yogs/chitintreads
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/bone = 1,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 1,
				/obj/item/stack/sheet/sinew = 1,
				/obj/item/stack/sheet/mineral/mythril = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/chitinarmor
	name = "Chitin Plate Armor"
	result = /obj/item/clothing/suit/yogs/armor/chitinplate
	time = 10 SECONDS
	reqs = list (/obj/item/stack/sheet/bone = 5,
				 /obj/item/stack/sheet/animalhide/weaver_chitin = 2,
				 /obj/item/stack/sheet/sinew = 3,
				 /obj/item/stack/sheet/mineral/mythril = 1,
				 /obj/item/clothing/suit/armor/bone = 1)
	category = CAT_PRIMAL

/datum/crafting_recipe/chitinhands
	name = "Chitin Gauntlets"
	result = /obj/item/clothing/gloves/yogs/chitinhands
	time = 3 SECONDS
	reqs = list (/obj/item/stack/sheet/bone = 3,
				 /obj/item/stack/sheet/animalhide/weaver_chitin = 1,
				 /obj/item/stack/sheet/sinew = 1,
				 /obj/item/stack/sheet/mineral/mythril = 1,
				 /obj/item/clothing/gloves/bracer = 1)
	category = CAT_PRIMAL
