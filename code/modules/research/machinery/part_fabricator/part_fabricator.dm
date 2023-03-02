/// The Production Producer
/obj/machinery/part_fabricator
	name = "experimental part fabricator"
	desc = "A strange machine that condenses materials into advanced parts."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/part_fabricator
	resistance_flags = UNACIDABLE | LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF

	use_power = IDLE_POWER_USE
	idle_power_usage = 5000
	active_power_usage = 20000
	density = TRUE

	var/static/part_recipes_generated = FALSE
	var/static/capacitor_energy_requirement
	var/static/matterbin_freon_moles_requirement
	var/static/list/datum/bounty/reagent/scanner_chemicals_requirement
	var/static/laser_money_requirement
	var/static/datum/bounty/item/botany/manipulator_plant_requirement
	var/static/manipulator_temp_requirement

	var/static/list/acceptable_items

	var/tab = "capacitor"

	var/production_speed = 1

	var/production_progress = 0

/obj/machinery/part_fabricator/attackby(obj/item/inserted, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, inserted))
		update_icon()
		return
	
	if(default_deconstruction_crowbar(inserted))
		return

	if(is_refillable() && inserted.is_drainable())
		return FALSE //inserting reagents into the machine
	
	if(inserted.get_item_credit_value() || is_type_in_list(inserted, acceptable_items))
		inserted.forceMove(src)
		to_chat(user, span_notice("You insert \the [inserted] into \the [src]."))
		return TRUE
	else if(user.a_intent == INTENT_HELP) // if they're bashing it they probably don't care
		to_chat(user, span_danger("\The [src] rejects \the [inserted]!"))
	
	return ..()

/obj/machinery/part_fabricator/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("\The [src]'s maintenance hatch is open!")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("Production speed at [production_speed*100]%")

/obj/machinery/part_fabricator/RefreshParts()
	production_speed = initial(production_speed)
	for(var/obj/item/stock_parts/P in component_parts)
		if(P.rating == 5)
			production_speed += 0.2 // 21 parts, up to 5.2x default speed
	if(reagents)
		reagents.maximum_volume = 0
		for(var/obj/item/reagent_containers/glass/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)

/obj/machinery/part_fabricator/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	for(var/obj/item/item in contents)
		forceMove(get_turf(src)) // Eject anything we may be holding

/obj/machinery/part_fabricator/Initialize()
	. = ..()
	create_reagents(0, OPENCONTAINER)
	RefreshParts()
	if(part_recipes_generated)
		return
	
	capacitor_energy_requirement = (rand() * 0.5 + 0.75) * 1000000000 // 0.75-1.25 GW

	matterbin_freon_moles_requirement = (rand() * 0.5 + 0.5) * 100 // 50-100 moles

	scanner_chemicals_requirement = list()
	scanner_chemicals_requirement += new /datum/bounty/reagent/simple_drink
	scanner_chemicals_requirement += new /datum/bounty/reagent/chemical_simple

	laser_money_requirement = round((rand() * 0.5 + 0.75) * 10000) // 7500-12500 credits

	var/list/possible_plants = subtypesof(/datum/bounty/item/botany)
	for(var/datum/bounty/item/botany/plant_bounty in possible_plants)
		if(initial(plant_bounty.multiplier) < 2)
			possible_plants -= plant_bounty
	manipulator_plant_requirement = new pick(possible_plants)

	manipulator_temp_requirement = (rand() + 1) * 40000 // 40000-80000 Kelvin

	acceptable_items = list(
		/obj/item/electrical_stasis_manifold,
		/obj/item/organic_augur,
		/obj/item/mmi/posibrain,
		/obj/item/gun/energy/laser,
		/obj/item/organ
	)

	part_recipes_generated = TRUE

/obj/machinery/part_fabricator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if(!ui)
		ui = new(user, src, "PartFabricator", name)
		ui.open()

/obj/machinery/part_fabricator/ui_data(mob/user)
	var/list/data = ..()

	var/my_contents = contents.Copy()

	// Capacitor requirements /////////////////////////////////////////////////////////////////
	var/current_ESMs = 0
	for(var/obj/item/electrical_stasis_manifold/esm in my_contents)
		my_contents -= esm
		current_ESMs++
	data["current_ESMs"] = current_ESMs ? current_ESMs : "0"

	var/current_energy = get_power(TRUE)
	data["current_energy"] = current_energy ? current_energy : "0"

	// Matter bin requirements /////////////////////////////////////////////////////////////////
	var/current_augurs = 0
	for(var/obj/item/organic_augur/augur in my_contents)
		current_augurs -= augur
		current_ESMs++
	data["current_augurs"] = current_augurs ? current_augurs : "0"

	var/datum/gas_mixture/my_gas = return_air()
	var/current_moles = my_gas.get_moles(/datum/gas/freon)
	data["current_moles"] = current_moles ? current_moles : "0"

	// Scanner requirements /////////////////////////////////////////////////////////////////
	var/current_posibrain = "ERROR: No artificial brain loaded"
	for(var/obj/item/mmi/posibrain/posi in my_contents)
		my_contents -= posi
		current_posibrain = "ERROR: Artificial brain inactive"
		if(posi.brainmob?.key && posi.brainmob.stat == CONSCIOUS && posi.brainmob.client)
			current_posibrain = "Artificial brain active"
			break
	data["current_posibrain"] = current_posibrain

	var/current_reagents = list()
	var/current_reagents_num = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		current_reagents += "[R.name]"
		current_reagents_num += R.volume
	data["current_reagents"] = current_reagents
	data["current_reagents_num"] = current_reagents_num

	// Laser requirements /////////////////////////////////////////////////////////////////
	var/current_lasergun = "ERROR: No laser gun loaded"
	for(var/obj/item/gun/energy/laser/lasgun in my_contents)
		my_contents -= lasgun
		var/valid = FALSE
		for(var/obj/item/ammo_casing/ammotype in lasgun.ammo_type)
			if(initial(ammotype.harmful)) // No practice laser guns
				valid = TRUE
				break
		if(valid)
			current_lasergun = "Laser gun loaded"
			break
	data["current_lasergun"] = current_lasergun

	var/current_money = 0
	for(var/obj/item/money in my_contents)
		var/worth = money.get_item_credit_value()
		if(!worth)
			continue
		my_contents -= money
		current_money += worth
	data["current_money"] = current_money ? current_money : "0"

	// Manipulator requirements /////////////////////////////////////////////////////////////////
	var/current_plants = 0
	for(var/selected_item in my_contents)
		if(is_type_in_list(selected_item, manipulator_plant_requirement.wanted_types))
			current_plants++
			my_contents -= selected_item
	data["current_plants"] = current_plants

	var/current_temp = my_gas.return_temperature()
	data["current_temp"] = current_temp ? current_temp : "0"

	// Other vars /////////////////////////////////////////////////////////////////

	data["production_progress"] = production_progress
	data["tab"] = tab

	return data

/obj/machinery/part_fabricator/ui_static_data(mob/user)
	var/list/data = ..()
	data["capacitor_energy"] = capacitor_energy_requirement
	data["matterbin_moles"] = matterbin_freon_moles_requirement
	data["scanner_chemicals"] = list()
	data["scanner_chemicals_num"] = list()
	for(var/datum/bounty/reagent/bounty in scanner_chemicals_requirement)
		data["scanner_chemicals"] += "[initial(bounty.wanted_reagent.name)]"
		data["scanner_chemicals_num"] += bounty.required_volume
	data["laser_money"] = laser_money_requirement
	data["manipulator_plant"] = manipulator_plant_requirement.name
	data["manipulator_plant_num"] = manipulator_plant_requirement.required_count
	data["manipulator_temp"] = manipulator_temp_requirement
	return data

/obj/machinery/part_fabricator/ui_act(action, list/params)
	if(..())
		return
	
	switch(action)
		if("goCapacitor")
			tab = "capacitor"
			return TRUE
		if("goMatterBin")
			tab = "matterbin"
			return TRUE
		if("goScanner")
			tab = "scanner"
			return TRUE
		if("goLaser")
			tab = "laser"
			return TRUE
		if("goManipulator")
			tab = "manipulator"
			return TRUE

/// Returns the power of the powernet of the APC of the room we're in
/obj/machinery/part_fabricator/proc/get_power(view = FALSE) // viewavail is nicer looking but not the true current power
	var/current_energy = 0
	var/area/my_area = get_area(src)
	if(!my_area)
		return
	// this is apparently the best way to get the current area's APC
	for(var/obj/machinery/power/apc/selected_apc as anything in GLOB.apcs_list)
		if(selected_apc.area == my_area)
			current_energy = view ? selected_apc.terminal?.powernet?.viewavail : selected_apc.terminal?.powernet?.avail
			break
	return current_energy
