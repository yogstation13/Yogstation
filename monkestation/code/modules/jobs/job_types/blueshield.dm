/datum/job/blueshield
	title = JOB_BLUESHIELD
	description = "Protect the heads of staff with your life. You are not a sec officer, and cannot perform arrests."
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Nanotrasen Representative and Central Command"
	minimal_player_age = 30
	exp_requirements = 7200
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_COMMAND
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "BLUESHIELD"

	allow_bureaucratic_error = FALSE
	allow_overflow = FALSE

	outfit = /datum/outfit/job/blueshield
	plasmaman_outfit = /datum/outfit/plasmaman/blueshield

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_CMD

	liver_traits = list(TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_BLUESHIELD
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/central_command,
		/datum/job_department/command,
		)

	family_heirlooms = list(/obj/item/bedsheet/captain, /obj/item/clothing/head/beret/blueshield)

	mail_goodies = list(
		/obj/item/storage/fancy/cigarettes/cigars/havana = 10,
		/obj/item/stack/spacecash/c500 = 3,
		/obj/item/disk/nuclear/fake/obvious = 2,
		/obj/item/clothing/head/collectable/captain = 4,
	)

	rpg_title = "Guard"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT | JOB_CANNOT_OPEN_SLOTS

	alt_titles = list(
		"Blueshield",
		"Corporate Henchman",
		"Bodyguard",
		"Revolutionary Repellent",
		"Heavily Armed Butler",
		"Honor Guard",
	)

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield/jacket
	gloves = /obj/item/clothing/gloves/tackler/combat
	id = /obj/item/card/id/advanced/centcom
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/headset_bs/alt
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses

	implants = list(/obj/item/implant/mindshield)
	backpack_contents = list(
		/obj/item/choice_beacon/blueshield = 1,
	)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel/blueshield
	duffelbag = /obj/item/storage/backpack/duffelbag/blueshield

	head = /obj/item/clothing/head/beret/blueshield
	box = /obj/item/storage/box/survival/security
	belt = /obj/item/storage/belt/military/assault/blueshield
	l_pocket = /obj/item/sensor_device/blueshield
	r_pocket = /obj/item/modular_computer/pda/blueshield
	pda_slot = ITEM_SLOT_RPOCKET
	id_trim = /datum/id_trim/job/blueshield

/datum/outfit/plasmaman/blueshield
	name = "Blueshield Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman/blueshield
	uniform = /obj/item/clothing/under/plasmaman/blueshield
