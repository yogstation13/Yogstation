
/datum/crafting_recipe/virus_analyzer_glasses
	name = "Viral Analyzer Glasses"
	result = /obj/item/clothing/glasses/sunglasses/pathology
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(
		/obj/item/clothing/glasses/pathology = 1,
		/obj/item/clothing/glasses/sunglasses = 1,
		/obj/item/stack/cable_coil = 5
	)
	category = CAT_EQUIPMENT

/datum/crafting_recipe/virus_analyzer_removal
	name = "Viral Analyzer removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 2 SECONDS
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/pathology = 1)
	category = CAT_EQUIPMENT
