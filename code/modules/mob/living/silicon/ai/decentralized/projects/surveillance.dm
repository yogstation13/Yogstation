/datum/ai_project/camera_tracker
	name = "Camera Memory Tracker"
	description = "Using complex LSTM nodes it is possible to automatically detect when a tagged individual enters camera visiblity."
	research_cost = 2500
	ram_required = 3
	research_requirements_text = "Examination Upgrade"
	research_requirements = list(/datum/ai_project/examine_humans)
	category = AI_PROJECT_SURVEILLANCE

/datum/ai_project/camera_tracker/run_project(force_run = FALSE)
	. = ..(force_run)
	if(!.)
		return .
	ai.canCameraMemoryTrack = TRUE
	ai.add_verb_ai(/mob/living/silicon/ai/proc/choose_camera_target)

/datum/ai_project/camera_tracker/stop()
	ai.canCameraMemoryTrack = FALSE
	remove_verb(ai, /mob/living/silicon/ai/proc/choose_camera_target)
	..()

/mob/living/silicon/ai/proc/choose_camera_target()
	set name = "Choose Camera Memory Target"
	set category = "AI Commands"
	set desc = "Select a target for the camera memory tracker. Case sensitive. "
	var/target = stripped_input(usr, "Please enter target name (Leave empty for cancel):", "Camera Tracker", "", MAX_NAME_LEN)
	if(!target)
		cameraMemoryTarget = null
		return
	if(cameraMemoryTarget)
		to_chat(usr, span_warning("Old target discarded. Exclusively tracking new target."))
	else
		to_chat(usr, span_notice("Now tracking new target, [target]."))

	cameraMemoryTarget = target
	cameraMemoryTickCount = 0
