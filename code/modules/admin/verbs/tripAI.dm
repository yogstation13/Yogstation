/client/proc/triple_ai()
	set category = "Admin.Round Interaction"
	set name = "Toggle AI Triumvirate"

	var/datum/job/job = SSjob.GetJob("AI")
	if(!job)
		to_chat(usr, "Unable to locate the AI job", confidential=TRUE)
		return
	if(SSticker.triai)
		SSticker.triai = 0
		job.total_positions = initial(job.total_positions)
		job.spawn_positions = initial(job.spawn_positions)
		to_chat(usr, "Only one AI will be spawned at round start.", confidential=TRUE)
		message_admins(span_adminnotice("[key_name_admin(usr)] has toggled off triple AIs at round start."))
	else
		SSticker.triai = 1
		job.total_positions = 3
		job.spawn_positions = 3
		to_chat(usr, "There will be an AI Triumvirate at round start.", confidential=TRUE)
		message_admins(span_adminnotice("[key_name_admin(usr)] has toggled on triple AIs at round start."))
