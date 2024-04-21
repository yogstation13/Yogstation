#define CAN_DEFAULT_RELEASE_PRESSURE (ONE_ATMOSPHERE)

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon = 'icons/obj/atmospherics/canisters.dmi'
	icon_state = "#mapme"
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#ffff00#000000"
	density = TRUE
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
	var/starter_temp = T20C
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

	var/icon/canister_overlay_file = 'icons/obj/atmospherics/canisters.dmi'

	//list of canister types for relabeling
	var/static/list/label2types = list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/plasma,
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

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Nitrogen canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#1b6d1b"
	gas_type = GAS_N2

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Oxygen canister"
	desc = "Oxygen. Necessary for human life."
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"
	gas_type = GAS_O2

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"
	gas_type = GAS_CO2

/obj/machinery/portable_atmospherics/canister/plasma
	name = "Plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#f63400#000000"
	gas_type = GAS_PLASMA

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	desc = "BZ, a powerful hallucinogenic nerve agent."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#f63800#ffffff"
	gas_type = GAS_BZ

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Nitrous oxide canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#1b6d1b#ffffff"
	gas_type = GAS_NITROUS

/obj/machinery/portable_atmospherics/canister/air
	name = "Air canister"
	desc = "Pre-mixed air."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Tritium canister"
	desc = "Tritium. Inhalation might cause irradiation."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#d41010#000000"
	gas_type = GAS_TRITIUM

/obj/machinery/portable_atmospherics/canister/nob
	name = "Hyper-noblium canister"
	desc = "Hyper-Noblium. More noble than all other gases."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"
	gas_type = GAS_HYPERNOB

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Nitrium canister"
	desc = "Nitrium gas. Feels great 'til the acid eats your lungs."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"
	gas_type = GAS_NITRIUM

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Pluoxium canister"
	desc = "Pluoxium. Like oxygen, but more bang for your buck."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#2786e5#000000"
	gas_type = GAS_PLUOXIUM

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Water vapor canister"
	desc = "Water vapor. We get it, you vape."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#17c3c7#ffffff"
	gas_type = GAS_H2O
	filled = 1

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Miasma canister"
	desc = "Foul miasma. Even the canister reeks of fetid refuse."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#d35ecb#943233"
	gas_type = GAS_MIASMA
	filled = 1

/obj/machinery/portable_atmospherics/canister/dilithium
	name = "Dilithium canister"
	desc = "A gas produced from dilithium crystal."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#ff83c0#f7d5d3"
	gas_type = GAS_DILITHIUM

/obj/machinery/portable_atmospherics/canister/freon
	name = "Freon canister"
	desc = "Freon. Can absorb heat."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#68d7ef#ffffff"
	gas_type = GAS_FREON
	filled = 1

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Hydrogen canister"
	desc = "Hydrogen, highly flammable."
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#d41010#ffffff"
	gas_type = GAS_H2
	filled = 1

/obj/machinery/portable_atmospherics/canister/healium
	name = "Healium canister"
	desc = "Healium, causes deep sleep."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#ff0e00"
	gas_type = GAS_HEALIUM
	filled = 1

/obj/machinery/portable_atmospherics/canister/pluonium
	name = "Pluonium canister"
	desc = "Pluonium, reacts differently with various gases."
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"
	gas_type = GAS_PLUONIUM
	filled = 1

/obj/machinery/portable_atmospherics/canister/halon
	name = "Halon canister"
	desc = "Halon, remove oxygen from high temperature fires and cool down the area."
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"
	gas_type = GAS_HALON
	filled = 1

/obj/machinery/portable_atmospherics/canister/hexane
	name = "Hexane canister"
	desc = "Hexane, highly flammable, what a shame."

	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b608b#fd89fd"
	gas_type = GAS_HEXANE
	filled = 1

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Zauker canister"
	desc = "Zauker, highly toxic"
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009a00#006600"
	gas_type = GAS_ZAUKER
	filled = 1

/obj/machinery/portable_atmospherics/canister/antinoblium
	name = "Antinoblium canister"
	desc = "Antinoblium, we still don't know what it does, but it sells for a lot."
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#000000#790000"
	gas_type = GAS_ANTINOB
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
	greyscale_config = /datum/greyscale_config/prototype_canister
	greyscale_colors = "#ffffff#a50021#ffffff"

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
	gas_type = GAS_O2
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2


/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
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
		if(air_contents.return_volume() == 0)
			CRASH("Air content volume is zero, this shouldn't be the case volume is: [volume]!")
		if(air_contents.return_temperature() == 0)
			CRASH("Air content temperature is zero, this shouldn't be the case!")
		if (gas_type)
			air_contents.set_moles(gas_type, (maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	if(air_contents.return_volume() == 0)
		CRASH("Air content volume is zero, this shouldn't be the case volume is: [volume]!")
	if(air_contents.return_temperature() == 0)
		CRASH("Air content temperature is zero, this shouldn't be the case!")
	air_contents.set_temperature(starter_temp)
	air_contents.set_moles(GAS_O2, (O2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))
	air_contents.set_moles(GAS_N2, (N2STANDARD * maximum_pressure * filled) * air_contents.return_volume() / (R_IDEAL_GAS_EQUATION * air_contents.return_temperature()))

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()
	if(stat & BROKEN)
		. += mutable_appearance(canister_overlay_file, "broken")
		return
	if(valve_open)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-tank")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")

	var/light_state = get_pressure_state(air_contents?.return_pressure())
	if(light_state) //happens when pressure is below 10kpa which means no light
		. += mutable_appearance(canister_overlay_file, light_state)

///return the icon_state component for the canister's indicator light based on its current pressure reading
/obj/machinery/portable_atmospherics/canister/proc/get_pressure_state(air_pressure)
	if(air_pressure < 10)
		return null
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

/obj/machinery/portable_atmospherics/canister/atom_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)

	atom_break()
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		usr.put_in_hands(holding)
		holding = null

	animate(src, 0.5 SECONDS, transform=turn(transform, 90), easing=BOUNCE_EASING)

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

	// Handle gas transfer.
	if(valve_open)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/target_air = holding ? holding.air_contents : T.return_air()

		air_contents.release_gas_to(target_air, release_pressure)
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
			var/label = tgui_input_list(usr, "New canister label", "Canister", label2types)
			if(isnull(label))
				return
			if(!..())
				var/newtype =  label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					investigate_log("was relabelled to [initial(replacement.name)] by [key_name(usr)].", INVESTIGATE_ATMOS)
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
					set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))
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
						if(!(GLOB.gas_data.flags[id] & GAS_FLAG_DANGEROUS))
							continue
						if(air_contents.get_moles(id) > (GLOB.gas_data.visibility[id] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
							danger[GLOB.gas_data.names[id]] = air_contents.get_moles(id) //ex. "plasma" = 20
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

/obj/machinery/portable_atmospherics/canister/fusion
	name = "Fusion Canister"
	desc = "A violent mix of gases resulting in a fusion reaction inside the canister. <br>\
			A note on the side reads: \"DANGER: DO NOT OPEN\""
	icon_state = "danger"

/* yog- ADMEME CANISTERS */

/// Canister 1 Kelvin below the fusion point. Is highly unoptimal, do not spawn to start fusion, only good for testing low instability mixes.
/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "Fusion Test Canister"
	desc = "This should never be spawned in game."
	icon_state = "danger"

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 10)
	air_contents.set_moles(GAS_PLASMA, 500)
	air_contents.set_moles(GAS_CO2, 500)
	air_contents.set_moles(GAS_NITROUS, 100)
	air_contents.set_temperature(FUSION_TEMPERATURE_THRESHOLD)

/// Canister 1 Kelvin below the fusion point. Contains far too much plasma. Only good for adding more fuel to ongoing fusion reactions.
 /obj/machinery/portable_atmospherics/canister/fusion_test_2
	name = "Fusion Test Canister"
	desc = "This should never be spawned in game."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test_2/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 10)
	air_contents.set_moles(GAS_PLASMA, 15000)
	air_contents.set_moles(GAS_CO2, 1500)
	air_contents.set_moles(GAS_NITROUS, 100)
	air_contents.set_temperature(FUSION_TEMPERATURE_THRESHOLD - 1)

/// Canister at the perfect conditions to start and continue fusion for a long time.
/obj/machinery/portable_atmospherics/canister/fusion_test_3
	name = "Fusion Test Canister"
	desc = "This should never be spawned in game."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test_3/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 1000)
	air_contents.set_moles(GAS_PLASMA, 4500)
	air_contents.set_moles(GAS_CO2, 1500)
	air_contents.set_temperature(1000000)

/** Canister for testing dilithium based cold fusion. Use fusion_test_3 if you don't know what you are doing.
 This canister is significantly harder to fix if shit goes wrong.*/
/obj/machinery/portable_atmospherics/canister/fusion_test_4
	name = "Cold Fusion Test Canister"
	desc = "This should never be spawned in game. Contains dilithium for cold fusion."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/fusion_test_4/create_gas()
	air_contents.set_moles(GAS_TRITIUM, 1000)
	air_contents.set_moles(GAS_PLASMA, 4500)
	air_contents.set_moles(GAS_CO2, 1500)
	air_contents.set_moles(GAS_DILITHIUM, 2000)
	air_contents.set_temperature(FUSION_TEMPERATURE_THRESHOLD - 1)

/// A canister that is 1 Kelvin away from doing the stimball reaction.
/obj/machinery/portable_atmospherics/canister/stimball_test
	name = "Stimball Test Canister"
	desc = "This should never be spawned in game except for testing purposes."
	icon_state = "danger"
/obj/machinery/portable_atmospherics/canister/stimball_test/create_gas()
	air_contents.set_moles(GAS_NITRIUM, 1000)
	air_contents.set_moles(GAS_PLASMA, 1000)
	air_contents.set_moles(GAS_PLUOXIUM, 1000)
	air_contents.set_temperature(FIRE_MINIMUM_TEMPERATURE_TO_EXIST-1)
