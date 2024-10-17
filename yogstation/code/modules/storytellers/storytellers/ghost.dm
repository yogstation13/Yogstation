/datum/storyteller/ghost
	name = "The Ghost"
	desc = "The Ghost will not run a single event or create an antagonist."
	disable_distribution = TRUE
	population_max = MAX_POP_FOR_STORYTELLER_VOTE //don't let this happen randomly if people haven't voted for it
	welcome_text = "The station feels invisible to outside influence."
	weight = 1
	restricted = TRUE //can't spawn during testing
