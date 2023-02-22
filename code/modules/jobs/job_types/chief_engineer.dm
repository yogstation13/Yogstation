/datum/job/chief_engineer
	title = "Chief Engineer"
	description = "Coordinate engineering, ensure equipment doesn't get stolen, \
		make sure the Supermatter doesn't blow up, maintain telecommunications."
	flag = CHIEF
	orbit_icon = "user-astronaut"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = ENGSEC
	head_announce = list("Engineering")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ffeeaa"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 720
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_ENGINEERING
	alt_titles = list("Engineering Director", "Head of Engineering", "Senior Engineer")

	outfit = /datum/outfit/job/ce

	added_access = list(ACCESS_CAPTAIN)
	base_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_SECURE_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
			            ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EVA, ACCESS_TCOM_ADMIN,
			            ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS, ACCESS_MINISAT, ACCESS_MECH_ENGINE,
			            ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_ENG

	bounty_types = CIV_JOB_ATMOS

	display_order = JOB_DISPLAY_ORDER_CHIEF_ENGINEER
	minimal_character_age = 30 //Combine all the jobs together; that's a lot of physics, mechanical, electrical, and power-based knowledge

	departments_list = list(
		/datum/job_department/engineering,
		/datum/job_department/command,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/cracker = 25, //you know. for poly
		/obj/item/stack/sheet/mineral/diamond = 15,
		///obj/item/stack/sheet/mineral/uranium/five = 15,
		///obj/item/stack/sheet/mineral/plasma/five = 15,
		/obj/item/stack/sheet/mineral/gold = 15
		///obj/effect/spawner/random/engineering/tool_advanced = 3
	)

	smells_like = "industry leadership"

/datum/outfit/job/ce
	name = "Chief Engineer"
	jobtype = /datum/job/chief_engineer

	id_type = /obj/item/card/id/silver
	pda_type = /obj/item/modular_computer/tablet/phone/preset/advanced/command/ce

	belt = /obj/item/storage/belt/utility/chief/full
	ears = /obj/item/radio/headset/heads/ce
	uniform = /obj/item/clothing/under/rank/chief_engineer
	uniform_skirt = /obj/item/clothing/under/rank/chief_engineer/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/command
	head = /obj/item/clothing/head/hardhat/white
	gloves = /obj/item/clothing/gloves/color/black
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1) //yogs - removes eng budget
	glasses = /obj/item/clothing/glasses/meson/sunglasses

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer
	chameleon_extras = /obj/item/stamp/ce

	pda_slot = SLOT_L_STORE

/datum/outfit/job/ce/rig
	name = "Chief Engineer (Hardsuit)"

	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/engine/elite
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit_store = /obj/item/tank/internals/oxygen
	glasses = /obj/item/clothing/glasses/meson/sunglasses
	gloves = /obj/item/clothing/gloves/color/yellow
	head = null
	internals_slot = SLOT_S_STORE
