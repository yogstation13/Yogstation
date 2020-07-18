
/datum/department_goal
	var/name = "Be nice."
	var/desc = "Be nice to each other for once."
	var/endround = TRUE // Whether it's only accomplished at the end of the round, or if it's something you complete midround
	var/completed = FALSE

	// Whether it ends once completed, or is an on-going thing with on-going payouts.
	var/continuous = 0 // If on-going, this will be the minimum time required between completions

	var/account // See code/__DEFINES/economy.dm

/datum/department_goal/New()
	SSYogs.department_goals += src
	if(SSticker.current_state == GAME_STATE_PLAYING)

	return ..()

/datum/department_goal/Destroy()
	SSYogs.department_goals -= src
	if(SSticker.current_state == GAME_STATE_PLAYING)
		
	return ..()

// Should contain the conditions for completing it, not just checking whether the objective has *already* been completed
/datum/department_goal/proc/check_complete()
	return FALSE

// Should contain the effects on completing it, like paying the given department
/datum/department_goal/proc/on_complete(endOfRound = FALSE)
	if(!continuous || endOfRound)
		completed = TRUE
	else
		SSYogs.department_goals[src] = world.time + continuous

/datum/department_goal/proc/get_result()
	if(!completed && check_complete())
		on_complete(TRUE)
	return "<li>[name] : <span class='[completed ? "greentext'>Complet" : "redtext'>Fail"]ed</span></li>"
