/datum/job/brigphysician
	title = "Brig Physician"
	flag = BRIGPHYS // check this
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and the head of security"
	selection_color = "#ffeeee"

	outfit = /datum/outfit/job/brigphysician

	minimal_character_age = 24 // "According to age statistics published by the Association of American Medical Colleges, the average age among medical students who matriculated at U.S. medical schools in the 2017-2018 school year was 24"

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_MECH_MEDICAL, ACCESS_MECH_SECURITY, ACCESS_BRIG_PHYS)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MEDICAL, ACCESS_BRIG_PHYS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_BRIG_PHYSICIAN

	changed_maps = list("EclipseStation")

/datum/job/brigphysician/proc/EclipseStationChanges()
	total_positions = 2
	spawn_positions = 1

/datum/outfit/job/brigphysician
	name = "Brig Physician"
	jobtype = /datum/job/brigphysician

	backpack_contents = list(/obj/item/roller = 1)
	belt = /obj/item/pda/physician
	ears = /obj/item/radio/headset/headset_medsec
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	uniform = /obj/item/clothing/under/yogs/rank/miner/medic
	suit = /obj/item/clothing/suit/toggle/labcoat/emt/physician
	l_hand = /obj/item/storage/firstaid/regular
	gloves = /obj/item/clothing/gloves/color/latex
	head = /obj/item/clothing/head/soft/emt/phys
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival

	implants = list(/obj/item/implant/mindshield)
