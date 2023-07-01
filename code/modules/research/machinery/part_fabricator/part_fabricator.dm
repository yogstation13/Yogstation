#define FAB_CAPACITOR 1
#define FAB_MATTERBIN 2
#define FAB_SCANNER 3
#define FAB_LASER 4
#define FAB_MANIPULATOR 5

/// The Production Producer
/obj/machinery/exp_part_fabricator
	name = "experimental part fabricator"
	desc = "A strange machine that condenses materials into advanced parts."
	icon = 'icons/obj/machines/part_fabricator.dmi'
	icon_state = "default"
	circuit = /obj/item/circuitboard/machine/part_fabricator
	resistance_flags = INDESTRUCTIBLE // dont want it to be destroyed by radballs

	pixel_x = -32

	use_power = IDLE_POWER_USE
	idle_power_usage = 5000
	active_power_usage = 10000000 // 10MW
	density = TRUE
	var/list/obj/structure/fillers = list()

	var/static/part_recipes_generated = FALSE
	var/static/capacitor_energy_requirement
	var/static/matterbin_freon_moles_requirement
	var/static/list/datum/bounty/reagent/scanner_chemicals_requirement
	var/static/laser_money_requirement
	var/static/datum/bounty/item/botany/manipulator_plant_requirement
	var/static/manipulator_temp_requirement

	var/static/list/acceptable_items

	var/production_speed = 1

	var/printing
	var/production_progress = 0

/obj/machinery/exp_part_fabricator/attackby(obj/item/inserted, mob/living/user, params)
	if(production_progress <= 0 && default_deconstruction_screwdriver(user, "screwed_open", initial(icon_state), inserted))
		update_icon()
		return

	if(default_deconstruction_crowbar(inserted))
		return

	if(is_refillable() && inserted.is_drainable())
		return FALSE //inserting reagents into the machine

	if(inserted.get_item_credit_value() || is_type_in_typecache(inserted, acceptable_items))
		flick("get_mat", src)
		inserted.forceMove(src)
		to_chat(user, span_notice("You insert \the [inserted] into \the [src]."))
		return TRUE
	else if(user.a_intent == INTENT_HELP) // if they're bashing it they probably don't care
		to_chat(user, span_danger("\The [src] rejects \the [inserted]!"))

	return ..()

/obj/machinery/exp_part_fabricator/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("\The [src]'s maintenance hatch is open!")
	if(in_range(user, src) || isobserver(user))
		. += span_notice("Production speed at [CEILING(production_speed*100, 0.0001)]%")

/obj/machinery/exp_part_fabricator/RefreshParts()
	production_speed = initial(production_speed)
	for(var/obj/item/stock_parts/P in component_parts)
		switch(P.rating)
			if(1)
				production_speed *= 0.25 // yeah you're going to want to upgrade this thing
			if(2)
				production_speed *= 0.5
			if(3)
				production_speed *= 0.75
			if(5 to INFINITY)
				production_speed += 0.2 // at 21 parts, this provides a maximum speed boost of 5.2x
	if(reagents)
		reagents.maximum_volume = 0
		for(var/obj/item/reagent_containers/glass/G in component_parts)
			reagents.maximum_volume += G.volume
			G.reagents.trans_to(src, G.reagents.total_volume)

/obj/machinery/exp_part_fabricator/on_deconstruction()
	for(var/obj/item/reagent_containers/glass/G in component_parts)
		reagents.trans_to(G, G.reagents.maximum_volume)
	for(var/obj/item/item in contents)
		item.forceMove(get_turf(src)) // Eject anything we may be holding
		adjust_item_drop_location(item)

/obj/machinery/exp_part_fabricator/Initialize(mapload)
	. = ..()
	create_reagents(0, OPENCONTAINER)
	RefreshParts()

	var/list/occupied = list()
	for(var/direct in list(EAST,WEST,NORTH))
		occupied += get_step(src,direct)

	for(var/T in occupied)
		var/obj/structure/filler/F = new(T)
		F.parent = src
		fillers += F

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
		if(initial(plant_bounty.multiplier) == 0)
			possible_plants -= plant_bounty
	var/bounty_type = pick(possible_plants)
	manipulator_plant_requirement = new bounty_type

	manipulator_temp_requirement = (rand() + 1) * 40000 // 40000-80000 Kelvin

	acceptable_items = typecacheof(list(
		/obj/item/electrical_stasis_manifold,
		/obj/item/organic_augur,
		/obj/item/mmi/posibrain,
		/obj/item/gun/energy/laser,
		/obj/item/organ
	))

	for(var/item in manipulator_plant_requirement.wanted_types)
		acceptable_items += typecacheof(item)

	part_recipes_generated = TRUE

/obj/machinery/exp_part_fabricator/Destroy()
	for(var/obj/structure/filler/filler as anything in fillers)
		filler.parent = null
		qdel(filler)
	. = ..()

/obj/machinery/exp_part_fabricator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if(!ui)
		ui = new(user, src, "PartFabricator", name)
		ui.open()

/obj/machinery/exp_part_fabricator/ui_data(mob/user)
	var/list/data = ..()

	var/current_ESMs = 0
	var/current_augurs = 0
	var/datum/gas_mixture/my_gas = return_air()
	var/current_posibrain = "ERROR: No artificial brain loaded"
	var/current_lasergun = "ERROR: No laser gun loaded"
	var/current_money = 0
	var/current_plants = 0
	for(var/obj/item/loaded_item in contents) // Run through contents once instead of several times
		if(istype(loaded_item, /obj/item/electrical_stasis_manifold))
			current_ESMs++
		else if(istype(loaded_item, /obj/item/organic_augur))
			current_augurs++
		else if(istype(loaded_item, /obj/item/mmi/posibrain))
			if(current_posibrain == "Artificial brain active")
				continue
			var/obj/item/mmi/posibrain/posi = loaded_item
			current_posibrain = "ERROR: Artificial brain inactive"
			if(posi.brainmob?.key && posi.brainmob.stat == CONSCIOUS && posi.brainmob.client)
				current_posibrain = "Artificial brain active"
		else if(istype(loaded_item, /obj/item/gun/energy/laser))
			if(current_lasergun == "Laser gun loaded")
				continue
			var/obj/item/gun/energy/laser/lasgun = loaded_item
			var/valid = FALSE
			for(var/obj/item/ammo_casing/ammotype in lasgun.ammo_type)
				if(initial(ammotype.harmful)) // No practice laser guns
					valid = TRUE
					break
			if(valid)
				current_lasergun = "Laser gun loaded"
		else if(loaded_item.get_item_credit_value())
			current_money += loaded_item.get_item_credit_value()
		else if(is_type_in_list(loaded_item, manipulator_plant_requirement.wanted_types))
			current_plants++

	// Capacitor requirements /////////////////////////////////////////////////////////////////
	data["current_ESMs"] = current_ESMs
	data["current_energy"] = get_power()

	// Matter bin requirements /////////////////////////////////////////////////////////////////
	data["current_augurs"] = current_augurs
	var/current_moles = my_gas.get_moles(/datum/gas/freon)
	data["current_moles"] = current_moles ? current_moles : 0

	// Scanner requirements /////////////////////////////////////////////////////////////////
	data["current_posibrain"] = current_posibrain
	var/current_reagents = list()
	var/current_reagents_num = list()
	for(var/datum/reagent/R in reagents.reagent_list)
		current_reagents += "[R.name]"
		current_reagents_num += R.volume
	data["current_reagents"] = current_reagents
	data["current_reagents_num"] = current_reagents_num

	// Laser requirements /////////////////////////////////////////////////////////////////
	data["current_lasergun"] = current_lasergun
	data["current_money"] = current_money

	// Manipulator requirements /////////////////////////////////////////////////////////////////
	data["current_plants"] = current_plants
	var/current_temp = my_gas.return_temperature()
	data["current_temp"] = current_temp ? current_temp : 0

	// Other vars /////////////////////////////////////////////////////////////////
	data["production_progress"] = production_progress

	return data

/obj/machinery/exp_part_fabricator/ui_static_data(mob/user)
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

/obj/machinery/exp_part_fabricator/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("tryPrint")
			var/tab = params["tab"]
			if(!isnum(tab))
				return
			return try_print(tab)
		/// Ejection ///
		if("ejectESM")
			eject_type(/obj/item/electrical_stasis_manifold)
			return TRUE
		if("ejectAugur")
			eject_type(/obj/item/organic_augur)
			return TRUE
		if("ejectPosi")
			eject_type(/obj/item/mmi/posibrain)
			return TRUE
		if("flushChems")
			reagents.remove_all(INFINITY)
			return TRUE
		if("ejectLaserGun")
			eject_type(/obj/item/gun/energy/laser)
			return TRUE
		if("ejectMoney")
			for(var/obj/item/item in contents)
				if(item.get_item_credit_value())
					eject_item(item)
			return TRUE
		if("ejectPlants")
			eject_type(manipulator_plant_requirement.wanted_types)
			return TRUE


/// Returns the power of the powernet of the APC of the room we're in
/obj/machinery/exp_part_fabricator/proc/get_power()
	var/area/my_area = get_area(src)
	if(!my_area)
		return 0
	var/obj/machinery/power/apc/my_apc = my_area.get_apc()
	if(!my_apc)
		return 0
	return my_apc.terminal?.powernet?.avail

/obj/machinery/exp_part_fabricator/proc/eject_type(list/eject_types)
	if(!islist(eject_types))
		eject_types = typecacheof(list(eject_types))
	if(!eject_types.len)
		return
	for(var/atom/movable/item in contents)
		if(is_type_in_typecache(item, eject_types))
			eject_item(item)

/obj/machinery/exp_part_fabricator/proc/eject_item(atom/movable/item)
	item.forceMove(get_step(drop_location(), WEST))
	adjust_item_drop_location(item)

/obj/machinery/exp_part_fabricator/proc/try_print(tab)
	if(!ISINTEGER(tab) || tab < FAB_CAPACITOR || tab > FAB_MANIPULATOR)
		return FALSE
	if(panel_open)
		return FALSE
	if(production_progress > 0)
		return FALSE
	printing = tab
	if(!is_satisfied())
		if(icon_state == "processing")
			icon_state = initial(icon_state)
			flick("up", src)
		balloon_alert_to_viewers("failed!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		printing = null
		use_power = IDLE_POWER_USE
		return FALSE
	production_progress = 1
	icon_state = "processing"
	flick("down", src)
	START_PROCESSING(SSobj, src)
	return TRUE

/obj/machinery/exp_part_fabricator/proc/is_satisfied()
	switch(printing)
		if(FAB_CAPACITOR)
			var/current_ESMs = 0
			for(var/obj/item/electrical_stasis_manifold/esm in contents)
				current_ESMs++
			if(current_ESMs < 1)
				return FALSE

			if(get_power() < capacitor_energy_requirement)
				return FALSE
			return TRUE

		if(FAB_MATTERBIN)
			var/current_augurs = 0
			for(var/obj/item/organic_augur/augur in contents)
				current_augurs++
			if(current_augurs < 1)
				return FALSE

			var/datum/gas_mixture/my_gas = return_air()
			var/current_moles = my_gas.get_moles(/datum/gas/freon)
			if(current_moles < matterbin_freon_moles_requirement)
				return FALSE
			return TRUE

		if(FAB_SCANNER)
			var/has_posi = FALSE
			for(var/obj/item/mmi/posibrain/posi in contents)
				has_posi = TRUE
				if(!posi.brainmob?.key || posi.brainmob.stat != CONSCIOUS || !posi.brainmob.client)
					return FALSE
			if(!has_posi)
				return FALSE

			for(var/datum/bounty/reagent/bounty in scanner_chemicals_requirement)
				if(!reagents.has_reagent(bounty.wanted_reagent.type, bounty.required_volume))
					return FALSE
			return TRUE

		if(FAB_LASER)
			var/has_lasergun = FALSE
			for(var/obj/item/gun/energy/laser/lasgun in contents)
				has_lasergun = TRUE
				for(var/obj/item/ammo_casing/ammotype in lasgun.ammo_type)
					if(!initial(ammotype.harmful)) // No practice laser guns
						return FALSE
			if(!has_lasergun)
				return FALSE

			var/current_money = 0
			for(var/obj/item/money in contents)
				current_money += money.get_item_credit_value()
			if(current_money < laser_money_requirement)
				return FALSE
			return TRUE

		if(FAB_MANIPULATOR)
			var/current_plants = 0
			for(var/selected_item in contents)
				if(is_type_in_list(selected_item, manipulator_plant_requirement.wanted_types))
					current_plants++
			if(current_plants < manipulator_plant_requirement.required_count)
				return FALSE

			var/datum/gas_mixture/my_gas = return_air()
			if(my_gas.return_temperature() < manipulator_temp_requirement)
				return FALSE
			return TRUE

/obj/machinery/exp_part_fabricator/process(delta_time)
	if(!printing)
		return PROCESS_KILL

	production_progress += production_speed * delta_time

	if(!is_satisfied())
		if(icon_state == "processing")
			icon_state = initial(icon_state)
			flick("up", src)
		balloon_alert_to_viewers("failed!")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		production_progress = 0
		printing = null
		use_power = IDLE_POWER_USE
		return PROCESS_KILL

	if(printing == FAB_CAPACITOR)
		use_power = ACTIVE_POWER_USE // Use 10MW while making capacitor

	if(production_progress >= 100)
		var/obj/item/stock_parts/printed
		switch(printing) // Print item and consume requirements
			if(FAB_CAPACITOR)
				printed = new /obj/item/stock_parts/capacitor/cubic
				// Consume electrical stasis manifold
				for(var/obj/item/electrical_stasis_manifold/ESM in contents)
					qdel(ESM)
					break
				// Energy is already consumed by active_power_use
			if(FAB_MATTERBIN)
				printed = new /obj/item/stock_parts/matter_bin/holding
				// Consume organic augur
				for(var/obj/item/organic_augur/augur in contents)
					qdel(augur)
					break
				var/datum/gas_mixture/my_gas = return_air()
				// Consume freon
				var/freon_amount = my_gas.get_moles(/datum/gas/freon)
				freon_amount -= matterbin_freon_moles_requirement
				my_gas.set_moles(/datum/gas/freon, max(freon_amount, 0))
			if(FAB_SCANNER)
				printed = new /obj/item/stock_parts/scanning_module/hexaphasic
				// Don't delete the posibrain!!!!!! We just needed to use its brain power for the process
				// Consume reagents
				for(var/datum/bounty/reagent/bounty in scanner_chemicals_requirement)
					reagents.remove_reagent(bounty.wanted_reagent.type, bounty.required_volume)
			if(FAB_LASER)
				printed = new /obj/item/stock_parts/micro_laser/quinthyper
				// Consume laser gun
				for(var/obj/item/gun/energy/laser/lasgun in contents)
					var/valid = FALSE
					for(var/obj/item/ammo_casing/ammotype in lasgun.ammo_type)
						if(initial(ammotype.harmful)) // No practice laser guns
							valid = TRUE
							break
					if(valid)
						qdel(lasgun)
						break

				// Consume money
				var/current_money = 0
				for(var/obj/item/money in contents)
					if(!money.get_item_credit_value())
						continue
					if(current_money < laser_money_requirement)
						if(istype(money, /obj/item/holochip))
							var/obj/item/holochip/holomoney = money
							if(holomoney.credits > laser_money_requirement - current_money)
								holomoney.credits -= laser_money_requirement - current_money
								holomoney.update_icon()
								break
						qdel(money)
					else
						break
					current_money += money.get_item_credit_value()
			if(FAB_MANIPULATOR)
				printed = new /obj/item/stock_parts/manipulator/planck
				// Consume plants
				var/current_plants = 0
				for(var/selected_item in contents)
					if(is_type_in_list(selected_item, manipulator_plant_requirement.wanted_types))
						if(current_plants < manipulator_plant_requirement.required_count)
							qdel(selected_item)
						else
							break
						current_plants++

				// Consume temperature
				var/datum/gas_mixture/my_gas = return_air()
				var/current_temp = my_gas.return_temperature()
				my_gas.set_temperature(max(current_temp - manipulator_temp_requirement, TCMB))
			else
				CRASH("Part fabricator tried to print unknown or null part: [printing]")

		balloon_alert_to_viewers("success!")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		icon_state = initial(icon_state)
		flick("up", src)
		printed.forceMove(drop_location())
		adjust_item_drop_location(printed)

		production_progress = 0
		printing = null
		use_power = IDLE_POWER_USE
		return PROCESS_KILL

#undef FAB_CAPACITOR
#undef FAB_MATTERBIN
#undef FAB_SCANNER
#undef FAB_LASER
#undef FAB_MANIPULATOR
