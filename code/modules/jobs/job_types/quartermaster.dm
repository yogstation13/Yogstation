/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"
	selection_color = "#d7b088"

	outfit = /datum/outfit/job/quartermaster

	alt_titles = list("Stock Controller", "Cargo Coordinator", "Shipping Overseer")

	added_access = list()
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER
	minimal_character_age = 20 //Probably just needs some baseline experience with bureaucracy, enough trust to land the position

	changed_maps = list("OmegaStation")

/datum/job/qm/proc/OmegaStationChanges()
	return TRUE

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/qm

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic/fountainpen

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo
	uniform_skirt = /obj/item/clothing/under/rank/cargo/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/export_scanner

	chameleon_extras = /obj/item/stamp/qm

