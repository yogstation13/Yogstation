/datum/job/captain
	title = "Captain"
	flag = CAPTAIN
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY|DEADMIN_POSITION_CRITICAL
	department_head = list("CentCom")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "NanoTrasen officers and Space law" //Changed to officer to separate from CentCom officials being their superior.
	selection_color = "#ccccff"
	req_admin_notify = 1
	space_law_notify = 1 //Yogs
	minimal_player_age = 14
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND
	alt_titles = list("Station Commander", "Facility Director")

	outfit = /datum/outfit/job/captain

	added_access = list() 			//See get_access()
	base_access = list() 	//See get_access()
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	mind_traits = list(TRAIT_DISK_VERIFIER)

	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	minimal_character_age = 35 //Feasibly expected to know everything and potentially do anything. Leagues of experience, briefing, training, and trust required for this role

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, .proc/minor_announce, "Captain [H.real_name] on deck!"))

/datum/outfit/job/captain
	name = "Captain"
	jobtype = /datum/job/captain

	id_type = /obj/item/card/id/gold
	pda_type = /obj/item/modular_computer/tablet/phone/preset/advanced/command/cap
	
	glasses = /obj/item/clothing/glasses/sunglasses
	ears = /obj/item/radio/headset/heads/captain/alt
	gloves = /obj/item/clothing/gloves/color/captain
	uniform =  /obj/item/clothing/under/rank/captain
	uniform_skirt = /obj/item/clothing/under/rank/captain/skirt
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/command
	head = /obj/item/clothing/head/caphat
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1, /obj/item/station_charter=1, /obj/item/gun/energy/e_gun=1) //yogs - adds egun/removes civ budget

	backpack = /obj/item/storage/backpack/captain
	satchel = /obj/item/storage/backpack/satchel/cap
	duffelbag = /obj/item/storage/backpack/duffelbag/captain

	implants = list(/obj/item/implant/mindshield)
	accessory = /obj/item/clothing/accessory/medal/gold/captain

	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/captain)

/datum/outfit/job/captain/hardsuit
	name = "Captain (Hardsuit)"

	mask = /obj/item/clothing/mask/gas/sechailer
	suit = /obj/item/clothing/suit/space/hardsuit/swat/captain
	suit_store = /obj/item/tank/internals/oxygen
