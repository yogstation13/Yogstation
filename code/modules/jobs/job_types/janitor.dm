/datum/job/janitor
	title = "Janitor"
	description = "Clean up trash and blood, replace broken lights and slip people over."
	flag = JANITOR
	orbit_icon = "broom"
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
	base_access = list(ACCESS_JANITOR, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_CARGO, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_ENGINE)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_JANITOR
	minimal_character_age = 20 //Theoretically janitors do actually need training and certifications in handling of certain hazardous materials as well as cleaning substances, but nothing absurd, I'd assume

	departments_list = list(
		/datum/job_department/service,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/spray/cleaner = 30,
		/obj/item/grenade/chem_grenade/cleaner = 30,
		/obj/item/storage/box/lights/mixed = 20,
		/obj/item/lightreplacer = 10
	)

	smells_like = "bleach"

/datum/outfit/job/janitor
	name = "Janitor"
	jobtype = /datum/job/janitor

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/janitor
	uniform_skirt = /obj/item/clothing/under/rank/janitor/skirt
