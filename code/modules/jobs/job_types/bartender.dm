/datum/job/bartender
	title = "Bartender"
	description = "Operate the city's bar, listen to the labor lead, try not to get shut down."
	orbit_icon = "cocktail"
	department_head = list("Labor Lead")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the labor lead"
	exp_type_department = EXP_TYPE_SERVICE // This is so the jobs menu can work properly

	outfit = /datum/outfit/job/bartender

	added_access = list(ACCESS_HYDROPONICS, ACCESS_KITCHEN, ACCESS_MORGUE)
	base_access = list(ACCESS_SERVICE, ACCESS_BAR, ACCESS_WEAPONS_PERMIT)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BARTENDER
	minimal_character_age = 21 //I shouldn't have to explain this one

	departments_list = list(
		/datum/job_department/service,
	)

	smells_like = "alcohol"

/datum/outfit/job/bartender
	name = "Bartender"
	jobtype = /datum/job/bartender
	glasses = /obj/item/clothing/glasses/sunglasses/reagent
	uniform = /obj/item/clothing/under/citizen
	