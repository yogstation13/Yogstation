//-----------------------------------------------
//--------------Engine Heaters-------------------
//This uses atmospherics, much like a thermomachine,
//but instead of changing temp, it stores plasma and uses
//it for the engine.
//-----------------------------------------------
/obj/machinery/atmospherics/components/unary/shuttle
	name = "shuttle atmospherics device"
	desc = "This does something to do with shuttle atmospherics"
	icon_state = "heater"
	icon = 'icons/turf/shuttle.dmi'

/obj/machinery/atmospherics/components/unary/shuttle/heater
	name = "engine heater"
	desc = "Directs energy into compressed particles in order to power an attached thruster."
	icon_state = "heater_pipe"
	var/icon_state_closed = "heater_pipe"
	var/icon_state_open = "heater_pipe_open"
	var/icon_state_off = "heater_pipe"
	idle_power_usage = 50
	circuit = /obj/item/circuitboard/machine/shuttle/heater

	density = TRUE
	max_integrity = 400
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 100, ACID = 30)
	layer = OBJ_LAYER
	showpipe = TRUE

	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY

	var/gas_type = /datum/gas/plasma
	var/efficiency_multiplier = 1
	var/gas_capacity = 0

/obj/machinery/atmospherics/components/unary/shuttle/heater/New()
	. = ..()
	GLOB.custom_shuttle_machines += src
	SetInitDirections()
	update_adjacent_engines()
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/heater/Destroy()
	. = ..()
	update_adjacent_engines()
	GLOB.custom_shuttle_machines -= src

/obj/machinery/atmospherics/components/unary/shuttle/heater/on_construction()
	..(dir, dir)
	SetInitDirections()
	update_adjacent_engines()

/obj/machinery/atmospherics/components/unary/shuttle/heater/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	SetInitDirections()
	var/obj/machinery/atmospherics/node = nodes[1]
	if(node)
		node.disconnect(src)
		nodes[1] = null
	if(!parents[1])
		return
	nullifyPipenet(parents[1])

	atmosinit()
	node = nodes[1]
	if(node)
		node.atmosinit()
		node.addMember(src)
	build_network()
	return TRUE

/obj/machinery/atmospherics/components/unary/shuttle/heater/RefreshParts()
	var/cap = 0
	var/eff = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		cap += M.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		eff += L.rating
	gas_capacity = 5000 * ((cap - 1) ** 2) + 1000
	efficiency_multiplier = round(((eff / 2) / 2.8) ** 2, 0.1)
	updateGasStats()

/obj/machinery/atmospherics/components/unary/shuttle/heater/examine(mob/user)
	. = ..()
	var/datum/gas_mixture/air_contents = airs[1]
	. += "The engine heater's gas dial reads [air_contents.get_moles(gas_type)] moles of gas.<br>" //This probably has issues [air_contents.get_moles]

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/updateGasStats()
	var/datum/gas_mixture/air_contents = airs[1]
	if(!air_contents)
		return
	air_contents.set_volume(gas_capacity)
	air_contents.set_temperature(T20C)
	if(gas_type)
		air_contents.set_moles(gas_type)

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/hasFuel(var/required)
	var/datum/gas_mixture/air_contents = airs[1]
	var/moles = air_contents.total_moles()
	return moles >= required

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/consumeFuel(var/amount)
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.remove(amount)
	return

/obj/machinery/atmospherics/components/unary/shuttle/heater/attackby(obj/item/I, mob/living/user, params)
	update_adjacent_engines()
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		return
	if(default_pry_open(I))
		return
	if(panel_open)
		if(default_change_direction_wrench(user, I))
			return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/shuttle/heater/proc/update_adjacent_engines()
	var/engine_turf
	switch(dir)
		if(NORTH)
			engine_turf = get_offset_target_turf(src, 0, -1)
		if(SOUTH)
			engine_turf = get_offset_target_turf(src, 0, 1)
		if(EAST)
			engine_turf = get_offset_target_turf(src, -1, 0)
		if(WEST)
			engine_turf = get_offset_target_turf(src, 1, 0)
	if(!engine_turf)
		return
	for(var/obj/machinery/shuttle/engine/E in engine_turf)
		E.check_setup()

//=============================
// Capacitor Bank
//=============================

/obj/machinery/power/engine_capacitor_bank
	name = "thruster capacitor bank"
	desc = "A capacitor bank that stores power for high-energy ion thrusters."
	icon_state = "heater_ion"
	icon = 'icons/turf/shuttle.dmi'
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/shuttle/capacitor_bank
	var/icon_state_closed = "heater_ion"
	var/icon_state_open = "heater_ion_open"
	var/icon_state_off = "heater_ion"
	var/stored_power = 0
	var/charge_rate = 20
	var/maximum_stored_power = 500

/obj/machinery/power/engine_capacitor_bank/Initialize(mapload)
	. = ..()
	GLOB.custom_shuttle_machines += src
	update_adjacent_engines()

/obj/machinery/power/engine_capacitor_bank/Destroy()
	GLOB.custom_shuttle_machines -= src
	. = ..()
	update_adjacent_engines()

/obj/machinery/power/engine_capacitor_bank/RefreshParts()
	maximum_stored_power = 0
	charge_rate = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		maximum_stored_power += C.rating * 200
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		charge_rate += L.rating * 20
	stored_power = min(stored_power, maximum_stored_power)

/obj/machinery/power/engine_capacitor_bank/examine(mob/user)
	. = ..()
	. += "The capacitor bank reads [stored_power]W of power stored.<br>"

/obj/machinery/power/engine_capacitor_bank/process(delta_time)
	take_power(delta_time)

/obj/machinery/power/engine_capacitor_bank/proc/take_power(delta_time)
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(!C)
		return
	var/datum/powernet/powernet = C.powernet
	if(!powernet)
		return
	//Consume power
	var/surplus = max(powernet.avail - powernet.load, 0)
	var/available_power = min(charge_rate * delta_time, surplus, maximum_stored_power - stored_power)
	if(available_power)
		powernet.load += available_power
		stored_power += available_power

//Annoying copy and paste because atmos machines aren't a component so engine heaters
//can't share from the same supertype
/obj/machinery/power/engine_capacitor_bank/proc/update_adjacent_engines()
	var/engine_turf
	switch(dir)
		if(NORTH)
			engine_turf = get_offset_target_turf(src, 0, -1)
		if(SOUTH)
			engine_turf = get_offset_target_turf(src, 0, 1)
		if(EAST)
			engine_turf = get_offset_target_turf(src, -1, 0)
		if(WEST)
			engine_turf = get_offset_target_turf(src, 1, 0)
	if(!engine_turf)
		return
	for(var/obj/machinery/shuttle/engine/E in engine_turf)
		E.check_setup()

/obj/machinery/power/engine_capacitor_bank/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, I))
		update_adjacent_engines()
		return
	if(default_pry_open(I))
		update_adjacent_engines()
		return
	if(panel_open)
		if(default_change_direction_wrench(user, I))
			update_adjacent_engines()
			return
	if(default_deconstruction_crowbar(I))
		update_adjacent_engines()
		return
	update_adjacent_engines()
	return ..()

/obj/machinery/power/engine_capacitor_bank/emp_act(severity)
	. = ..()
	stored_power = rand(0, stored_power)

/obj/machinery/power/engine_capacitor_bank/escape_pod
	name = "emergency thruster capacitor bank"
	desc = "A single-use, non-rechargable, high-capacitor capacitor bank used for getting shuttles away from a location fast."
	//Starts with maximum power
	stored_power = 600
	//Cannot be recharged
	charge_rate = 0
	//Provides 2 minutes of thrust when using burst thrusters
	maximum_stored_power = 600

/obj/machinery/power/engine_capacitor_bank/escape_pod/emp_act(severity)
	return

/obj/machinery/power/engine_capacitor_bank/escape_pod/RefreshParts()
	return
