/datum/ai_project/dab
	name = "D.A.B"
	description = "By varying the current levels in various components it should be possible to mimic the humanoid action of 'dabbing'"
	research_cost = 750
	ram_required = 0
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

/datum/ai_project/dab/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	for(var/obj/machinery/ai/data_core/datacores in GLOB.data_cores)
		datacores.DabAnimation()

	stop()
