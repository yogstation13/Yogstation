/datum/job/hop
	title = "Labor Lead"
	description = "Organize work tasks for the citizens, and order any necessary materials you see fit."
	orbit_icon = "dog"
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list("City Administrator")
	head_announce = list(RADIO_CHANNEL_SUPPLY, RADIO_CHANNEL_SERVICE)
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the city administrator"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 0
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_CREW

	outfit = /datum/outfit/job/hop

	added_access = list(ACCESS_CAPTAIN)
	base_access = list(ACCESS_COMMAND, ACCESS_SERVICE, ACCESS_CARGO, ACCESS_HOP,
					ACCESS_CHANGE_IDS, ACCESS_PERSONAL_LOCKERS, ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE,
					ACCESS_CREMATORIUM, ACCESS_LIBRARY, ACCESS_BAR, ACCESS_KITCHEN,
					ACCESS_HYDROPONICS, ACCESS_JANITOR, ACCESS_LAWYER, ACCESS_CLERK,
					ACCESS_CARGO_BAY, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_QM,
					ACCESS_MECH_MINING, ACCESS_SEC_BASIC, ACCESS_MAINT_TUNNELS, ACCESS_EVA,
					ACCESS_WEAPONS_PERMIT, ACCESS_AI_SAT, ACCESS_MEDICAL, ACCESS_ENGINEERING,
					ACCESS_AUX_BASE, ACCESS_SCIENCE, ACCESS_MECH_SECURITY, ACCESS_MECH_MEDICAL,
					ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_VAULT, ACCESS_RC_ANNOUNCE,
					ACCESS_KEYCARD_AUTH)



	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL
	minimal_character_age = 26 //Baseline age requirement and competency, as well as ability to assume leadership in shite situations

	departments_list = list(
		/datum/job_department/service,
		/datum/job_department/command,
	)

	smells_like = "bureaucracy"

// Special handling to avoid lighting up the entirety of supply whenever there's a HoP.
/datum/job/head_of_personnel/areas_to_light_up(minimal_access = TRUE)
	return minimal_lightup_areas | GLOB.command_lightup_areas

//only pet worth reviving
/datum/job/hop/get_mail_goodies(mob/recipient)
	. = ..()
	// Strange Reagent if the pet is dead.
	for(var/mob/living/simple_animal/pet/dog/corgi/Ian/staff_pet in GLOB.dead_mob_list)
		. += list(/datum/reagent/medicine/strange_reagent = 20)
		break

/datum/job/hop/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	H.faction += "combine"

/datum/outfit/job/hop
	name = "Labor Lead"
	jobtype = /datum/job/hop

	id_type = /obj/item/card/id/silver


	ears = /obj/item/radio/headset/heads/hop
	uniform = /obj/item/clothing/under/citizen
	head = /obj/item/clothing/head/hardhat
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/melee/classic_baton/telescopic

	implants = list(/obj/item/implant/mindshield)
