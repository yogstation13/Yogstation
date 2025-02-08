/datum/job/roboticist
	title = "Roboticist"
	description = "Build and repair the AI and cyborgs, create mechs."
	orbit_icon = "battery-half"
	department_head = list("Research Director")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	exp_requirements = 60
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Augmentation Theorist", "Cyborg Maintainer", "Robotics Intern", "Biomechanical Engineer", "Mechatronic Engineer", "Machinist", "Chrome Shaman", "Ripperdoc")

	outfit = /datum/outfit/job/roboticist

	added_access = list(ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_XENOBIOLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_EXPERIMENTATION)
	base_access = list(ACCESS_SCIENCE, ACCESS_ROBOTICS, ACCESS_ROBO_CONTROL, ACCESS_MORGUE,
					ACCESS_MECH_SCIENCE, ACCESS_MECH_ENGINE, ACCESS_MECH_MEDICAL, ACCESS_MECH_MINING)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST
	minimal_character_age = 22 //Engineering, AI theory, robotic knowledge and the like

	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_LOW,
		SKILL_TECHNICAL = EXP_LOW,
		SKILL_SCIENCE = EXP_LOW,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = 3

	departments_list = list(
		/datum/job_department/science,
	)

	mail_goodies = list(
		/obj/item/storage/box/flashes = 20,
		/obj/item/stack/sheet/metal/fifty = 15,
		/obj/item/stack/sheet/plasteel/twenty = 5,
		/obj/item/modular_computer/tablet/preset/advanced = 5,
		/obj/item/stock_parts/cell/bluespace = 5,
		/obj/item/stack/ore/dilithium_crystal/refined = 5
	)

	lightup_areas = list(/area/science/mixing, /area/science/storage)
	minimal_lightup_areas = list(
		/area/medical/morgue,
		/area/science/robotics,
		/area/storage/tech
	)
	
	smells_like = "burnt solder"

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/robo

	belt = /obj/item/storage/belt/utility/full
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	uniform_skirt = /obj/item/clothing/under/rank/rnd/roboticist/skirt
	suit = /obj/item/clothing/suit/toggle/labcoat

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	pda_slot = ITEM_SLOT_LPOCKET
