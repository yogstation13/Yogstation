#define MAXIMUM_POWER_LIMIT 1000000000000000.0
/datum/computer_file/program/energy_harvester_control
	filename = "energy_harvester_control"
	filedesc = "Energy Harvester Control"
	ui_header = "energy_harvester_null.gif"
	program_icon_state = "energy_harvester_null"
	extended_desc = "This program connects remotely to the onboard energy harvester, allowing a chief engineer to control the input rates and check for cashflow."
	requires_ntnet = TRUE
	transfer_access = ACCESS_CE
	network_destination = "energy harvester controller"
	size = 1
	tgui_id = "NtosEnergyHarvesterController"
	program_icon = "charging-station"

	var/status
	var/obj/item/energy_harvester/moneysink

///updates icon
/datum/computer_file/program/energy_harvester_control/process_tick()
	..()
	var/new_status
	if(isnull(moneysink))
		new_status = "null"
	else if(moneysink.input_energy==0)
		new_status = "off"
	else
		new_status = "on"

	if(new_status != status)
		status = new_status
		ui_header = "energy_harvester_[status].gif"
		program_icon_state = "energy_harvester_[status]"
		if(istype(computer))
			update_computer_icon()

/datum/computer_file/program/energy_harvester_control/run_program(mob/living/user)
	. = ..(user)
	refresh()

/datum/computer_file/program/energy_harvester_control/kill_program(forced = FALSE)
	moneysink = null
	..()

/// Resyncs energy harvester
/datum/computer_file/program/energy_harvester_control/proc/refresh()
	moneysink = SSeconomy.moneysink

/datum/computer_file/program/energy_harvester_control/ui_data()
	var/list/data = get_header_data()
	var/turf/T = get_turf(moneysink)
	var/turf/curr = get_turf(ui_host())

	if(isnull(moneysink)||!T) //something has gone horribly wrong, time to abort.
		data["status"] = "null"
	else
		if(!moneysink.anchored || isnull(moneysink.PN) || moneysink.input_energy==0)
			data["status"] = "Unpowered"
		else
			data["status"] = "Working"
		data["x"] = T.x
		data["y"] = T.y
		data["area"] = get_area_name(T)
		data["dist"] = get_dist_euclidian(curr, T)
		data["rotation"] = Get_Angle(curr, T)
		data["power"] = moneysink.accumulated_power
		data["power_setting"] = moneysink.manual_power_setting
		data["input"] = moneysink.input_energy
		data["power_switch"] = moneysink.manual_switch
		data["payout"] = moneysink.calculateMoney()
		data["last_power"] = moneysink.last_accumulated_power
		data["last_payout"] = moneysink.last_payout

	return data

/datum/computer_file/program/energy_harvester_control/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("switch")
			computer.play_interact_sound()
			moneysink.manual_switch = !moneysink.manual_switch
			if(moneysink.manual_switch)
				START_PROCESSING(SSobj, moneysink)
			else
				STOP_PROCESSING(SSobj, moneysink)
			. = TRUE
		if("setinput")
			var/target = params["target"]
			computer.play_interact_sound()
			if(target == "input")
				target = input("New input target (0-[MAXIMUM_POWER_LIMIT]):", moneysink.name, moneysink.manual_power_setting) as num|null
				computer.play_interact_sound()
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = MAXIMUM_POWER_LIMIT
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			else if(isnum(target))
				. = TRUE
			if(.)
				moneysink.manual_power_setting = clamp(target, 0, MAXIMUM_POWER_LIMIT)



#undef MAXIMUM_POWER_LIMIT
