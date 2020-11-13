/datum/department_goal/srv
	account = ACCOUNT_SRV

//the fuck does a service even do
/datum/department_goal/srv/dwink
	name = "Have 5 drinks"
	desc = "Have 5 different drinks in the drink showcase in the bar"
	reward = 5000 // Idfk

/datum/department_goal/srv/dwink/check_complete()
	for(var/obj/machinery/smartfridge/drinks/dwink in GLOB.machines)
		if(!is_station_level(dwink.z))
			continue
		if(dwink.contents.len >= 5)
			return TRUE
	return FALSE
			
