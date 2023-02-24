/datum/job/clerk
	title = "Clerk"
	description = "Set up shop on the station and unique sell trinkets to the crew for a profit."
	flag = CLERK
	orbit_icon = "basket-shopping"
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

	departments_list = list(
		/datum/job_department/service,
	)

	smells_like = "cheap plastic"

/datum/outfit/job/clerk
	name = "Clerk"
	jobtype = /datum/job/clerk

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/yogs/rank/clerk
	uniform_skirt = /obj/item/clothing/under/yogs/rank/clerk/skirt
	shoes = /obj/item/clothing/shoes/sneakers/black
	head = /obj/item/clothing/head/yogs/clerkcap
	backpack_contents = list(/obj/item/circuitboard/machine/paystand = 1)
