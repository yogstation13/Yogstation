#define ATMOS_SIM_MODE_BOMB 1
#define ATMOS_SIM_MODE_TANK 2
#define ATMOS_SIM_MODE_COUNT 2

/obj/machinery/computer/atmos_sim
	name = "atmospherics simulator"
	desc = "Used to simulate various atmospherics events"
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/computer/atmos_sim
	var/mode = 2
	var/datum/gas_mixture/tank_mix = new
	var/datum/gas_mixture/bomb_1 = new
	var/datum/gas_mixture/bomb_2 = new
	var/datum/gas_mixture/bomb_result = new
	var/list/bomb_explosion_size = null

/obj/machinery/computer/atmos_sim/Initialize()
	tank_mix.temperature = T20C
	tank_mix.volume = CELL_VOLUME
	bomb_1.temperature = T20C
	bomb_1.volume = 70
	bomb_2.temperature = T20C
	bomb_2.volume = 70
	..()

/obj/machinery/computer/atmos_sim/proc/simulate_bomb()
	bomb_explosion_size = null
	bomb_result = new /datum/gas_mixture()
	bomb_result.volume = bomb_1.volume + bomb_2.volume
	bomb_result.merge(bomb_1)
	bomb_result.merge(bomb_2)
	for(var/I in 1 to 10)
		bomb_result.react()
		if(bomb_result.return_pressure() >= TANK_FRAGMENT_PRESSURE)
			// Explosion!
			bomb_result.react()
			bomb_result.react()
			bomb_result.react()
			var/range = (bomb_result.return_pressure()-TANK_FRAGMENT_PRESSURE)/TANK_FRAGMENT_SCALE
			bomb_explosion_size = list(round(range*0.25), round(range*0.5), round(range))
			break

/obj/machinery/computer/atmos_sim/ui_interact(mob/living/user)
	. = ..()
	var/dat
	dat += "<b>Mode:</b>"
	for(var/i in 1 to ATMOS_SIM_MODE_COUNT)
		var/mode_name = null
		switch(i)
			if(1)
				mode_name = "TTV Bomb"
			if(2)
				mode_name = "Gas Reactions"
		dat += "<a href='?src=[REF(src)];mode=[i]' class='[mode == i ? "linkOn" : ""]'>[mode_name]</a>"
	dat += "<br>"
	switch(mode)
		if(ATMOS_SIM_MODE_BOMB)
			dat += "<table><tr><td>"
			dat += gas_html(bomb_1, "Left Tank", "bomb_1")
			dat += "</td><td>"
			dat += gas_html(bomb_2, "Right Tank", "bomb_2")
			dat += "</td></tr></table>"
			if(bomb_explosion_size)
				dat += "<div>Theoretical Explosion Size: ([bomb_explosion_size[1]]/[bomb_explosion_size[2]]/[bomb_explosion_size[3]])</div>"
			dat += gas_html(bomb_result, "Result")
		if(ATMOS_SIM_MODE_TANK)
			dat += gas_html(tank_mix, "Tank Contents", "tank_mix")
			dat += "<div><a href='?src=[REF(src)];react_tank=1'>Run Reaction Tick</a></div>"

	var/datum/browser/popup = new(user, "atmos_sim", name, 700, 550)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/computer/atmos_sim/proc/gas_html(datum/gas_mixture/mix, name, mix_id)
	var/dat = "<table border=1>"
	dat += "<tr><td colspan=4 style='text-align:center'><b>[name]</b></td></tr>"
	if(mix_id)
		dat += "<tr><td colspan=2><a href='?src=[REF(src)];mix=[mix_id];change_volume=1'>Volume: [mix.volume] L</a></td><td colspan=2><a href='?src=[REF(src)];mix=[mix_id];change_temperature=1'>Temp: [mix.temperature] K</a></td></tr>"
	else
		dat += "<tr><td colspan=1>Volume: [mix.volume] L</td><td colspan=2>Temp: [mix.temperature] K</td></tr>"
	for(var/id in mix.gases)
		var/list/gas = mix.gases[id]
		dat += "<tr>"
		if(mix_id)
			dat += "<td><a href='?src=[REF(src)];mix=[mix_id];delete_gas=[id]'>X</a></td>"
			dat += "<td>[gas[GAS_META][META_GAS_NAME]]</td>"
			dat += "<td><a href='?src=[REF(src)];mix=[mix_id];change_moles=[id]'>[gas[MOLES]] moles</a></td>"
			dat += "<td><a href='?src=[REF(src)];mix=[mix_id];change_pressure=[id]'>[gas[MOLES] * R_IDEAL_GAS_EQUATION * mix.temperature / mix.volume] kPa</a></td>"
		else
			dat += "<td>[gas[GAS_META][META_GAS_NAME]]</td>"
			dat += "<td>[gas[MOLES]] moles</td>"
			dat += "<td>[gas[MOLES] * R_IDEAL_GAS_EQUATION * mix.temperature / mix.volume] kPa</td>"
		dat += "</tr>"
	if(mix_id)
		dat += "<tr><td colspan=4><a href='?src=[REF(src)];mix=[mix_id];add_gas=1'>Add Gas</a></td></tr>"
	dat += "<tr><td colspan=[mix_id?2:1]>TOTAL</td><td>[mix.total_moles()] moles</td><td>[mix.return_pressure()] kPa</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/computer/atmos_sim/proc/gas_topic(datum/gas_mixture/mix, href_list)
	if(href_list["delete_gas"])
		mix.gases -= text2path(href_list["delete_gas"])
	if(href_list["change_moles"])
		var/id = text2path(href_list["change_moles"])
		if(mix.gases[id])
			var/new_moles = input(usr, "Enter a new mole count for [mix.gases[id][GAS_META][META_GAS_NAME]]", name) as null|num
			if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src) || new_moles == null)
				return
			mix.gases[id][MOLES] = new_moles
	if(href_list["change_pressure"])
		var/id = text2path(href_list["change_pressure"])
		if(mix.gases[id])
			var/new_pressure = input(usr, "Enter a new pressure for [mix.gases[id][GAS_META][META_GAS_NAME]]", name) as null|num
			if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src) || new_pressure == null)
				return
			mix.gases[id][MOLES] = new_pressure / R_IDEAL_GAS_EQUATION / mix.temperature * mix.volume
	if(href_list["add_gas"])
		var/list/valid_gas_types = subtypesof(/datum/gas)
		for(var/id in mix.gases)
			valid_gas_types -= id
		var/list/gas_types_map = list()
		for(var/id in valid_gas_types)
			var/datum/gas/gas_type = id
			gas_types_map[initial(gas_type.name)] = id
		var/gas_type = input(usr, "Select a gas type", name) as null|anything in gas_types_map
		if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src) || gas_type == null)
			return
		mix.assert_gas(gas_types_map[gas_type])
	if(href_list["change_volume"])
		var/volume_type = input(usr, "Select a container type", name) as null|anything in list("Custom", "Floor Tile", "Canister", "Portable Tank")
		if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src) || volume_type == null)
			return
		var/desired_volume
		switch(volume_type)
			if("Custom")
				desired_volume = input(usr, "Enter a new volume", name) as null|num
				if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src) || desired_volume == null)
					return
			if("Floor Tile")
				desired_volume = CELL_VOLUME
			if("Canister")
				desired_volume = 1000
			if("Portable Tank")
				desired_volume = 70
		mix.volume = desired_volume
	if(href_list["change_temperature"])
		var/new_temp = input(usr, "Enter a new temperature (0 degrees C = [T0C] K)", name) as null|num
		if(!src || !usr || !usr.canUseTopic(src) || stat || QDELETED(src) || new_temp == null)
			return
		new_temp = max(TCMB, new_temp)
		var/temp_ratio = mix.temperature / new_temp
		for(var/gas_id in mix.gases)
			mix.gases[gas_id][MOLES] *= temp_ratio // Preserve the pressure
		mix.temperature = new_temp

/obj/machinery/computer/atmos_sim/Topic(href, href_list)
	if(..())
		return
	if(!usr || !usr.canUseTopic(src) || stat || QDELETED(src))
		return
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
	if(href_list["mix"])
		var/mix_id = href_list["mix"]
		var/datum/gas_mixture/mix
		var/do_simulate_bomb = FALSE
		switch(mix_id)
			if("tank_mix")
				mix = tank_mix
			if("bomb_1")
				mix = bomb_1
				do_simulate_bomb = TRUE
			if("bomb_2")
				mix = bomb_2
				do_simulate_bomb = TRUE
		if(mix)
			gas_topic(mix, href_list)
		if(do_simulate_bomb)
			simulate_bomb()
	if(href_list["react_tank"])
		tank_mix.react()
	ui_interact(usr)

#undef ATMOS_SIM_MODE_BOMB
#undef ATMOS_SIM_MODE_TANK
#undef ATMOS_SIM_MODE_COUNT
