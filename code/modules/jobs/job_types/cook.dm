/datum/job/cook
	title = "Cook"
	description = "Operate the city's restaurant, listen to the labor lead, and try not to get shut down."
	orbit_icon = "utensils"
	department_head = list("Labor Lead")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the labor lead"

	outfit = /datum/outfit/job/cook

	added_access = list(ACCESS_HYDROPONICS, ACCESS_BAR)
	base_access = list(ACCESS_SERVICE, ACCESS_KITCHEN, ACCESS_MORGUE)

	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_COOK
	minimal_character_age = 18 //My guy they just a cook

	departments_list = list(
		/datum/job_department/service,
	)

	smells_like = "delicious food"

/datum/outfit/job/cook
	name = "Cook"
	jobtype = /datum/job/cook

	suit = /obj/item/clothing/suit/apron/chef
	head = /obj/item/clothing/head/chefhat
	uniform = /obj/item/clothing/under/citizen
