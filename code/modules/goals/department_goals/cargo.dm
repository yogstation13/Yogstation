/datum/department_goal/car
	account = ACCOUNT_CAR


// Have 500 plasteel sheets in the ore silo
// I'ven't played this game for so long I have no clue how viable this even is.
// Is this easy? Is this hard? Is the reward too high? Who knows?
/datum/department_goal/car/uranium
	name = "Have 500 uranium"
	desc = "Store 500 uranium sheets in the ore silo"
	reward = "50000"

/datum/department_goal/car/uranium/check_complete()
	var/obj/machinery/ore_silo/O = GLOB.ore_silo_default
	var/datum/component/material_container/materials = O.GetComponent(/datum/component/material_container)
	return materials.has_enough_of_material(/datum/material/uranium, MINERAL_MATERIAL_AMOUNT, 500)

// Setup a tesla in cargo
/datum/department_goal/car/tesla
	name = "Create a tesla"
	desc = "Create a tesla engine in the cargo bay"
	reward = "50000"

/datum/department_goal/car/tesla/check_complete()
	for(var/obj/singularity/energy_ball/e in GLOB.singularities)
		if(istype(get_area(e), /area/quartermaster/storage))
			return TRUE
	return FALSE
