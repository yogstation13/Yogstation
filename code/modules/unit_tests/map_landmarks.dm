/// Tests that [/datum/job/proc/get_default_roundstart_spawn_point] returns a landmark from all joinable jobs.
/datum/unit_test/job_roundstart_spawnpoints

/datum/unit_test/job_roundstart_spawnpoints/Run()
	for(var/datum/job/job as anything in SSjob.joinable_occupations)
		if(job.spawn_positions <= 0)
			// Zero spawn positions means we don't need to care if they don't have a roundstart landmark
			continue
		for(var/obj/effect/landmark/start/start_landmark in GLOB.start_landmarks_list)
			if(start_landmark.name != job.title)
				continue
			return

		TEST_FAIL("Job [job.title] ([job.type]) has no default roundstart spawn landmark.")
