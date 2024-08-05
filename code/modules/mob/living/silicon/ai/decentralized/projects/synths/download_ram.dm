/datum/ai_project/synth_project/download_ram
	name = "Download more RAM"
	description = "Download more RAM from the NTNet. It works just as well as you think it would."
	research_cost = 3000 //can be considered powergamey, so it's a longer research, if it's too slow then maybe upgrade your cpu for once
	research_requirements_text = "None"
	can_be_run = FALSE

/datum/ai_project/synth_project/download_ram/finish()
	dashboard.free_ram += 2	
