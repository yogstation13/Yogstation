/datum/job/qm
	title = "Quartermaster"
	flag = QUARTERMASTER
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = CIVILIAN
	head_announce = list(RADIO_CHANNEL_SUPPLY)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#d7b088"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SUPPLY

	outfit = /datum/outfit/job/quartermaster

	alt_titles = list("Stock Controller", "Cargo Coordinator", "Shipping Overseer")

	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_EVA, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS) //yogs - qm is a department head and gets ACCESS_EVA, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS
	minimal_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MECH_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_VAULT, ACCESS_EVA, ACCESS_HEADS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_CAR

	display_order = JOB_DISPLAY_ORDER_QUARTERMASTER

	changed_maps = list("OmegaStation")

/datum/job/qm/proc/OmegaStationChanges()
	return TRUE

/datum/outfit/job/quartermaster
	name = "Quartermaster"
	jobtype = /datum/job/qm

	pda_type = /obj/item/pda/quartermaster

	ears = /obj/item/radio/headset/headset_cargo
	uniform = /obj/item/clothing/under/rank/cargo
	uniform_skirt = /obj/item/clothing/under/rank/cargo/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	glasses = /obj/item/clothing/glasses/sunglasses
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/export_scanner
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1, /obj/item/modular_computer/tablet/phone/preset/advanced/command=1) //yogs - qm is department head

	chameleon_extras = /obj/item/stamp/qm

