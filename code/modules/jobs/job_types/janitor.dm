/datum/job/janitor
	title = "Janitor"
	flag = JANITOR
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 2
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#bbe291"

	outfit = /datum/outfit/job/janitor

	alt_titles = list("Custodian", "Sanitation Worker", "Cleaner", "Caretaker", "Maid")

	added_access = list()
	base_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_JANITOR
	minimal_character_age = 20 //Theoretically janitors do actually need training and certifications in handling of certain hazardous materials as well as cleaning substances, but nothing absurd, I'd assume

	changed_maps = list("OmegaStation", "EclipseStation")

/datum/job/janitor/proc/OmegaStationChanges()
	added_access = list()
	base_access = list(ACCESS_JANITOR, ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	supervisors = "the captain and the head of personnel"

/datum/job/janitor/proc/EclipseStationChanges()
	total_positions = 4
	spawn_positions = 2

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/janitor
	uniform_skirt = /obj/item/clothing/under/rank/janitor/skirt
