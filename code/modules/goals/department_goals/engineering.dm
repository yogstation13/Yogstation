/datum/department_goal/eng
	account = ACCOUNT_ENG

// Store 1.4e9J
// Which is around 21 roundstart SMES' worth (so requires upgrades)
// Or 6 fully upgraded SMES'
/datum/department_goal/eng/SMES
	name = "Store 1.4GJ"
	desc = "Store 1.4GJ of energy in the station's SMES"
	reward = 50000

/datum/department_goal/eng/SMES/check_complete()
	var/charge = 0
	for(var/obj/machinery/power/smes/s in GLOB.machines)
		if(!is_station_level(s.z))
			continue
		charge += s.charge
	return charge >= 1.4e9


// Fire up a supermatter
/datum/department_goal/eng/additional_supermatter
	name = "Fire up a supermatter"
	desc = "Order and fire up a supermatter shard"
	reward = 50000

// Only available if the station doesn't have a suppermatter
/datum/department_goal/eng/additional_supermatter/is_available()
	return !(GLOB.main_supermatter_engine)


// Set up a singularity
/datum/department_goal/eng/additional_singularity
	name = "Spark a singularity"
	desc = "Start a singularity engine using a singularity generator"
	reward = 50000

/datum/department_goal/eng/additional_singularity/is_available()
	return GLOB.main_supermatter_engine

/datum/department_goal/eng/additional_singularity/check_complete()
	for(var/obj/singularity/s in GLOB.singularities)
		if(is_station_level(s.z) && !istype(s, /obj/singularity/energy_ball))
			return TRUE
	return FALSE

// Set up a tesla
/datum/department_goal/eng/tesla
	name = "Create a tesla"
	desc = "Create a tesla engine using a tesla generator"
	reward = 50000

/datum/department_goal/eng/tesla/check_complete()
	for(var/obj/singularity/energy_ball/e in GLOB.singularities)
		if(is_station_level(e.z))
			return TRUE
	return FALSE
