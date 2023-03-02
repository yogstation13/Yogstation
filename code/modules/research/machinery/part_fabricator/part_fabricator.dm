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

	var/static/part_recipes_generated = FALSE
	var/static/capacitor_energy_requirement
	var/static/matterbin_freon_moles_requirement
	var/static/list/datum/bounty/reagent/scanner_chemicals_requirement
	var/static/laser_money_requirement
	var/static/manipulator_temp_requirement

	var/tab = "capacitor"

	var/production_speed = 1

/obj/machinery/part_fabricator/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("[src]'s maintenance hatch is open!")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("Production speed at [production_speed*100]%")

/obj/machinery/part_fabricator/RefreshParts()
	production_speed = initial(production_speed)
	for(var/obj/item/stock_parts/P in component_parts)
		if(P.rating == 5)
			production_speed += 0.2 // 21 parts, up to 5.2x default speed
	if(!reagents)
		create_reagents(0, OPENCONTAINER)
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
	if(part_recipes_generated)
		return
	
	capacitor_energy_requirement = (rand() * 0.5 + 0.75) * 1000000000 // 0.75-1.25 GW

	matterbin_freon_moles_requirement = (rand() * 0.5 + 0.5) * 100 // 50-100 moles

	scanner_chemicals_requirement = list()
	scanner_chemicals_requirement += new /datum/bounty/reagent/simple_drink
	scanner_chemicals_requirement += new /datum/bounty/reagent/chemical_simple

	laser_money_requirement = round((rand() * 0.5 + 0.75) * 10000) // 7500-12500 credits

	manipulator_temp_requirement = (rand() + 1) * 40000 // 40000-80000 Kelvin

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
	data["tab"] = tab
	var/my_contents = contents.Copy()

	// Capacitor requirements
	var/current_ESMs = 0
	for(var/obj/item/electrical_stasis_manifold/esm in my_contents)
		my_contents -= esm
		current_ESMs++
	data["current_ESMs"] = current_ESMs ? current_ESMs : "0"
	var/current_energy = get_power(TRUE)
	data["current_energy"] = current_energy ? DisplayPower(current_energy) : "0"

	// Matter bin requirements
	var/current_augurs = 0
	for(var/obj/item/organic_augur/augur in my_contents)
		current_augurs -= augur
		current_ESMs++
	data["current_augurs"] = current_augurs ? current_augurs : "0"
	var/datum/gas_mixture/my_gas = return_air()
	var/current_moles = my_gas.get_moles(/datum/gas/freon)
	data["current_moles"] = current_moles ? current_moles : "0"

	// Scanner requirements
	var/current_posibrain = "ERROR: No artificial brain loaded"
	for(var/obj/item/mmi/posibrain/posi in my_contents)
		my_contents -= posi
		current_posibrain = "ERROR: Artificial brain inactive"
		if(posi.brainmob?.key && posi.brainmob.stat == CONSCIOUS && posi.brainmob.client)
			current_posibrain = "Artificial brain active"
			break
	data["current_posibrain"] = current_posibrain
	var/current_reagents = ""
	for(var/datum/reagent/R in reagents.reagent_list)
		current_reagents += "\n[R.name]: [R.volume]u"
	data["current_reagents"] = current_reagents

	// Laser requirements
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

	return data

/obj/machinery/part_fabricator/ui_static_data(mob/user)
	var/list/data = ..()
	data["capacitor_energy"] = "[CEILING(capacitor_energy_requirement / 1000000000, 0.01)]GW"
	data["matterbin_moles"] = "[CEILING(matterbin_freon_moles_requirement, 0.01)] moles"
	data["scanner_chemicals"] = ""
	for(var/datum/bounty/reagent/bounty in scanner_chemicals_requirement)
		data["scanner_chemicals"] += "\n[bounty.required_volume]u of [initial(bounty.wanted_reagent.name)]"
	data["laser_money"] = "[laser_money_requirement] credits"
	data["manipulator_temp"] = "[CEILING(manipulator_temp_requirement, 1)] Kelvin"
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
