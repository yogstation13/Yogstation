/datum/interview_manager/enqueue(datum/interview/to_queue)
	..()

	if (!to_queue || (to_queue in interview_queue))
		return

	SSplexora.newinterview(to_queue);
