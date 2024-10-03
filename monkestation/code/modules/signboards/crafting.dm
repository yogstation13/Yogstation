/datum/crafting_recipe/signboard
	name = "Signboard"
	desc = "A sign, you can write anything on it!"
	tool_behaviors = list(TOOL_WRENCH, TOOL_SCREWDRIVER)
	result = /obj/structure/signboard
	reqs = list(
		/obj/item/stack/sheet/mineral/wood = 5,
	)
	time = 5 SECONDS
	category = CAT_FURNITURE

/datum/crafting_recipe/holosign
	name = "Holographic Signboard"
	desc = "A sign, you can write anything on it! Now available in many colors!"
	tool_behaviors = list(TOOL_WRENCH, TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	result = /obj/structure/signboard/holosign
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 1,
	)
	time = 10 SECONDS
	category = CAT_FURNITURE
