/datum/department_goal/eng
	account = ACCOUNT_ENG

// Store like 70e6 joules
// Which is like, 14 roundstart SMES' worth (so requires upgrades)
/datum/department_goal/eng/SMES
	name = "Store 70MW"
	desc = "Store 70MW of energy in the station's SMES'"
	reward = "50000"

/datum/department_goal/eng/SMES/check_complete()
	var/charge = 0
	for(var/obj/machinery/power/smes/s in GLOB.machines)
		if(!is_station_level(s.z))
			continue
		charge += s.charge
	return charge >= 70e6
