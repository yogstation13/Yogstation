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

	changed_maps = list("EclipseStation", "OmegaStation")

	mail_goodies = list(
		/obj/item/stack/sheet/bluespace_crystal = 10,
		/obj/item/megaphone = 10,
		/obj/item/anomaly_neutralizer = 5,
		/obj/item/relic = 5,
		/obj/item/camera_bug = 1
	)

	smells_like = "slime"

/datum/job/scientist/proc/EclipseStationChanges()
	total_positions = 6
	spawn_positions = 5

/datum/job/scientist/proc/OmegaStationChanges()
	total_positions = 3
	spawn_positions = 3
	added_access = list()
	base_access = list(ACCESS_ROBO_CONTROL, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MINERAL_STOREROOM, ACCESS_TECH_STORAGE)
	supervisors = "the captain and the head of personnel"

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
