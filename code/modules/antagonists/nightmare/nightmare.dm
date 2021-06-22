/datum/antagonist/nightmare
	name = "Nightmare"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE

/datum/antagonist/nightmare/proc/forge_objectives()
	var/datum/objective/new_objective = new
	new_objective.owner = owner
	new_objective.completed = TRUE
	objectives += new_objective
	new_objective.explanation_text = "This station is an insult to the void. Return it to darkness."
	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival // just dont die doing it

/datum/antagonist/nightmare/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/nightmare/greet()
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/ethereal_exit.ogg'))
