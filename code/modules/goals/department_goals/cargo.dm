/datum/department_goal/car
	account = ACCOUNT_CAR


// Have 50 of every (traditional) sheet (not bananium or plastic)
/datum/department_goal/car/sheets
	name = "Have 50 of every ore sheet"
	desc = "Store 50 of every ore sheet in the ore silo"
	reward = 5000
	continuous = 3000 // rewards every 5 minutes

/datum/department_goal/car/sheets/check_complete()
	var/obj/machinery/ore_silo/O = GLOB.ore_silo_default
	var/datum/component/material_container/materials = O.GetComponent(/datum/component/material_container)
	var/list/material_list = list(
		"bluespace",
		"diamond",
		"uranium",
		"gold",
		"titanium",
		"silver",
		"plasma",
		"glass",
		"iron")
	for(var/datum/material/I in material_list)
		if(!materials.has_enough_of_material(I, MINERAL_MATERIAL_AMOUNT, 50))
			return FALSE
	return TRUE

// Setup a tesla in cargo
/datum/department_goal/car/tesla
	name = "Create a tesla"
	desc = "Create a tesla engine in the cargo bay"
	reward = 50000

/datum/department_goal/car/tesla/check_complete()
	for(var/obj/singularity/energy_ball/e in GLOB.singularities)
		if(istype(get_area(e), /area/quartermaster/storage))
			return TRUE
	return FALSE
