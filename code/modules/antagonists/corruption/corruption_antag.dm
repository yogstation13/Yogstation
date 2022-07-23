/datum/antagonist/corruption
	name = "Corruption Avatar"
	show_name_in_check_antagonists = TRUE
	can_hijack = HIJACK_HIJACKER

/datum/antagonist/corruption/on_gain()
	. = ..()
	to_chat(owner, span_userdanger("You are the Corrution Avatar!"))
	forge_objectives()

/datum/antagonist/corruption/proc/forge_objectives()
	var/datum/objective/new_objective = new
	new_objective.owner = owner
	new_objective.completed = TRUE
	objectives += new_objective
	new_objective.explanation_text = "This station shouldn't exist in it's current state. Corrupt it, aswell as any living being on it."
	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival

/datum/antagonist/corrupted
	name = "Corrupted"
	show_name_in_check_antagonists = TRUE
	var/mob/living/corruption_avatar

/datum/antagonist/corrupted/on_gain()
	. = ..()
	to_chat(owner, span_userdanger("You have been corrupted!"))
	forge_objectives()

/datum/antagonist/corrupted/proc/forge_objectives()
	var/datum/objective/new_objective = new
	new_objective.owner = owner
	new_objective.completed = TRUE
	objectives += new_objective
	new_objective.explanation_text = "Serve [corruption_avatar] in their mission."

/datum/antagonist/corrupted/farewell()
	to_chat(owner, span_userdanger("You are no longer corrupted. You feel... free."))
