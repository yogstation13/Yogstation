/datum/ai_project/camera_tracker
	name = "Camera Memory Tracker"
	description = "Using complex LSTM nodes it is possible to automatically detect when a tagged individual enters camera visiblity."
	research_cost = 4000
	ram_required = 4
	research_requirements_text = "Examination Upgrade"
	research_requirements = list(/datum/ai_project/examine_humans)
	category = AI_PROJECT_SURVEILLANCE

/datum/ai_project/camera_tracker/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.canCameraMemoryTrack = TRUE

/datum/ai_project/camera_tracker/stop()
	ai.canCameraMemoryTrack = FALSE
	..()

