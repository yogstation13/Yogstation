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

/datum/crafting_recipe/ashtray
	name = "Ashtray"
	result = /obj/item/ashtray
	time = 2 SECONDS
	reqs = list (
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/sheet/metal = 1
	)
	tool_paths = list(/obj/item/weldingtool)
	category = CAT_STRUCTURES
