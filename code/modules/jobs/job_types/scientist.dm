/datum/job/scientist
	title = "Union Scientist"
	description = "Operate your minature science station under the supervision of the labor lead, requesting assistants if necessary."
	orbit_icon = "flask"
	department_head = list("labor lead")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the labor lead"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	outfit = /datum/outfit/job/scientist

	added_access = list(ACCESS_ROBO_CONTROL, ACCESS_GENETICS, ACCESS_ROBOTICS)
	base_access = list(ACCESS_SCIENCE, ACCESS_RESEARCH, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE,
					ACCESS_EXPERIMENTATION, ACCESS_XENOBIOLOGY, ACCESS_AUX_BASE, ACCESS_MECH_SCIENCE)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	liver_traits = list(TRAIT_BALLMER_SCIENTIST)

	display_order = JOB_DISPLAY_ORDER_SCIENTIST
	minimal_character_age = 24 //Consider the level of knowledge that spans xenobio, nanites, and toxins

	departments_list = list(
		/datum/job_department/science,
	)
	
	smells_like = "slime"

/datum/outfit/job/scientist
	name = "Union Scientist"
	jobtype = /datum/job/scientist

	uniform = /obj/item/clothing/under/citizen
	accessory = /obj/item/clothing/accessory/armband/science
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
