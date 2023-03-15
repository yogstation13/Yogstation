/datum/job/network_admin
	title = "Network Admin"
	description = "Maintain and upgrade the AI, try not to break radio communications."
	flag = NETWORKADMIN
	orbit_icon = "satellite-dish"
	department_head = list("Chief Engineer", "Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief engineer and research director"
	selection_color = "#ffeeff"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("AI Tech Support", "SysOp")

	outfit = /datum/outfit/job/network_admin

	added_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)
	base_access = list(ACCESS_TCOMSAT, ACCESS_TCOM_ADMIN, ACCESS_TECH_STORAGE, ACCESS_RC_ANNOUNCE, ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE, ACCESS_NETWORK, ACCESS_RESEARCH, ACCESS_MINISAT, ACCESS_TOX)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI
	display_order = JOB_DISPLAY_ORDER_NETWORK_ADMIN
	minimal_character_age = 22 //Feasibly same level as engineer, mostly a data engineer instead of a mechanical or construction-based one, though is still capable of making certain machines

	departments_list = list(
		/datum/job_department/engineering,
	)

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/plushies = 20
	)

	smells_like = "thermal paste"

/datum/outfit/job/network_admin
	name = "Network Admin"
	jobtype = /datum/job/network_admin

	pda_type = /obj/item/modular_computer/tablet/pda/preset/basic

	l_hand = /obj/item/modular_computer/laptop/preset/network_admin
	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_network
	uniform = /obj/item/clothing/under/yogs/rank/network_admin
	suit = /obj/item/clothing/suit/hooded/wintercoat/engineering/tcomms
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/engineer

	pda_slot = SLOT_L_STORE
