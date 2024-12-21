/datum/job/officer
	title = "Security Officer"
	description = "Protect company assets, follow Space Law\
		, eat donuts."
	orbit_icon = "shield-halved"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security")
	faction = "Station"
	total_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	spawn_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	supervisors = "the head of security, and the head of your assigned department (if applicable)"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/security

	alt_titles = list("Threat Response Officer", "Civilian Protection Officer", "Corporate Officer", "Peacekeeper")

	added_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_DETECTIVE, ACCESS_BRIG_PHYS)
	base_access = list(ACCESS_SECURITY, ACCESS_SEC_BASIC, ACCESS_BRIG, ACCESS_WEAPONS_PERMIT,
					ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MECH_SECURITY) // See /datum/job/officer/get_access()

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER
	minimal_character_age = 18 //Just a few months of boot camp, not a whole year

	departments_list = list(
		/datum/job_department/security,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/donut/jelly = 10,
		/obj/item/reagent_containers/food/snacks/donut/meat = 10,
		/obj/item/reagent_containers/food/snacks/donut/spaghetti = 5,
		/obj/item/grenade/chem_grenade/teargas = 4,
		/obj/item/grenade/flashbang = 2,
		/obj/item/clothing/mask/gas/sechailer/swat = 1
	)

	minimal_lightup_areas = list(/area/construction/mining/aux_base)

	smells_like = "donuts"

/datum/job/officer/get_access()
	var/list/L = list()
	L |= ..() | check_config_for_sec_maint()
	return L

GLOBAL_LIST_INIT(available_depts_sec, list(SEC_DEPT_ENGINEERING, SEC_DEPT_MEDICAL, SEC_DEPT_SCIENCE, SEC_DEPT_SUPPLY, SEC_DEPT_SERVICE))

/datum/job/officer/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	// Assign department security
	var/department
	if(M && M.client && M.client.prefs)
		department = M.client?.prefs?.read_preference(/datum/preference/choiced/security_department)
		if(!LAZYLEN(GLOB.available_depts_sec) || department == "None")
			return
		else if(department in GLOB.available_depts_sec)
			LAZYREMOVE(GLOB.available_depts_sec, department)
		else
			department = pick_n_take(GLOB.available_depts_sec)
	var/ears = null
	var/accessory = null
	var/list/dep_access = null
	var/destination = null
	var/spawn_point = null
	switch(department)
		if(SEC_DEPT_SUPPLY)
			ears = /obj/item/radio/headset/headset_sec/alt/department/supply
			dep_access = list(ACCESS_CARGO, ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION)
			destination = /area/security/checkpoint/supply
			spawn_point = locate(/obj/effect/landmark/start/depsec/supply) in GLOB.department_security_spawns
			accessory = /obj/item/clothing/accessory/armband/cargo
			minimal_lightup_areas |= GLOB.supply_lightup_areas
		if(SEC_DEPT_ENGINEERING)
			ears = /obj/item/radio/headset/headset_sec/alt/department/engi
			dep_access = list(ACCESS_ENGINEERING, ACCESS_ATMOSPHERICS, ACCESS_CONSTRUCTION, ACCESS_TECH_STORAGE, ACCESS_TCOMMS)
			destination = /area/security/checkpoint/engineering
			spawn_point = locate(/obj/effect/landmark/start/depsec/engineering) in GLOB.department_security_spawns
			accessory = /obj/item/clothing/accessory/armband/engine
			minimal_lightup_areas |= GLOB.engineering_lightup_areas
		if(SEC_DEPT_MEDICAL)
			ears = /obj/item/radio/headset/headset_sec/alt/department/med
			dep_access = list(ACCESS_MEDICAL, ACCESS_SURGERY, ACCESS_PARAMEDIC, ACCESS_CHEMISTRY, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_PSYCHOLOGY, ACCESS_GENETICS)
			destination = /area/security/checkpoint/medical
			spawn_point = locate(/obj/effect/landmark/start/depsec/medical) in GLOB.department_security_spawns
			accessory =  /obj/item/clothing/accessory/armband/medblue
			minimal_lightup_areas |= GLOB.medical_lightup_areas
		if(SEC_DEPT_SCIENCE)
			ears = /obj/item/radio/headset/headset_sec/alt/department/sci
			dep_access = list(ACCESS_SCIENCE, ACCESS_TOXINS, ACCESS_EXPERIMENTATION, ACCESS_GENETICS, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY)
			destination = /area/security/checkpoint/science
			spawn_point = locate(/obj/effect/landmark/start/depsec/science) in GLOB.department_security_spawns
			accessory = /obj/item/clothing/accessory/armband/science
			minimal_lightup_areas |= GLOB.science_lightup_areas
		if(SEC_DEPT_SERVICE)
			ears = /obj/item/radio/headset/headset_sec/alt/department/service
			dep_access = list(ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_CLERK)
			destination = /area/security/checkpoint/service
			spawn_point = locate(/obj/effect/landmark/start/depsec/service) in GLOB.department_security_spawns
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

	var/teleport = 0
	if(!CONFIG_GET(flag/sec_start_brig))
		if(destination || spawn_point)
			teleport = 1
	if(teleport)
		var/turf/T
		if(spawn_point)
			T = get_turf(spawn_point)
			H.Move(T)
		else
			var/safety = 0
			while(safety < 25)
				T = pick(get_area_turfs(destination))
				if(T && !H.Move(T))
					safety += 1
					continue
				else
					break

	if(M?.client?.prefs)
		var/obj/item/badge/security/badge
		switch(M.client.prefs.exp[title] / 60)
			if(200 to INFINITY)
				badge = new /obj/item/badge/security/officer3
			if(50 to 200)
				badge = new /obj/item/badge/security/officer2
			else
				badge = new /obj/item/badge/security/officer1
		badge.owner_string = H.real_name
		var/obj/item/clothing/suit/my_suit = H.wear_suit
		my_suit.attach_badge(badge)

	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")



/datum/outfit/job/security
	name = "Security Officer"
	jobtype = /datum/job/officer

	pda_type = /obj/item/modular_computer/tablet/pda/preset/security

	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/officer
	uniform_skirt = /obj/item/clothing/under/rank/security/officer/skirt
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/helmet/sec
	suit = /obj/item/clothing/suit/armor/vest/alt
	shoes = /obj/item/clothing/shoes/jackboots
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/assembly/flash/handheld
	backpack_contents = list(/obj/item/melee/baton/loaded=1)

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec
	box = /obj/item/storage/box/survival/security

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = list(/obj/item/gun/energy/disabler, /obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/head/helmet)
	//The helmet is necessary because /obj/item/clothing/head/helmet/sec is overwritten in the chameleon list by the standard helmet, which has the same name and icon state


/obj/item/radio/headset/headset_sec/alt/department/Initialize(mapload)
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = list()
	recalculateChannels()

/obj/item/radio/headset/headset_sec/alt/department/engi
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_eng

/obj/item/radio/headset/headset_sec/alt/department/supply
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_cargo

/obj/item/radio/headset/headset_sec/alt/department/med
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_med

/obj/item/radio/headset/headset_sec/alt/department/sci
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_sci

/obj/item/radio/headset/headset_sec/alt/department/service
	keyslot = new /obj/item/encryptionkey/headset_sec
	keyslot2 = new /obj/item/encryptionkey/headset_service
