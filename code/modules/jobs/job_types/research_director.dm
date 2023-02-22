/datum/job/rd
	title = "Research Director"
	description = "Supervise research efforts, ensure Robotics is in working \
		order, make sure the AI and its Cyborgs aren't rogue, replacing them if \
		they are"
	flag = RD_JF
	orbit_icon = "user-graduate"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = MEDSCI
	head_announce = list("Science")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffddff"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_type_department = EXP_TYPE_SCIENCE
	exp_requirements = 720
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SCIENCE
	alt_titles = list("Chief Science Officer", "Head of Research", "Chief Technology Officer")

	outfit = /datum/outfit/job/rd

	added_access = list(ACCESS_CAPTAIN)
	base_access = list(ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
			            ACCESS_TOX_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS, ACCESS_MECH_SCIENCE,
			            ACCESS_RESEARCH, ACCESS_ROBO_CONTROL, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
			            ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM,
			            ACCESS_TECH_STORAGE, ACCESS_MINISAT, ACCESS_MAINT_TUNNELS, ACCESS_NETWORK)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SCI

	display_order = JOB_DISPLAY_ORDER_RESEARCH_DIRECTOR
	minimal_character_age = 26 //Barely knows more than actual scientists, just responsibility and AI things

	departments_list = list(
		/datum/job_department/science,
		/datum/job_department/command,
	)

	mail_goodies = list(
		/obj/item/storage/box/monkeycubes = 30,
		///obj/item/circuitboard/machine/sleeper/party = 3,
		/obj/item/borg/upgrade/ai = 2
	)

	smells_like = "theorhetical education"
	
	bounty_types = list(CIV_JOB_ROBO, CIV_JOB_SCI, CIV_JOB_XENO)

/datum/outfit/job/rd
	name = "Research Director"
	jobtype = /datum/job/rd

	id_type = /obj/item/card/id/silver
	pda_type = /obj/item/modular_computer/tablet/phone/preset/advanced/command/rd

	ears = /obj/item/radio/headset/heads/rd
	glasses = /obj/item/clothing/glasses/hud/diagnostic/sunglasses/rd
	uniform = /obj/item/clothing/under/rank/research_director
	uniform_skirt = /obj/item/clothing/under/rank/research_director/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/command
	suit = /obj/item/clothing/suit/toggle/labcoat
	l_hand = /obj/item/clipboard
	l_pocket = /obj/item/laser_pointer
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1, /obj/item/analyzer/ranged=1) //yogs - removes sci budget

	backpack = /obj/item/storage/backpack/science
	satchel = /obj/item/storage/backpack/satchel/tox

	chameleon_extras = /obj/item/stamp/rd

/datum/outfit/job/rd/rig
	name = "Research Director (Hardsuit)"

	l_hand = null
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/rd
	suit_store = /obj/item/tank/internals/oxygen
	internals_slot = SLOT_S_STORE
