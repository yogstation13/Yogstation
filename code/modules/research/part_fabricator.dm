/// The Production Producer
/obj/machinery/part_fabricator
	name = "experimental part fabricator"
	desc = "A strange machine that condenses materials into advanced parts."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/part_fabricator
	resistance_flags = UNACIDABLE | LAVA_PROOF | FIRE_PROOF | FREEZE_PROOF

	var/static/part_recipes_generated = FALSE
	var/static/capacitor_energy_requirement
	var/static/matterbin_freon_moles_requirement
	var/static/list/scanner_chemicals_requirement
	var/static/laser_money_requirement
	var/static/manipulator_temp_requirement

	var/tab = "capacitor"

/obj/machinery/part_fabricator/Initialize()
	. = ..()
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
	return data

/obj/machinery/part_fabricator/ui_static_data(mob/user)
	var/list/data = ..()
	data["capacitor_energy"] = "[CEILING(capacitor_energy_requirement / 1000000000, 0.01)]GW"
	data["matterbin_moles"] = "[CEILING(matterbin_freon_moles_requirement, 0.01)] moles"
	data["scanner_chemicals"] = list()
	for(var/datum/bounty/reagent/bounty in scanner_chemicals_requirement)
		data["scanner_chemicals"] += "[bounty.required_volume]u of [initial(bounty.wanted_reagent.name)]"
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
