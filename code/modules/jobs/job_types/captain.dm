/datum/job/captain
	title = "City Administrator"
	description = "Be responsible for the city, manage your underlings, \
		keep the city functioning, be prepared to do anything and everything or die \
		horribly trying."
	orbit_icon = "crown"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY|DEADMIN_POSITION_CRITICAL
	department_head = list("CentCom")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "Overwatch"
	req_admin_notify = 1
	space_law_notify = 1 //Yogs
	minimal_player_age = 14
	exp_requirements = 600 //10 hours
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND

	outfit = /datum/outfit/job/captain

	added_access = list() 			//See get_access()
	base_access = list() 	//See get_access()
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SEC

	department_for_prefs = /datum/job_department/captain
	departments_list = list(
		/datum/job_department/command,
	)

	mind_traits = list(TRAIT_DISK_VERIFIER)

	mail_goodies = list(
		/obj/item/clothing/mask/cigarette/cigar/havana = 20,
		///obj/item/storage/fancy/cigarettes/cigars/havana = 15,
		/obj/item/reagent_containers/food/drinks/bottle/champagne = 10,
		/obj/item/fakeartefact = 5,
		/obj/item/skub = 1,
		/obj/item/greentext = 1
	)
	
	minimal_lightup_areas = list(
		/area/crew_quarters/heads/captain,
		/area/crew_quarters/heads/hop,
		/area/security
	)

	display_order = JOB_DISPLAY_ORDER_CAPTAIN
	minimal_character_age = 35 //Feasibly expected to know everything and potentially do anything. Leagues of experience, briefing, training, and trust required for this role

	smells_like = "unquestionable leadership"

/datum/job/captain/get_access()
	return get_all_accesses()

/datum/job/captain/announce(mob/living/carbon/human/H)
	..()
	SSticker.OnRoundstart(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(minor_announce), "City Administrator [H.real_name] will be managing the city."))

/datum/outfit/job/captain
	name = "City Administrator"
	jobtype = /datum/job/captain

	id_type = /obj/item/card/id/gold

	ears = /obj/item/radio/headset/heads/captain/alt
	uniform =  /obj/item/clothing/under/administrator
	shoes = /obj/item/clothing/shoes/sneakers/brown

	belt = /obj/item/melee/classic_baton/telescopic

	implants = list(/obj/item/implant/mindshield)

/datum/outfit/job/captain/hardsuit
	name = "City Administrator (Hardsuit)"

