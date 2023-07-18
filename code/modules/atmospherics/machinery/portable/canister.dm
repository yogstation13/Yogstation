#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/obj/atmospherics/canister.dmi'
	icon_state = "hazard"
	density = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 1.4
	light_on = FALSE
	var/valve_open = FALSE
	var/obj/machinery/atmospherics/components/binary/passive_gate/pump
	var/release_log = ""

	volume = 1000
	var/filled = 0.5
	var/gas_type
	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)

	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, BIO = 100, RAD = 100, FIRE = 80, ACID = 50)
	max_integrity = 250
	integrity_failure = 100
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	var/starter_temp
	// Prototype vars
	var/prototype = FALSE
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	var/restricted = FALSE
	req_access = list()

	//list of canister types for relabeling
	var/static/list/label2types = list(
		"generic" = /obj/machinery/portable_atmospherics/canister/generic,
		"generic striped" = /obj/machinery/portable_atmospherics/canister/generic/stripe,
		"generic hazard" = /obj/machinery/portable_atmospherics/canister/generic/hazard,
		"caution" = /obj/machinery/portable_atmospherics/canister,
		"danger" = /obj/machinery/portable_atmospherics/canister/fusion_test,
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/toxins,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"nitrium" = /obj/machinery/portable_atmospherics/canister/nitrium,
		"bz" = /obj/machinery/portable_atmospherics/canister/bz,
		"air" = /obj/machinery/portable_atmospherics/canister/air,
		"water vapor" = /obj/machinery/portable_atmospherics/canister/water_vapor,
		"tritium" = /obj/machinery/portable_atmospherics/canister/tritium,
		"hyper-noblium" = /obj/machinery/portable_atmospherics/canister/nob,
		"anti-noblium" = /obj/machinery/portable_atmospherics/canister/antinoblium,
		"pluoxium" = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"miasma" = /obj/machinery/portable_atmospherics/canister/miasma,
		"dilithium" = /obj/machinery/portable_atmospherics/canister/dilithium,
		"freon" = /obj/machinery/portable_atmospherics/canister/freon,
		"hydrogen" = /obj/machinery/portable_atmospherics/canister/hydrogen,
		"healium" = /obj/machinery/portable_atmospherics/canister/healium,
		"pluonium" = /obj/machinery/portable_atmospherics/canister/pluonium,
		"zauker" = /obj/machinery/portable_atmospherics/canister/zauker,
		"halon" = /obj/machinery/portable_atmospherics/canister/halon,
		"hexane" = /obj/machinery/portable_atmospherics/canister/hexane
	)

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	if(!allowed(user))
		to_chat(user, span_warning("Error - Unauthorized User"))
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, 1)
		return
	..()

/obj/machinery/portable_atmospherics/canister/generic
	icon_state = "generic"

/obj/machinery/portable_atmospherics/canister/generic/stripe
	icon_state = "generic-stripe"

/obj/machinery/portable_atmospherics/canister/generic/hazard
	icon_state = "generic-hazard"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Nitrogen canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	icon_state = "nitrogen"
	gas_type = /datum/gas/nitrogen

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Oxygen canister"
	desc = "Oxygen. Necessary for human life."
	icon_state = "oxygen"
	gas_type = /datum/gas/oxygen

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	icon_state = "carbon"
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/portable_atmospherics/canister/toxins
	name = "Plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	icon_state = "plasma"
	gas_type = /datum/gas/plasma

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	desc = "BZ, a powerful hallucinogenic nerve agent."
	icon_state = "bz"
	gas_type = /datum/gas/bz

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Nitrous oxide canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	icon_state = "nitrous"
	gas_type = /datum/gas/nitrous_oxide

/obj/machinery/portable_atmospherics/canister/air
	name = "Air canister"
	desc = "Pre-mixed air."
	icon_state = "air"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Tritium canister"
	desc = "Tritium. Inhalation might cause irradiation."
	icon_state = "tritium"
	gas_type = /datum/gas/tritium

/obj/machinery/portable_atmospherics/canister/nob
	name = "Hyper-noblium canister"
	desc = "Hyper-Noblium. More noble than all other gases."
	icon_state = "hypno"
	gas_type = /datum/gas/hypernoblium

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Nitrium canister"
	desc = "Nitrium gas. Feels great 'til the acid eats your lungs."
	icon_state = "nitrium"
	gas_type = /datum/gas/nitrium

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Pluoxium canister"
	desc = "Pluoxium. Like oxygen, but more bang for your buck."
	icon_state = "pluoxium"
	gas_type = /datum/gas/pluoxium

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Water vapor canister"
	desc = "Water vapor. We get it, you vape."
	icon_state = "water"
	gas_type = /datum/gas/water_vapor
	filled = 1

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Miasma canister"
	desc = "Foul miasma. Even the canister reeks of fetid refuse."
	icon_state = "miasma"
	gas_type = /datum/gas/miasma
	filled = 1

/obj/machinery/portable_atmospherics/canister/dilithium
	name = "Dilithium canister"
	desc = "A gas produced from dilithium crystal."
	icon_state = "dilithium"
	gas_type = /datum/gas/dilithium

/obj/machinery/portable_atmospherics/canister/freon
	name = "Freon canister"
	desc = "Freon. Can absorb heat"
	icon_state = "freon"
	gas_type = /datum/gas/freon
	filled = 1

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Hydrogen canister"
	desc = "Hydrogen, highly flammable"
	icon_state = "h2"
	gas_type = /datum/gas/hydrogen
	filled = 1

/obj/machinery/portable_atmospherics/canister/healium
	name = "Healium canister"
	desc = "Healium, causes deep sleep"
	icon_state = "healium"
	gas_type = /datum/gas/healium
	filled = 1

/obj/machinery/portable_atmospherics/canister/pluonium
	name = "Pluonium canister"
	desc = "Pluonium, reacts differently with various gases"
	icon_state = "pluonium"
	gas_type = /datum/gas/pluonium
	filled = 1

/obj/machinery/portable_atmospherics/canister/halon
	name = "Halon canister"
	desc = "Halon, remove oxygen from high temperature fires and cool down the area"
	icon_state = "halon"
	gas_type = /datum/gas/halon
	filled = 1

/obj/machinery/portable_atmospherics/canister/hexane
	name = "Hexane canister"
	desc = "hexane, highly flammable."
	icon_state = "hexane"
	gas_type = /datum/gas/hexane
	filled = 1

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Zauker canister"
	desc = "Zauker, highly toxic"
	icon_state = "zauker"
	gas_type = /datum/gas/zauker
	filled = 1

/obj/machinery/portable_atmospherics/canister/antinoblium
	name = "Antinoblium canister"
	desc = "Antinoblium, we still don't know what it does, but it sells for a lot"
	icon_state = "antino"
	gas_type = /datum/gas/antinoblium
	filled = 1

/obj/machinery/portable_atmospherics/canister/proc/get_time_left()
	if(timing)
		. = round(max(0, valve_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/portable_atmospherics/canister/proc/set_active()
	timing = !timing
	if(timing)
		valve_timer = world.time + (timer_set * 10)
	update_appearance(UPDATE_ICON)

/obj/machinery/portable_atmospherics/canister/proto
	name = "prototype canister"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "proto"

/obj/machinery/portable_atmospherics/canister/proto/default
	name = "prototype canister"
	desc = "The best way to fix an atmospheric emergency... or the best way to introduce one."
	volume = 5000
	max_integrity = 300
	temperature_resistance = 2000 + T0C
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	prototype = TRUE

/obj/machinery/portable_atmospherics/canister/proto/default/oxygen
	name = "prototype canister"
	desc = "A prototype canister for a prototype bike, what could go wrong?"
	gas_type = /datum/gas/oxygen
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2


/obj/machinery/portable_atmospherics/canister/New(loc, datum/gas_mixture/existing_mixture)
	..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()
	pump = new(src, FALSE)
	pump.on = TRUE
	pump.stat = 0
	SSair.add_to_rebuild_queue(pump)

/obj/machinery/portable_atmospherics/canister/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/machinery/portable_atmospherics/canister/Destroy()
	qdel(pump)
	pump = null
	return ..()

/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type)
		if(starter_temp)
			air_contents.set_temperature(starter_temp)
		air_contents.set_moles(gas_type, (maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	if(starter_temp)
		air_contents.set_temperature(starter_temp)
	air_contents.set_moles(/datum/gas/oxygen, (O2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))
	air_contents.set_moles(/datum/gas/nitrogen, (N2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/update_icon_state()
	if(stat & BROKEN)
		icon_state = "[initial(icon_state)]-1"
	return ..()

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()
	if(stat & BROKEN)
		return
	if(valve_open)
		. += "can-open"
	if(holding)
		. += "can-tank"
	if(connected_port)
		. += "can-connector"

	var/light_state = get_pressure_state(air_contents?.return_pressure())
	if(light_state) //happens when pressure is below 10kpa which means no light
		. += mutable_appearance(icon, light_state)

///return the icon_state component for the canister's indicator light based on its current pressure reading
/obj/machinery/portable_atmospherics/canister/proc/get_pressure_state(air_pressure)
	switch(air_pressure)
		if((9100) to INFINITY)
			return "can-oF"
		if((40 * ONE_ATMOSPHERE) to (9100)) //volume pump max
			return "can-o6"
		if((30 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			return "can-o5"
		if((20 * ONE_ATMOSPHERE) to (30 * ONE_ATMOSPHERE))
			return "can-o4"
		if((10 * ONE_ATMOSPHERE) to (20 * ONE_ATMOSPHERE))
			return "can-o3"
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			return "can-o2"
		if((10) to (5 * ONE_ATMOSPHERE))
			return "can-o1"
		else
			return "can-o0"

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(stat & BROKEN)
		if(!I.tool_start_check(user, amount=0))
			return TRUE
		to_chat(user, span_notice("You begin cutting [src] apart..."))
		if(I.use_tool(src, user, 30, volume=50))
			deconstruct(TRUE)
	else
		to_chat(user, span_notice("You cannot slice [src] apart when it isn't broken."))

	return TRUE

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)
	air_update_turf()

	obj_break()
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		usr.put_in_hands(holding)
		holding = null

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
		if(close_valve)
			valve_open = FALSE
			update_appearance(UPDATE_ICON)
			investigate_log("Valve was <b>closed</b> by [key_name(user)].<br>", INVESTIGATE_ATMOS)
		else if(valve_open && holding)
			investigate_log("[key_name(user)] started a transfer into [holding].<br>", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()
	if(stat & BROKEN)
		return PROCESS_KILL
	if(timing && valve_timer < world.time)
		valve_open = !valve_open
		timing = FALSE
	if(valve_open)
		var/turf/T = get_turf(src)
		pump.airs[1] = air_contents
		pump.airs[2] = holding ? holding.air_contents : T.return_air()
		pump.target_pressure = release_pressure

		pump.process_atmos() // Pump gas.
		if(!holding)
			air_update_turf() // Update the environment if needed.
	else
		pump.airs[1] = null
		pump.airs[2] = null

	update_appearance(UPDATE_ICON)

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_static_data(mob/user)
	return list(
		"defaultReleasePressure" = round(CAN_DEFAULT_RELEASE_PRESSURE),
		"minReleasePressure" = round(can_min_release_pressure),
		"maxReleasePressure" = round(can_max_release_pressure),
		"holdingTankLeakPressure" = round(TANK_LEAK_PRESSURE),
		"holdingTankFragPressure" = round(TANK_FRAGMENT_PRESSURE)
	)

/obj/machinery/portable_atmospherics/canister/ui_data()
	. = list(
		"portConnected" = !!connected_port,
		"tankPressure" = round(air_contents.return_pressure()),
		"releasePressure" = round(release_pressure),
		"valveOpen" = !!valve_open,
		"isPrototype" = !!prototype,
		"hasHoldingTank" = !!holding
	)

	if (prototype)
		. += list(
			"restricted" = restricted,
			"timing" = timing,
			"time_left" = get_time_left(),
			"timer_set" = timer_set,
			"timer_is_not_default" = timer_set != default_timer_set,
			"timer_is_not_min" = timer_set != minimum_timer_set,
			"timer_is_not_max" = timer_set != maximum_timer_set
		)

	if (holding)
		. += list(
			"holdingTank" = list(
				"name" = holding.name,
				"tankPressure" = round(holding.air_contents.return_pressure())
			)
		)

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("relabel")
			var/label = input("New canister label:", name) as null|anything in label2types
			if(label && !..())
				var/newtype = label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
		if("restricted")
			restricted = !restricted
			if(restricted)
				req_access = list(ACCESS_ENGINE)
			else
				req_access = list()
				. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
				investigate_log(logmsg, INVESTIGATE_ATMOS)
				if(!holding)
					var/list/danger = list()
					for(var/id in air_contents.get_gases())
						if(!GLOB.meta_gas_info[id][META_GAS_DANGER])
							continue
						if(air_contents.get_moles(id) > (GLOB.meta_gas_info[id][META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
							danger[GLOB.meta_gas_info[id][META_GAS_NAME]] = air_contents.get_moles(id) //ex. "plasma" = 20

					if(danger.len)
						message_admins("[ADMIN_LOOKUPFLW(usr)] opened a canister that contains the following at [ADMIN_VERBOSEJMP(src)]:")
						log_admin("[key_name(usr)] opened a canister that contains the following at [AREACOORD(src)]:")
						investigate_log("Contents:", INVESTIGATE_ATMOS)
						for(var/name in danger)
							var/msg = "[name]: [danger[name]] moles."
							log_admin(msg)
							message_admins(msg)
							investigate_log(msg, INVESTIGATE_ATMOS)
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
				investigate_log(logmsg, INVESTIGATE_ATMOS)
			release_log += logmsg
			. = TRUE
		if("timer")
			var/change = params["change"]
			switch(change)
				if("reset")
					timer_set = default_timer_set
				if("decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
				if("increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
				if("input")
					var/user_input = input(usr, "Set time to valve toggle.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = clamp(N,minimum_timer_set,maximum_timer_set)
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] removed [holding] from [src] with valve still open at [ADMIN_VERBOSEJMP(src)] releasing contents into the [span_boldannounce("air")].")
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transferring into the [span_boldannounce("air")].", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE
	update_appearance(UPDATE_ICON)

/obj/machinery/portable_atmospherics/canister/examine(mob/dead/observer/user)
	if(istype(user))
		analyzer_act(user, src)
	return ..()

/* yog- ADMEME CANISTERS */

/// Canister 1 Kelvin below the fusion point. Is highly unoptimal, do not spawn to start fusion, only good for testing low instability mixes.
/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "Fusion Test Canister"
	desc = "This should never be spawned in game."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.set_moles(/datum/gas/tritium, 10)
	air_contents.set_moles(/datum/gas/plasma, 500)
	air_contents.set_moles(/datum/gas/hydrogen, 500)
	air_contents.set_moles(/datum/gas/nitrous_oxide, 100)
	air_contents.set_temperature(10000)

/// Canister 1 Kelvin below the fusion point. Contains far too much plasma. Only good for adding more fuel to ongoing fusion reactions.
 /obj/machinery/portable_atmospherics/canister/fusion_test_2
	name = "Fusion Test Canister"
	desc = "This should never be spawned in game."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test_2/create_gas()
	air_contents.set_moles(/datum/gas/tritium, 10)
	air_contents.set_moles(/datum/gas/plasma, 15000)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 1500)
	air_contents.set_moles(/datum/gas/nitrous_oxide, 100)
	air_contents.set_temperature(9999)

/// Canister at the perfect conditions to start and continue fusion for a long time.
/obj/machinery/portable_atmospherics/canister/fusion_test_3
	name = "Fusion Test Canister"
	desc = "This should never be spawned in game."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test_3/create_gas()
	air_contents.set_moles(/datum/gas/tritium, 1000)
	air_contents.set_moles(/datum/gas/plasma, 4500)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 1500)
	air_contents.set_temperature(1000000)

/** Canister for testing dilithium based cold fusion. Use fusion_test_3 if you don't know what you are doing.
 This canister is significantly harder to fix if shit goes wrong.*/
/obj/machinery/portable_atmospherics/canister/fusion_test_4
	name = "Cold Fusion Test Canister"
	desc = "This should never be spawned in game. Contains dilithium for cold fusion."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test_4/create_gas()
	air_contents.set_moles(/datum/gas/tritium, 1000)
	air_contents.set_moles(/datum/gas/plasma, 4500)
	air_contents.set_moles(/datum/gas/carbon_dioxide, 1500)
	air_contents.set_moles(/datum/gas/dilithium, 2000)
	air_contents.set_temperature(10000)

/// A canister that is 1 Kelvin away from doing the stimball reaction.
/obj/machinery/portable_atmospherics/canister/stimball_test
	name = "Stimball Test Canister"
	desc = "This should never be spawned in game except for testing purposes."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/stimball_test/create_gas()
	air_contents.set_moles(/datum/gas/nitrium, 1000)
	air_contents.set_moles(/datum/gas/plasma, 1000)
	air_contents.set_moles(/datum/gas/pluoxium, 1000)
	air_contents.set_temperature(FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1)
