/datum/job/brigphysician
	title = "Brig Physician"
	flag = BRIGPHYS
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/brigphysician

	alt_titles = list("Security Medic", "Security Medical Support", "Penitentiary Medical Care Unit", "Junior Brig Physician", "Detention Center Health Officer") 

	minimal_character_age = 24 // "According to age statistics published by the Association of American Medical Colleges, the average age among medical students who matriculated at U.S. medical schools in the 2017-2018 school year was 24"

	added_access = list(ACCESS_SURGERY)
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_BRIG, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MEDICAL, ACCESS_BRIG_PHYS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_BRIG_PHYSICIAN

	changed_maps = list("OmegaStation", "EclipseStation")

/datum/job/brigphysician/proc/OmegaStationChanges()
	return TRUE

/datum/job/brigphysician/proc/EclipseStationChanges()
	total_positions = 2
	spawn_positions = 1

/datum/outfit/job/brigphysician
	name = "Brig Physician"
	jobtype = /datum/job/brigphysician

	pda_type = /obj/item/pda/physician

	backpack_contents = list(/obj/item/roller = 1)
	ears = /obj/item/radio/headset/headset_medsec
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/jackboots
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
