/datum/job/officer
	title = "Civil Protection Officer"
	description = "Keep the citizens in line, and in working condition."
	orbit_icon = "shield-halved"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Divisional Lead")
	faction = "Station"
	total_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	spawn_positions = 5 //Handled in /datum/controller/occupations/proc/setup_officer_positions()
	supervisors = "the Divisional Lead and District Administrator"
	minimal_player_age = 7
	exp_requirements = 0
	exp_type = EXP_TYPE_CREW

	cmode_music = 'sound/music/combat/apprehensionandevasion.ogg'

	outfit = /datum/outfit/job/officer

	added_access = list(ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_DETECTIVE, ACCESS_BRIG_PHYS)
	base_access = list(ACCESS_SECURITY, ACCESS_HYDROPONICS, ACCESS_SCIENCE, ACCESS_CARGO, ACCESS_SEC_BASIC, ACCESS_BRIG, ACCESS_WEAPONS_PERMIT, ACCESS_MEDICAL,
					ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MECH_SECURITY) // See /datum/job/officer/get_access()

	paycheck = PAYCHECK_HARD
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_OFFICER
	minimal_character_age = 18 //Just a few months of boot camp, not a whole year
	var/static/list/used_numbers = list()

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
	H.faction += "combine"
	var/r = rand(100,9000)
	while (used_numbers.Find(r))
		r = rand(100,9000)
	used_numbers += r
	if(istype(H.wear_id, /obj/item/card/id))
		var/obj/item/card/id/ID = H.wear_id
		ID.registered_name = "CP-[used_numbers[used_numbers.len]]"
		ID.update_label()
/*
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

	if(department)
		to_chat(M, "<b>You have been assigned to [department]!</b>")
	else
		to_chat(M, "<b>You have not been assigned to any department. Patrol the halls and help where needed.</b>")

*/

/datum/outfit/job/officer
	name = "Civil Protection Officer"
	jobtype = /datum/job/officer

	ears = /obj/item/radio/headset/civilprotection
	uniform = /obj/item/clothing/under/combine/civilprotection
	gloves = /obj/item/clothing/gloves/color/civilprotection
	suit = /obj/item/clothing/suit/armor/civilprotection
	suit_store = /obj/item/gun/ballistic/automatic/pistol/usp
	shoes = /obj/item/clothing/shoes/jackboots/civilprotection
	glasses = /obj/item/clothing/glasses/hud/security/civilprotection

	mask = /obj/item/clothing/mask/gas/civilprotection
	belt = /obj/item/storage/belt/civilprotection/full

	implants = list(/obj/item/implant/mindshield, /obj/item/implant/biosig_ert)



/obj/item/radio/headset/headset_sec/alt/department/Initialize(mapload)
	. = ..()
	wires = new/datum/wires/radio(src)
	secure_radio_connections = new
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
