/datum/job/qm
	title = "Quartermaster"
	description = "Coordinate cargo technicians and shaft miners, assist with \
		economical purchasing."
	flag = QUARTERMASTER
	orbit_icon = "sack-dollar"
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"
	outfit = /datum/outfit/job/quartermaster
	alt_titles = list("Stock Controller", "Cargo Coordinator", "Shipping Overseer", "Postmaster General")
	added_access = list()
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR
	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	minimal_character_age = 20 //Probably just needs some baseline experience with bureaucracy, enough trust to land the position

	departments_list = list(
		/datum/job_department/cargo,
	)

	changed_maps = list("OmegaStation")

	mail_goodies = list(
		/obj/item/circuitboard/machine/emitter = 3
	)

	smells_like = "capitalism"

	exp_requirements = 120
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SUPPLY

/datum/job/qm/proc/OmegaStationChanges()
	return TRUE

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/qm

	pda_type = /obj/item/modular_computer/tablet/pda/preset/cargo

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo
	uniform_skirt = /obj/item/clothing/under/rank/cargo/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/export_scanner

	chameleon_extras = /obj/item/stamp/qm

