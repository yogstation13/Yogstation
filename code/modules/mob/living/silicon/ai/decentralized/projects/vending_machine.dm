/datum/ai_project/vending_machine
	name = "Vending Machine Control"
	description = "By reverse engineering the security subsystems in the vending machines, we can bypass the access and payment gates and dispense items."
	research_cost = 500
	can_be_run = FALSE
	research_requirements_text = "None"
	category = AI_PROJECT_MISC

/datum/ai_project/vending_machine/finish()
	ai.ignores_capitalism = TRUE
