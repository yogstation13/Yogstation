/datum/job/synthetic
	title = "Synthetic"
	description = "Watch over the crew, carry out mundane tasks that nobody else want to. Do no harm."
	orbit_icon = "eye"
	auto_deadmin_role_flags = DEADMIN_POSITION_SILICON|DEADMIN_POSITION_CRITICAL
	department_head = list("AI")
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the AI"
	selection_color = "#ddffdd"
	minimal_player_age = 30
	exp_requirements = 900
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

/datum/job/synthetic/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()

	addtimer(CALLBACK(src, .proc/synth_name_choose, H, M), 1 SECONDS,)

/datum/job/synthetic/proc/synth_name_choose(mob/living/H, mob/M)
	var/newname = sanitize_name(reject_bad_text(stripped_input(M, "Please input your name.", "Name change", H.real_name, MAX_NAME_LEN)))

	H.fully_replace_character_name(H.real_name, newname)
	if(iscarbon(H)) //doing these two JUST to be sure you dont have edge cases of your DNA and mind not matching your new name, somehow
		var/mob/living/carbon/C = H
		if(C?.dna)
			C?.dna?.real_name = newname
	if(H?.mind)
		H?.mind?.name = newname


/datum/job/synthetic/get_access()
	return get_all_accesses() - list(ACCESS_HOS, ACCESS_WEAPONS, ACCESS_CREMATORIUM, ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_ARMORY)


/datum/outfit/job/synthetic
	name = "Synthetic"

	jobtype = /datum/job/synthetic
	ears = /obj/item/radio/headset/headset_synthetic

	pda_type = null
	id_type = /obj/item/card/id/synthetic

/datum/outfit/job/synthetic/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(H.w_uniform)
		var/obj/item/clothing/under/wearing = H.w_uniform
		wearing.has_sensor = FALSE
	
	var/obj/machinery/ai/data_core/core 
	core = H.available_ai_cores(forced = TRUE)
	if(core)
		core.network.add_synth(H)

	

	

/datum/outfit/job/synthetic/naked
	name = "Synthetic (Naked)"

	uniform = null
	ears = null
	back = null
	shoes = null
	box = null

	preload = FALSE // These are used by the prefs ui, and also just kinda could use the extra help at roundstart

	backpack = null
	satchel  = null
	duffelbag = null


/datum/outfit/job/synthetic/naked/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	return
