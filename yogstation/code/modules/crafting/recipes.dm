/datum/crafting_recipe/improvised_bandage
	name = "Improvised Bandage"
	result = /obj/item/medical/bandage/improvised
	reqs = list(/obj/item/clothing/torncloth = 1)
	time = 45
	category = CAT_MISC

/datum/crafting_recipe/soaked_improvised_bandage
	name = "Improvised Bandage (Soaked)"
	result = /obj/item/medical/bandage/improvised_soaked
	reqs = list(/obj/item/clothing/torncloth = 1, /datum/reagent/water = 20)
	time = 45
	category = CAT_MISC
	
/datum/crafting_recipe/drone_shell
	name = "Drone Shell"
	result = /obj/item/drone_shell
	reqs = list(/obj/item/stock_parts/cell = 1, /obj/item/assembly/flash/handheld = 1, /obj/item/crowbar = 1, /obj/item/wrench = 1, /obj/item/restraints/handcuffs/cable = 1, /obj/item/screwdriver = 1, /obj/item/multitool = 1, /obj/item/weldingtool = 1, /obj/item/wirecutters = 1, /obj/item/storage/backpack = 1, /obj/item/stack/sheet/plasteel = 5)
	time = 120
	category = CAT_ROBOT