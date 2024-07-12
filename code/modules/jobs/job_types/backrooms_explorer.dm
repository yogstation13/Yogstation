/datum/job/backrooms_explorer
	title = "Backrooms Explorer"
	description = "Delve deep into unknown realms, \
		search the unknown for valuable relics for the station to research, \
		don't get eaten by the mosters that live there."
	orbit_icon = "box"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	supervisors = "the quartermaster and the head of personnel"

	outfit = /datum/outfit/job/cargo_tech

	alt_titles = list("Pioneer", "Pathfinder", "Delver", "Traveller", "New-Hire", "Company Asset")

	added_access = list(ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION)
	base_access = list(ACCESS_MAINT_TUNNELS, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_EASY
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_BACKROOMS_EXPLORER
	minimal_character_age = 18 //We love manual labor and exploiting the young for our corporate purposes

	departments_list = list(
		/datum/job_department/cargo,
	)

	mail_goodies = list(
		/obj/item/stack/spacecash = 10 /// dont send cash through the mail
		
	)
	
	lightup_areas = list(/area/quartermaster/qm)

	smells_like = "carpet"

/datum/outfit/job/backrooms_explorer
	name = "Backrooms Explorer"
	jobtype = /datum/job/backrooms_explorer

	pda_type = /obj/item/modular_computer/tablet/pda/preset/cargo

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo/tech
	uniform_skirt = /obj/item/clothing/under/rank/cargo/tech/skirt

/datum/outfit/job/backrooms_explorer/no_pda
	name = "Backrooms Explorer (No PDA)"

	pda_type = null
