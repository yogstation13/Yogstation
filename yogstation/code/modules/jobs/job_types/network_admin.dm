/datum/job/network_admin
	title = "Network Admin"
	flag = NETWORKADMIN
	department_head = list("Chief Engineer", "Research Director")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief engineer and research director"
	selection_color = "#fff5cc"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("AI Tech Support", "SysOp")

	outfit = /datum/outfit/job/network_admin

	added_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)
	base_access = list(ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN, ACCESS_TECH_STORAGE, ACCESS_RC_ANNOUNCE, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE, ACCESS_NETWORK, ACCESS_RESEARCH, ACCESS_MINISAT)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG
	display_order = JOB_DISPLAY_ORDER_NETWORK_ADMIN
	minimal_character_age = 22 //Feasibly same level as engineer, mostly a data engineer instead of a mechanical or construction-based one, though is still capable of making certain machines

	changed_maps = list("OmegaStation")

/datum/job/network_admin/proc/OmegaStationChanges()
	added_access = list()
	base_access = list(ACCESS_ENGINE, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN, ACCESS_RESEARCH, ACCESS_TOX)
	supervisors = "the captain and the head of personnel"

/datum/outfit/job/network_admin
	name = "Network Admin"
	jobtype = /datum/job/network_admin

	pda_type = /obj/item/pda/network_admin

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_network
	uniform = /obj/item/clothing/under/yogs/rank/network_admin
	suit = /obj/item/clothing/suit/hooded/wintercoat/engineering/tcomms
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/engineering
	backpack_contents = list(/obj/item/modular_computer/tablet/preset/advanced=1)

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer

	pda_slot = SLOT_L_STORE
