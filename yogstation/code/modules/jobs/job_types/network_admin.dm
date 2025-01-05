/datum/job/network_admin
	title = "Network Admin"
	description = "Maintain and upgrade the AI, try not to break radio communications."
	orbit_icon = "satellite-dish"
	department_head = list("Chief Engineer", "Research Director")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief engineer and research director"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("AI Tech Support", "SysOp")

	outfit = /datum/outfit/job/network_admin

	added_access = list(ACCESS_ENGINEERING, ACCESS_ENGINE_EQUIP, ACCESS_MAINT_TUNNELS)
	base_access = list(ACCESS_SCIENCE, ACCESS_TCOMMS, ACCESS_TCOMMS_ADMIN, ACCESS_TECH_STORAGE, ACCESS_RC_ANNOUNCE,
					ACCESS_CONSTRUCTION, ACCESS_MECH_ENGINE, ACCESS_RESEARCH, ACCESS_AI_SAT)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI
	display_order = JOB_DISPLAY_ORDER_NETWORK_ADMIN
	minimal_character_age = 22 //Feasibly same level as engineer, mostly a data engineer instead of a mechanical or construction-based one, though is still capable of making certain machines

	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_MID,
		SKILL_SCIENCE = EXP_MID,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = 2

	departments_list = list(
		/datum/job_department/engineering,
	)

	mail_goodies = list(
		/obj/effect/spawner/lootdrop/plushies = 20,
		/obj/item/pizzabox = 10,
		/obj/item/ai_cpu/experimental = 5
	)

	smells_like = "thermal paste"

/datum/outfit/job/network_admin
	name = "Network Admin"
	jobtype = /datum/job/network_admin

	pda_type = /obj/item/modular_computer/tablet/pda/preset/network_admin

	l_hand = /obj/item/modular_computer/laptop/preset/network_admin
	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_network
	uniform = /obj/item/clothing/under/yogs/rank/network_admin
	uniform_skirt = /obj/item/clothing/under/yogs/rank/network_admin/skirt
	suit = /obj/item/clothing/suit/hooded/wintercoat/engineering/tcomms
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes/workboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/engineering

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

	pda_slot = ITEM_SLOT_LPOCKET
