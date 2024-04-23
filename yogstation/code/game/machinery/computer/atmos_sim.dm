/// Bomb simulator mode
#define ATMOS_SIM_MODE_BOMB 1
/// Tank reaction mode
#define ATMOS_SIM_MODE_TANK 2
/// Maximum number of times the simulator will react
#define ATMOS_SIM_MAX_REACTIONS 10

/obj/machinery/computer/atmos_sim
	name = "atmospherics simulator"
	desc = "Used to simulate various atmospherics events"
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_sim
	var/mode = ATMOS_SIM_MODE_BOMB
	var/datum/gas_mixture/tank_mix
	var/datum/gas_mixture/bomb_1
	var/datum/gas_mixture/bomb_2
	var/datum/gas_mixture/bomb_result
	var/list/bomb_explosion_size = null

/obj/machinery/computer/atmos_sim/Initialize(mapload)
	tank_mix = new(CELL_VOLUME)
	tank_mix.set_temperature(T20C)
	bomb_1 = new(70)
	bomb_1.set_temperature(T20C)
	bomb_2 = new(70)
	bomb_2.set_temperature(T20C)
	bomb_result = new(70)
	bomb_result.set_temperature(T20C)
	return ..()

/obj/machinery/computer/atmos_sim/proc/simulate_bomb()
	bomb_explosion_size = null
	bomb_result.clear()
	bomb_result.set_volume(bomb_1.return_volume() + bomb_2.return_volume())
	bomb_result.merge(bomb_1)
	bomb_result.merge(bomb_2)
	for(var/I in 1 to ATMOS_SIM_MAX_REACTIONS)
		bomb_result.react()
		if(bomb_result.return_pressure() >= TANK_FRAGMENT_PRESSURE)
			// Explosion!
			bomb_result.react()
			bomb_result.react()
			bomb_result.react()
			var/range = (bomb_result.return_pressure()-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
			bomb_explosion_size = list(round(range*0.25), round(range*0.5), round(range))
			break

/obj/machinery/computer/atmos_sim/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if(!ui)
		ui = new(user, src, "AtmosSimulator", name)
		ui.open()

/obj/machinery/computer/atmos_sim/ui_data(mob/user)
	var/list/data = list()

	switch(mode)
		// Tank Reaction mode
		if(ATMOS_SIM_MODE_TANK)
			data["tank_mix"] = REF(tank_mix)

			var/tank_mix_pressure = tank_mix.return_pressure()
			var/tank_mix_moles = tank_mix.total_moles()
			var/list/tank_mix_gases = list()
			for(var/gas_id in tank_mix.get_gases())
				tank_mix_gases.Add(list(list(
					"id" = gas_id,
					"moles" = tank_mix.get_moles(gas_id),
					"pressure" = tank_mix_moles ? (tank_mix.get_moles(gas_id) / tank_mix_moles) * tank_mix_pressure : 0,
				)))
			data["tank_mix_gases"] = tank_mix_gases
			data["tank_mix_pressure"] = tank_mix_pressure
			data["tank_mix_moles"] = tank_mix_moles
			data["tank_mix_volume"] = tank_mix.return_volume()
			data["tank_mix_temperature"] = tank_mix.return_temperature()
		// Bomb Simulator mode
		if(ATMOS_SIM_MODE_BOMB)
			data["bomb_1"] = REF(bomb_1)
			data["bomb_2"] = REF(bomb_2)

			var/bomb_1_pressure = bomb_1.return_pressure()
			var/bomb_1_moles = bomb_1.total_moles()
			var/list/bomb_1_gases = list()
			for(var/gas_id in bomb_1.get_gases())
				bomb_1_gases.Add(list(list(
					"id" = gas_id,
					"moles" = bomb_1.get_moles(gas_id),
					"pressure" = bomb_1_moles ? (bomb_1.get_moles(gas_id) / bomb_1_moles) * bomb_1_pressure : 0,
				)))
			data["bomb_1_gases"] = bomb_1_gases
			data["bomb_1_pressure"] = bomb_1_pressure
			data["bomb_1_moles"] = bomb_1_moles
			data["bomb_1_volume"] = bomb_1.return_volume()
			data["bomb_1_temperature"] = bomb_1.return_temperature()

			var/bomb_2_pressure = bomb_2.return_pressure()
			var/bomb_2_moles = bomb_2.total_moles()
			var/list/bomb_2_gases = list()
			for(var/gas_id in bomb_2.get_gases())
				bomb_2_gases.Add(list(list(
					"id" = gas_id,
					"moles" = bomb_2.get_moles(gas_id),
					"pressure" = bomb_2_moles ? (bomb_2.get_moles(gas_id) / bomb_2_moles) * bomb_2_pressure : 0,
				)))
			data["bomb_2_gases"] = bomb_2_gases
			data["bomb_2_pressure"] = bomb_2_pressure
			data["bomb_2_moles"] = bomb_2_moles
			data["bomb_2_volume"] = bomb_2.return_volume()
			data["bomb_2_temperature"] = bomb_2.return_temperature()

			var/bomb_result_pressure = bomb_result.return_pressure()
			var/bomb_result_moles = bomb_result.total_moles()
			var/list/bomb_result_gases = list()
			for(var/gas_id in bomb_result.get_gases())
				bomb_result_gases.Add(list(list(
					"id" = gas_id,
					"moles" = bomb_result.get_moles(gas_id),
					"pressure" = bomb_result_moles ? (bomb_result.get_moles(gas_id) / bomb_result_moles) * bomb_result_pressure : 0,
				)))
			data["bomb_result_gases"] = bomb_result_gases
			data["bomb_result_pressure"] = bomb_result_pressure
			data["bomb_result_moles"] = bomb_result_moles
			data["bomb_result_volume"] = bomb_result.return_volume()
			data["bomb_result_temperature"] = bomb_result.return_temperature()

			data["bomb_explosion_size"] = bomb_explosion_size?.Copy()

	data["mode"] = mode
	return data

/obj/machinery/computer/atmos_sim/ui_static_data(mob/user)
	var/list/data = list()
	data["gas_data"] = list()
	for(var/gas_id in GLOB.gas_data.ids)
		data["gas_data"] += list(list(
			"id" = gas_id,
			"label" = GLOB.gas_data.labels[gas_id],
			"ui_color" = GLOB.gas_data.ui_colors[gas_id],
		))
	return data

/obj/machinery/computer/atmos_sim/ui_act(action, list/params)
	if(..())
		return TRUE
	switch(action)
		if("set_mode")
			mode = params["mode"]
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("set_volume")
			var/datum/gas_mixture/tank = locate(params["tank"])
			tank.set_volume(params["volume"])
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("set_temperature")
			var/datum/gas_mixture/tank = locate(params["tank"])
			tank.set_temperature(params["temperature"])
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("set_moles")
			var/datum/gas_mixture/tank = locate(params["tank"])
			tank.set_moles(params["gas"], params["moles"])
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("set_pressure")
			var/datum/gas_mixture/tank = locate(params["tank"])
			tank.set_moles(params["gas"], params["pressure"] * tank.return_volume() / (tank.return_temperature() * R_IDEAL_GAS_EQUATION))
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("remove_gas")
			var/datum/gas_mixture/tank = locate(params["tank"])
			tank.set_moles(params["gas"], 0)
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("add_gas")
			var/datum/gas_mixture/tank = locate(params["tank"])
			var/new_gas = tgui_input_list(usr, "Add new gas", "Atmospheric Simulator", GLOB.gas_data.ids)
			if(!new_gas)
				return
			tank.set_moles(new_gas, round(ONE_ATMOSPHERE) * tank.return_volume() / (tank.return_temperature() * R_IDEAL_GAS_EQUATION))
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE
		if("react")
			tank_mix.react()
			return TRUE
		if("clear")
			var/datum/gas_mixture/tank = locate(params["tank"])
			tank.clear()
			if(mode == ATMOS_SIM_MODE_BOMB)
				simulate_bomb()
			return TRUE

#undef ATMOS_SIM_MODE_BOMB
#undef ATMOS_SIM_MODE_TANK
#undef ATMOS_SIM_MAX_REACTIONS
