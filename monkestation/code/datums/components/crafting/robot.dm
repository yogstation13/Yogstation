/datum/crafting_recipe/cleanbot_jr
	name = "Scrubs Junior"
	desc = "A little cleaning robot, he graduated from medical school!"
	result = /mob/living/basic/bot/cleanbot/medbay/jr
	reqs = list(
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/assembly/health = 1,
		/obj/item/bodypart/arm/right/robot = 1,

	)
	parts = list(/obj/item/reagent_containers/cup/bucket = 1)
	time = 5 SECONDS
	category = CAT_ROBOT
