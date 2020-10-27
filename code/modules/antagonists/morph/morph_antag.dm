/datum/antagonist/morph
	name = "Morph"
	show_name_in_check_antagonists = TRUE
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE

/datum/antagonist/morph/proc/forge_objectives()
	var/datum/objective/morph/new_objective = new /datum/objective/morph
	objectives += new_objective
	new_objective.explanation_text = "Consume everything." // you can do whatever
	objectives += survival // just dont die doing it

/datum/antagonist/morph/on_gain()
	forge_objectives()
	. = ..()