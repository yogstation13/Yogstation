//I love nuclear energy!!!!!
/datum/computer_file/program/nuclear_monitor
	filename = "agcnrmonitor"
	filedesc = "Nuclear Reactor Monitoring"
	category = PROGRAM_CATEGORY_ENGI
	ui_header = "smmon_0.gif"
	program_icon_state = "smmon_0"
	extended_desc = "This program connects to specially calibrated sensors to provide information on the status of nuclear reactors."
	requires_ntnet = TRUE
	transfer_access = ACCESS_ENGINE
	program_icon = "radiation" // duh
	//network_destination = "reactor monitoring system" dont need anymore?
	size = 2
	tgui_id = "NtosReactorStats"
	var/active = TRUE //Easy process throttle
	var/next_stat_interval = 0
	var/list/kpaData = list()
	var/list/powerData = list()
	var/list/tempCoreData = list()
	var/list/tempInputData = list()
	var/list/tempOutputData = list()
	var/list/reactors
	var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/reactor //Our reactor.

/datum/computer_file/program/nuclear_monitor/process_tick()
	..()
	if(!reactor || !active)
		return FALSE
	var/stage = 0
	switch(reactor.temperature)
		if(REACTOR_TEMPERATURE_MINIMUM to REACTOR_TEMPERATURE_OPERATING)
			stage = 1
		if(REACTOR_TEMPERATURE_OPERATING to REACTOR_TEMPERATURE_CRITICAL)
			stage = 2
		if(REACTOR_TEMPERATURE_CRITICAL to REACTOR_TEMPERATURE_MELTDOWN)
			stage = 4
		if(REACTOR_TEMPERATURE_MELTDOWN to INFINITY)
			stage = 5
			if(reactor.vessel_integrity <= 100) //Bye bye! GET OUT!
				stage = 6
	ui_header = "smmon_[stage].gif"
	program_icon_state = "smmon_[stage]"
	if(istype(computer))
		computer.update_appearance(UPDATE_ICON)

// Refreshes list of active reactors, stolen from SM monitor code
/datum/computer_file/program/nuclear_monitor/proc/refresh()
	reactors = list()
	var/turf/T = get_turf(ui_host())
	if(!T)
		return
	for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/N in GLOB.machines)
		if(!isturf(N.loc) || !(is_station_level(N.z) || is_mining_level(N.z) || N.z == T.z))
			continue
		reactors.Add(N)

	if(!(reactor in reactors))
		reactor = null

/datum/computer_file/program/nuclear_monitor/run_program(mob/living/user)
	. = ..(user)
	//No reactor? Go find one then.
	if(!(reactor in GLOB.machines))
		reactor = null
	refresh()
	active = TRUE

/datum/computer_file/program/nuclear_monitor/kill_program(forced = FALSE)
	active = FALSE
	..()

/datum/computer_file/program/nuclear_monitor/ui_data()
	var/list/data = get_header_data()
	if(istype(reactor))
		if(!get_turf(reactor))
			reactor = null
			refresh()
			return
		data["powerData"] = reactor.powerData
		data["kpaData"] = reactor.kpaData
		data["tempCoreData"] = reactor.tempCoreData
		data["tempInputData"] = reactor.tempInputData
		data["tempOutputData"] = reactor.tempOutputData
		data["coreTemp"] = reactor.temperature
		data["coolantInput"] = reactor.last_coolant_temperature
		data["coolantOutput"] = reactor.last_output_temperature
		data["power"] = reactor.last_power_produced
		data["kpa"] = reactor.pressure
		data["k"] = reactor.K
		data["integrity"] = reactor.get_integrity()
		data["selected"] = TRUE
	else
		var/list/reactor_data = list()
		var/next_uid = 0
		for(var/obj/machinery/atmospherics/components/trinary/nuclear_reactor/N as anything in reactors)
			var/area/A = get_area(N)
			next_uid++
			if(A)
				reactor_data.Add(list(list(
					"area_name" = A.name,
					"integrity" = N.get_integrity(),
					"uid" = next_uid
				)))
		data["selected"] = FALSE
		data["reactors"] = reactor_data
	return data

/datum/computer_file/program/nuclear_monitor/ui_act(action, params)
	if(..())
		return TRUE

	switch(action)
		if("PRG_clear")
			reactor = null
			return TRUE
		if("PRG_refresh")
			refresh()
			return TRUE
		if("PRG_set")
			var/new_id = text2num(params["target"])
			if(new_id < 1 || new_id > reactors.len)
				return TRUE
			reactor = reactors[new_id]
			powerData = list()
			kpaData = list()
			tempCoreData = list()
			tempInputData = list()
			tempOutputData = list()
			return TRUE
