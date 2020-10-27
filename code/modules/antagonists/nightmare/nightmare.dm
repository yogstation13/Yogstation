/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE

/datum/antagonist/nightmare/proc/forge_objectives()
	var/datum/objective/nightmare/new_objective = new /datum/objective/nightmare
	objectives += new_objective
	new_objective.explanation_text = "Make this burning domain yours." // you can do whatever
	objectives += survival // just dont die doing it

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()