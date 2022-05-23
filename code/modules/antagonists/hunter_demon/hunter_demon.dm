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
	to_chat(owner, span_warning("Go fuck yourself, i will setup antag datum only after setting up the mob and the orb!"))

/datum/antagonist/hunter/forge_objectives()
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = owner
	objectives += new_objective2





