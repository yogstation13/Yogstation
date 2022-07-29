/datum/job/scientist
	title = "Scientist"
	flag = SCIENTIST
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 5
	spawn_positions = 3
	supervisors = "the research director"
	selection_color = "#ffeeff"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Researcher", "Toxins Specialist", "Physicist", "Test Associate", "Anomalist", "Quantum Physicist", "Xenobiologist", "Explosives Technician")

	outfit = /datum/outfit/job/scientist

	added_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_GENETICS)
	base_access = list(ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MECH_SCIENCE, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_SCIENTIST
	minimal_character_age = 24 //Consider the level of knowledge that spans xenobio, nanites, and toxins

	changed_maps = list("EclipseStation", "OmegaStation")

/datum/job/scientist/proc/EclipseStationChanges()
	total_positions = 6
	spawn_positions = 5

/datum/job/scientist/proc/OmegaStationChanges()
	total_positions = 3
	spawn_positions = 3
	added_access = list()
	base_access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/scientist
	name = "Scientist"
	jobtype = /datum/job/scientist

	pda_type = /obj/item/pda/toxins

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
