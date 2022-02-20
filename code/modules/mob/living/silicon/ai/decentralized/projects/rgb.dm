/datum/ai_project/rgb
	name = "RGB Lighting"
	description = "By varying the current levels in the lighting subsystems of your servers, you can make pretty colors."
	research_cost = 1
	ram_required = 0
	research_requirements_text = "None"
	category = AI_PROJECT_MISC
	var/static/party_overlay

/datum/ai_project/rgb/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	for(var/obj/machinery/ai/data_core/datacores in GLOB.data_cores)
		var/area/A
		A = get_area(datacores)
		if (!A || A.party || A.name == "Space")
			return
		A.party = TRUE
		if (!party_overlay)
			party_overlay = iconstate2appearance('icons/turf/areas.dmi', "party")
		A.add_overlay(party_overlay)


/datum/ai_project/rgb/stop()
	for(var/obj/machinery/ai/data_core/datacores in GLOB.machines)
		var/area/A
		A = get_area(datacores)
		if (!A || !A.party)
			return
		A.party = FALSE
		A.cut_overlay(party_overlay)
	..()
