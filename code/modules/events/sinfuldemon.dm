/datum/round_event_control/sinfuldemon
	name = "Create Demon of Sin"
	typepath = /datum/round_event/ghost_role/sinfuldemon
	max_occurrences = 2 //misery loves company
	weight = 5 //50% less likely to happen compared to most events
	min_players = 15
	earliest_start = 20 MINUTES

/datum/round_event/ghost_role/sinfuldemon
	var/success_spawn = 0
	minimum_required = 1
	role_name = "demon of sin"
	fakeable = FALSE
	// LAME jobs that people typically do not care about
	var/static/list/possible_jobs = list("Assistant", "Tourist", "Artist", "Clerk", "Lawyer")

/datum/round_event/ghost_role/sinfuldemon/kill()
	if(!success_spawn && control)
		control.occurrences--
	return ..()

/datum/round_event/ghost_role/sinfuldemon/spawn_role()
	//selecting a spawn_loc
	if(!SSjob.latejoin_trackers.len)
		return MAP_ERROR

	//selecting a candidate player
	var/list/candidates = get_candidates(ROLE_SINFULDEMON, null, ROLE_SINFULDEMON)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	// Select the job we spawn as
	var/datum/job/selected_job
	var/list/datum/job/potential_job_list = list()
	var/list/datum/job/job_datum_list = list()
	for(var/jobname in possible_jobs)
		var/datum/job/job_datum = SSjob.GetJob(jobname)
		if(!job_datum || !istype(job_datum))
			continue
		potential_job_list |= job_datum // Backup in case all jobs are somehow filled, just bypass job limits
		if((job_datum.current_positions >= job_datum.total_positions) && job_datum.total_positions != -1)
			continue
		job_datum_list |= job_datum

	if(!potential_job_list.len)
		return "No valid possible_jobs"

	if(!job_datum_list.len)
		job_datum_list = potential_job_list

	selected_job = pick(job_datum_list)

	var/mob/dead/selected_candidate = pick_n_take(candidates)
	var/key = selected_candidate.key

	var/datum/mind/Mind = create_sinfuldemon_mind(key)
	Mind.active = TRUE

	var/mob/living/carbon/human/sinfuldemon = create_event_sinfuldemon()
	Mind.transfer_to(sinfuldemon)
	Mind.add_antag_datum(/datum/antagonist/sinfuldemon)

	spawned_mobs += sinfuldemon
	message_admins("[ADMIN_LOOKUPFLW(sinfuldemon)] has been made into a demon of sin by an event.")
	log_game("[key_name(sinfuldemon)] was spawned as a demon of sin by an event.")

	if(SSshuttle.arrivals)
		SSshuttle.arrivals.QueueAnnounce(sinfuldemon, selected_job.title)
	Mind.assigned_role = selected_job.title //sets up the manifest properly
	selected_job.equip(sinfuldemon)

	var/obj/item/card/id/id = sinfuldemon.get_idcard()
	if(id && istype(id))
		id.assignment = selected_job.title
		id.originalassignment = selected_job.title
		id.update_label()
	
	GLOB.data_core.manifest_inject(sinfuldemon, force = TRUE)
	sinfuldemon.update_move_intent_slowdown() //prevents you from going super duper fast
	return SUCCESSFUL_SPAWN


/proc/create_event_sinfuldemon(spawn_loc)
	var/mob/living/carbon/human/new_sinfuldemon = new(spawn_loc)
	if(!spawn_loc)
		SSjob.SendToLateJoin(new_sinfuldemon)
	new_sinfuldemon.randomize_human_appearance(~(RANDOMIZE_SPECIES))
	new_sinfuldemon.dna.update_dna_identity()
	return new_sinfuldemon

/proc/create_sinfuldemon_mind(key)
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.special_role = ROLE_SINFULDEMON
	return Mind
