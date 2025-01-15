/obj/item/book/manual/botanical_lexicon
	name = "Botanical Lexicon"
	desc = "A transcribed list of all known plant mutations and how to acquire them"
	icon = 'monkestation/icons/obj/ranching.dmi'
	icon_state = "chicken_book"
	unique = TRUE

/obj/item/book/manual/botanical_lexicon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotanicalLexicon")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/item/book/manual/botanical_lexicon/ui_static_data(mob/user)
	var/list/plants = list()
	for(var/datum/hydroponics/plant_mutation/mutation as anything in (subtypesof(/datum/hydroponics/plant_mutation) - /datum/hydroponics/plant_mutation/spliced_mutation - /datum/hydroponics/plant_mutation/infusion))
		if(!mutation::created_seed)
			continue
		var/datum/hydroponics/plant_mutation/listed_mutation = new mutation
		var/list/details = list()

		var/obj/item/seeds/created_seed = listed_mutation.created_seed

		details["name"] = created_seed::name
		details["desc"] = created_seed::desc

		var/list/requirements = list()
		if(length(listed_mutation.required_potency))
			requirements += list(list(
				"stat" = "Potency",
				"low" = listed_mutation.required_potency[1],
				"high" = listed_mutation.required_potency[2],
			))
		if(length(listed_mutation.required_yield))
			requirements += list(list(
				"stat" = "Yield",
				"low" = listed_mutation.required_yield[1],
				"high" = listed_mutation.required_yield[2],
			))
		if(length(listed_mutation.required_production))
			requirements += list(list(
				"stat" = "Production",
				"low" = listed_mutation.required_production[1],
				"high" = listed_mutation.required_production[2],
			))
		if(length(listed_mutation.required_endurance))
			requirements += list(list(
				"stat" = "Endurance",
				"low" = listed_mutation.required_endurance[1],
				"high" = listed_mutation.required_endurance[2],
			))
		if(length(listed_mutation.required_lifespan))
			requirements += list(list(
				"stat" = "Lifespan",
				"low" = listed_mutation.required_lifespan[1],
				"high" = listed_mutation.required_lifespan[2],
			))
		details["requirements"] = requirements

		if(length(listed_mutation.mutates_from))
			var/list/parents = list()
			for(var/obj/item/seeds/linked_seeds as anything in listed_mutation.mutates_from)
				parents += linked_seeds::name
			if(length(parents))
				details["mutates_from"] = english_list(parents)

		if(istype(listed_mutation, /datum/hydroponics/plant_mutation/infusion))
			var/datum/hydroponics/plant_mutation/infusion/infused_type = listed_mutation
			var/list/reagent_names = list()
			for(var/datum/reagent/listed_reagent as anything in infused_type.reagent_requirement)
				reagent_names += listed_reagent::name
			if(length(reagent_names))
				details["required_reagents"] = english_list(reagent_names)

		QDEL_NULL(listed_mutation)

		var/results = list(list(
			"path" = created_seed,
			"icon" = created_seed::icon,
			"icon_state" = created_seed::icon_state,
		))
		var/obj/item/product = created_seed::product
		if(product && product::icon && product::icon_state)
			results += list(list(
				"path" = product,
				"icon" = product::icon,
				"icon_state" = product::icon_state,
			))
		details["results"] = results

		plants += list(details)

	return list("plants" = plants)
