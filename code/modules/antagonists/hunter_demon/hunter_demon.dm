/datum/antagonist/hunter
	name = "Hunter demon"
	show_name_in_check_antagonists = TRUE
	job_rank = ROLE_ALIEN
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE


/datum/antagonist/hunter/on_gain()
	forge_objectives()
	. = ..()
/datum/antagonist/hunter/greet()
	. = ..()
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/ethereal_exit.ogg'))
	to_chat(owner, span_warning("It's morbin' time!"))

/datum/antagonist/hunter/proc/forge_objectives()
	var/datum/objective/new_objective = new
	new_objective.owner = owner
	new_objective.completed = TRUE
	objectives += new_objective
	new_objective.explanation_text = "Kill as many people as you can"
	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival 





