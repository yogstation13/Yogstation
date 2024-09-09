/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber
	name = "pressurized reaction chamber"
	desc = "An afront to both chemists and atmospheric technicans."

	icon_state = "reaction_chamber"
	icon = 'icons/obj/plumbing/plumbers.dmi'

	initialize_directions = EAST

	var/static/list/pressurized_reaction_recipes = list()
	var/datum/pressurized_reaction/chosen_recipe
	var/processing = FALSE

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/Initialize(mapload)
	. = ..()
	create_reagents(1000, TRANSPARENT)
	AddComponent(/datum/component/plumbing/pressurized_reaction_chamber)

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/set_init_directions()
	. = ..()
	switch(dir)
		if(SOUTH)
			initialize_directions = EAST
		if(NORTH)
			initialize_directions = WEST
		if(WEST)
			initialize_directions = SOUTH
		if(EAST)
			initialize_directions = NORTH

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/ui_interact(mob/user, datum/tgui/ui)
	if(!length(pressurized_reaction_recipes))
		create_recipes()
	chosen_recipe = tgui_input_list(user, "Choose a recipe to focus on.", name, pressurized_reaction_recipes)

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/proc/create_recipes()
	for(var/datum/pressurized_reaction/new_recipes as anything in subtypesof(/datum/pressurized_reaction))
		pressurized_reaction_recipes += new new_recipes

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/examine(mob/user)
	. = ..()
	if(chosen_recipe)
		. += "[chosen_recipe.name] requires:"
		for(var/datum/reagent/reagent as anything in chosen_recipe.required_reagents)
			var/amount = reagents.get_reagent_amount(reagent)
			. += "[reagent.name]: [amount] / [chosen_recipe.required_reagents[reagent]]"
		. += "[chosen_recipe.required_pressure]kPa of pressure."

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/process_atmos()
	if(!chosen_recipe)
		return

	var/passes_all_chemicals = TRUE
	for(var/datum/reagent/reagent as anything in chosen_recipe.required_reagents)
		var/amount = reagents.get_reagent_amount(reagent)
		if(amount < chosen_recipe.required_reagents[reagent])
			passes_all_chemicals = FALSE
			break
	if(!passes_all_chemicals)
		return
	var/datum/gas_mixture/mixture = airs[1]
	var/pressure = mixture.return_pressure()
	if(pressure < chosen_recipe.required_pressure)
		return

	if(!processing)
		playsound(get_turf(src), 'sound/effects/bubbles2.ogg', 25, TRUE)
		var/list/seen = viewers(4, get_turf(src))
		var/iconhtml = icon2html(src, seen)
		audible_message(span_notice("[iconhtml] The solution bubbles fiercely!"))
		addtimer(CALLBACK(src, PROC_REF(create_recipe)), 7 SECONDS)
		processing = TRUE

/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/proc/create_recipe()
	processing = FALSE
	for(var/datum/reagent/reagent as anything in chosen_recipe.required_reagents)
		reagents.remove_all_type(reagent, chosen_recipe.required_reagents[reagent])

	for(var/datum/reagent/reagent as anything in chosen_recipe.outputs)
		reagents.add_reagent(reagent, chosen_recipe.outputs[reagent])

/datum/component/plumbing/pressurized_reaction_chamber
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/pressurized_reaction_chamber/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/pressurized_reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/reaction_chamber = parent
	if(!. || !reaction_chamber.emptying || reagents.is_reacting == TRUE)
		return FALSE

/datum/component/plumbing/pressurized_reaction_chamber/send_request(dir)
	var/obj/machinery/atmospherics/components/unary/pressurized_reaction_chamber/chamber = parent
	if(!chamber.chosen_recipe)
		return

	for(var/required_reagent in chamber.chosen_recipe.required_reagents)
		var/has_reagent = FALSE
		for(var/datum/reagent/containg_reagent as anything in reagents.reagent_list)
			if(required_reagent == containg_reagent.type)
				has_reagent = TRUE
				if(containg_reagent.volume + CHEMICAL_QUANTISATION_LEVEL < chamber.chosen_recipe.required_reagents[required_reagent])
					process_request(min(chamber.chosen_recipe.required_reagents[required_reagent] - containg_reagent.volume, MACHINE_REAGENT_TRANSFER) , required_reagent, dir)
					return
		if(!has_reagent)
			process_request(min(chamber.chosen_recipe.required_reagents[required_reagent], MACHINE_REAGENT_TRANSFER), required_reagent, dir)
			return
