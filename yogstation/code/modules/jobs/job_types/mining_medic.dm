/datum/job/miningmedic
	title = "Mining Medic"
	flag = MMEDIC
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer and the quartermaster"
	selection_color = "#d4ebf2"

	outfit = /datum/outfit/job/miningmedic

	alt_titles = list("Mining Medical Support", "Lavaland Medical Care Unit", "Junior Mining Medic", "Planetside Health Officer")

	minimal_character_age = 26 //Matches MD

	added_access = list(ACCESS_SURGERY, ACCESS_CARGO)
	base_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MAILSORTING, ACCESS_MINERAL_STOREROOM, ACCESS_MECH_MINING, ACCESS_MECH_MEDICAL)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED
	display_order = JOB_DISPLAY_ORDER_MINING_MEDIC

	changed_maps = list("EclipseStation")

/datum/job/miningmedic/proc/EclipseStationChanges()
	total_positions = 2
	spawn_positions = 1

/datum/outfit/job/miningmedic
	name = "Mining Medic"
	jobtype = /datum/job/miningmedic
	
	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic

	backpack_contents = list(/obj/item/roller = 1,\
		/obj/item/kitchen/knife/combat/survival = 1)
	belt = /obj/item/storage/belt/medical/mining
	ears = /obj/item/radio/headset/headset_medcargo
	glasses = /obj/item/clothing/glasses/hud/health/meson
	shoes = /obj/item/clothing/shoes/workboots/mining
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/medical
	suit = /obj/item/clothing/suit/toggle/labcoat/emt/explorer
	uniform = /obj/item/clothing/under/yogs/rank/miner/medic
	l_hand = /obj/item/storage/firstaid/hypospray/qmc
	gloves = /obj/item/clothing/gloves/color/latex
	head = /obj/item/clothing/head/soft/emt/mining
	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel/med
	duffelbag = /obj/item/storage/backpack/duffelbag/med
	box = /obj/item/storage/box/survival_mining
	pda_slot = SLOT_L_STORE
