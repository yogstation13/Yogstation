/datum/job/detective
	title = "Detective"
	description = "Investigate crimes, gather evidence, perform interrogations, \
		look badass, smoke cigarettes."
	orbit_icon = "user-secret"
	auto_deadmin_role_flags = DEADMIN_POSITION_SECURITY
	department_head = list("Head of Security")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of security"
	minimal_player_age = 7
	exp_requirements = 180
	exp_type = EXP_TYPE_SECURITY

	outfit = /datum/outfit/job/detective

	alt_titles = list("Forensic Analyst", "Private Eye")

	added_access = list(ACCESS_EXTERNAL_AIRLOCKS)
	base_access = list(ACCESS_SEC_BASIC, ACCESS_DETECTIVE, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_BRIG, ACCESS_WEAPONS_PERMIT, ACCESS_MECH_SECURITY)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SEC
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_DETECTIVE
	minimal_character_age = 22 //Understanding of forensics, crime analysis, and theory. Less of a grunt officer and more of an intellectual, theoretically, despite how this is never reflected in-game

	base_skills = list(
		SKILL_PHYSIOLOGY = EXP_MID,
		SKILL_MECHANICAL = EXP_NONE,
		SKILL_TECHNICAL = EXP_NONE,
		SKILL_SCIENCE = EXP_NONE,
		SKILL_FITNESS = EXP_MID,
	)
	skill_points = 2

	departments_list = list(
		/datum/job_department/security,
	)

	mail_goodies = list(
		///obj/item/storage/fancy/cigarettes = 25,
		/obj/item/ammo_box/c38/rubber = 25,
		/obj/item/ammo_box/c38 = 5,
		///obj/item/ammo_box/c38/dumdum = 5,
		///obj/item/ammo_box/c38/match = 5,
		///obj/item/storage/belt/holster/detective/full = 1
	)
	
	minimal_lightup_areas = list(/area/medical/morgue, /area/security/detectives_office)

	smells_like = "whisky-soaked despair"

/datum/job/detective/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	if(M?.client?.prefs)
		var/obj/item/badge/security/badge
		switch(M.client.prefs.exp[title] / 60)
			if(200 to INFINITY)
				badge = new /obj/item/badge/security/det3
			if(50 to 200)
				badge = new /obj/item/badge/security/det2
			else
				badge = new /obj/item/badge/security/det1
		badge.owner_string = H.real_name
		var/obj/item/clothing/suit/my_suit = H.wear_suit
		my_suit.attach_badge(badge)

/datum/outfit/job/detective
	name = "Detective"
	jobtype = /datum/job/detective

	pda_type = /obj/item/modular_computer/tablet/pda/preset/security/detective

	ears = /obj/item/radio/headset/headset_sec/alt
	uniform = /obj/item/clothing/under/rank/security/detective
	uniform_skirt = /obj/item/clothing/under/rank/security/detective/skirt
	neck = /obj/item/clothing/neck/tie/detective
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/jackboots
	suit = /obj/item/clothing/suit/det_suit
	gloves = /obj/item/clothing/gloves/color/black/forensic
	head = /obj/item/clothing/head/fedora/det_hat
	l_pocket = /obj/item/toy/crayon/white
	r_pocket = /obj/item/lighter
	backpack_contents = list(/obj/item/storage/box/evidence=1,\
		/obj/item/detective_scanner=1,\
		/obj/item/melee/classic_baton=1)
	mask = /obj/item/clothing/mask/cigarette

	implants = list(/obj/item/implant/mindshield)

	chameleon_extras = list(/obj/item/gun/ballistic/revolver/detective, /obj/item/clothing/glasses/sunglasses)

/datum/outfit/job/detective/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	var/obj/item/clothing/mask/cigarette/cig = H.wear_mask
	if(istype(cig)) //Some species specfic changes can mess this up (plasmamen)
		cig.light("")

	if(visualsOnly)
		return

