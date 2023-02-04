/datum/job/synthetic
	title = "Synthetic"
	description = "Watch over the crew, carry out mundane tasks that nobody else want to. Do no harm. NOTE: Currently not playable"
	flag = SYNTHETIC_JF
	orbit_icon = "eye"
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON|DEADMIN_POSITION_CRITICAL
	department_head = list("AI")
	department_flag = ENGSEC
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	supervisors = "the AI"
	selection_color = "#ddffdd"
	minimal_player_age = 7
	exp_requirements = 300
	exp_type = EXP_TYPE_CREW
	exp_type_department = EXP_TYPE_COMMAND

	outfit = /datum/outfit/job/synthetic

	added_access = list()
	base_access = list()
	paycheck = 0
	paycheck_department = ACCOUNT_SCI
	mind_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SYNTHETIC

	departments_list = list(
		/datum/job_department/silicon,
	)


	mail_goodies = list()

	smells_like = "calculated machinery"
	alt_titles = list()

	forced_species = /datum/species/wy_synth

/datum/job/synthetic/get_access()
	return get_all_accesses()


/datum/outfit/job/synthetic
	name = "Synthetic"

	jobtype = /datum/job/synthetic
	ears = /obj/item/radio/headset/headset_synthetic

	pda_type = null
	id_type = /obj/item/card/id/synthetic

/datum/outfit/job/synthetic/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()

	H.w_uniform.has_sensors = FALSE
