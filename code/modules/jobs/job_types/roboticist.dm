/datum/job/roboticist
	title = "Roboticist"
	description = "Build and repair the AI and cyborgs, create mechs."
	flag = ROBOTICIST
	orbit_icon = "battery-half"
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Augmentation Theorist", "Cyborg Maintainer", "Robotics Intern", "Biomechanical Engineer", "Mechatronic Engineer", "Machinist")

	outfit = /datum/outfit/job/roboticist

	added_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_XENOBIOLOGY, ACCESS_GENETICS)
	base_access = list(ACCESS_ROBO_CONTROL, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MECH_SCIENCE, ACCESS_MECH_ENGINE, ACCESS_MECH_MEDICAL, ACCESS_MECH_MINING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST
	minimal_character_age = 22 //Engineering, AI theory, robotic knowledge and the like

	departments_list = list(
		/datum/job_department/science,
	)

	changed_maps = list("OmegaStation")

	mail_goodies = list(
		/obj/item/storage/box/flashes = 20,
		/obj/item/stack/sheet/metal/twenty = 15,
		/obj/item/modular_computer/tablet/preset/advanced = 5
	)

	smells_like = "burnt solder"

/datum/job/roboticist/proc/OmegaStationChanges()
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/robo

	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/roboticist
	uniform_skirt = /obj/item/clothing/under/rank/roboticist/skirt
	suit = /obj/item/clothing/suit/toggle/labcoat

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = SLOT_L_STORE
