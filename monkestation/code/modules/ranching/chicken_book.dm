/obj/item/book/manual/chicken_encyclopedia
	name = "chicken encyclopedia"
	desc = "The exciting sequel to the encyclopedia of 21st century trains!"
	icon = 'monkestation/icons/obj/ranching.dmi'
	icon_state = "chicken_book"
	unique = TRUE

/obj/item/book/manual/chicken_encyclopedia/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "RanchingEncyclopedia")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/book/manual/chicken_encyclopedia/ui_static_data(mob/user)
	var/list/chickens = list()
	for(var/datum/mutation/ranching/chicken/mutation_type as anything in GLOB.chicken_mutations)
		var/datum/mutation/ranching/chicken/mutation = GLOB.chicken_mutations[mutation_type]
		var/male_name = mutation.chicken_type::breed_name_male || "[mutation.chicken_type::breed_name] Rooster"
		var/female_name = mutation.chicken_type::breed_name_female || "[mutation.chicken_type::breed_name] Hen"

		var/list/details = list()

		var/list/food_names = list()
		for(var/obj/item/food/food_item as anything in mutation.food_requirements)
			food_names |= "[food_item::name]s"

		var/list/reagent_names = list()
		for(var/datum/reagent/listed_reagent as anything in mutation.reagent_requirements)
			reagent_names |= listed_reagent::name

		var/list/turf_names = list()
		for(var/turf/listed_turf as anything in mutation.needed_turfs)
			turf_names |= listed_turf::name

		var/list/obj_names = list()
		for(var/obj/item/listed_item as anything in mutation.nearby_items)
			obj_names |= listed_item::name

		var/rooster_string
		if(mutation.required_rooster)
			rooster_string = mutation.required_rooster::breed_name_male || mutation.required_rooster::breed_name

		var/species_string
		if(mutation.needed_species)
			species_string = mutation.needed_species::name

		details["name"] = "[female_name] / [male_name]"
		details["desc"] = mutation.chicken_type::book_desc
		/* details["max_age"] = 100 */
		details["happiness"] = mutation.happiness
		details["temperature"] = mutation.needed_temperature
		details["temperature_variance"] = mutation.temperature_variance
		details["needed_pressure"] = mutation.needed_pressure
		details["pressure_variance"] = mutation.pressure_variance
		details["food_requirements"] = food_names && english_list(food_names)
		details["reagent_requirements"] = reagent_names && english_list(reagent_names)
		details["player_job"] = mutation.player_job
		details["player_health"] = mutation.player_health
		details["needed_species"] = species_string
		details["required_atmos"] = mutation.required_atmos && english_list(mutation.required_atmos)
		details["required_rooster"] = rooster_string
		details["liquid_depth"] = mutation.liquid_depth
		details["needed_turfs"] = turf_names && english_list(turf_names)
		details["nearby_items"] = obj_names && english_list(obj_names)
		details["comes_from"] = mutation.can_come_from_string

		details["icon"] = mutation.chicken_type::icon
		details["icon_suffix"] = mutation.chicken_type::icon_suffix || "white"

		chickens += list(details)

	return list("chickens" = chickens)
