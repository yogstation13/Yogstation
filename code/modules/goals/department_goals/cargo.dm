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
		/datum/material/bluespace,
		/datum/material/diamond,
		/datum/material/uranium,
		/datum/material/gold,
		/datum/material/titanium,
		/datum/material/silver,
		/datum/material/plasma,
		/datum/material/glass,
		/datum/material/iron)

	for(var/mat in material_list)
		var/datum/material/M = getmaterialref(mat)
		if(!materials.has_enough_of_material(M, MINERAL_MATERIAL_AMOUNT, 50))
			return FALSE
	return TRUE
