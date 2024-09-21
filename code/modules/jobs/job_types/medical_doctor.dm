/datum/job/doctor
	title = "Medical Doctor"
	description = "Operate the medical bay, listening to the labor lead for directions if necessary."
	orbit_icon = "staff-snake"
	department_head = list("Labor Lead")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the labor lead"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Physician", "Surgeon", "Nurse")

	outfit = /datum/outfit/job/doctor

	added_access = list(ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_VIROLOGY)
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING,
					ACCESS_MECH_MEDICAL)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_MEDICAL_DOCTOR
	minimal_character_age = 26 //Barely acceptable considering the theoretically absurd knowledge they have, but fine

	departments_list = list(
		/datum/job_department/medical,
	)

	smells_like = "a hospital"

/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor
	uniform = /obj/item/clothing/under/citizen
	accessory = /obj/item/clothing/accessory/armband/medblue
	ears = /obj/item/radio/headset
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
