/datum/job/engineer
	title = "Station Engineer"
	description = "Start the Supermatter, wire the solars, repair station hull \
		and wiring damage."
	orbit_icon = "gears"
	department_head = list("Chief Engineer")
	faction = "Station"
	total_positions = 5
	spawn_positions = 5
	supervisors = "the chief engineer"
	exp_requirements = 180
	exp_type = EXP_TYPE_CREW
	alt_titles = list("Engine Technician", "Solar Engineer", "Project Engineer", "Junior Engineer", "Construction Specialist")

	outfit = /datum/outfit/job/engineer

	added_access = list(ACCESS_ATMOSPHERICS, ACCESS_SCIENCE, ACCESS_RESEARCH)
	base_access = list(ACCESS_ENGINEERING, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_MECH_ENGINE,
						ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_AUX_BASE)

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_ENG

	display_order = JOB_DISPLAY_ORDER_STATION_ENGINEER
	minimal_character_age = 22 //You need to know a lot of complicated stuff about engines, could theoretically just have a traditional bachelor's

	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_NONE,
		SKILL_MECHANICAL = EXP_MID,
		SKILL_TECHNICAL = EXP_LOW,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_NONE,
	)
	skill_points = 3

	departments_list = list(
		/datum/job_department/engineering,
	)

	mail_goodies = list(
		/obj/item/stack/sheet/metal/fifty = 25,
		/obj/item/stack/sheet/glass/fifty = 25,
		/obj/item/holosign_creator/engineering = 8,
		/obj/item/rcd_ammo = 5,
		/obj/item/stack/sheet/plasteel/twenty = 5,
		/obj/item/clothing/head/hardhat/red/upgraded = 2,
		/obj/item/clothing/suit/space/hardsuit/engine = 1
	)

	lightup_areas = list(/area/engine/atmos)
	
	smells_like = "welding fuel"

GLOBAL_LIST_INIT(available_depts_eng, list(ENG_DEPT_MEDICAL, ENG_DEPT_SCIENCE, ENG_DEPT_SUPPLY, ENG_DEPT_SERVICE))

/datum/job/engineer/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign department engineering
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client.prefs.read_preference(/datum/preference/choiced/engineering_department)
		if(!LAZYLEN(GLOB.available_depts_eng) || department == "None")
			return
		else if(department in GLOB.available_depts_eng)
			LAZYREMOVE(GLOB.available_depts_eng, department)
		else
			department = pick_n_take(GLOB.available_depts_eng)
	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	switch(department)
		if(ENG_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_eng/department/supply
			dep_access = list(ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION)
			accessory = /obj/item/clothing/accessory/armband/cargo
			minimal_lightup_areas |= GLOB.supply_lightup_areas
		if(ENG_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_eng/department/med
			dep_access = list(ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_MORGUE, ACCESS_CLONING, ACCESS_GENETICS)
			accessory =  /obj/item/clothing/accessory/armband/medblue
			minimal_lightup_areas |= GLOB.medical_lightup_areas
		if(ENG_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_eng/department/sci
			dep_access = list(ACCESS_SCIENCE, ACCESS_TOXINS, ACCESS_TOXINS_STORAGE, ACCESS_EXPERIMENTATION, ACCESS_XENOBIOLOGY)
			accessory = /obj/item/clothing/accessory/armband/science
			minimal_lightup_areas |= GLOB.science_lightup_areas
		if(ENG_DEPT_SERVICE)
			ears = /obj/item/radio/headset/headset_eng/department/service
			dep_access = list(ACCESS_SERVICE, ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CLERK)
			accessory =  /obj/item/clothing/accessory/armband/service
			

	if(accessory)
		var/obj/item/clothing/under/U = H.w_uniform
		U.attach_accessory(new accessory)
	if(ears)
		if(H.ears)
			qdel(H.ears)
		H.equip_to_slot_or_del(new ears(H),ITEM_SLOT_EARS)

	var/obj/item/card/id/W = H.get_idcard()
	W.access |= dep_access

	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")

/datum/outfit/job/engineer
	name = "Station Engineer"
	jobtype = /datum/job/engineer

	pda_type = /obj/item/modular_computer/tablet/pda/preset/engineering

	belt = /obj/item/storage/belt/utility/full/engi
	ears = /obj/item/radio/headset/headset_eng
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	uniform_skirt = /obj/item/clothing/under/rank/engineering/engineer/skirt
	shoes = /obj/item/clothing/shoes/workboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/engineering
	head = /obj/item/clothing/head/hardhat
	r_pocket = /obj/item/t_scanner

	backpack = /obj/item/storage/backpack/industrial
	satchel = /obj/item/storage/backpack/satchel/eng
	duffelbag = /obj/item/storage/backpack/duffelbag/engineering
	box = /obj/item/storage/box/survival/engineer

	pda_slot = ITEM_SLOT_LPOCKET

/datum/outfit/job/engineer/gloved
	name = "Station Engineer (Gloves)"
	gloves = /obj/item/clothing/gloves/color/yellow

/datum/outfit/job/engineer/gloved/rig
	name = "Station Engineer (Hardsuit)"
	mask = /obj/item/clothing/mask/breath
	suit = /obj/item/clothing/suit/space/hardsuit/engine
	suit_store = /obj/item/tank/internals/oxygen
	head = null
	internals_slot = ITEM_SLOT_SUITSTORE

/obj/item/radio/headset/headset_eng/department/Initialize(mapload)
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = new
	recalculateChannels()

/obj/item/radio/headset/headset_eng/department/supply
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_eng/department/med
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_eng/department/sci
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_eng/department/service
	keyslot = new /obj/item/encryptionkey/headset_eng
	keyslot2 = new /obj/item/encryptionkey/headset_service
