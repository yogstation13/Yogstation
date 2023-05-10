/datum/job/cargo_tech
	title = "Cargo Technician"
	description = "Distribute supplies to the departments that ordered them, \
		collect empty crates, load and unload the supply shuttle, \
		ship bounty cubes."
	flag = CARGOTECH
	orbit_icon = "box"
	department_head = list("Head of Personnel")
	department_flag = CIVILIAN
	faction = "Station"
	total_positions = 3
	spawn_positions = 2
	supervisors = "the quartermaster and the head of personnel"
	selection_color = "#dcba97"

	outfit = /datum/outfit/job/cargo_tech

	alt_titles = list("Deliveryperson", "Mail Service", "Exports Handler", "Cargo Trainee", "Crate Pusher", "Courier")

	added_access = list(ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION)
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_CARGO_TECHNICIAN
	minimal_character_age = 18 //We love manual labor and exploiting the young for our corporate purposes

	departments_list = list(
		/datum/job_department/cargo,
	)

	mail_goodies = list(
		/obj/item/pizzabox = 10,
		/obj/item/stack/sheet/mineral/gold = 5,
		/obj/item/stack/sheet/mineral/uranium = 4,
		/obj/item/stack/sheet/mineral/diamond = 3,
		/obj/item/gun/ballistic/rifle/boltaction = 1
	)

	smells_like = "cardboard"

/datum/outfit/job/cargo_tech
	name = "Cargo Technician"
	jobtype = /datum/job/cargo_tech

	pda_type = /obj/item/modular_computer/tablet/pda/preset/cargo

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargotech
	uniform_skirt = /obj/item/clothing/under/rank/cargotech/skirt
	l_hand = /obj/item/export_scanner

