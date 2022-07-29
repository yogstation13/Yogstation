/datum/ai_project/rgb
	name = "RGB Lighting"
	description = "By varying the current levels in the lighting subsystems of your servers, you can make pretty colors."
	research_cost = 500
	ram_required = 0
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

/datum/ai_project/rgb/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	for(var/obj/machinery/ai/data_core/datacores in GLOB.data_cores)
		if(!datacores.TimerID)
			datacores.partytime()


/datum/ai_project/rgb/stop()
	for(var/obj/machinery/ai/data_core/datacores in GLOB.data_cores)
		datacores.stoptheparty()
	..()
