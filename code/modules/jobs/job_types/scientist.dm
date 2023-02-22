/datum/job/scientist
	title = "Scientist"
	description = "Do experiments, perform research, feed the slimes, make bombs."
	flag = SCIENTIST
	orbit_icon = "flask"
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Researcher", "Toxins Specialist", "Physicist", "Test Associate", "Anomalist", "Quantum Physicist", "Theoretical Physicist", "Xenobiologist", "Explosives Technician", "Hypothetical Physicist")
	outfit = /datum/outfit/job/scientist

	added_access = list(ACCESS_ROBO_CONTROL, ACCESS_TECH_STORAGE, ACCESS_GENETICS)
	base_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_SCIENTIST
	minimal_character_age = 24 //Consider the level of knowledge that spans xenobio, nanites, and toxins

	departments_list = list(
		/datum/job_department/science,
	)

	mail_goodies = list(
		///obj/item/raw_anomaly_core/random = 10,
		///obj/item/disk/tech_disk/spaceloot = 2,
		/obj/item/camera_bug = 1
	)

	smells_like = "slime"

	bounty_types = list(CIV_JOB_SCI, CIV_JOB_XENO)

/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic

	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/scientist
	uniform_skirt = /obj/item/clothing/under/rank/scientist/skirt
	shoes = /obj/item/clothing/shoes/sneakers/white
	suit = /obj/item/clothing/suit/toggle/labcoat/science

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

/datum/outfit/job/scientist/pre_equip(mob/living/carbon/human/H)
	..()
	if(prob(0.4))
		neck = /obj/item/clothing/neck/tie/horrible

/datum/outfit/job/scientist/get_types_to_preload()
	. = ..()
	. += /obj/item/clothing/neck/tie/horrible
