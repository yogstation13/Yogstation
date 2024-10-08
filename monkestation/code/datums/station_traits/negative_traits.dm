/datum/station_trait/clown_bridge
	name = "Clown Bridge Access"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 2
	show_in_report = TRUE
	report_message = "The Clown Planet has discovered a weakness in the ID scanners of specific airlocks."
	trait_to_give = STATION_TRAIT_CLOWN_BRIDGE

/datum/station_trait/overflow_job_bureaucracy/proc/set_overflow_job_override(datum/source)
	SIGNAL_HANDLER
	var/datum/job/picked_job
	var/list/possible_jobs = SSjob.joinable_occupations.Copy()
	while(length(possible_jobs) && !picked_job?.allow_overflow)
		picked_job = pick_n_take(possible_jobs)
	if(!picked_job)
		CRASH("Failed to find valid job to pick for overflow!")
	chosen_job_name = lowertext(picked_job.title) // like Chief Engineers vs like chief engineers
	SSjob.set_overflow_role(picked_job.type)
