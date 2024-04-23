/datum/job/cmo
	title = "Chief Medical Officer"
	description = "Coordinate doctors and other medbay employees, ensure they \
		know how to save lives, check for injuries on the crew monitor."
	orbit_icon = "user-md"
	department_head = list("Captain")
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	head_announce = list(RADIO_CHANNEL_MEDICAL)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	req_admin_notify = 1
	minimal_player_age = 7
	exp_requirements = 1500 //25 hours
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_MEDICAL
	alt_titles = list("Medical Director", "Head of Medical")

	outfit = /datum/outfit/job/cmo

	added_access = list(ACCESS_CAPTAIN) //Yogs: Gives CMO access to the brig physicians locker
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_HEADS, ACCESS_MINERAL_STOREROOM,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE, ACCESS_MECH_MEDICAL,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_BRIG_PHYS, ACCESS_PARAMEDIC, ACCESS_PSYCH) //Yogs: Gives CMO access to the brig physicians locker
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_MED

	display_order = JOB_DISPLAY_ORDER_CHIEF_MEDICAL_OFFICER
	minimal_character_age = 30 //Do you knoW HOW MANY JOBS YOU HAVE TO KNOW TO DO?? This should really be like 35 or something

	departments_list = list(
		/datum/job_department/medical,
		/datum/job_department/command,
	)

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/organ_spawner = 10,
		/obj/effect/spawner/lootdrop/memeorgans = 8,
		/obj/effect/spawner/lootdrop/surgery_tool_advanced = 4,
		/obj/item/statuebust/hippocratic = 2,
		/obj/effect/spawner/lootdrop/surgery_tool_alien = 1
	)

	minimal_lightup_areas = list(
		/area/crew_quarters/heads/cmo,
		/area/medical/chemistry,
		/area/medical/genetics,
		/area/medical/morgue,
		/area/medical/surgery,
		/area/storage/eva
	)

	smells_like = "blood-soaked stress"

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/cmo

	id_type = /obj/item/card/id/silver
	pda_type = /obj/item/modular_computer/tablet/phone/preset/advanced/command/cmo

	belt = /obj/item/storage/belt/medical/chief/full
	ears = /obj/item/radio/headset/heads/cmo
	uniform = /obj/item/clothing/under/rank/chief_medical_officer
	uniform_skirt = /obj/item/clothing/under/rank/chief_medical_officer/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/command
	suit = /obj/item/clothing/suit/toggle/labcoat/cmo
	l_hand = /obj/item/storage/firstaid/medical
	suit_store = /obj/item/flashlight/pen/paramedic/advanced
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses/cmo
	backpack_contents = list(/obj/item/melee/classic_baton/telescopic=1) //yogs - removes med budget
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med

	chameleon_extras = list(/obj/item/gun/syringe, /obj/item/stamp/cmo)

	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/cmo/hardsuit
	name = "Chief Medical Officer (Hardsuit)"

	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/medical
	suit_store = /obj/item/tank/internals/oxygen
	r_pocket = /obj/item/flashlight/pen/paramedic
