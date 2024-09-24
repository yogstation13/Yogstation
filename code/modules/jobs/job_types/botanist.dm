/datum/job/hydro
	title = "Botanist"
	description = "Grow combine approved produce substitutes for citizen consumptions and combine biofuel use."
	orbit_icon = "seedling"
	department_head = list("Labor Lead")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the labor lead"

	outfit = /datum/outfit/job/botanist

	added_access = list(ACCESS_BAR, ACCESS_KITCHEN)
	base_access = list(ACCESS_SERVICE, ACCESS_HYDROPONICS, ACCESS_MORGUE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV
	display_order = JOB_DISPLAY_ORDER_BOTANIST
	minimal_character_age = 22 //Biological understanding of plants and how to manipulate their DNAs and produces relatively "safely". Not just something that comes to you without education

	departments_list = list(
		/datum/job_department/service,
	)
	
	smells_like = "fertilizer"

/datum/outfit/job/botanist
	name = "Botanist"
	jobtype = /datum/job/hydro

	uniform = /obj/item/clothing/under/citizen
	gloves  =/obj/item/clothing/gloves/botanic_leather
