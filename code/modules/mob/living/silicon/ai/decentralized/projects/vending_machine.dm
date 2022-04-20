/datum/ai_project/vending_machine
	name = "Unlock vending machines"
	description = "By reverse engineering the security subsystems in the vending machines, we can bypass the access and payment gates and dispense items."
	research_cost = 500
	ram_required = 1
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

/datum/ai_project/vending_machine/run_project(force_run = FALSE)
	. = ..()
	if(!.)
		return .
	ai.ignores_capitalism = TRUE


/datum/ai_project/vending_machine/stop()
	ai.ignores_capitalism = FALSE //This will break if someone manually enables it but
	..()
