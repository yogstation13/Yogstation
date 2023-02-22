/datum/job/brigphysician
	title = "Brig Physician"
	description = "Watch over the Brig and Prison Wing to ensure prisoners receive medical attention when needed."
	flag = BRIGPHYS
	orbit_icon = "suitcase-medical"
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#d4ebf2"
	minimal_player_age = 5 //seriously stop griefing
	exp_requirements = 100
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/brigphysician

	alt_titles = list("Security Medic", "Security Medical Support", "Penitentiary Medical Care Unit", "Junior Brig Physician", "Detention Center Health Officer") 

	minimal_character_age = 26 //Matches MD

	departments_list = list(
		/datum/job_department/medical,
		/datum/job_department/security,
	)

	added_access = list(ACCESS_SURGERY)
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_BRIG, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MECH_MEDICAL, ACCESS_BRIG_PHYS)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_BRIG_PHYSICIAN

	smells_like = "crimson guardianship"

	bounty_types = list(CIV_JOB_SEC, CIV_JOB_MED)

/datum/outfit/job/brigphysician
	name = "Brig Physician"
	jobtype = /datum/job/brigphysician

	pda_type = /obj/item/modular_computer/tablet/pda/preset/paramed

	backpack_contents = list(/obj/item/roller = 1)
	ears = /obj/item/radio/headset/headset_medsec
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	shoes = /obj/item/clothing/shoes/jackboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/jackboots
	uniform = /obj/item/clothing/under/yogs/rank/miner/medic
	uniform_skirt = /obj/item/clothing/under/yogs/rank/physician/white/skirt
	suit = /obj/item/clothing/suit/toggle/labcoat/emt/physician
	l_hand = /obj/item/storage/firstaid/regular
	r_hand = /obj/item/modular_computer/laptop/preset/paramedic/brig_physician
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	head = /obj/item/clothing/head/soft/emt/phys
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival

	implants = list(/obj/item/implant/mindshield)
