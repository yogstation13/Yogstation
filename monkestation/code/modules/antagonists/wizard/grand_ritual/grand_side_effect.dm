/obj/effect/abstract/local_food_rain/proc/drop_food(turf/landing_zone)
	var/food_type = get_random_food()
	var/obj/item/food/summoned_food = new food_type
	summoned_food.preserved_food = TRUE // it's magical food
	podspawn(list(
			"target" = landing_zone,
			"style" = STYLE_SEETHROUGH,
			"spawn" = summoned_food,
			"delays" = list(POD_TRANSIT = 0, POD_FALLING = (3 SECONDS), POD_OPENING = 0, POD_LEAVING = 0),
			"effectStealth" = TRUE,
			"effectQuiet" = TRUE,
		)
	)
