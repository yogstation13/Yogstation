/datum/job/blueshield
	title = "Blueshield"
	flag = BLUESHIELD
	department_head = list("Captain")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the Captain"
	selection_color = "#ddddff"

	outfit = /datum/outfit/job/blueshield

	access = list(ACCESS_BLUESHIELD, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TELEPORTER, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_CMO, ACCESS_RD, ACCESS_QM, ACCESS_WEAPONS, ACCESS_CE, ACCESS_HOP, ACCESS_HOS, ACCESS_KEYCARD_AUTH, ACCESS_CLONING)
	minimal_access = list(ACCESS_BLUESHIELD, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG	, ACCESS_COURT, ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TELEPORTER, ACCESS_HEADS, ACCESS_CAPTAIN, ACCESS_ROBOTICS, ACCESS_CMO, ACCESS_RD, ACCESS_QM, ACCESS_WEAPONS, ACCESS_CE, ACCESS_HOP, ACCESS_HOS, ACCESS_KEYCARD_AUTH, ACCESS_CLONING)
	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	display_order = JOB_DISPLAY_ORDER_BLUESHIELD

/datum/outfit/job/blueshield
	name = "Blueshield"
	jobtype = /datum/job/blueshield
	
	uniform = /obj/item/clothing/under/rank/blueshield
	suit = /obj/item/clothing/suit/armor/vest/blueshield
	gloves = /obj/item/clothing/gloves/combat
	head = /obj/item/clothing/head/beret/sec/navyofficer
	shoes = /obj/item/clothing/shoes/jackboots
	ears = /obj/item/radio/headset/heads/blueshield/alt
	belt = /obj/item/pda/security
	backpack_contents = list(/obj/item/gun/energy/gun/e_gun = 1)
	implants = list(/obj/item/implant/mindshield)
	backpack = /obj/item/storage/backpack/blueshield
	satchel = /obj/item/storage/backpack/satchel_blueshield
	dufflebag = /obj/item/storage/backpack/duffel/blueshield