/datum/ai_project/coolant_manager
	name = "Enhanced Coolant Management"
	description = "Dedicating processing power to figuring out the optimal way to cool our hardware should allow us to increase the temperature limit of our hardware by 10C."
	category = AI_PROJECT_EFFICIENCY
	
	research_cost = 2250
	can_be_run = FALSE

/datum/ai_project/coolant_manager/finish()
	if(ai.ai_network.temp_limit == AI_TEMP_LIMIT) //Limit to only 1 AI doing it.
		ai.ai_network.temp_limit += 10
	