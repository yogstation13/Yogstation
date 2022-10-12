/datum/job/clerk
	title = "Clerk"
	flag = CLERK
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#dddddd"
	added_access = list()
	base_access = list(ACCESS_MANUFACTURING)
	alt_titles = list("Salesman", "Gift Shop Attendent", "Retail Worker")
	outfit = /datum/outfit/job/clerk
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_CLERK
	minimal_character_age = 18 //Capitalism doesn't care about age

	changed_maps = list("EclipseStation", "OmegaStation")

/datum/job/clerk/proc/EclipseStationChanges()
	total_positions = 2
	spawn_positions = 1

/datum/job/clerk/proc/OmegaStationChanges()
	return TRUE

/datum/outfit/job/clerk
	name = "Clerk"
	jobtype = /datum/job/clerk

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/yogs/rank/clerk
	uniform_skirt = /obj/item/clothing/under/yogs/rank/clerk/skirt
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/yogs/clerkcap
	backpack_contents = list(/obj/item/circuitboard/machine/paystand = 1)
