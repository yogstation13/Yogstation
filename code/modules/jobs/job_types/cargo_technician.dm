/datum/job/cargo_tech
	title = "Cargo Technician"
	flag = CARGOTECH
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/cargo_tech

	alt_titles = list("Deliveryperson", "Mail Service", "Exports Handler", "Cargo Trainee", "Crate Pusher")

	added_access = list(ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION)
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	minimal_character_age = 18 //We love manual labor and exploiting the young for our corporate purposes

	changed_maps = list("EclipseStation", "OmegaStation")

/datum/job/cargo_tech/proc/EclipseStationChanges()
	total_positions = 5
	spawn_positions = 4

/datum/job/cargo_tech/proc/OmegaStationChanges()
	total_positions = 2
	spawn_positions = 2
	added_access = list()
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)
	supervisors = "the head of personnel"

/datum/outfit/job/cargo_tech
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_tech

	pda_type = /obj/item/pda/cargo

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargotech
	uniform_skirt = /obj/item/clothing/under/rank/cargotech/skirt
	l_hand = /obj/item/export_scanner

