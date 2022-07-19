/datum/job/cmo
	title = "Chief Medical Officer"
	flag = CMO_JF
	department_head = list("Captain")
	department_flag = MEDSCI
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	head_announce = list(RADIO_CHANNEL_MEDICAL)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#c1e1ec"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 720
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MEDICAL
	alt_titles = list("Medical Director", "Head of Medical")

	outfit = /datum/outfit/job/cmo

	added_access = list(ACCESS_CAPTAIN) //Yogs: Gives CMO access to the brig physicians locker
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_HEADS, ACCESS_MINERAL_STOREROOM,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE, ACCESS_MECH_MEDICAL,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_BRIG_PHYS, ACCESS_PARAMEDIC) //Yogs: Gives CMO access to the brig physicians locker
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	minimal_character_age = 30 //Do you knoW HOW MANY JOBS YOU HAVE TO KNOW TO DO?? This should really be like 35 or something

	changed_maps = list("OmegaStation")

/datum/job/cmo/proc/OmegaStationChanges()
	return TRUE

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/cmo

	id_type = /obj/item/card/id/silver
	pda_type = /obj/item/pda/heads/cmo

	belt = /obj/item/storage/belt/medical/chief/full
	ears = /obj/item/radio/headset/heads/cmo
	uniform = /obj/item/clothing/under/rank/chief_medical_officer
	uniform_skirt = /obj/item/clothing/under/rank/chief_medical_officer/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/command
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	l_hand = /obj/item/storage/firstaid/medical
	suit_store = /obj/item/flashlight/pen/paramedic
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1, /obj/item/modular_computer/tablet/phone/preset/advanced/command=1) //yogs - removes med budget

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = list(/obj/item/gun/syringe, /obj/item/stamp/cmo)

	pda_slot = SLOT_L_STORE

/datum/outfit/job/cmo/hardsuit
	name = "Chief Medical Officer (Hardsuit)"

	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/medical
	suit_store = /obj/item/tank/internals/oxygen
	r_pocket = /obj/item/flashlight/pen/paramedic
