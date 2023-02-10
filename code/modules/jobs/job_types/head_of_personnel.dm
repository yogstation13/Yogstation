/datum/job/hop
	title = "Head of Personnel"
	description = "Alter access on ID cards, manage civil and supply departments, \
		protect Ian, run the station when the captain dies."
	flag = HOP
	orbit_icon = "dog"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("Captain")
	department_flag = CIVILIAN
	head_announce = list(RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SERVICE)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the captain"
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 720
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_SUPPLY
	alt_titles = list("Chief of Staff", "Head of Internal Affairs", "First Officer")

	outfit = /datum/outfit/job/hop

	added_access = list(ACCESS_CAPTAIN)
	base_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_COURT, ACCESS_WEAPONS,
			            ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
			            ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
			            ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
						ACCESS_MECH_MINING, ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY, ACCESS_MECH_MEDICAL,
			            ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_VAULT, ACCESS_MINING_STATION,
			            ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_GATEWAY, ACCESS_MINERAL_STOREROOM, ACCESS_MANUFACTURING) //yogs - added ACCESS_MANUFACTURING as it's the clerk's
	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL
	minimal_character_age = 26 //Baseline age requirement and competency, as well as ability to assume leadership in shite situations

	departments_list = list(
		/datum/job_department/service,
		/datum/job_department/command,
	)

	mail_goodies = list(
		/obj/item/card/id/silver = 10,
		/obj/item/stack/sheet/bone = 5
	)

	smells_like = "bureaucracy"

//only pet worth reviving
/datum/job/hop/get_mail_goodies(mob/recipient)
	. = ..()
	// Strange Reagent if the pet is dead.
	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/staff_pet in GLOB.dead_mob_list)
		. += list(/datum/reagent/medicine/strange_reagent = 20)
		break

/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/hop

	id_type = /obj/item/card/id/silver
	pda_type = /obj/item/modular_computer/tablet/phone/preset/advanced/command/hop

	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/rank/head_of_personnel
	uniform_skirt = /obj/item/clothing/under/rank/head_of_personnel/skirt
	shoes = /obj/item/clothing/shoes/sneakers/brown
	digitigrade_shoes = /obj/item/clothing/shoes/xeno_wraps/command
	head = /obj/item/clothing/head/hopcap
	backpack_contents = list(/obj/item/storage/box/ids=1,\
		/obj/item/melee/classic_baton/telescopic=1) //yogs - removes serv budget


	chameleon_extras = list(/obj/item/gun/energy/e_gun, /obj/item/stamp/hop)
